#-----------------------------------------------------------------------------
enable_testing()
include(CTest)

#-----------------------------------------------------------------------------
# Set a default build type if none was specified
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
  mark_as_advanced(CMAKE_BUILD_TYPE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "RelWithDebInfo")
endif()
#-----------------------------------------------------------------------------
# Set a default external project build type if none was specified
set(EXTERNAL_PROJECT_BUILD_TYPE "Release" CACHE STRING "Default build type for support libraries")
set_property(CACHE EXTERNAL_PROJECT_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "RelWithDebInfo")

#-----------------------------------------------------------------------------
# Change the default install prefix for superbuild packages
if(NOT CMAKE_INSTALL_PREFIX_SET)
  set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/${LOCAL_PROJECT_NAME}-${CMAKE_BUILD_TYPE}-${PROJECT_VERSION}"
      CACHE PATH "Install directory used by install" FORCE)
endif()
set(CMAKE_INSTALL_PREFIX_SET TRUE
      CACHE BOOL "TAG indicating that INSTALL_PREFIX_WAS_SET" FORCE )
include(GNUInstallDirs)

if(NOT Slicer_BUILD_BRAINSTOOLS)
  set(BRAINSTOOLS_MACOSX_RPATH ON)
endif()
#-----------------------------------------------------------------------------
if(APPLE)
  ## RPATH-RPATH-RPATH
  ## https://cmake.org/Wiki/CMake_RPATH_handling
  ## Always full RPATH
  # In many cases you will want to make sure that the required libraries are
  # always found independent from LD_LIBRARY_PATH and the install location. Then
  # you can use these settings:

  # use, i.e. don't skip the full RPATH for the build tree
  set(CMAKE_SKIP_BUILD_RPATH  FALSE)

  # when building, don't use the install RPATH already
  # (but later on when installing)
  set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

  set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")

  # add the automatically determined parts of the RPATH
  # which point to directories outside the build tree to the install RPATH
  set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)


  # the RPATH to be used when installing, but only if it's not a system directory
  list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)
  if(isSystemDir EQUAL -1)
    set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
  endif()
  ## RPATH-RPATH-RPATH
endif()
#-----------------------------------------------------------------------------
# Sanity checks
#------------------------------------------------------------------------------
include(PreventInSourceBuilds)
include(PreventInBuildInstalls)
include(itkCheckSourceTree)

include(CMakeDependentOption)

#------------------------------------------------------------------------------
find_package(Python3 3.12 REQUIRED COMPONENTS Interpreter)
mark_as_superbuild(VARS Python3_EXECUTABLE:FILEPATH ALL_PROJECTS)

#------------------------------------------------------------------------------
set(BUILD_SHARED_LIBS OFF) ## Build everything static for non-slicer builds

#------------------------------------------------------------------------------

# Enable this option to avoid unnecessary re-compilation associated with command line module
set(GENERATECLP_USE_MD5 ON)

#-----------------------------------------------------------------------------
# Build option(s)
#-----------------------------------------------------------------------------

option(${SUPERBUILD_TOPLEVEL_PROJECT}_REQUIRES_VTK "Determine if tools depending on VTK need to be built." ON)
mark_as_advanced(${SUPERBUILD_TOPLEVEL_PROJECT}_REQUIRES_VTK)
option(${SUPERBUILD_TOPLEVEL_PROJECT}_BUILD_SimpleITK "Build SimpleITK with Python wrapping against the superbuild ITK." OFF)
option(${SUPERBUILD_TOPLEVEL_PROJECT}_REQUIRES_TBB "Build TBB and enable the ITK and VTK TBB backends." ON)
mark_as_advanced(${SUPERBUILD_TOPLEVEL_PROJECT}_REQUIRES_TBB)

cmake_dependent_option(${LOCAL_PROJECT_NAME}_USE_QT
      "Find and use Qt with VTK to build GUI Tools" OFF
      "${SUPERBUILD_TOPLEVEL_PROJECT}_REQUIRES_VTK" OFF)

if(UNIX AND NOT APPLE)
  set(OpenGL_GL_PREFERENCE "GLVND" CACHE STRING "OpenGL library preference passed to VTK (LEGACY or GLVND)")
  set_property(CACHE OpenGL_GL_PREFERENCE PROPERTY STRINGS LEGACY GLVND)
endif()

# ITK VtkGlue and the VTK rendering modules are only needed for the Qt GUI tools.
if(${LOCAL_PROJECT_NAME}_USE_QT)
  set(${SUPERBUILD_TOPLEVEL_PROJECT}_REQUIRES_VTK_RENDERING ON)
else()
  set(${SUPERBUILD_TOPLEVEL_PROJECT}_REQUIRES_VTK_RENDERING OFF)
endif()





#-----------------------------------------------------------------------------
if(NOT COMMAND SETIFEMPTY)
  macro(SETIFEMPTY)
    set(KEY ${ARGV0})
    set(VALUE ${ARGV1})
    if(NOT ${KEY})
      set(${ARGV})
    endif()
  endmacro()
endif()

#-----------------------------------------------------------------------------
SETIFEMPTY(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
SETIFEMPTY(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
SETIFEMPTY(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
SETIFEMPTY(CMAKE_BUNDLE_OUTPUT_DIRECTORY  ${CMAKE_CURRENT_BINARY_DIR}/bin)
file(MAKE_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})

#-----------------------------------------------------------------------------
SETIFEMPTY(CMAKE_INSTALL_LIBRARY_DESTINATION lib)
SETIFEMPTY(CMAKE_INSTALL_ARCHIVE_DESTINATION lib)
SETIFEMPTY(CMAKE_INSTALL_RUNTIME_DESTINATION bin)

#-------------------------------------------------------------------------
SETIFEMPTY(BRAINSTools_CLI_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
SETIFEMPTY(BRAINSTools_CLI_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})
SETIFEMPTY(BRAINSTools_CLI_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})

#-------------------------------------------------------------------------
SETIFEMPTY(BRAINSTools_CLI_INSTALL_LIBRARY_DESTINATION ${CMAKE_INSTALL_LIBRARY_DESTINATION})
SETIFEMPTY(BRAINSTools_CLI_INSTALL_ARCHIVE_DESTINATION ${CMAKE_INSTALL_ARCHIVE_DESTINATION})
SETIFEMPTY(BRAINSTools_CLI_INSTALL_RUNTIME_DESTINATION ${CMAKE_INSTALL_RUNTIME_DESTINATION})


#-------------------------------------------------------------------------
# Augment compiler flags
#-------------------------------------------------------------------------
include(ITKSetStandardCompilerFlags)
string(APPEND CMAKE_C_FLAGS  " ${ITK_REQUIRED_C_FLAGS}")
string(APPEND CMAKE_CXX_FLAGS " ${ITK_REQUIRED_CXX_FLAGS}")
string(APPEND CMAKE_EXE_LINKER_FLAGS " ${ITK_REQUIRED_LINK_FLAGS}")
string(APPEND CMAKE_SHARED_LINKER_FLAGS " ${ITK_REQUIRED_LINK_FLAGS}")
string(APPEND CMAKE_MODULE_LINKER_FLAGS " ${ITK_REQUIRED_LINK_FLAGS}")

#-----------------------------------------------------------------------------
# Add needed flag for gnu on linux like enviroments to build static common libs
# suitable for linking with shared object libs.
if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
  if(NOT "${CMAKE_CXX_FLAGS}" MATCHES "-fPIC")
    string(APPEND CMAKE_CXX_FLAGS " -fPIC")
    string(APPEND ep_CMAKE_CXX_FLAGS " -fPIC")
  endif()
  if(NOT "${CMAKE_C_FLAGS}" MATCHES "-fPIC")
    string(APPEND CMAKE_C_FLAGS " -fPIC")
    string(APPEND ep_CMAKE_C_FLAGS " -fPIC")
  endif()
endif()

option(BUILD_OPTIMIZED "Set compiler flags for native host building." OFF)
mark_as_advanced(BUILD_OPTIMIZED)

if(BUILD_OPTIMIZED AND NOT BUILD_COVERAGE)
  if(CAN_BUILD_CXX_OPTIMIZED AND CAN_BUILD_C_OPTIMIZED)
    string(APPEND CMAKE_CXX_FLAGS ${BRAINSToools_CXX_OPTIMIZATION_FLAGS})
    string(APPEND CMAKE_C_FLAGS ${BRAINSToools_CXX_OPTIMIZATION_FLAGS})
    string(REPLACE " " ";" CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${${PROJECT_NAME}_C_OPTIMIZATION_FLAGS} ${${PROJECT_NAME}_C_WARNING_FLAGS}")
    list(REMOVE_DUPLICATES CMAKE_C_FLAGS)
    string(REPLACE ";" " " CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")

    string(REPLACE " " ";" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${${PROJECT_NAME}_CXX_OPTIMIZATION_FLAGS} ${${PROJECT_NAME}_CXX_WARNING_FLAGS}")
    list(REMOVE_DUPLICATES CMAKE_CXX_FLAGS)
    string(REPLACE ";" " " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
  else()
    message("WARNING: Requested optimized build, but -march=native flag not supported by"
            "${CMAKE_CXX_COMPILER}"
            "${CMAKE_C_COMPILER}")
  endif()
endif()
mark_as_superbuild(VARS BUILD_OPTIMIZED:BOOL PROJECTS ${LOCAL_PROJECT_NAME} )

mark_as_superbuild(
   VARS
#--  The following are probably do not need to be propagated
#--    CMAKE_BUILD_TYPE:STRING
#--    CMAKE_CXX_FLAGS_DEBUG:STRING
#--    CMAKE_CXX_FLAGS_MINSIZEREL:STRING
#--    CMAKE_CXX_FLAGS_RELEASE:STRING
#--    CMAKE_CXX_FLAGS_RELWITHDEBINFO:STRING
#--    CMAKE_C_FLAGS_DEBUG:STRING
#--    CMAKE_C_FLAGS_MINSIZEREL:STRING
#--    CMAKE_C_FLAGS_RELEASE:STRING
#--    CMAKE_C_FLAGS_RELWITHDEBINFO:STRING
#--    CMAKE_EXE_LINKER_FLAGS:STRING
#--    CMAKE_EXE_LINKER_FLAGS_DEBUG:STRING
#--    CMAKE_EXE_LINKER_FLAGS_MINSIZEREL:STRING
#--    CMAKE_EXE_LINKER_FLAGS_RELEASE:STRING
#--    CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO:STRING
#--    CMAKE_EXTRA_GENERATOR:STRING
#--    CMAKE_GENERATOR:STRING
    CMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH
    CMAKE_BUNDLE_OUTPUT_DIRECTORY:PATH
    CMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH
    CMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH
#--    CMAKE_MODULE_LINKER_FLAGS:STRING
#--    CMAKE_MODULE_LINKER_FLAGS_DEBUG:STRING
#--    CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL:STRING
#--    CMAKE_MODULE_LINKER_FLAGS_RELEASE:STRING
#--    CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO:STRING
#--    CMAKE_MODULE_PATH:PATH
#--    CMAKE_SHARED_LINKER_FLAGS:STRING
#--    CMAKE_SHARED_LINKER_FLAGS_DEBUG:STRING
#--    CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL:STRING
#--    CMAKE_SHARED_LINKER_FLAGS_RELEASE:STRING
#--    CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO:STRING
#--    CMAKE_SKIP_RPATH:BOOL
#--    CTEST_NEW_FORMAT:BOOL
#--    MEMORYCHECK_COMMAND:PATH
#--    MEMORYCHECK_COMMAND_OPTIONS:STRING
   ALL_PROJECTS
)

set( EXTERNAL_PROJECT_DEFAULTS
  -DCMAKE_BUILD_TYPE:STRING=${EXTERNAL_PROJECT_BUILD_TYPE}
  -DBUILD_EXAMPLES:BOOL=OFF
  -DBUILD_TESTING:BOOL=OFF
  #-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/${proj}-install
  -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
  -DBUILD_SHARED_LIBS:BOOL=${EXTERNAL_BUILD_SHARED_LIBS}
  -DCMAKE_POLICY_VERSION_MINIMUM:STRING=3.5
  -DCMAKE_POLICY_DEFAULT_CMP0057:STRING=NEW # if(IN_LIST) in ITKConfig.cmake; CMake < 4 ignores the line above
)

if(NOT CMAKE_C_COMPILER_LAUNCHER AND NOT CMAKE_CXX_COMPILER_LAUNCHER)
  find_program(CCACHE_PROGRAM ccache)
  if(CCACHE_PROGRAM)
    set(CMAKE_C_COMPILER_LAUNCHER   "${CCACHE_PROGRAM}" CACHE STRING "C compiler launcher")
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}" CACHE STRING "CXX compiler launcher")
  endif()
endif()
if(CMAKE_C_COMPILER_LAUNCHER)
  list(APPEND EXTERNAL_PROJECT_DEFAULTS -DCMAKE_C_COMPILER_LAUNCHER:STRING=${CMAKE_C_COMPILER_LAUNCHER})
endif()
if(CMAKE_CXX_COMPILER_LAUNCHER)
  list(APPEND EXTERNAL_PROJECT_DEFAULTS -DCMAKE_CXX_COMPILER_LAUNCHER:STRING=${CMAKE_CXX_COMPILER_LAUNCHER})
endif()

option(${SUPERBUILD_TOPLEVEL_PROJECT}_EP_GIT_SHALLOW
  "Use shallow (depth-1) git clones for ExternalProject downloads." OFF)
mark_as_advanced(${SUPERBUILD_TOPLEVEL_PROJECT}_EP_GIT_SHALLOW)
