---@class terminalTest
---@field terminalTest.terminals TerminalMultiplexer
---@field terminalTest.tests_info table<string, terminal.testInfo>
---@field terminalTest.test_in_terminal fun(test_info: terminal.testInfo)
---@field terminalTest.test_buf_in_terminals fun(test_command_format: string)
---@field terminalTest.test_nearest_in_terminal fun(test_command_format: string)
---@field terminalTest.test_tracked_in_terminal fun()
---@field terminalTest.view_enclosing_test fun()
---@field terminalTest.view_last_test_teriminal fun()

---@class terminal.testInfo
---@field name string
---@field status string
---@field fail_at_line? number
---@field test_bufnr number
---@field test_line number
---@field test_command string
---@field file string

---@class gotest
---@field tests_info gotest.TestInfo[]
---@field job_id number

---@class gotest.TestInfo
---@field name string
---@field status string "running"|"pass"|"fail"|"paused"|"cont"|"start"
---@field fail_at_line number
---@field file string
---
---
---@class Tracker
---@field track_list terminal.testInfo[]
---@field add_test_to_tracker? fun(test_command_format: string)
---@field jump_to_tracked_test_by_index? fun(index: integer)
---@field toggle_tracked_terminal_by_index? fun(index: integer)
---@field select_delete_tracked_test? fun()
---@field reset_tracker? fun()
---@field toggle_tracker_window? fun()
---@field update_tracker_window? fun()
---@field get_test_index_under_cursor? fun(): integer
---@field jump_to_test_under_cursor? fun()
---@field toggle_terminal_under_cursor? fun()
---@field delete_test_under_cursor? fun()
---@field run_test_under_cursor? fun()
---@field _create_tracker_window? fun()
---@field _original_win_id? integer
---@field _win_id? integer
---@field _buf_id? integer
---@field _is_open boolean
