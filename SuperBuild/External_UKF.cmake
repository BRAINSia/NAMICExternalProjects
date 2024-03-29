set(proj        UKF) #This local name

# Set dependency list
set(${proj}_DEPENDENCIES VTK teem Eigen Boost SlicerExecutionModel)

ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

### --- Project specific additions here
set(${proj}_CMAKE_OPTIONS
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}
  -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}
  -DUSE_SYSTEM_ITK:BOOL=ON
  -DUSE_SYSTEM_SLICER_EXECUTION_MODEL:BOOL=ON
  -DSlicerExecutionModel_DEFAULT_CLI_RUNTIME_OUTPUT_DIRECTORY:PATH=${SlicerExecutionModel_DEFAULT_CLI_RUNTIME_OUTPUT_DIRECTORY}
  -DSlicerExecutionModel_DEFAULT_CLI_LIBRARY_OUTPUT_DIRECTORY:PATH=${SlicerExecutionModel_DEFAULT_CLI_LIBRARY_OUTPUT_DIRECTORY}
  -DSlicerExecutionModel_DEFAULT_CLI_ARCHIVE_OUTPUT_DIRECTORY:PATH=${SlicerExecutionModel_DEFAULT_CLI_ARCHIVE_OUTPUT_DIRECTORY}
  -DSlicerExecutionModel_DEFAULT_CLI_INSTALL_RUNTIME_DESTINATION:PATH=${SlicerExecutionModel_DEFAULT_CLI_INSTALL_RUNTIME_DESTINATION}
  -DSlicerExecutionModel_DEFAULT_CLI_INSTALL_LIBRARY_DESTINATION:PATH=${SlicerExecutionModel_DEFAULT_CLI_INSTALL_LIBRARY_DESTINATION}
  -DSlicerExecutionModel_DEFAULT_CLI_INSTALL_ARCHIVE_DESTINATION:PATH=${SlicerExecutionModel_DEFAULT_CLI_INSTALL_ARCHIVE_DESTINATION}
  -DITK_DIR:PATH=${ITK_DIR}
  -DVTK_DIR:PATH=${VTK_DIR}
  -DBUILD_EXAMPLES:BOOL=OFF
  -DBUILD_TESTING:BOOL=OFF
  -DUKF_SUPERBUILD:BOOL=OFF
  -DEigen_INCLUDE_DIR:PATH=${Eigen_INCLUDE_DIR}
  -DEP_Eigen_INCLUDE_DIR:PATH=${Eigen_INCLUDE_DIR}
  -DTeem_DIR:PATH=${Teem_DIR}
  -DSlicerExecutionModel_DIR:PATH=${SlicerExecutionModel_DIR}
  -DSlicer_SOURCE_DIR:BOOL=ON ## THIS is a hack to prevent looking for slicer
  -DUKFTractography_SUPERBUILD:BOOL=OFF

  -DUSE_SYSTEM_ZLIB:BOOL=ON
  -Dzlib_DIR:PATH=${zlib_DIR}
  -DZLIB_ROOT:PATH=${ZLIB_ROOT}
  -DZLIB_INCLUDE_DIR:PATH=${ZLIB_INCLUDE_DIR}
  -DZLIB_LIBRARY:FILEPATH=${ZLIB_LIBRARY}

  -DUSE_SYSTEM_Boost:BOOL=ON
  -DBoost_NO_BOOST_CMAKE:BOOL=ON #Set Boost_NO_BOOST_CMAKE to ON to disable the search for boost-cmake
  -DBoost_DIR:PATH=${BOOST_ROOT}
  -DBOOST_ROOT:PATH=${BOOST_ROOT}
  -DBOOST_INCLUDE_DIR:PATH=${BOOST_INCLUDE_DIR}
  -DBOOST_INCLUDEDIR:PATH=${BOOST_INCLUDE_DIR}
  )

string(REPLACE ";" " " NO_SEMIS_OPTIONS "${${proj}_CMAKE_OPTIONS}")
FILE(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${proj}-build/${proj}_cmake_options.txt "${NO_SEMIS_OPTIONS}\n")
unset(NO_SEMIS_OPTIONS)

### --- End Project specific additions
#set(${proj}_REPOSITORY "${git_protocol}://github.com/BRAINSia/ukftractography.git")
set(${proj}_REPOSITORY "${git_protocol}://github.com/pnlbwh/ukftractography.git")
set(${proj}_GIT_TAG "2c859b318ab3125c54750045a5e3877fcd50139d") # 20220213
ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
  GIT_REPOSITORY ${${proj}_REPOSITORY}
  GIT_TAG ${${proj}_GIT_TAG}
  SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}
  BINARY_DIR ${proj}-build
  LOG_CONFIGURE 0  # Wrap configure in script to ignore log output from dashboards
  LOG_BUILD     0  # Wrap build in script to to ignore log output from dashboards
  LOG_TEST      0  # Wrap test in script to to ignore log output from dashboards
  LOG_INSTALL   0  # Wrap install in script to to ignore log output from dashboards
  ${cmakeversion_external_update} "${cmakeversion_external_update_value}"
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS -Wno-dev --no-warn-unused-cli
    -DRUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    -DLIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
    -DARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
    -DINSTALL_RUNTIME_DESTINATION:PATH=${CMAKE_INSTALL_RUNTIME_DESTINATION}
    -DINSTALL_LIBRARY_DESTINATION:PATH=${CMAKE_INSTALL_LIBRARY_DESTINATION}
    -DINSTALL_ARCHIVE_DESTINATION:PATH=${CMAKE_INSTALL_ARCHIVE_DESTINATION}
  CMAKE_CACHE_ARGS
  ${${proj}_CMAKE_OPTIONS}
  INSTALL_COMMAND ""
  DEPENDS
  ${${proj}_DEPENDENCIES}
  )

set(${proj}_DIR ${CMAKE_BINARY_DIR}/${proj}-build)
mark_as_superbuild(
  VARS ${proj}_DIR:PATH
  LABELS "FIND_PACKAGE"
  )

