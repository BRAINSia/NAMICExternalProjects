list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/CMake)

include(CMakeDependentOption)
include(Artichoke)

option(${PRIMARY_PROJECT_NAME}_INSTALL_DEVELOPMENT "Install development support include and libraries for external packages." OFF)
mark_as_advanced(${PRIMARY_PROJECT_NAME}_INSTALL_DEVELOPMENT)

set(ITK_VERSION_MAJOR 4 CACHE STRING "Choose the expected ITK major version to build, only version 4 allowed.")
set_property(CACHE ITK_VERSION_MAJOR PROPERTY STRINGS "4")

#-----------------------------------------------------------------------------
# Set a default build type if none was specified
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

#-----------------------------------------------------------------------------
# Build option(s)
#-----------------------------------------------------------------------------
option(USE_BRAINSFit                      "Build BRAINSFit"                      ON)
option(USE_BRAINSSnapShotWriter           "Build BRAINSSnapShotWriter"           ON)
if( NOT USE_ANTs )
option(USE_ANTs                           "Build ANTs"                           ON)
endif()

option(${PRIMARY_PROJECT_NAME}_USE_QT "Find and use Qt with VTK to build GUI Tools" ON)
mark_as_advanced(${PRIMARY_PROJECT_NAME}_USE_QT)

if(${PRIMARY_PROJECT_NAME}_USE_QT)
  if(NOT QT4_FOUND)
    find_package(Qt4 4.6 COMPONENTS QtCore QtGui QtNetwork QtXml REQUIRED)
    include(${QT_USE_FILE})
  endif()
endif()

cmake_dependent_option(${PRIMARY_PROJECT_NAME}_USE_PYTHONQT "Use python with QT" ON
  "${PRIMARY_PROJECT_NAME}_USE_QT" OFF)

if( USE_BRAINSFit ) ## This is to force configuration of python early.
  ## NIPYPE is not stable under python 2.6, so require 2.7 when using autoworkup
  ## Enthought Canopy or anaconda are convenient ways to install python 2.7 on linux
  ## or the other option is the free version of Anaconda from https://store.continuum.io/
  set(REQUIRED_PYTHON_VERSION 2.7)
  if(APPLE)
   set(PYTHON_EXECUTABLE
         /System/Library/Frameworks/Python.framework/Versions/${REQUIRED_PYTHON_VERSION}/bin/python2.7
         CACHE FILEPATH "The apple specified python version" )
   set(PYTHON_LIBRARY
         /System/Library/Frameworks/Python.framework/Versions/${REQUIRED_PYTHON_VERSION}/lib/libpython2.7.dylib
         CACHE FILEPATH "The apple specified python shared library" )
   set(PYTHON_INCLUDE_DIR
         /System/Library/Frameworks/Python.framework/Versions/${REQUIRED_PYTHON_VERSION}/include/python2.7
         CACHE PATH "The apple specified python headers" )
  else()
    if (NOT EXISTS ${PYTHON_EXECUTABLE} )
      find_package ( PythonInterp ${REQUIRED_PYTHON_VERSION} REQUIRED )
    endif()

    if (NOT EXISTS ${PYTHON_LIBRARY} )
      message(STATUS "Found PythonInterp version ${PYTHON_VERSION_STRING}")
      find_package ( PythonLibs ${PYTHON_VERSION_STRING} EXACT REQUIRED )
    endif()
  endif()

  set(PYTHON_INSTALL_CMAKE_ARGS
        PYTHON_EXECUTABLE:FILEPATH
        PYTHON_LIBRARY:FILEPATH
        PYTHON_INCLUDE_DIR:PATH
     )
endif()

#-----------------------------------------------------------------------------
# Update CMake module path
#------------------------------------------------------------------------------
set(CMAKE_MODULE_PATH
  ${${PROJECT_NAME}_SOURCE_DIR}/CMake
  ${${PROJECT_NAME}_BINARY_DIR}/CMake
  ${CMAKE_MODULE_PATH}
  )

#-----------------------------------------------------------------------------
# Sanity checks
#------------------------------------------------------------------------------
include(PreventInSourceBuilds)
include(PreventInBuildInstalls)

#-----------------------------------------------------------------------------
# Platform check
#-----------------------------------------------------------------------------
set(PLATFORM_CHECK true)
if(PLATFORM_CHECK)
  # See CMake/Modules/Platform/Darwin.cmake)
  #   6.x == Mac OSX 10.2 (Jaguar)
  #   7.x == Mac OSX 10.3 (Panther)
  #   8.x == Mac OSX 10.4 (Tiger)
  #   9.x == Mac OSX 10.5 (Leopard)
  #  10.x == Mac OSX 10.6 (Snow Leopard)
  if (DARWIN_MAJOR_VERSION LESS "9")
    message(FATAL_ERROR "Only Mac OSX >= 10.5 are supported !")
  endif()
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
#SETIFEMPTY(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
#SETIFEMPTY(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
#SETIFEMPTY(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)

#-----------------------------------------------------------------------------
#SETIFEMPTY(CMAKE_INSTALL_LIBRARY_DESTINATION lib)
#SETIFEMPTY(CMAKE_INSTALL_ARCHIVE_DESTINATION lib)
#SETIFEMPTY(CMAKE_INSTALL_RUNTIME_DESTINATION bin)

#-------------------------------------------------------------------------
#SETIFEMPTY(BRAINSTools_CLI_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
#SETIFEMPTY(BRAINSTools_CLI_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})
#SETIFEMPTY(BRAINSTools_CLI_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})

#-------------------------------------------------------------------------
SETIFEMPTY(BRAINSTools_CLI_INSTALL_LIBRARY_DESTINATION ${CMAKE_INSTALL_LIBRARY_DESTINATION})
SETIFEMPTY(BRAINSTools_CLI_INSTALL_ARCHIVE_DESTINATION ${CMAKE_INSTALL_ARCHIVE_DESTINATION})
SETIFEMPTY(BRAINSTools_CLI_INSTALL_RUNTIME_DESTINATION ${CMAKE_INSTALL_RUNTIME_DESTINATION})

#-------------------------------------------------------------------------
# Augment compiler flags
#-------------------------------------------------------------------------
include(ITKSetStandardCompilerFlags)
#------------------------------------------------------------------------
# Check for clang -- c++11 necessary for boost
#------------------------------------------------------------------------
if("${CMAKE_CXX_COMPILER}${CMAKE_CXX_COMPILER_ARG1}" MATCHES ".*clang.*")
  set(CMAKE_COMPILER_IS_CLANGXX ON CACHE BOOL "compiler is CLang")
endif()

set(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} ${ITK_REQUIRED_C_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ITK_REQUIRED_CXX_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${ITK_REQUIRED_LINK_FLAGS}")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${ITK_REQUIRED_LINK_FLAGS}")
set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} ${ITK_REQUIRED_LINK_FLAGS}")


#-----------------------------------------------------------------------------
# Add needed flag for gnu on linux like enviroments to build static common libs
# suitable for linking with shared object libs.
if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
  if(NOT "${CMAKE_CXX_FLAGS}" MATCHES "-fPIC")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
  endif()
  if(NOT "${CMAKE_C_FLAGS}" MATCHES "-fPIC")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
  endif()
endif()
#
# SimpleITK has large internal libraries, which take an extremely long
# time to link on windows when they are static. Creating shared
# SimpleITK internal libraries can reduce linking time. Also the size
# of the debug libraries are monstrous. Using shared libraries for
# debug, reduce disc requirements, and can improve linking
# times. However, these shared libraries take longer to load than the
# monolithic target from static libraries.
#
set( ${PRIMARY_PROJECT_NAME}_USE_SimpleITK_SHARED_DEFAULT OFF)
string(TOUPPER "${CMAKE_BUILD_TYPE}" _CMAKE_BUILD_TYPE)
if(MSVC OR _CMAKE_BUILD_TYPE MATCHES "DEBUG")
  set(${PRIMARY_PROJECT_NAME}_USE_SimpleITK_SHARED_DEFAULT ON)
endif()
CMAKE_DEPENDENT_OPTION(${PRIMARY_PROJECT_NAME}_USE_SimpleITK_SHARED "Build SimpleITK with shared libraries. Reduces linking time, increases run-time load time." ${${PRIMARY_PROJECT_NAME}_USE_SimpleITK_SHARED_DEFAULT} "${PRIMARY_PROJECT_NAME}_USE_SimpleITK" OFF )
mark_as_superbuild(${PRIMARY_PROJECT_NAME}_USE_SimpleITK_SHARED)

# TODO: figure out what this Slicer rigamarole is actually supposed to be doing
#-----------------------------------------------------------------------------
# ${PRIMARY_PROJECT_NAME} install directories
#-----------------------------------------------------------------------------
set(${PRIMARY_PROJECT_NAME}_INSTALL_ROOT "./")
set(${PRIMARY_PROJECT_NAME}_BUNDLE_LOCATION "${${PRIMARY_PROJECT_NAME}_MAIN_PROJECT_APPLICATION_NAME}.app/Contents")
# NOTE: Make sure to update vtk${PRIMARY_PROJECT_NAME}ApplicationLogic::IsEmbeddedModule if
#       the following variables are changed.
set(${PRIMARY_PROJECT_NAME}_EXTENSIONS_DIRBASENAME "Extensions")
set(${PRIMARY_PROJECT_NAME}_EXTENSIONS_DIRNAME "${${PRIMARY_PROJECT_NAME}_EXTENSIONS_DIRBASENAME}-${${PRIMARY_PROJECT_NAME}_WC_REVISION}")
if(APPLE)
  set(${PRIMARY_PROJECT_NAME}_INSTALL_ROOT "${${PRIMARY_PROJECT_NAME}_BUNDLE_LOCATION}/") # Set to create Bundle
endif()

set(${PRIMARY_PROJECT_NAME}_INSTALL_BIN_DIR "${${PRIMARY_PROJECT_NAME}_INSTALL_ROOT}${${PRIMARY_PROJECT_NAME}_BIN_DIR}")
set(${PRIMARY_PROJECT_NAME}_INSTALL_LIB_DIR "${${PRIMARY_PROJECT_NAME}_INSTALL_ROOT}${${PRIMARY_PROJECT_NAME}_LIB_DIR}")
set(${PRIMARY_PROJECT_NAME}_INSTALL_INCLUDE_DIR "${${PRIMARY_PROJECT_NAME}_INSTALL_ROOT}${${PRIMARY_PROJECT_NAME}_INCLUDE_DIR}")
set(${PRIMARY_PROJECT_NAME}_INSTALL_SHARE_DIR "${${PRIMARY_PROJECT_NAME}_INSTALL_ROOT}${${PRIMARY_PROJECT_NAME}_SHARE_DIR}")
set(${PRIMARY_PROJECT_NAME}_INSTALL_ITKFACTORIES_DIR "${${PRIMARY_PROJECT_NAME}_INSTALL_LIB_DIR}/ITKFactories")
set(${PRIMARY_PROJECT_NAME}_INSTALL_QM_DIR "${${PRIMARY_PROJECT_NAME}_INSTALL_ROOT}${${PRIMARY_PROJECT_NAME}_QM_DIR}")

if(${PRIMARY_PROJECT_NAME}_BUILD_CLI_SUPPORT)
  set(${PRIMARY_PROJECT_NAME}_INSTALL_CLIMODULES_BIN_DIR "${${PRIMARY_PROJECT_NAME}_INSTALL_ROOT}${${PRIMARY_PROJECT_NAME}_CLIMODULES_BIN_DIR}")
  set(${PRIMARY_PROJECT_NAME}_INSTALL_CLIMODULES_LIB_DIR "${${PRIMARY_PROJECT_NAME}_INSTALL_ROOT}${${PRIMARY_PROJECT_NAME}_CLIMODULES_LIB_DIR}")
  set(${PRIMARY_PROJECT_NAME}_INSTALL_CLIMODULES_SHARE_DIR "${${PRIMARY_PROJECT_NAME}_INSTALL_ROOT}${${PRIMARY_PROJECT_NAME}_CLIMODULES_SHARE_DIR}")
endif()
