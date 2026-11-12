set(proj Uncrustify)

set(${proj}_DEPENDENCIES "")
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

if(USE_SYSTEM_Uncrustify)
  find_program(Uncrustify_EXE uncrustify DOC "Path of uncrustify")
  ExternalProject_Add_Empty(${proj} DEPENDS ${${proj}_DEPENDENCIES})
  mark_as_superbuild(VARS Uncrustify_EXE:FILEPATH LABELS "FIND_PACKAGE")
  return()
endif()

ExternalProject_SetIfNotDefined(
  ${CMAKE_PROJECT_NAME}_${proj}_GIT_REPOSITORY
  "${git_protocol}://github.com/uncrustify/uncrustify.git"
  QUIET
  )
ExternalProject_SetIfNotDefined(
  ${CMAKE_PROJECT_NAME}_${proj}_GIT_TAG
  uncrustify-0.83.0
  QUIET
  )

ExternalProject_Add(${proj}
  ${${proj}_EP_ARGS}
  GIT_REPOSITORY "${${CMAKE_PROJECT_NAME}_${proj}_GIT_REPOSITORY}"
  GIT_TAG "${${CMAKE_PROJECT_NAME}_${proj}_GIT_TAG}"
  GIT_SHALLOW ${${SUPERBUILD_TOPLEVEL_PROJECT}_EP_GIT_SHALLOW}
  UPDATE_DISCONNECTED TRUE
  SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}
  BINARY_DIR ${proj}-build
  LOG_CONFIGURE ON
  LOG_BUILD ON
  LOG_INSTALL ON
  LOG_OUTPUT_ON_FAILURE ON
  CMAKE_ARGS -Wno-dev --no-warn-unused-cli
  CMAKE_CACHE_ARGS
    ${EXTERNAL_PROJECT_DEFAULTS}
    -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}/Utils
  DEPENDS
    ${${proj}_DEPENDENCIES}
  )
set(Uncrustify_EXE ${CMAKE_BINARY_DIR}/Utils/bin/uncrustify)
mark_as_superbuild(VARS Uncrustify_EXE:FILEPATH LABELS "FIND_PACKAGE")
