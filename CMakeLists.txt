cmake_minimum_required(VERSION 3.2.0 FATAL_ERROR) # 3.1.0 NEEDED for CMAKE_CXX_STANDARD suppor

cmake_policy(VERSION 3.2.0)
if(POLICY CMP0048)
  cmake_policy(SET CMP0048 OLD) #OLD project() behavior for setting VERSION variable
endif()
if(POLICY CMP0017)
  cmake_policy(SET CMP0017 OLD) #Prefer files from the CMake module directory when including from there
endif()
foreach(p
  CMP0054 # CMake 3.1 Only interpret ``if()`` arguments as variables or keywords when unquoted.
  CMP0042 # ``MACOSX_RPATH`` is enabled by default.
  CMP0025 # AppleClang vs. regular Clang
  )
  if(POLICY ${p})
    cmake_policy(SET ${p} NEW)
  endif()
endforeach()

#-----------------------------------------------------------------------------
# Check for common error case,  can not build with anaconda on path
string(REPLACE ":" ";" LOCAL_PATH "$ENV{PATH}")
foreach(mypath in ${LOCAL_PATH})
  string(REGEX MATCH "anaconda" ANACONDA_PATH ${mypath})
  if( "${ANACONDA_PATH}" MATCHES "anaconda")
    message(FATAL_ERROR "ERROR: Can not build when anaconda is on the path: ${mypath}, due to library incompatibilieis")
  endif()
endforeach()

#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake" ${CMAKE_MODULE_PATH})
include(ExternalProject)
include(ExternalProjectDependency)
#-----------------------------------------------------------------------------
if(APPLE)
  # Note: By setting CMAKE_OSX_* variables before any enable_language() or project() calls,
  #       we ensure that the bitness, and C++ standard library will be properly detected.
  include(BlockSetCMakeOSXVariables)
  mark_as_superbuild(
    VARS CMAKE_OSX_ARCHITECTURES:STRING CMAKE_OSX_SYSROOT:PATH CMAKE_OSX_DEPLOYMENT_TARGET:STRING
    ALL_PROJECTS
    )
endif()

set(PRIMARY_PROJECT_NAME NAMICExternalProjects)
## NOTE THERE SHOULD BE NO PROJECT STATEMENT HERE!
## This file acts as a simple switch to initiate
## two completely independant CMake build environments.

#-----------------------------------------------------------------------------
# Superbuild Option - Enabled by default
#                   Phase I:  ${PRIMARY_PROJECT_NAME}_SUPERBUILD is set to ON, and the
#                             supporting packages defined in "SuperBuild.cmake"
#                             are built.  The last package in "SuperBuild.cmake"
#                             to be built is a recursive call to this
#                             file with ${PRIMARY_PROJECT_NAME}_SUPERBUILD explicitly
#                             set to "OFF" to initiate Phase II
#
#                   Phase II: Build the ${PRIMARY_PROJECT_NAME}, referencing the support
#                             packages built in Phase I.
#-----------------------------------------------------------------------------
option(${PRIMARY_PROJECT_NAME}_SUPERBUILD "Build ${PRIMARY_PROJECT_NAME} and the projects it depends on via SuperBuild.cmake." ON)
mark_as_advanced(${PRIMARY_PROJECT_NAME}_SUPERBUILD)

#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# Common build features for both the superbuild and the main build
#-----------------------------------------------------------------------------
include(${CMAKE_CURRENT_SOURCE_DIR}/Common.cmake)

#-----------------------------------------------------------------------------
# Superbuild script
#-----------------------------------------------------------------------------
if(${PRIMARY_PROJECT_NAME}_SUPERBUILD)
  project(SuperBuild_${PRIMARY_PROJECT_NAME})  # <- NOTE: Project name for pre-requisites is different form main project
  if(NOT CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD 98) # Supported values are ``98``, ``11`` and ``14``.
  endif()
  #-----------------------------------------------------------------------------
  # Sanity checks
  #------------------------------------------------------------------------------
  if(WIN32)
    set(${PROJECT_NAME}_ROOT_DIR_MAX_LENGTH 40)
    if(NOT ${PROJECT_NAME}_SUPERBUILD)
      string(LENGTH ${Slicer_BINARY_INNER_SUBDIR} _inner_subdir_length)
      math(EXPR ${PROJECT_NAME}_ROOT_DIR_MAX_LENGTH "${${PROJECT_NAME}_ROOT_DIR_MAX_LENGTH} + ${_inner_subdir_length}")
    endif()
    include(PreventDirWithTooManyChars)
  endif()
  include(PreventInSourceBuilds)
  include(PreventInBuildInstalls)
  include(PreventDirWithSpaces)
  mark_as_superbuild(${PROJECT_NAME}_SKIP_DIR_WITH_SPACES_CHECK:BOOL)

  include("${CMAKE_CURRENT_SOURCE_DIR}/SuperBuild.cmake")
  return()
else()
  project(${PRIMARY_PROJECT_NAME})             # <- NOTE: Here is the main project name setting
  if(NOT CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD 98) # Supported values are ``98``, ``11`` and ``14``.
  endif()
  include("${CMAKE_CURRENT_SOURCE_DIR}/${PRIMARY_PROJECT_NAME}.cmake")
  return()
endif()

message(FATAL_ERROR "You should never reach this point !")
