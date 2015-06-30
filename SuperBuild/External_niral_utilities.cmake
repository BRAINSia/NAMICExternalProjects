# Make sure this file is included only once by creating globally unique varibles
# based on the name of this included file.
# get_filename_component(CMAKE_CURRENT_LIST_FILENAME ${CMAKE_CURRENT_LIST_FILE} NAME_WE)
# if(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED)
#   return()
# endif()
# set(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED 1)

# Make sure that the ExtProjName/IntProjName variables are unique globally
# even if other External_${ExtProjName}.cmake files are sourced by
# SlicerMacroCheckExternalProjectDependency
set(extProjName niral_utilities) #The find_package known name
set(proj        ${extProjName}) #This local name
set(${extProjName}_REQUIRED_VERSION ITKv4 VTK SlicerExecutionModel)

# Sanity checks
if(DEFINED ${extProjName}_DIR AND NOT EXISTS ${${extProjName}_DIR})
  message(FATAL_ERROR "${extProjName}_DIR variable is defined but corresponds to non-existing directory (${${extProjName}_DIR})")
endif()

# Set dependency list
set(${proj}_DEPENDENCIES ITKv4)
#if(${PROJECT_NAME}_BUILD_DICOM_SUPPORT)
#  list(APPEND ${proj}_DEPENDENCIES DCMTK)
#endif()

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

if(NOT ( DEFINED "USE_SYSTEM_${extProjName}" AND "${USE_SYSTEM_${extProjName}}" ) )
  #message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(${proj}_CMAKE_OPTIONS
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
    -DSlicerExecutionModel_DIR:PATH=${SlicerExecutionModel_DIR}
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/${proj}-install
    -DCOMPILE_CONVERTITKFORMATS:BOOL=ON
    -DCOMPILE_CORREVAL:BOOL=ON
    -DCOMPILE_CROPTOOLS:BOOL=ON
    -DCOMPILE_CURVECOMPARE:BOOL=OFF
    -DCOMPILE_DTIAtlasBuilder:BOOL=OFF
    -DCOMPILE_DWI_NIFTINRRDCONVERSION:BOOL=ON
    -DCOMPILE_IMAGEMATH:BOOL=ON
    -DCOMPILE_IMAGESTAT:BOOL=ON
    -DCOMPILE_POLYDATAMERGE:BOOL=ON
    -DCOMPILE_POLYDATATRANSFORM:BOOL=ON
    -DCOMPILE_TRANSFORMDEFORMATIONFIELD:BOOL=OFF
    -DUSE_SYSTEM_SlicerExecutionModel:BOOL=ON
    -DUSE_SYSTEM_ITK:BOOL=ON
    -DUSE_SYSTEM_VTK:BOOL=ON
    -DITK_VERSION_MAJOR:STRING=${ITK_VERSION_MAJOR}
    -DITK_DIR:PATH=${ITK_DIR}
    -DGenerateCLP_DIR:PATH=${GenerateCLP_DIR}
    -DVTK_DIR:PATH=${VTK_DIR}
    )

  ### --- End Project specific additions
#set(${proj}_REPOSITORY "${git_protocol}://github.com/NIRALUser/niral_utilities.git")
#set(${proj}_GIT_TAG "dea3323b99be580b6fd2a7214ce60ddb9d7baec2")
set(${proj}_REPOSITORY "${git_protocol}://github.com/BRAINSia/niral_utilities.git")
set(${proj}_GIT_TAG a542c082fdccd539218487b4fb394f28e9377973)  # "NAMICExternalProjectsFixes"
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
    INSTALL_COMMAND ""
    ${cmakeversion_external_update} "${cmakeversion_external_update_value}"
    CMAKE_GENERATOR ${gen}
    CMAKE_ARGS -Wno-dev --no-warn-unused-cli
    CMAKE_CACHE_ARGS
      ${${proj}_CMAKE_OPTIONS}
## We really do want to install in order to limit # of include paths INSTALL_COMMAND ""
    DEPENDS
      ${${proj}_DEPENDENCIES}
  )
  set(${extProjName}_DIR ${CMAKE_BINARY_DIR}/${proj}-build)
else()
  if(${USE_SYSTEM_${extProjName}})
    find_package(${extProjName} ${${extProjName}_REQUIRED_VERSION} REQUIRED)
    message("USING the system ${extProjName}, set ${extProjName}_DIR=${${extProjName}_DIR}")
  endif()
  # The project is provided using ${extProjName}_DIR, nevertheless since other
  # project may depend on ${extProjName}, let's add an 'empty' one
  ExternalProject_Add_Empty(${proj} "${${proj}_DEPENDENCIES}")
endif()

mark_as_superbuild(
  VARS
    ${extProjName}_DIR:FILE
  LABELS
     "FIND_PACKAGE"
)
