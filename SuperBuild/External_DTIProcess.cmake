set(proj        DTIProcess) #This local name

# Set dependency list
set(${proj}_DEPENDENCIES ITKv4 VTK SlicerExecutionModel Boost)

ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

### --- Project specific additions here
set(${proj}_CMAKE_OPTIONS
#  -DBOOST_ROOT:PATH=${BOOST_ROOT}
#  -DBOOST_INCLUDE_DIR:PATH=${BOOST_INCLUDE_DIR}
  -DBOOST_ROOT:PATH=${BOOST_ROOT}
  -DBOOST_INCLUDE_DIR:PATH=${BOOST_INCLUDE_DIR}
  -DBUILD_dwiAtlas:BOOL=ON
  -DUSE_SYSTEM_ITK:BOOL=ON
  -DUSE_SYSTEM_VTK:BOOL=ON
  -DUSE_SYSTEM_SlicerExecutionModel:BOOL=ON
  -DITK_DIR:PATH=${ITK_DIR}
  -DDCMTK_DIR:PATH=${DCMTK_DIR}
  -DVTK_DIR:PATH=${VTK_DIR}
  -DUSE_VTK_6:BOOL=${USE_VTK_6}
  -DVTK_VERSION_MAJOR:STRING=${VTK_VERSION_MAJOR}
  -DSlicerExecutionModel_DIR:PATH=${SlicerExecutionModel_DIR}
  -DDTIProcess_SUPERBUILD:BOOL=OFF
  -DBUILD_PolyDataTransform:BOOL=OFF
  -DBUILD_PolyDataMerge:BOOL=OFF
  )

### --- End Project specific additions
set(${proj}_REPOSITORY "${git_protocol}://github.com/NIRALUser/DTIProcessToolkit.git")
set(${proj}_GIT_TAG "b94e187187c76a7dbc1e0637631321dd361abb25")
ExternalProject_Add(${proj}
  GIT_REPOSITORY ${${proj}_REPOSITORY}
  GIT_TAG ${${proj}_GIT_TAG}
  SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}
  BINARY_DIR ${proj}-build
  INSTALL_COMMAND ""
  LOG_CONFIGURE 0  # Wrap configure in script to ignore log output from dashboards
  LOG_BUILD     0  # Wrap build in script to to ignore log output from dashboards
  LOG_TEST      0  # Wrap test in script to to ignore log output from dashboards
  LOG_INSTALL   0  # Wrap install in script to to ignore log output from dashboards
  ${cmakeversion_external_update} "${cmakeversion_external_update_value}"
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS -Wno-dev --no-warn-unused-cli
  CMAKE_CACHE_ARGS
  ${CMAKE_OSX_EXTERNAL_PROJECT_ARGS}
  ${COMMON_EXTERNAL_PROJECT_ARGS}
  ${${proj}_CMAKE_OPTIONS}
  ## We really do want to install in order to limit # of include paths INSTALL_COMMAND ""
  DEPENDS
  ${${proj}_DEPENDENCIES}
  )
set(${proj}_DIR ${CMAKE_BINARY_DIR}/${proj}-build)
mark_as_superbuild(
  VARS ${proj}_DIR:PATH
  LABELS "FIND_PACKAGE"
  )
