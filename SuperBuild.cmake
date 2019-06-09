#-----------------------------------------------------------------------------
include(SlicerMacroGetOperatingSystemArchitectureBitness)

#-----------------------------------------------------------------------------
# Where should the superbuild source files be downloaded to?
# By keeping this outside of the build tree, you can share one
# set of external source trees for multiple build trees
#-----------------------------------------------------------------------------
# set( SOURCE_DOWNLOAD_CACHE ${CMAKE_CURRENT_LIST_DIR}/ExternalSources )
set( SOURCE_DOWNLOAD_CACHE ${CMAKE_CURRENT_BINARY_DIR} ) #<-- Note same as default

#-----------------------------------------------------------------------------
# CTestCustom
#-----------------------------------------------------------------------------
if(BUILD_TESTING AND NOT BRAINSTools_DISABLE_TESTING)
  configure_file(
    CMake/CTestCustom.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/CTestCustom.cmake
    @ONLY)
endif()

#-----------------------------------------------------------------------------
# Git protocol option
#-----------------------------------------------------------------------------
option(${CMAKE_PROJECT_NAME}_USE_GIT_PROTOCOL "If behind a firewall turn this off to use http instead." ON)
set(git_protocol "git")
if(NOT ${CMAKE_PROJECT_NAME}_USE_GIT_PROTOCOL)
  set(git_protocol "https")
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

find_package(Git REQUIRED)

cmake_dependent_option(${CMAKE_PROJECT_NAME}_USE_CTKAPPLAUNCHER "CTKAppLauncher used with python" ON
  "NOT ${CMAKE_PROJECT_NAME}_USE_SYSTEM_python" OFF)

if(NOT ${SUPERBUILD_TOPLEVEL_PROJECT}_USE_QT)
  message("NOTE: Following toolkit is dependent to Qt:
          - DTIPrep
          You need to set ${SUPERBUILD_TOPLEVEL_PROJECT}_USE_QT to ON to build above application.")
endif()

# Compute -G arg for configuring external projects with the same CMake generator:
if(CMAKE_EXTRA_GENERATOR)
  set(gen "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
else()
  set(gen "${CMAKE_GENERATOR}")
endif()


set(cmakeversion_external_update LOG_UPDATE )
set(cmakeversion_external_update_value 1)

#-----------------------------------------------------------------------------
# Superbuild option(s)
#-----------------------------------------------------------------------------
option(BUILD_STYLE_UTILS "Build uncrustify, cppcheck, & KWStyle" OFF)
cmake_dependent_option(
  USE_SYSTEM_Uncrustify "Use system Uncrustify program" OFF
  "BUILD_STYLE_UTILS" OFF
  )
cmake_dependent_option(
  USE_SYSTEM_KWStyle "Use system KWStyle program" OFF
  "BUILD_STYLE_UTILS" OFF
  )
cmake_dependent_option(
  USE_SYSTEM_Cppcheck "Use system Cppcheck program" OFF
  "BUILD_STYLE_UTILS" OFF
  )

set(EXTERNAL_PROJECT_BUILD_TYPE "Release" CACHE STRING "Default build type for support libraries")

option(USE_SYSTEM_ITK "Build using an externally defined version of ITK" OFF)
option(USE_SYSTEM_SlicerExecutionModel "Build using an externally defined version of SlicerExecutionModel"  OFF)
option(USE_SYSTEM_VTK "Build using an externally defined version of VTK" OFF)
option(USE_SYSTEM_zlib "build using the system version of zlib" OFF)
option(USE_SYSTEM_DCMTK "Build using an externally defined version of DCMTK" OFF)
option(${SUPERBUILD_TOPLEVEL_PROJECT}_BUILD_DICOM_SUPPORT "Build Dicom Support" ON)

option(USE_ANTS "Build BRAINSTools with ANTs integration" ON)

#------------------------------------------------------------------------------
# ${LOCAL_PROJECT_NAME} dependency list
#------------------------------------------------------------------------------

list(APPEND ${SUPERBUILD_TOPLEVEL_PROJECT}_DEPENDENCIES DCMTK)
list(APPEND ${SUPERBUILD_TOPLEVEL_PROJECT}_DEPENDENCIES ITKv5)
list(APPEND ${SUPERBUILD_TOPLEVEL_PROJECT}_DEPENDENCIES SlicerExecutionModel)
list(APPEND ${SUPERBUILD_TOPLEVEL_PROJECT}_DEPENDENCIES teem)
#list(APPEND ${SUPERBUILD_TOPLEVEL_PROJECT}_DEPENDENCIES Boost)
list(APPEND ${SUPERBUILD_TOPLEVEL_PROJECT}_DEPENDENCIES TBB)

list(APPEND ${SUPERBUILD_TOPLEVEL_PROJECT}_DEPENDENCIES dcm2niix)

if(BUILD_STYLE_UTILS)
  list(APPEND ${SUPERBUILD_TOPLEVEL_PROJECT}_DEPENDENCIES Cppcheck KWStyle Uncrustify)
endif()


option(BUILD_CALATK "build the calatk project" ON)
set(CALATK_DEP)
if(${BUILD_CALATK})
  set(CALATK_DEP calatk)
endif()


#-----------------------------------------------------------------------------
# Common external projects CMake variables
#-----------------------------------------------------------------------------

if(${LOCAL_PROJECT_NAME}_USE_QT)
  mark_as_superbuild(
    VARS
      ${LOCAL_PROJECT_NAME}_USE_QT:BOOL
      QT_QMAKE_EXECUTABLE:PATH
      QT_MOC_EXECUTABLE:PATH
      QT_UIC_EXECUTABLE:PATH
    PROJECTS VTK ${LOCAL_PROJECT_NAME}
    )
endif()

set(extProjName ${LOCAL_PROJECT_NAME})
set(proj        ${LOCAL_PROJECT_NAME})

#-----------------------------------------------------------------------------
# Enable and setup External project global properties
#-----------------------------------------------------------------------------

set(ep_common_c_flags "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_INIT} ${ADDITIONAL_C_FLAGS}")
set(ep_common_cxx_flags "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_INIT} ${ADDITIONAL_CXX_FLAGS}")

set(${LOCAL_PROJECT_NAME}_CLI_RUNTIME_DESTINATION  bin)
set(${LOCAL_PROJECT_NAME}_CLI_LIBRARY_DESTINATION  lib)
set(${LOCAL_PROJECT_NAME}_CLI_ARCHIVE_DESTINATION  lib)
set(${LOCAL_PROJECT_NAME}_CLI_INSTALL_RUNTIME_DESTINATION  bin)
set(${LOCAL_PROJECT_NAME}_CLI_INSTALL_LIBRARY_DESTINATION  lib)
set(${LOCAL_PROJECT_NAME}_CLI_INSTALL_ARCHIVE_DESTINATION  lib)

set(${LOCAL_PROJECT_NAME}_INSTALL_LIB_DIR ${${LOCAL_PROJECT_NAME}_CLI_LIBRARY_DESTINATION} )

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
# Add external project CMake args
#-----------------------------------------------------------------------------
mark_as_superbuild(
  VARS
    BUILD_EXAMPLES:BOOL
    BUILD_TESTING:BOOL
    BUILD_SHARED_LIBS:BOOL

    MAKECOMMAND:STRING

    INSTALL_RUNTIME_DESTINATION:STRING
    INSTALL_LIBRARY_DESTINATION:STRING
    INSTALL_ARCHIVE_DESTINATION:STRING

    SITE:STRING
    BUILDNAME:STRING
  ALL_PROJECTS
  )



## for i in SuperBuild/*; do  echo $i |sed 's/.*External_\([a-zA-Z]*\).*/\1/g'|fgrep -v cmake|fgrep -v Template; done|sort -u
list(APPEND ${SUPERBUILD_TOPLEVEL_PROJECT}_DEPENDENCIES
  MRParameterMaps
  OpenCV
  Eigen
  SlicerExecutionModel
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
  #LogSymmetricDemons
  )
if(${SUPERBUILD_TOPLEVEL_PROJECT}_REQUIRES_VTK)
  list(APPEND ${SUPERBUILD_TOPLEVEL_PROJECT}_DEPENDENCIES
  VTK
  #  This does not build currently  MultiAtlas
  # NOT CURRENTLY USED DTIReg
  #   BatchMake  Needed by DTIReg
  # THIS DOES NOT WORK YET  DTIProcess
  UKF
)
endif()

if(NOT ${SUPERBUILD_TOPLEVEL_PROJECT}_REQUIRES_VTK)
  message("NOTE: Following toolkits are dependent to VTK:
           - DTIReg
           - DTIProcess
           - UKF
           You need to set ${SUPERBUILD_TOPLEVEL_PROJECT}_REQUIRES_VTK to ON to build above applications.")
endif()

# Use Anaconda version list(APPEND ${SUPERBUILD_TOPLEVEL_PROJECT}_DEPENDENCIES SimpleITK)
# Use Anaconda version list(APPEND SimpleITK_DEPENDENCIES PCRE Swig)
list(APPEND ${SUPERBUILD_TOPLEVEL_PROJECT}_DEPENDENCIES NIPYPE)

if(BUILD_STYLE_UTILS)
  list(APPEND ${SUPERBUILD_TOPLEVEL_PROJECT}_DEPENDENCIES Cppcheck KWStyle ) #Uncrustify)
endif()

#-----------------------------------------------------------------------------
# Enable and setup External project global properties
#-----------------------------------------------------------------------------

set(ep_common_c_flags "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_INIT} ${ADDITIONAL_C_FLAGS}")
set(ep_common_cxx_flags "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_INIT} ${ADDITIONAL_CXX_FLAGS}")

mark_as_superbuild(
  VARS
    USE_SYSTEM_SlicerExecutionModel:BOOL
#    SlicerExecutionModel_DIR:PATH
#    ITK_DIR:PATH
    VTK_DIR:PATH
    #BOOST_INCLUDE_DIR:PATH

    BRAINSTools_LIBRARY_PATH:PATH
    BRAINSTools_MAX_TEST_LEVEL:STRING

    ${LOCAL_PROJECT_NAME}_REQUIRES_VTK:BOOL
    BUILD_STYLE_UTILS:BOOL
    ${SUPERBUILD_TOPLEVEL_PROJECT}_BUILD_DICOM_SUPPORT:BOOL
    BRAINS_DEBUG_IMAGE_WRITE:BOOL

    BRAINSTools_USE_CTKAPPLAUNCHER:BOOL
    BRAINSTools_USE_GIT_PROTOCOL:BOOL
    EXTERNAL_PROJECT_BUILD_TYPE:STRING

    USE_SYSTEM_DCMTK:BOOL
    USE_SYSTEM_ITK:BOOL
    USE_SYSTEM_VTK:BOOL
    VTK_GIT_REPOSITORY:STRING

    ${LOCAL_PROJECT_NAME}_CLI_LIBRARY_OUTPUT_DIRECTORY:PATH
    ${LOCAL_PROJECT_NAME}_CLI_ARCHIVE_OUTPUT_DIRECTORY:PATH
    ${LOCAL_PROJECT_NAME}_CLI_RUNTIME_OUTPUT_DIRECTORY:PATH
    ${LOCAL_PROJECT_NAME}_CLI_INSTALL_LIBRARY_DESTINATION:PATH
    ${LOCAL_PROJECT_NAME}_CLI_INSTALL_ARCHIVE_DESTINATION:PATH
    ${LOCAL_PROJECT_NAME}_CLI_INSTALL_RUNTIME_DESTINATION:PATH

    SlicerExecutionModel_DIR:PATH
    SlicerExecutionModel_DEFAULT_CLI_RUNTIME_OUTPUT_DIRECTORY:PATH
    SlicerExecutionModel_DEFAULT_CLI_LIBRARY_OUTPUT_DIRECTORY:PATH
    SlicerExecutionModel_DEFAULT_CLI_ARCHIVE_OUTPUT_DIRECTORY:PATH
    SlicerExecutionModel_DEFAULT_CLI_INSTALL_RUNTIME_DESTINATION:PATH
    SlicerExecutionModel_DEFAULT_CLI_INSTALL_LIBRARY_DESTINATION:PATH
    SlicerExecutionModel_DEFAULT_CLI_INSTALL_ARCHIVE_DESTINATION:PATH
  PROJECTS ${LOCAL_PROJECT_NAME}
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
set( ${SUPERBUILD_TOPLEVEL_PROJECT}_USE_SimpleITK_SHARED_DEFAULT OFF)
string(TOUPPER "${CMAKE_BUILD_TYPE}" _CMAKE_BUILD_TYPE)
if(MSVC OR _CMAKE_BUILD_TYPE MATCHES "DEBUG")
  set(${SUPERBUILD_TOPLEVEL_PROJECT}_USE_SimpleITK_SHARED_DEFAULT ON)
endif()
CMAKE_DEPENDENT_OPTION(${SUPERBUILD_TOPLEVEL_PROJECT}_USE_SimpleITK_SHARED "Build SimpleITK with shared libraries. Reduces linking time, increases run-time load time." ${${SUPERBUILD_TOPLEVEL_PROJECT}_USE_SimpleITK_SHARED_DEFAULT} "${SUPERBUILD_TOPLEVEL_PROJECT}_USE_SimpleITK" OFF )
mark_as_superbuild(${SUPERBUILD_TOPLEVEL_PROJECT}_USE_SimpleITK_SHARED)

#------------------------------------------------------------------------------
# Calling this macro last will ensure all prior calls to 'mark_as_superbuild' are
# considered when updating the variable '${LOCAL_PROJECT_NAME}_EP_ARGS' passed to the main project
# below.
ExternalProject_Include_Dependencies( ${LOCAL_PROJECT_NAME}
   PROJECT_VAR proj
   DEPENDS_VAR ${SUPERBUILD_TOPLEVEL_PROJECT}_DEPENDENCIES
)


#------------------------------------------------------------------------------
# Configure and build ${PROJECT_NAME}
#------------------------------------------------------------------------------
ExternalProject_Add(${LOCAL_PROJECT_NAME}
  DEPENDS ${${SUPERBUILD_TOPLEVEL_PROJECT}_DEPENDENCIES}
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}
  BINARY_DIR ${LOCAL_PROJECT_NAME}-build
  DOWNLOAD_COMMAND ""
  UPDATE_COMMAND ""
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    --no-warn-unused-cli    # HACK Only expected variables should be passed down.
  ${${LOCAL_PROJECT_NAME}_EP_ARGS} # All superbuild options should be passed by mark_as_superbuild
  CMAKE_CACHE_ARGS
    -D${LOCAL_PROJECT_NAME}_SUPERBUILD:BOOL=OFF #<-- Critical override
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}
      -DCMAKE_CXX_STANDARD_REQUIRED:BOOL=${CMAKE_CXX_STANDARD_REQUIRED}
      -DCMAKE_CXX_EXTENSIONS:BOOL=${CMAKE_CXX_EXTENSIONS}
      -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/${proj}-install
      -DCMAKE_INCLUDE_DIRECTORIES_BEFORE:BOOL=OFF

      -DTBB_DIR:PATH=${TBB_DIR}

  INSTALL_COMMAND ""
  )

# This custom external project step forces the build and later
# steps to run whenever a top level build is done...
#
# BUILD_ALWAYS flag is available in CMake 3.1 that allows force build
# of external projects without this workaround. Remove this workaround
# and use the CMake flag instead, when BRAINSTools's required minimum CMake
# version will be at least 3.1.
#
if(CMAKE_CONFIGURATION_TYPES)
  set(BUILD_STAMP_FILE "${CMAKE_CURRENT_BINARY_DIR}/${LOCAL_PROJECT_NAME}-prefix/src/${LOCAL_PROJECT_NAME}-stamp/${CMAKE_CFG_INTDIR}/${LOCAL_PROJECT_NAME}-build")
else()
  set(BUILD_STAMP_FILE "${CMAKE_CURRENT_BINARY_DIR}/${LOCAL_PROJECT_NAME}-prefix/src/${LOCAL_PROJECT_NAME}-stamp/${LOCAL_PROJECT_NAME}-build")
endif()
ExternalProject_Add_Step(${LOCAL_PROJECT_NAME} forcebuild
  COMMAND ${CMAKE_COMMAND} -E remove ${BUILD_STAMP_FILE}
  COMMENT "Forcing build step for '${LOCAL_PROJECT_NAME}'"
  DEPENDEES build
  ALWAYS 1
  )
add_subdirectory(src)
