set(proj        Ipopt) #This local name
set(${proj}_REQUIRED_VERSION "")  #If a required version is necessary, then set this, else leave blank

#if(${USE_SYSTEM_${proj}})
#  unset(${proj}_DIR CACHE)
#endif()

# Sanity checks
if(DEFINED ${proj}_DIR AND NOT EXISTS ${${proj}_DIR})
  message(FATAL_ERROR "${proj}_DIR variable is defined but corresponds to non-existing directory (${${proj}_DIR})")
endif()

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
External_Project_IncludeDependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES )

if(NOT ( DEFINED "USE_SYSTEM_${proj}" AND "${USE_SYSTEM_${proj}}" ) )
  #message(STATUS "${__indent}Adding project ${proj}")

  ### --- Project specific additions here
  set(${proj}_CMAKE_OPTIONS
      -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}/${proj}-install
      -DBUILD_EXAMPLES:BOOL=OFF
      -DBUILD_TESTING:BOOL=OFF
      -DBUILD_TESTS:BOOL=OFF
      -DBUILD_SHARED_LIBS:BOOL=OFF
  )

  set(${proj}_binary_dir ${CMAKE_CURRENT_BINARY_DIR}/${proj}-build)
  set(${proj}_source_dir ${CMAKE_CURRENT_BINARY_DIR}/${proj})
  set(${proj}_install_dir ${CMAKE_CURRENT_BINARY_DIR}/${proj}-install)
  set(${proj}_configure_script
    ${CMAKE_CURRENT_BINARY_DIR}/External_Ipopt_configure_step.cmake)
  configure_file(${CMAKE_CURRENT_LIST_DIR}/External_Ipopt_configure_step.cmake.in
    ${${proj}_configure_script}
    @ONLY)

  set(${proj}_CONFIGURE_COMMAND ${CMAKE_COMMAND}
    -P ${${proj}_configure_script})

  ### --- End Project specific additions
  set(${proj}_REPOSITORY "https://projects.coin-or.org/svn/Ipopt/trunk") # USE THIS FOR UPDATED VERSION
  set(${proj}_GIT_TAG "r2163")
  ExternalProject_Add(${proj}
    SVN_REPOSITORY ${${proj}_REPOSITORY}
    SVN_REVISION -r ${${proj}_GIT_TAG}
    SVN_TRUST_CERT 1
    SOURCE_DIR ${SOURCE_DOWNLOAD_CACHE}/${proj}
    BINARY_DIR ${proj}-build
    LOG_CONFIGURE 0  # Wrap configure in script to ignore log output from dashboards
    LOG_BUILD     0  # Wrap build in script to to ignore log output from dashboards
    LOG_TEST      0  # Wrap test in script to to ignore log output from dashboards
    LOG_INSTALL   0  # Wrap install in script to to ignore log output from dashboards
    ${cmakeversion_external_update} "${cmakeversion_external_update_value}"
    CONFIGURE_COMMAND ${${proj}_CONFIGURE_COMMAND}
    DEPENDS
      ${${proj}_DEPENDENCIES}
  )
  set(${proj}_DIR ${CMAKE_BINARY_DIR}/${proj}-build)
else()
  if(${USE_SYSTEM_${proj}})
    find_package(${proj} ${${proj}_REQUIRED_VERSION} REQUIRED)
    message("USING the system ${proj}, set ${proj}_DIR=${${proj}_DIR}")
  endif()
  # The project is provided using ${proj}_DIR, nevertheless since other
  # project may depend on ${proj}, let's add an 'empty' one
  ExternalProject_Add_Empty(${proj} "${${proj}_DEPENDENCIES}")
endif()

mark_as_superbuild(
  VARS
    ${proj}_DIR:PATH
  LABELS
     "FIND_PACKAGE"
)
