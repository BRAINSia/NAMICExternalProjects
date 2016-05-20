################################################################################
#
#  Program: NAMIC External Projects
#
#  Copyright (c) Kitware Inc.
#
#  See COPYRIGHT.txt
#  or http://www.slicer.org/copyright/copyright.txt for details.
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#  This file was originally developed for the Slicer project by
#   Dave Partyka and Jean-Christophe Fillion-Robin, Kitware Inc.
#  and was partially funded by NIH grant 3P41RR013218-12S1
#
################################################################################

#-----------------------------------------------------------------------------
enable_language(C)
enable_language(CXX)

#-----------------------------------------------------------------------------
include(SlicerMacroGetOperatingSystemArchitectureBitness)

#-----------------------------------------------------------------------------
# Where should the superbuild source files be downloaded to?
# By keeping this outside of the build tree, you can share one
# set of external source trees for multiple build trees
#-----------------------------------------------------------------------------
set( SOURCE_DOWNLOAD_CACHE ${CMAKE_CURRENT_BINARY_DIR} CACHE PATH
    "The path for downloading external source directories" )
mark_as_advanced( SOURCE_DOWNLOAD_CACHE )

#-----------------------------------------------------------------------------
# Git protocol option
#-----------------------------------------------------------------------------
option(${CMAKE_PROJECT_NAME}_USE_GIT_PROTOCOL "If behind a firewall turn this off to use http instead." ON)
set(git_protocol "git")
if(NOT ${CMAKE_PROJECT_NAME}_USE_GIT_PROTOCOL)
  set(git_protocol "http")
  # Verify that the global git config has been updated with the expected "insteadOf" option.
  function(_check_for_required_git_config_insteadof base insteadof)
    execute_process(
      COMMAND ${GIT_EXECUTABLE} config --global --get "url.${base}.insteadof"
      OUTPUT_VARIABLE output
      OUTPUT_STRIP_TRAILING_WHITESPACE
      RESULT_VARIABLE error_code
      )
    if(error_code OR NOT "${output}" STREQUAL "${insteadof}")
      message(FATAL_ERROR
"Since the ExternalProject modules doesn't provide a mechanism to customize the clone step by "
"adding 'git config' statement between the 'git checkout' and the 'submodule init', it is required "
"to manually update your global git config to successfully build ${CMAKE_PROJECT_NAME} with "
"option ${CMAKE_PROJECT_NAME}_USE_GIT_PROTOCOL set to FALSE. "
"See http://na-mic.org/Mantis/view.php?id=2731"
"\nYou could do so by running the command:\n"
"  ${GIT_EXECUTABLE} config --global url.\"${base}\".insteadOf \"${insteadof}\"\n")
    endif()
  endfunction()
endif()

CMAKE_DEPENDENT_OPTION(${CMAKE_PROJECT_NAME}_USE_CTKAPPLAUNCHER "CTKAppLauncher used with python" ON
  "NOT ${CMAKE_PROJECT_NAME}_USE_SYSTEM_python" OFF)

find_package(Git REQUIRED)

# I don't know who removed the Find_Package for QT, but it needs to be here
# in order to build VTK if ${PRIMARY_PROJECT_NAME}_USE_QT is set.
if(${PRIMARY_PROJECT_NAME}_USE_QT)
  CMAKE_DEPENDENT_OPTION(
    BUILD_DTIPrep "BUILD_DTIPrep option" OFF "${PRIMARY_PROJECT_NAME}_USE_QT" ON
  )
  set(QT_DEPENDENT_PACKAGES ) # vv package can also be built but was causing problems
  if(BUILD_DTIPrep)  # Do not build DTIPrep until it behave better. Hans 2015-01-30
    set(QT_DEPENDENT_PACKAGES DTIPrep ) # vv package can also be built but was causing problems
  endif()
  find_package(Qt4 REQUIRED)
else()
  set(QT_DEPENDENT_PACKAGES "")
endif()

if(NOT ${PRIMARY_PROJECT_NAME}_USE_QT)
  message("NOTE: Following toolkit is dependent to Qt:
          - DTIPrep
          You need to set ${PRIMARY_PROJECT_NAME}_USE_QT to ON to build above application.")
endif()

#-----------------------------------------------------------------------------
# Enable and setup External project global properties
#-----------------------------------------------------------------------------
include(ExternalProject)

# Compute -G arg for configuring external projects with the same CMake generator:
if(CMAKE_EXTRA_GENERATOR)
  set(gen "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
else()
  set(gen "${CMAKE_GENERATOR}")
endif()


# With CMake 2.8.9 or later, the UPDATE_COMMAND is required for updates to occur.
# For earlier versions, we nullify the update state to prevent updates and
# undesirable rebuild.
option(FORCE_EXTERNAL_BUILDS "Force rebuilding of external project (if they are updated)" ON)
if(CMAKE_VERSION VERSION_LESS 2.8.9 OR NOT FORCE_EXTERNAL_BUILDS)
  set(cmakeversion_external_update UPDATE_COMMAND)
  set(cmakeversion_external_update_value "" )
else()
  set(cmakeversion_external_update LOG_UPDATE )
  set(cmakeversion_external_update_value 1)
endif()

#-----------------------------------------------------------------------------
# Superbuild option(s)
#-----------------------------------------------------------------------------
option(BUILD_STYLE_UTILS "Build uncrustify, cppcheck, & KWStyle" OFF)
CMAKE_DEPENDENT_OPTION(
  USE_SYSTEM_Uncrustify "Use system Uncrustify program" OFF
  "BUILD_STYLE_UTILS" OFF
  )
CMAKE_DEPENDENT_OPTION(
  USE_SYSTEM_KWStyle "Use system KWStyle program" OFF
  "BUILD_STYLE_UTILS" OFF
  )
CMAKE_DEPENDENT_OPTION(
  USE_SYSTEM_Cppcheck "Use system Cppcheck program" OFF
  "BUILD_STYLE_UTILS" OFF
  )

set(EXTERNAL_PROJECT_BUILD_TYPE "Release" CACHE STRING "Default build type for support libraries")
set_property(CACHE EXTERNAL_PROJECT_BUILD_TYPE PROPERTY
  STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")

option(USE_SYSTEM_ITK "Build using an externally defined version of ITK" OFF)
option(USE_SYSTEM_SlicerExecutionModel "Build using an externally defined version of SlicerExecutionModel"  OFF)
option(USE_SYSTEM_VTK "Build using an externally defined version of VTK" OFF)
option(USE_SYSTEM_zlib "build using the system version of zlib" OFF)
option(USE_SYSTEM_DCMTK "Build using an externally defined version of DCMTK" OFF)
option(${PROJECT_NAME}_BUILD_DICOM_SUPPORT "Build Dicom Support" ON)
mark_as_superbuild(
  VARS
    ${PROJECT_NAME}_BUILD_DICOM_SUPPORT:BOOL
  ALL_PROJECTS
)

option(BUILD_CALATK "build the calatk project" ON)
set(CALATK_DEP)
if(${BUILD_CALATK})
  set(CALATK_DEP calatk)
endif()

#------------------------------------------------------------------------------
set(SlicerExecutionModel_INSTALL_BIN_DIR bin)
set(SlicerExecutionModel_INSTALL_LIB_DIR lib)
set(SlicerExecutionModel_INSTALL_NO_DEVELOPMENT 1)
set(SlicerExecutionModel_DEFAULT_CLI_RUNTIME_OUTPUT_DIRECTORY bin)
set(SlicerExecutionModel_DEFAULT_CLI_LIBRARY_OUTPUT_DIRECTORY lib)
set(SlicerExecutionModel_DEFAULT_CLI_ARCHIVE_OUTPUT_DIRECTORY lib)
set(SlicerExecutionModel_DEFAULT_CLI_INSTALL_RUNTIME_DESTINATION bin)
set(SlicerExecutionModel_DEFAULT_CLI_INSTALL_LIBRARY_DESTINATION lib)
set(SlicerExecutionModel_DEFAULT_CLI_INSTALL_ARCHIVE_DESTINATION lib)

mark_as_superbuild(
  VARS
    SlicerExecutionModel_DIR:PATH
    SlicerExecutionModel_DEFAULT_CLI_RUNTIME_OUTPUT_DIRECTORY:PATH
    SlicerExecutionModel_DEFAULT_CLI_LIBRARY_OUTPUT_DIRECTORY:PATH
    SlicerExecutionModel_DEFAULT_CLI_ARCHIVE_OUTPUT_DIRECTORY:PATH
    SlicerExecutionModel_DEFAULT_CLI_INSTALL_RUNTIME_DESTINATION:PATH
    SlicerExecutionModel_DEFAULT_CLI_INSTALL_LIBRARY_DESTINATION:PATH
    SlicerExecutionModel_DEFAULT_CLI_INSTALL_ARCHIVE_DESTINATION:PATH
    ALL_PROJECTS
  )
mark_as_superbuild(
  VARS
    SlicerExecutionModel_INSTALL_BIN_DIR:STRING
    SlicerExecutionModel_INSTALL_LIB_DIR:STRING
    SlicerExecutionModel_INSTALL_NO_DEVELOPMENT
  PROJECTS SlicerExecutionModel
  )

#-----------------------------------------------------------------------------
# Common external projects CMake variables
#-----------------------------------------------------------------------------
set(CMAKE_INCLUDE_DIRECTORIES_BEFORE OFF CACHE BOOL "Set default to prepend include directories.")

set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "Write compile_commands.json")


if(${PRIMARY_PROJECT_NAME}_USE_QT)
  mark_as_superbuild(
    VARS
      ${PRIMARY_PROJECT_NAME}_USE_QT:BOOL
      QT_QMAKE_EXECUTABLE:PATH
      QT_MOC_EXECUTABLE:PATH
      QT_UIC_EXECUTABLE:PATH
    ALL_PROJECTS
    )
endif()
mark_as_superbuild(${PRIMARY_PROJECT_NAME}_USE_QT)

set(extProjName ${PRIMARY_PROJECT_NAME})
set(proj        ${PRIMARY_PROJECT_NAME})


#-----------------------------------------------------------------------------
# Set CMake OSX variable to pass down the external projects
#-----------------------------------------------------------------------------
if(APPLE)
  mark_as_superbuild(
    VARS
      CMAKE_OSX_ARCHITECTURES:STRING
      CMAKE_OSX_SYSROOT:PATH
      CMAKE_OSX_DEPLOYMENT_TARGET:STRING
    ALL_PROJECTS
    )
endif()

set(${PRIMARY_PROJECT_NAME}_CLI_RUNTIME_DESTINATION  bin)
set(${PRIMARY_PROJECT_NAME}_CLI_LIBRARY_DESTINATION  lib)
set(${PRIMARY_PROJECT_NAME}_CLI_ARCHIVE_DESTINATION  lib)
set(${PRIMARY_PROJECT_NAME}_CLI_INSTALL_RUNTIME_DESTINATION  bin)
set(${PRIMARY_PROJECT_NAME}_CLI_INSTALL_LIBRARY_DESTINATION  lib)
set(${PRIMARY_PROJECT_NAME}_CLI_INSTALL_ARCHIVE_DESTINATION  lib)
#-----------------------------------------------------------------------------
# Add external project CMake args
#-----------------------------------------------------------------------------

mark_as_superbuild(
  VARS
    BUILD_EXAMPLES:BOOL
    BUILD_TESTING:BOOL
    ITK_VERSION_MAJOR:STRING
    ITK_DIR:PATH

    ${PRIMARY_PROJECT_NAME}_CLI_LIBRARY_OUTPUT_DIRECTORY:PATH
    ${PRIMARY_PROJECT_NAME}_CLI_ARCHIVE_OUTPUT_DIRECTORY:PATH
    ${PRIMARY_PROJECT_NAME}_CLI_RUNTIME_OUTPUT_DIRECTORY:PATH
    ${PRIMARY_PROJECT_NAME}_CLI_INSTALL_LIBRARY_DESTINATION:PATH
    ${PRIMARY_PROJECT_NAME}_CLI_INSTALL_ARCHIVE_DESTINATION:PATH
    ${PRIMARY_PROJECT_NAME}_CLI_INSTALL_RUNTIME_DESTINATION:PATH

    INSTALL_RUNTIME_DESTINATION:STRING
    INSTALL_LIBRARY_DESTINATION:STRING
    INSTALL_ARCHIVE_DESTINATION:STRING
  ALL_PROJECTS
)


string(REPLACE ";" "^" ${CMAKE_PROJECT_NAME}_SUPERBUILD_EP_VARNAMES "${${CMAKE_PROJECT_NAME}_SUPERBUILD_EP_VARNAMES}")

#------------------------------------------------------------------------------
# ${PRIMARY_PROJECT_NAME} dependency list
#------------------------------------------------------------------------------
set(ITK_EXTERNAL_NAME ITKv${ITK_VERSION_MAJOR})

## for i in SuperBuild/*; do  echo $i |sed 's/.*External_\([a-zA-Z]*\).*/\1/g'|fgrep -v cmake|fgrep -v Template; done|sort -u
set(${PRIMARY_PROJECT_NAME}_DEPENDENCIES
  MRParameterMaps
  OpenCV
  Eigen
  SlicerExecutionModel
  DCMTK
  ${ITK_EXTERNAL_NAME}
  JPEG
  GDCM
  DoubleConvert
  NIPYPE
  BRAINSTools
  teem
  SlicerJointRicianAnisotropicLMMSEFilter
  UnbiasedNonLocalMeans
  ANTs
  ${QT_DEPENDENT_PACKAGES}
## These packages are not yet needed, but will evenutally be needed.
  #qhull
  #${CALATK_DEP}
  #tract_querier
  #BatchMake
  #  -- This recursively builds DTIProcess, but does not pass the flags DTI_Tract_Stat
  # niral_utilities
  #LogSymmetricDemons
  #python
  )
if(${PRIMARY_PROJECT_NAME}_REQUIRES_VTK)
  list(APPEND ${PRIMARY_PROJECT_NAME}_DEPENDENCIES
  VTK
  #  This does not build currently  MultiAtlas
  DTIReg
  # THIS DOES NOT WORK YET  DTIProcess
  DTIProcess
  UKF
)
endif()

if(NOT ${PRIMARY_PROJECT_NAME}_REQUIRES_VTK)
  message("NOTE: Following toolkits are dependent to VTK:
           - DTIReg
           - DTIProcess
           - UKF
           You need to set ${PRIMARY_PROJECT_NAME}_REQUIRES_VTK to ON to build above applications.")
endif()

# Use Anaconda version list(APPEND ${PRIMARY_PROJECT_NAME}_DEPENDENCIES SimpleITK)
# Use Anaconda version list(APPEND SimpleITK_DEPENDENCIES PCRE Swig)
list(APPEND ${PRIMARY_PROJECT_NAME}_DEPENDENCIES NIPYPE)

if(BUILD_STYLE_UTILS)
  list(APPEND ${PRIMARY_PROJECT_NAME}_DEPENDENCIES Cppcheck KWStyle ) #Uncrustify)
endif()


#-----------------------------------------------------------------------------
# Enable and setup External project global properties
#-----------------------------------------------------------------------------

set(ep_common_c_flags "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_INIT} ${ADDITIONAL_C_FLAGS}")
set(ep_common_cxx_flags "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_INIT} ${ADDITIONAL_CXX_FLAGS}")

ExternalProject_Include_Dependencies(${proj} DEPENDS_VAR ${PRIMARY_PROJECT_NAME}_DEPENDENCIES)

#-----------------------------------------------------------------------------
# CTestCustom
#-----------------------------------------------------------------------------
if(BUILD_TESTING AND NOT ${PRIMARY_PROJECT_NAME}_BUILD_SLICER_EXTENSION)
  configure_file(
    CMake/CTestCustom.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/CTestCustom.cmake
    @ONLY)
endif()


#------------------------------------------------------------------------------
# Configure and build ${PROJECT_NAME}
#------------------------------------------------------------------------------
set(proj ${PRIMARY_PROJECT_NAME})
ExternalProject_Add(${proj}
  ${${proj}_EP_ARGS}
  DEPENDS ${${PRIMARY_PROJECT_NAME}_DEPENDENCIES}
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}
  BINARY_DIR ${PRIMARY_PROJECT_NAME}-build
  DOWNLOAD_COMMAND ""
  UPDATE_COMMAND ""
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    --no-warn-unused-cli    # HACK Only expected variables should be passed down.
  CMAKE_CACHE_ARGS
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
    -D${PRIMARY_PROJECT_NAME}_SUPERBUILD:BOOL=OFF    #NOTE: VERY IMPORTANT reprocess top level CMakeList.txt
  INSTALL_COMMAND ""
  )

# This custom external project step forces the build and later
# steps to run whenever a top level build is done...
ExternalProject_Add_Step(${proj} forcebuild
  COMMAND ${CMAKE_COMMAND} -E remove
    ${CMAKE_CURRENT_BINARY_DIR}/${proj}-prefix/src/${proj}-stamp/${proj}-build
  COMMENT "Forcing build step for '${proj}'"
  DEPENDEES build
  ALWAYS 1
  )

add_subdirectory(src)
