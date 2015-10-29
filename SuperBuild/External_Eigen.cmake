# even if other External_${ExtProjName}.cmake files are sourced by
# ExternalProject_Include_Dependencies
set(extProjName Eigen) #The find_package known name
set(proj        Eigen) #This local name
set(${extProjName}_REQUIRED_VERSION "")  #If a required version is necessary, then set this, else leave blank

# Sanity checks
if(DEFINED ${extProjName}_DIR AND NOT EXISTS ${${extProjName}_DIR})
  message(FATAL_ERROR "${extProjName}_DIR variable is defined but corresponds to non-existing directory (${${extProjName}_DIR})")
endif()

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

if(NOT ( DEFINED "USE_SYSTEM_${extProjName}" AND "${USE_SYSTEM_${extProjName}}" ) )
  #message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(${proj}_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/${proj}-install)
  set(${proj}_CMAKE_OPTIONS
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}
      -DCMAKE_INSTALL_PREFIX:PATH=${${proj}_INSTALL_DIR}
      -DEIGEN_BUILD_PKGCONFIG:BOOL=OFF
      -DEIGEN_TEST_NOQT:BOOL=ON
      -DBUILD_TESTING:BOOL=ON
    )

  ### --- End Project specific additions
  set(${proj}_REPOSITORY "${git_protocol}://github.com/BRAINSia/eigen.git")
  set(${proj}_GIT_TAG "c841867b51aeea0533835c0af93bac86a37d4a1f")
    #URL https://bitbucket.org/eigen/eigen/get/3.2.0.tar.gz
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
    INSTALL_DIR ${${proj}_INSTALL_DIR}
    CMAKE_GENERATOR ${gen}
    CMAKE_ARGS -Wno-dev --no-warn-unused-cli
    CMAKE_CACHE_ARGS
      ${${proj}_CMAKE_OPTIONS}
## We really do want to install in order to limit # of include paths INSTALL_COMMAND ""
    DEPENDS
      ${${proj}_DEPENDENCIES}
  )
  set(${extProjName}_DIR ${CMAKE_BINARY_DIR}/${proj}-install)
  set(${extProjName}_INCLUDE_DIR ${CMAKE_BINARY_DIR}/${proj}-install/include/eigen3)
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
    ${extProjName}_DIR:PATH
    ${extProjName}_INCLUDE_DIR:PATH
  LABELS "FIND_PACKAGE"
  )

