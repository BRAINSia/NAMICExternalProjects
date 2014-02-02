# Make sure this file is included only once by creating globally unique varibles
# based on the name of this included file.
get_filename_component(CMAKE_CURRENT_LIST_FILENAME ${CMAKE_CURRENT_LIST_FILE} NAME_WE)
if(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED)
  return()
endif()
set(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED 1)

## External_${extProjName}.cmake files can be recurisvely included,
## and cmake variables are global, so when including sub projects it
## is important make the extProjName and proj variables
## appear to stay constant in one of these files.
## Store global variables before overwriting (then restore at end of this file.)
ProjectDependancyPush(CACHED_extProjName ${extProjName})
ProjectDependancyPush(CACHED_proj ${proj})

# Make sure that the ExtProjName/IntProjName variables are unique globally
# even if other External_${ExtProjName}.cmake files are sourced by
# SlicerMacroCheckExternalProjectDependency
set(extProjName Swig) #The find_package known name
set(proj        Swig) #This local name

#if(${USE_SYSTEM_${extProjName}})
#  unset(${extProjName}_DIR CACHE)
#endif()

# Sanity checks
if(DEFINED ${extProjName}_DIR AND NOT EXISTS ${${extProjName}_DIR})
  message(FATAL_ERROR "${extProjName}_DIR variable is defined but corresponds to non-existing directory (${${extProjName}_DIR})")
endif()

if(NOT SWIG_DIR)

  set(SWIG_TARGET_VERSION 2.0.11)
  set(SWIG_DOWNLOAD_SOURCE_HASH "291ba57c0acd218da0b0916c280dcbae")
  set(SWIG_DOWNLOAD_WIN_HASH "b902bac6500eb3ea8c6e62c4e6b3832c" )


  if(WIN32)
    # binary SWIG for windows
    #------------------------------------------------------------------------------


    set(swig_source_dir ${CMAKE_CURRENT_BINARY_DIR}/swigwin-${SWIG_TARGET_VERSION})

    # patch step
    configure_file(
      ${CMAKE_CURRENT_LIST_DIR}/External_Swig_patch_step.cmake.in
      ${CMAKE_CURRENT_BINARY_DIR}/External_Swig_patch_step.cmake
      @ONLY)
    set(swig_PATCH_COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/External_Swig_patch_step.cmake)

    # swig.exe available as pre-built binary on Windows:
    ExternalProject_Add(${proj}
      URL http://midas3.kitware.com/midas/api/rest?method=midas.bitstream.download&checksum=${SWIG_DOWNLOAD_WIN_HASH}&name=swigwin-${SWIG_TARGET_VERSION}.zip
      URL_MD5 ${SWIG_DOWNLOAD_WIN_HASH}
      SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/swigwin-${SWIG_TARGET_VERSION}
      ${cmakeversion_external_update} "${cmakeversion_external_update_value}"
      PATCH_COMMAND ${swig_PATCH_COMMAND}
      CONFIGURE_COMMAND ""
      BUILD_COMMAND ""
      INSTALL_COMMAND ""
      )

    set(SWIG_DIR ${CMAKE_CURRENT_BINARY_DIR}/swigwin-${SWIG_TARGET_VERSION}) # path specified as source in ep
    set(SWIG_EXECUTABLE ${CMAKE_CURRENT_BINARY_DIR}/swigwin-${SWIG_TARGET_VERSION}/swig.exe)
    set(Swig_DEPEND "")
  else()
    # Set dependency list
    set(${proj}_DEPENDENCIES "PCRE")

    # Include dependent projects if any
    SlicerMacroCheckExternalProjectDependency(${proj})
    #
    # SWIG
    #

    # swig uses bison find it by cmake and pass it down
    find_package(BISON)
    set(BISON_FLAGS "" CACHE STRING "Flags used by bison")
    mark_as_advanced(BISON_FLAGS)


    # follow the standard EP_PREFIX locations
    set(swig_binary_dir ${CMAKE_CURRENT_BINARY_DIR}/Swig-prefix/src/Swig-build)
    set(swig_source_dir ${CMAKE_CURRENT_BINARY_DIR}/Swig-prefix/src/Swig)
    set(swig_install_dir ${CMAKE_CURRENT_BINARY_DIR}/Swig)

    # configure step
    configure_file(
      ${CMAKE_CURRENT_LIST_DIR}/External_Swig_configure_step.cmake.in
      ${CMAKE_CURRENT_BINARY_DIR}/External_Swig_configure_step.cmake
      @ONLY)
    set(swig_CONFIGURE_COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/External_Swig_configure_step.cmake)

    # patch step
    configure_file(
      ${CMAKE_CURRENT_LIST_DIR}/External_Swig_patch_step.cmake.in
      ${CMAKE_CURRENT_BINARY_DIR}/External_Swig_patch_step.cmake
      @ONLY)
    set(swig_PATCH_COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/External_Swig_patch_step.cmake)

    ExternalProject_Add(${proj}
      URL http://midas3.kitware.com/midas/api/rest?method=midas.bitstream.download&checksum=${SWIG_DOWNLOAD_SOURCE_HASH}&name=swig-${SWIG_TARGET_VERSION}.tar.gz
      URL_MD5 ${SWIG_DOWNLOAD_SOURCE_HASH}
      LOG_CONFIGURE 0  # Wrap configure in script to ignore log output from dashboards
      LOG_BUILD     0  # Wrap build in script to to ignore log output from dashboards
      LOG_TEST      0  # Wrap test in script to to ignore log output from dashboards
      LOG_INSTALL   0  # Wrap install in script to to ignore log output from dashboards
      ${cmakeversion_external_update} "${cmakeversion_external_update_value}"
      CONFIGURE_COMMAND ${swig_CONFIGURE_COMMAND}
      PATCH_COMMAND ${swig_PATCH_COMMAND}
      DEPENDS ${${proj}_DEPENDENCIES}
      )

    set(SWIG_DIR ${swig_install_dir}/share/swig/${SWIG_TARGET_VERSION})
    set(SWIG_EXECUTABLE ${swig_install_dir}/bin/swig)
    set(Swig_DEPEND ${${proj}_DEPENDENCIES})

    ExternalProject_Add_Step(${proj} cpvec
      COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_LIST_DIR}/External_Swig_std_vector_for_R_swig.i ${SWIG_DIR}/r/std_vector.i
       DEPENDEES install
    )
  endif()
endif()

ProjectDependancyPop(CACHED_extProjName extProjName)
ProjectDependancyPop(CACHED_proj proj)
