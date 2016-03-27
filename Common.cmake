#-----------------------------------------------------------------------------
# Update CMake module path
#------------------------------------------------------------------------------
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/CMake)

#-----------------------------------------------------------------------------
enable_language(C)
enable_language(CXX)

include(ExternalProjectDependency)

include(CMakeDependentOption)

option(${PRIMARY_PROJECT_NAME}_INSTALL_DEVELOPMENT "Install development support include and libraries for external packages." OFF)
mark_as_advanced(${PRIMARY_PROJECT_NAME}_INSTALL_DEVELOPMENT)

## VTK is not easy to build on all platforms
if(Slicer_BUILD_BRAINSTOOLS)
  option(${PRIMARY_PROJECT_NAME}_REQUIRES_VTK "Determine if tools depending on VTK need to be built." ON)
else()
  option(${PRIMARY_PROJECT_NAME}_REQUIRES_VTK "Determine if tools depending on VTK need to be built." OFF)
endif()
mark_as_advanced(${PRIMARY_PROJECT_NAME}_REQUIRES_VTK)

option(${LOCAL_PROJECT_NAME}_INSTALL_DEVELOPMENT "Install development support include and libraries for external packages." OFF)
mark_as_advanced(${LOCAL_PROJECT_NAME}_INSTALL_DEVELOPMENT)


set(USE_ITKv4 ON)
set(ITK_VERSION_MAJOR 4 CACHE STRING "Choose the expected ITK major version to build BRAINS only version 4 allowed.")
# Set the possible values of ITK major version for cmake-gui
set_property(CACHE ITK_VERSION_MAJOR PROPERTY STRINGS "4")
set(expected_ITK_VERSION_MAJOR ${ITK_VERSION_MAJOR})
if(${ITK_VERSION_MAJOR} VERSION_LESS ${expected_ITK_VERSION_MAJOR})
  # Note: Since ITKv3 doesn't include a ITKConfigVersion.cmake file, let's check the version
  #       explicitly instead of passing the version as an argument to find_package() command.
  message(FATAL_ERROR "Could not find a configuration file for package \"ITK\" that is compatible "
                      "with requested version \"${expected_ITK_VERSION_MAJOR}\".\n"
                      "The following configuration files were considered but not accepted:\n"
                      "  ${ITK_CONFIG}, version: ${ITK_VERSION_MAJOR}.${ITK_VERSION_MINOR}.${ITK_VERSION_PATCH}\n")
endif()


#-----------------------------------------------------------------------------
# Set a default build type if none was specified
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
  set(CTEST_CONFIGURATION_TYPE ${CMAKE_BUILD_TYPE} CACHE STRING "Choose the type of test." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

#-----------------------------------------------------------------------------
# Build option(s)
#-----------------------------------------------------------------------------
option(USE_BRAINSFit                      "Build BRAINSFit"                      ON)
option(USE_BRAINSSnapShotWriter           "Build BRAINSSnapShotWriter"           ON)
if( NOT USE_ANTS )
option(USE_ANTS                           "Build ANTs"                           ON)
endif()

option(${PRIMARY_PROJECT_NAME}_USE_QT "Find and use Qt with VTK to build GUI Tools" OFF)
mark_as_advanced(${PRIMARY_PROJECT_NAME}_USE_QT)

if(${PRIMARY_PROJECT_NAME}_USE_QT)
  if(NOT QT4_FOUND)
    find_package(Qt4 4.6 COMPONENTS QtCore QtGui QtNetwork QtXml REQUIRED)
    include(${QT_USE_FILE})
  endif()
endif()

cmake_dependent_option(${PRIMARY_PROJECT_NAME}_USE_PYTHONQT "Use python with QT" OFF "${PRIMARY_PROJECT_NAME}_USE_QT" OFF)

if( ${PRIMARY_PROJECT_NAME}_USE_PYTHONQT ) ## This is to force configuration of python early.
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

mark_as_superbuild(
  VARS
    PYTHON_EXECUTABLE:FILEPATH
    PYTHON_LIBRARY:FILEPATH
    PYTHON_INCLUDE_DIR:PATH
  ALL_PROJECTS
  )
endif()

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
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
set(CMAKE_BUNDLE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)

#-------------------------------------------------------------------------
set(BRAINSTools_CLI_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
set(BRAINSTools_CLI_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})
set(BRAINSTools_CLI_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})

mark_as_superbuild(
  VARS
    CMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH
    CMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH
    CMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH
    CMAKE_BUNDLE_OUTPUT_DIRECTORY:PATH
    CMAKE_INSTALL_RUNTIME_DESTINATION:PATH
    CMAKE_INSTALL_LIBRARY_DESTINATION:PATH
    CMAKE_INSTALL_ARCHIVE_DESTINATION:PATH
    CMAKE_BUNDLE_OUTPUT_DESTINATION:PATH
  ALL_PROJECTS
  )

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
#-------------------------------------------------------------------------
# Augment compiler flags
#-------------------------------------------------------------------------
include(ITKSetStandardCompilerFlags)
#------------------------------------------------------------------------
# Check for clang -- c++11 necessary for boost
#------------------------------------------------------------------------
if("${CMAKE_CXX_COMPILER}${CMAKE_CXX_COMPILER_ARG1}" MATCHES ".*clang.*")
  set(CMAKE_COMPILER_IS_CLANGXX ON CACHE BOOL "compiler is Clang")
endif()

set(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} ${ITK_REQUIRED_C_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ITK_REQUIRED_CXX_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${ITK_REQUIRED_LINK_FLAGS}")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${ITK_REQUIRED_LINK_FLAGS}")
set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} ${ITK_REQUIRED_LINK_FLAGS}")


mark_as_superbuild(
  VARS
    MAKECOMMAND:STRING
    CMAKE_SKIP_RPATH:BOOL
    BUILD_SHARED_LIBS:BOOL
    CMAKE_MODULE_PATH:PATH
    CMAKE_BUILD_TYPE:STRING
    # BUILD_SHARED_LIBS:BOOL
    CMAKE_INCLUDE_DIRECTORIES_BEFORE:BOOL
    CMAKE_CXX_COMPILER:PATH
    CMAKE_CXX_FLAGS:STRING
    CMAKE_CXX_FLAGS_DEBUG:STRING
    CMAKE_CXX_FLAGS_MINSIZEREL:STRING
    CMAKE_CXX_FLAGS_RELEASE:STRING
    CMAKE_CXX_FLAGS_RELWITHDEBINFO:STRING
    CMAKE_C_COMPILER:PATH
    CMAKE_C_FLAGS:STRING
    CMAKE_C_FLAGS_DEBUG:STRING
    CMAKE_C_FLAGS_MINSIZEREL:STRING
    CMAKE_C_FLAGS_RELEASE:STRING
    CMAKE_C_FLAGS_RELWITHDEBINFO:STRING
    CMAKE_EXE_LINKER_FLAGS:STRING
    CMAKE_EXE_LINKER_FLAGS_DEBUG:STRING
    CMAKE_EXE_LINKER_FLAGS_MINSIZEREL:STRING
    CMAKE_EXE_LINKER_FLAGS_RELEASE:STRING
    CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO:STRING
    CMAKE_MODULE_LINKER_FLAGS:STRING
    CMAKE_MODULE_LINKER_FLAGS_DEBUG:STRING
    CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL:STRING
    CMAKE_MODULE_LINKER_FLAGS_RELEASE:STRING
    CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO:STRING
    CMAKE_SHARED_LINKER_FLAGS:STRING
    CMAKE_SHARED_LINKER_FLAGS_DEBUG:STRING
    CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL:STRING
    CMAKE_SHARED_LINKER_FLAGS_RELEASE:STRING
    CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO:STRING
    CMAKE_GENERATOR:STRING
    CMAKE_EXTRA_GENERATOR:STRING
    CMAKE_EXPORT_COMPILE_COMMANDS:BOOL
    CMAKE_INSTALL_PREFIX:PATH
    CTEST_NEW_FORMAT:BOOL
    MEMORYCHECK_COMMAND_OPTIONS:STRING
    MEMORYCHECK_COMMAND:PATH
    CMAKE_SHARED_LINKER_FLAGS:STRING
    CMAKE_EXE_LINKER_FLAGS:STRING
    CMAKE_MODULE_LINKER_FLAGS:STRING
    SITE:STRING
    BUILDNAME:STRING
  ALL_PROJECTS
  )
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

