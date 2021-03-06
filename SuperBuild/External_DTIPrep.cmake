
set(proj DTIPrep) #The find_package known name


# Set dependency list
set(${proj}_DEPENDENCIES DCMTK ITKv5 SlicerExecutionModel VTK BRAINSTools ANTs)

ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

set(BRAINSCommonLibWithANTs_OPTIONS
  -DUSE_ANTS:BOOL=${USE_ANTS}
  )

if(USE_ANTS)
  list(APPEND BRAINSCommonLibWithANTs_OPTIONS
    -DUSE_SYSTEM_ANTs:BOOL=ON
    -DANTs_SOURCE_DIR:PATH=${ANTs_SOURCE_DIR}
    -DANTs_LIBRARY_DIR:PATH=${ANTs_LIBRARY_DIR}
    -DUSE_SYSTEM_Boost:BOOL=ON
    -DBoost_NO_BOOST_CMAKE:BOOL=ON #Set Boost_NO_BOOST_CMAKE to ON to disable the search for boost-cmake
    -DBoost_DIR:PATH=${BOOST_ROOT}
    -DBOOST_ROOT:PATH=${BOOST_ROOT}
    -DBOOST_INCLUDE_DIR:PATH=${BOOST_INCLUDE_DIR}
    -DDTIPrepTools_SUPERBUILD:STRING=OFF
    )
endif()

### --- Project specific additions here
set(${proj}_CMAKE_OPTIONS
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
  -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}
  -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/${proj}-install
  -DKWSYS_USE_MD5:BOOL=ON # Required by SlicerExecutionModel
  -DUSE_SYSTEM_ITK:BOOL=ON
  -DUSE_SYSTEM_VTK:BOOL=ON
  -DUSE_SYSTEM_DCMTK:BOOL=ON
  -DUSE_SYSTEM_SlicerExecutionModel:BOOL=ON
  -DITK_DIR:PATH=${ITK_DIR}
  -DVTK_DIR:PATH=${VTK_DIR}
  -DDCMTK_DIR:PATH=${DCMTK_DIR}
  -DGenerateCLP_DIR:PATH=${GenerateCLP_DIR}
  -DSlicerExecutionModel_DIR:PATH=${SlicerExecutionModel_DIR}
  -DBRAINSCommonLib_DIR:PATH=${BRAINSCommonLib_DIR}
  -D${proj}_USE_QT:BOOL=${PRIMARY_PROJECT_NAME}_USE_QT
  -DDTIPrepTools_SUPERBUILD:STRING=OFF
  -DBRAINSTools_SOURCE_DIR:PATH=${BRAINSTools_SOURCE_DIR}
  ${BRAINSCommonLibWithANTs_OPTIONS}
  )

### --- End Project specific additions
set(${proj}_REPOSITORY "${git_protocol}://github.com/NIRALUser/DTIPrep.git")
set(${proj}_GIT_TAG "44f7302015bbecc1890c1cb975a95fae9da2f893")
ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
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
