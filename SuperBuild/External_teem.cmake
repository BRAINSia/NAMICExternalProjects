
set(proj teem)

# Set dependency list
set(${proj}_DEPENDENCIES zlib)
if(NOT ${CMAKE_PROJECT_NAME}_USE_SYSTEM_teem)
  list(APPEND ${proj}_DEPENDENCIES VTK)
endif()

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

if(${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj})
  unset(Teem_DIR CACHE)
  find_package(Teem REQUIRED NO_MODULE)
endif()

# Sanity checks
if(DEFINED Teem_DIR AND NOT EXISTS ${Teem_DIR})
  message(FATAL_ERROR "Teem_DIR variable is defined but corresponds to non-existing directory")
endif()

set(EXTERNAL_PROJECT_OPTIONAL_ARGS)

set(CMAKE_PROJECT_INCLUDE_EXTERNAL_PROJECT_ARG)
if(CTEST_USE_LAUNCHERS)
  set(CMAKE_PROJECT_INCLUDE_EXTERNAL_PROJECT_ARG
    "-DCMAKE_PROJECT_Teem_INCLUDE:FILEPATH=${CMAKE_ROOT}/Modules/CTestUseLaunchers.cmake")
endif()

if(${CMAKE_VERSION} VERSION_GREATER "2.8.11.2")
  # Following CMake commit 2a7975398, the FindPNG.cmake module
  # supports detection of release and debug libraries. Specifying only
  # the release variable is enough to ensure the variable PNG_LIBRARY
  # is internally set if the project is built either in Debug or Release.
  list(APPEND EXTERNAL_PROJECT_OPTIONAL_ARGS
    -DPNG_LIBRARY_RELEASE:FILEPATH=${PNG_LIBRARY}
    )
else()
  list(APPEND EXTERNAL_PROJECT_OPTIONAL_ARGS
    -DPNG_LIBRARY:FILEPATH=${PNG_LIBRARY}
    )
endif()

set(${proj}_REPOSITORY "${git_protocol}://github.com/BRAINSia/teem.git")
set(${proj}_TAG "9db65f15e554119989bb49d12b404e7e44f150e4")

ExternalProject_Add(${proj}
  ${${proj}_EP_ARGS}
  GIT_REPOSITORY ${${proj}_REPOSITORY}
  GIT_TAG ${${proj}_TAG}
  URL_MD5 ${teem_MD5}
  DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}
  SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/ExternalSources/teem
  BINARY_DIR teem-build
  CMAKE_CACHE_ARGS
  -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
  # Not needed -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
  -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
  -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
  -DBUILD_TESTING:BOOL=OFF
  -DBUILD_SHARED_LIBS:BOOL=ON
  ${CMAKE_PROJECT_INCLUDE_EXTERNAL_PROJECT_ARG}
  -DTeem_USE_LIB_INSTALL_SUBDIR:BOOL=ON
  -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF
  -DVTK_DIR:PATH=${VTK_DIR}
  -DTeem_PTHREAD:BOOL=OFF
  -DTeem_BZIP2:BOOL=OFF
  -DTeem_ZLIB:BOOL=ON
  -DTeem_PNG:BOOL=OFF
  -DZLIB_ROOT:PATH=${ZLIB_ROOT}
  -DZLIB_INCLUDE_DIR:PATH=${ZLIB_INCLUDE_DIR}
  -DZLIB_LIBRARY:FILEPATH=${ZLIB_LIBRARY}
  -DTeem_VTK_MANGLE:BOOL=OFF ## NOT NEEDED FOR EXTERNAL ZLIB outside of vtk
  -DPNG_PNG_INCLUDE_DIR:PATH=${PNG_INCLUDE_DIR}
  -DTeem_PNG_DLLCONF_IPATH:PATH=${VTK_DIR}/Utilities
  ${EXTERNAL_PROJECT_OPTIONAL_ARGS}
  INSTALL_COMMAND ""
  DEPENDS
  ${${proj}_DEPENDENCIES}
  )

ExternalProject_Add_Step(${proj} fix_AIR_EXISTS
    COMMAND ${CMAKE_COMMAND} -DAIR_FILE=${CMAKE_CURRENT_LIST_DIR}/ExternalSources/teem/src/air/air.h
    -P ${CMAKE_CURRENT_LIST_DIR}/TeemPatch.cmake
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_LIST_DIR}/ExternalSources/teem/include/teem
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_LIST_DIR}/ExternalSources/teem/src/bane/bane.h
    ${CMAKE_CURRENT_LIST_DIR}/ExternalSources/teem/include/teem/bane.h
    DEPENDEES download
    DEPENDERS configure
    )

set(Teem_DIR ${CMAKE_BINARY_DIR}/teem-build)

mark_as_superbuild(
  VARS Teem_DIR:PATH
  LABELS "FIND_PACKAGE"
  )
