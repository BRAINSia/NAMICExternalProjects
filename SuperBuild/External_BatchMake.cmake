
set(proj BatchMake)

# Set dependency list
 set(${proj}_DEPENDENCIES ${ITK_EXTERNAL_NAME})

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

if(${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj})
  message(FATAL_ERROR "Enabling ${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj} is not supported !")
endif()

if(NOT DEFINED git_protocol)
  set(git_protocol "git")
endif()

ExternalProject_Add(${proj}
  ${${proj}_EP_ARGS}
  GIT_REPOSITORY "${git_protocol}://batchmake.org/BatchMake.git"
  GIT_TAG "7da88ae6027eb4eac363c09834a6e014306f3038"
  SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/ExternalSources/BatchMake
  BINARY_DIR BatchMake-build
  CMAKE_ARGS -Wno-dev --no-warn-unused-cli
  CMAKE_CACHE_ARGS
  ${COMMON_EXTERNAL_PROJECT_ARGS}
  -DBUILD_TESTING:BOOL=OFF
  -DBUILD_SHARED_LIBS:BOOL=ON
  -DUSE_FLTK:BOOL=OFF
  -DDASHBOARD_SUPPORT:BOOL=OFF
  -DGRID_SUPPORT:BOOL=ON
  -DUSE_SPLASHSCREEN:BOOL=OFF
  -DITK_DIR:PATH=${ITK_DIR}
  -DCURL_SPECIAL_LIBZ:FILEPATH=${ZLIB_LIBRARY}
  INSTALL_COMMAND ""
  DEPENDS
  ${${proj}_DEPENDENCIES}
  )

set(BatchMake_DIR ${CMAKE_BINARY_DIR}/BatchMake-build)

mark_as_superbuild(
  VARS BatchMake_DIR:PATH
  LABELS "FIND_PACKAGE"
  )
