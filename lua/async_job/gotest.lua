local make_notify = require('mini.notify').make_notify {}
local display = require 'go_test_display'
local displayer = display.new()

---@class gotest
---@field tests_info gotest.TestInfo[]
---@field job_id number
local M = {
  tests_info = {}, ---@type gotest.TestInfo[]
  job_id = -1, ---@type number
}

local ignored_actions = {
  skip = true,
}

local action_state = {
  pause = true,
  cont = true,
  start = true,
  fail = true,
  pass = true,
}

---@class gotest.TestInfo
---@field name string
---@field status string "running"|"pass"|"fail"|"paused"|"cont"|"start"
---@field fail_at_line number
---@field file string

M.clean_up_prev_job = function(job_id)
  if job_id ~= -1 then
    make_notify(string.format('stopping job: %d', job_id))
    vim.fn.jobstop(job_id)
    vim.diagnostic.reset()
  end
end

local make_key = function(entry)
  if not entry.Test then
    return entry.Package -- Fallback for package-level tests
  end
  assert(entry.Test, 'Must have test name' .. vim.inspect(entry))
  return entry.Test
end

---@param tests gotest.TestInfo[]
local add_golang_test = function(tests, entry)
  local key = make_key(entry)
  tests[key] = {
    name = entry.Test,
    fail_at_line = 0,
    output = {},
    status = 'running',
    file = '',
  }
end

---@param tests gotest.TestInfo[]
local add_golang_output = function(tests, entry)
  assert(tests, vim.inspect(tests))
  local key = make_key(entry)
  local test = tests[key]
  if not test then
    return
  end
  local trimmed_output = vim.trim(entry.Output)
  local file, line = string.match(trimmed_output, '([%w_%-]+%.go):(%d+):')
  if file and line then
    local line_num = tonumber(line)
    assert(line_num, 'Line number must be a number')
    test.fail_at_line = line_num
    test.file = file
  end
  if trimmed_output:match '^--- FAIL:' then
    test.status = 'fail'
  end
end

local mark_outcome = function(tests, entry)
  local key = make_key(entry)
  local test = tests[key]
  if not test then
    return
  end
  test.status = entry.Action
end

M.run_test_all = function(command)
  M.tests_info = {}
  displayer:setup(M.tests_info)
  M.clean_up_prev_job(M.job_id)
  M.job_id = vim.fn.jobstart(command, {
    stdout_buffered = false,
    on_stdout = function(_, data)
      assert(data, 'No data received from job')
      for _, line in ipairs(data) do
        if line == '' then
          goto continue
        end
        local success, decoded = pcall(vim.json.decode, line)
        if not success or not decoded then
          goto continue
        end
        if ignored_actions[decoded.Action] then
          goto continue
        end
        if decoded.Action == 'run' then
          add_golang_test(M.tests_info, decoded)
          vim.schedule(function() displayer:update_tracker_buffer(M.tests_info) end)
          goto continue
        end
        if decoded.Action == 'output' then
          if decoded.Test or decoded.Package then
            add_golang_output(M.tests_info, decoded)
          end
          goto continue
        end
        if action_state[decoded.Action] then
          mark_outcome(M.tests_info, decoded)
          vim.schedule(function() displayer:update_tracker_buffer(M.tests_info) end)
          goto continue
        end
        ::continue::
      end
    end,
    on_exit = function()
      vim.schedule(function() displayer:update_tracker_buffer(M.tests_info) end)
    end,
  })
end

vim.api.nvim_create_user_command('GoTestAll', function()
  local command = { 'go', 'test', './...', '-json', '-v' }
  M.run_test_all(command)
end, {})

return M
