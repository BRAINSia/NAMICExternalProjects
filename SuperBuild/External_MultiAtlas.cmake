set(proj        MultiAtlas) #This local name

# Sanity checks
if(DEFINED ${extProjName}_DIR AND NOT EXISTS ${${extProjName}_DIR})
  message(FATAL_ERROR "${extProjName}_DIR variable is defined but corresponds to non-existing directory (${${extProjName}_DIR})")
endif()

# Set dependency list
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

### --- Project specific additions here
set(${proj}_CMAKE_OPTIONS
  -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/${proj}-install
  -DUSE_SYSTEM_ITK:BOOL=ON
  -DUSE_SYSTEM_SLICER_EXECUTION_MODEL:BOOL=ON
  -DITK_DIR:PATH=${ITK_DIR}
  -DBUILD_EXAMPLES:BOOL=OFF
  -DBUILD_TESTING:BOOL=OFF
  -DSlicerExecutionModel_DIR:PATH=${SlicerExecutionModel_DIR}
  -DSlicer_SOURCE_DIR:BOOL=ON ## THIS is a hack to prevent looking for slicer
  )

### --- End Project specific additions
set(${proj}_REPOSITORY "https://github.com/BRAINSia/MultiAtlas.git")
set(${proj}_GIT_TAG "742848031ae486169d4c39b5069d4a911835509e")
ExternalProject_Add(${proj}
  GIT_REPOSITORY ${${proj}_REPOSITORY}
  GIT_TAG ${${proj}_GIT_TAG}
  SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/ExternalSources/${proj}
  BINARY_DIR ${proj}-build
  LOG_CONFIGURE 0  # Wrap configure in script to ignore log output from dashboards
  LOG_BUILD     0  # Wrap build in script to to ignore log output from dashboards
  LOG_TEST      0  # Wrap test in script to to ignore log output from dashboards
  LOG_INSTALL   0  # Wrap install in script to to ignore log output from dashboards
  ${cmakeversion_external_update} "${cmakeversion_external_update_value}"
  CMAKE_GENERATOR ${gen}
  CMAKE_CACHE_ARGS
  ${CMAKE_OSX_EXTERNAL_PROJECT_ARGS}
  ${COMMON_EXTERNAL_PROJECT_ARGS}
  ${${proj}_CMAKE_OPTIONS}
  ## We really do want to install in order to limit # of include paths INSTALL_COMMAND ""
  DEPENDS
  ${${proj}_DEPENDENCIES}
  )
set(${extProjName}_DIR ${CMAKE_BINARY_DIR}/${proj}-build)

mark_as_superbuild(
  VARS ${extProjName}_DIR:PATH
  LABELS "FIND_PACKAGE"
  )