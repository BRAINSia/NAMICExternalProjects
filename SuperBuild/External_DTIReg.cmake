set(proj        DTIReg) #This local name
set(${proj}_REQUIRED_VERSION "")  #If a required version is necessary, then set this, else leave blank

#if(${USE_SYSTEM_${proj}})
#  unset(${proj}_DIR CACHE)
#endif()

# Sanity checks
if(DEFINED ${proj}_DIR AND NOT EXISTS ${${proj}_DIR})
  message(FATAL_ERROR "${proj}_DIR variable is defined but corresponds to non-existing directory (${${proj}_DIR})")
endif()

# Set dependency list
set(${proj}_DEPENDENCIES ITKv4 BatchMake SlicerExecutionModel)
#if(${PROJECT_NAME}_BUILD_DICOM_SUPPORT)
#  list(APPEND ${proj}_DEPENDENCIES DCMTK)
#endif()

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

if(NOT ( DEFINED "USE_SYSTEM_${proj}" AND "${USE_SYSTEM_${proj}}" ) )
  #message(STATUS "${__indent}Adding project ${proj}")

  # Set CMake OSX variable to pass down the external project
  set(CMAKE_OSX_EXTERNAL_PROJECT_ARGS)
  if(APPLE)
    list(APPEND CMAKE_OSX_EXTERNAL_PROJECT_ARGS
      -DCMAKE_OSX_ARCHITECTURES:STRING=${CMAKE_OSX_ARCHITECTURES}
      -DCMAKE_OSX_SYSROOT:STRING=${CMAKE_OSX_SYSROOT}
      -DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=${CMAKE_OSX_DEPLOYMENT_TARGET})
  endif()

  ### --- Project specific additions here
  set(${proj}_CMAKE_OPTIONS
    -DUSE_SYSTEM_BatchMake:BOOL=ON
    -DUSE_SYSTEM_ITK:BOOL=ON
    -DUSE_SYSTEM_VTK:BOOL=ON
    -DUSE_SYSTEM_SlicerExecutionModel:BOOL=ON
     -DBatchMake_DIR:PATH=${BatchMake_DIR}
     -DITK_DIR:PATH=${ITK_DIR}
     -DVTK_DIR:PATH=${VTK_DIR}
     -DCOMPILE_EXTERNAL_dtiprocess:BOOL=OFF
     -DDTIReg_SUPERBUILD:BOOL=OFF
     -DSlicerExecutionModel_DIR:PATH=${SlicerExecutionModel_DIR}
     -DDTIReg_ADDITIONAL_LINK_DIRS:PATH=${CMAKE_CURRENT_BINARY_DIR}/lib
    )

  ### --- End Project specific additions
  set(${proj}_REPOSITORY https://www.nitrc.org/svn/dtireg/trunk)
  set(${proj}_REVISION -r "77") ## Fix SlicerExecutionModel find_package

  ExternalProject_Add(${proj}
    SVN_REPOSITORY ${${proj}_REPOSITORY}
    SVN_REVISION ${${proj}_REVISION}
    SVN_USERNAME slicerbot
    SVN_PASSWORD slicer
    SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}
    BINARY_DIR ${proj}-build
    LOG_CONFIGURE 0  # Wrap configure in script to ignore log output from dashboards
    LOG_BUILD     0  # Wrap build in script to to ignore log output from dashboards
    LOG_TEST      0  # Wrap test in script to to ignore log output from dashboards
    LOG_INSTALL   0  # Wrap install in script to to ignore log output from dashboards
    ${cmakeversion_external_update} "${cmakeversion_external_update_value}"
    INSTALL_COMMAND ""
    CMAKE_GENERATOR ${gen}
    CMAKE_ARGS -Wno-dev --no-warn-unused-cli
    CMAKE_CACHE_ARGS
      ${CMAKE_OSX_EXTERNAL_PROJECT_ARGS}
      ${COMMON_EXTERNAL_PROJECT_ARGS}
      ${${proj}_CMAKE_OPTIONS}
      DEPENDS ${${proj}_DEPENDENCIES}
    )

  ## Force rebuilding of the main subproject every time building from super structure
  ExternalProject_Add_Step(DTIReg forcebuild
      COMMAND ${CMAKE_COMMAND} -E remove
      ${CMAKE_CURRENT_BUILD_DIR}/DTIReg-prefix/src/DTIReg-stamp/DTIReg-build
      DEPENDEES configure
      DEPENDERS build
      ALWAYS 1
    )
else()
  if(${USE_SYSTEM_${proj}})
    find_package(${proj} ${${proj}_REQUIRED_VERSION} REQUIRED)
    message("USING the system ${proj}, set ${proj}_DIR=${${proj}_DIR}")
  endif()
  # The project is provided using ${proj}_DIR, nevertheless since other
  # project may depend on ${proj}, let's add an 'empty' one
  Externalproject_Add_empty(${proj} "${${proj}_DEPENDENCIES}")
endif()

mark_as_superbuild(VARS ${proj}_DIR:PATH LABELS "FIND_PACKAGE")

