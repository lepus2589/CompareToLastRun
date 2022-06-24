#[[
MIT License

Copyright (c) 2022 Tim Haase

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

#[[
This function creates a backup of the variable to check and returns `true`, if
the variable is different from the last CMake run. It creates two variables in
the parent scope (`_LAST_RUN_CHECKED_${VARIABLE_NAME_TO_CHECK}`,
`_LAST_RUN_DIFFERS_${VARIABLE_NAME_TO_CHECK}`). It also creates the backup cache
variable (`_LAST_RUN_${VARIABLE_NAME_TO_CHECK}`).
\param IS_DIFFERENT The result variable name
\param VARIABLE_NAME_TO_CHECK The variable name to check
]]
function (compare_to_last_run IS_DIFFERENT VARIABLE_NAME_TO_CHECK)
    # If the variable to check is being checked the first time this run
    if (NOT DEFINED _LAST_RUN_CHECKED_${VARIABLE_NAME_TO_CHECK})
        # Compare backup with current value. If there is no backup on first run,
        # the result is always true.
        if (_LAST_RUN_${VARIABLE_NAME_TO_CHECK} STREQUAL ${VARIABLE_NAME_TO_CHECK})
            # Write the result to variable in local function scope.
            set(_LAST_RUN_DIFFERS_${VARIABLE_NAME_TO_CHECK} False)
            # Write the result to variable in parent scope. This is used as a
            # cache for subsequent queries for the same variable during this run
            # of CMake.
            set(_LAST_RUN_DIFFERS_${VARIABLE_NAME_TO_CHECK} False PARENT_SCOPE)
        else ()
            # Write the result to variable in local function scope.
            set(_LAST_RUN_DIFFERS_${VARIABLE_NAME_TO_CHECK} True)
            # Write the result to variable in parent scope. This is used as a
            # cache for subsequent queries for the same variable during this run
            # of CMake.
            set(_LAST_RUN_DIFFERS_${VARIABLE_NAME_TO_CHECK} True PARENT_SCOPE)
        endif ()

        # The check has been performed once. It will not be checked again this
        # run.
        set(_LAST_RUN_CHECKED_${VARIABLE_NAME_TO_CHECK} True PARENT_SCOPE)
        # Update the backup in the cache for next run.
        set(
            _LAST_RUN_${VARIABLE_NAME_TO_CHECK}
            ${${VARIABLE_NAME_TO_CHECK}}
            CACHE
            INTERNAL
            "Backup of ${VARIABLE_NAME_TO_CHECK} variable for next run."
        )
    endif ()

    # Export the result to the user requested variable ${IS_DIFFERENT}. In the
    # first query, _LAST_RUN_DIFFERS_${VARIABLE_NAME_TO_CHECK} is from the local
    # function scope. On subsequent queries for the same variable during this
    # run, the cached _LAST_RUN_DIFFERS_${VARIABLE_NAME_TO_CHECK} from the
    # parent scope is used.
    set(${IS_DIFFERENT} ${_LAST_RUN_DIFFERS_${VARIABLE_NAME_TO_CHECK}} PARENT_SCOPE)
endfunction ()
