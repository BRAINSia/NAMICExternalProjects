
# Make sure this file is included only once

set(proj PCRE)

# Set dependency list
set(${proj}_DEPENDENCIES "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj DEPENDS_VAR ${proj}_DEPENDENCIES)

if(${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj})
  message(FATAL_ERROR "Enabling ${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj} is not supported !")
endif()

# Sanity checks
if(DEFINED PCRE_DIR AND NOT EXISTS ${PCRE_DIR})
  message(FATAL_ERROR "PCRE_DIR variable is defined but corresponds to nonexistent directory")
endif()

if(NOT ${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj})
  #
  #  PCRE (Perl Compatible Regular Expressions)
  #

  set(PCRE_TARGET_VERSION 8.36)
  set(PCRE_DOWNLOAD_SOURCE_HASH "ff7b4bb14e355f04885cf18ff4125c98")

  # follow the standard EP_PREFIX locations
  set(pcre_binary_dir ${CMAKE_CURRENT_BINARY_DIR}/PCRE-prefix/src/PCRE-build)
  set(pcre_source_dir ${CMAKE_CURRENT_BINARY_DIR}/PCRE-prefix/src/PCRE)
  set(pcre_install_dir ${CMAKE_CURRENT_BINARY_DIR}/PCRE)

    include(ExternalProjectForNonCMakeProject)

    # environment
    set(_env_script ${CMAKE_BINARY_DIR}/${proj}_Env.cmake)
    ExternalProject_Write_SetBuildEnv_Commands(${_env_script})
    file(APPEND ${_env_script}
"#------------------------------------------------------------------------------
# Added by '${CMAKE_CURRENT_LIST_FILE}'

set(ENV{YACC} \"${BISON_EXECUTABLE}\")
set(ENV{YFLAGS} \"${BISON_FLAGS}\")
")

    # configure step
    set(_configure_script ${CMAKE_BINARY_DIR}/${proj}_configure_step.cmake)
    file(WRITE ${_configure_script}
"include(\"${_env_script}\")
set(${proj}_WORKING_DIR \"${pcre_binary_dir}\")
ExternalProject_Execute(${proj} \"configure\" sh ${pcre_source_dir}/configure
    --prefix=${pcre_install_dir} --disable-shared)
")

  ExternalProject_add(PCRE
    ${${proj}_EP_ARGS}
    URL http://midas3.kitware.com/midas/api/rest?method=midas.bitstream.download&checksum=${PCRE_DOWNLOAD_SOURCE_HASH}&name=pcre-${PCRE_TARGET_VERSION}.tar.gz
    URL_MD5 "${PCRE_DOWNLOAD_SOURCE_HASH}"
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -P ${_configure_script}
    UPDATE_COMMAND "" # Disable update
    DEPENDS
      ${${proj}_DEPENDENCIES}
    )
endif()
