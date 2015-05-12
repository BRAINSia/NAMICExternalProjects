
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
  GIT_TAG "17de793f92a1d20388a0d508a6456b09382da584"
  SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/BatchMake
  BINARY_DIR BatchMake-build
  CMAKE_ARGS -Wno-dev --no-warn-unused-cli
  CMAKE_CACHE_ARGS
  -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
  -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
  -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
  -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
  -DBUILD_TESTING:BOOL=OFF
  -DBUILD_SHARED_LIBS:BOOL=OFF
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
