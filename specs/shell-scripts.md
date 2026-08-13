# Shell Script Specs

These requirements apply to every Bash script in the root `gamesvr` project and every active game-server repository,
including entry points, build and test scripts, sourced libraries, maintenance utilities, and other helper scripts.

## Function Documentation

Every Bash function must have a documentation block immediately before its definition. This includes public helpers,
internal helpers, signal handlers, cleanup handlers, and functions intended to be called only by traps. All function
documentation blocks in all shell script files must use the following format and field order:

```bash
# DESCRIPTION: Briefly describes what the function does.
# PARAMETERS:
#   $1 (parameter_name) - Describes the first positional parameter.
#   $2 (another_parameter) - Describes the second positional parameter.
# RETURNS:
#   0 - Describes the successful result.
#   1 - Describes this nonzero result.
function_name() {
    # Function body.
}
```

The fields have these requirements:

* `DESCRIPTION` must describe the function's purpose and any significant side effects.
* `PARAMETERS` must list every positional parameter in numeric order, give each parameter a descriptive name in
  parentheses, and state whether it is optional when applicable. A function with no parameters must use
  `#   None.`.
* `RETURNS` must document every return status produced by the function and what each status means. A function that
  always succeeds must still document `#   0 - Always.`.
* If a function can terminate the script by calling `exit`, its `RETURNS` field must state the possible process exit
  statuses and the conditions that produce them. If it does not otherwise return to its caller, the field must say so.
* If a function preserves or propagates the status of another command, signal, or function, its `RETURNS` field must
  state that behavior instead of attempting to enumerate unknown statuses.
* Documentation must describe the function's current behavior. Generic text such as "returns success or failure" is
  insufficient when the conditions can be stated more precisely.

For example, a function without parameters that terminates the script uses the same fields:

```bash
# DESCRIPTION: Restores output streams, reports created image tags, and terminates the script.
# PARAMETERS:
#   None.
# RETURNS:
#   Does not return. Exits with the status captured when the exit handler began.
on_exit() {
    local exit_status=$?
    # Function body.
    exit "$exit_status"
}
```
