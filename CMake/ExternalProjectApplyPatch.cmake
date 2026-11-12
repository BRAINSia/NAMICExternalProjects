# Apply PATCH_FILE to the current source tree unless it is already applied.
# Usage: cmake -DGIT_EXECUTABLE=<git> -DPATCH_FILE=<file> -P ExternalProjectApplyPatch.cmake
foreach(var IN ITEMS GIT_EXECUTABLE PATCH_FILE)
  if(NOT ${var})
    message(FATAL_ERROR "${var} is required")
  endif()
endforeach()

execute_process(
  COMMAND ${GIT_EXECUTABLE} apply --reverse --check --whitespace=nowarn ${PATCH_FILE}
  RESULT_VARIABLE already_applied
  OUTPUT_QUIET ERROR_QUIET
  )
if(already_applied EQUAL 0)
  message(STATUS "Already applied: ${PATCH_FILE}")
  return()
endif()

execute_process(
  COMMAND ${GIT_EXECUTABLE} apply --whitespace=nowarn ${PATCH_FILE}
  RESULT_VARIABLE apply_result
  )
if(NOT apply_result EQUAL 0)
  message(FATAL_ERROR "Failed to apply ${PATCH_FILE}")
endif()
