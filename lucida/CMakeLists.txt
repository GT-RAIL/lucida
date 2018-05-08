cmake_minimum_required(VERSION 3.0)
project(lucida)

# Force check the separation of source and build dir
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
  message(FATAL_ERROR "DO NOT BUILD in-tree.")
endif()

# Set internal variables
set(
  LUCIDA_PYTHON_SITE_PACKAGES
  $ENV{LUCIDA_PYTHON_ENV}/lib/python2.7/site-packages
  CACHE INTERNAL ""
)
string(TIMESTAMP TMP_BUILD_TIMESTAMP) # Variable for temporary build artefacts

# Set exposed variables
set(APACHE_DIRECTORY "/etc/apache2" CACHE PATH "")
set(THRIFT_PYTHON "${LUCIDA_PYTHON_SITE_PACKAGES}" CACHE PATH "")
set(THRIFT_JAVA "$ENV{LUCIDA_BUILD}/gen-java" CACHE PATH "")
set(THRIFT_CPP "$ENV{LUCIDA_BUILD}/gen-cpp2" CACHE PATH "")

# Set more internal variables
get_filename_component(_THRIFT_CPP_DIRNAME ${THRIFT_CPP} NAME_WE)
set(
  THRIFT_CPP_INCLUDE ${THRIFT_CPP}/include/${_THRIFT_CPP_DIRNAME}
  CACHE INTERNAL ""
)

# First generate the thrift targets. This is included in all
add_custom_target(
  thrift ALL
  DEPENDS thrift-python thrift-java thrift-cpp
)
add_custom_target(
  thrift-python
  thrift --gen py -out . ${CMAKE_SOURCE_DIR}/lucidaservice.thrift
    && thrift --gen py -out . ${CMAKE_SOURCE_DIR}/lucidatypes.thrift
    && rm __init__.py
  WORKING_DIRECTORY ${THRIFT_PYTHON}
  SOURCES ${CMAKE_SOURCE_DIR}/lucidaservice.thrift ${CMAKE_SOURCE_DIR}/lucidatypes.thrift
)
add_custom_target(
  thrift-java
  mkdir -p ${THRIFT_JAVA}
    && thrift --gen java -out ${THRIFT_JAVA} ${CMAKE_SOURCE_DIR}/lucidaservice.thrift
    && thrift --gen java -out ${THRIFT_JAVA} ${CMAKE_SOURCE_DIR}/lucidatypes.thrift
    # TODO: Add more processing based on how the java files need to be compiled
  SOURCES ${CMAKE_SOURCE_DIR}/lucidaservice.thrift ${CMAKE_SOURCE_DIR}/lucidatypes.thrift
)
add_custom_target(
  thrift-cpp
  rm -rf ${THRIFT_CPP}
    && mkdir -p "/tmp/lucida-${TMP_BUILD_TIMESTAMP}"
    && python -m thrift_compiler.main --gen cpp2 -o "/tmp/lucida-${TMP_BUILD_TIMESTAMP}" ${CMAKE_SOURCE_DIR}/lucidaservice.thrift
    && python -m thrift_compiler.main --gen cpp2 -o "/tmp/lucida-${TMP_BUILD_TIMESTAMP}" ${CMAKE_SOURCE_DIR}/lucidatypes.thrift
    && mv "/tmp/lucida-${TMP_BUILD_TIMESTAMP}/gen-cpp2" ${THRIFT_CPP}
    && mkdir -p ${THRIFT_CPP_INCLUDE}
    && ln -s ${THRIFT_CPP}/*.h ${THRIFT_CPP_INCLUDE}/
  SOURCES ${CMAKE_SOURCE_DIR}/lucidaservice.thrift ${CMAKE_SOURCE_DIR}/lucidatypes.thrift
)
set_property(
  DIRECTORY .
  APPEND
  PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${THRIFT_PYTHON}/lucidaservice" "${THRIFT_PYTHON}/lucidatypes" "${THRIFT_JAVA}" "${THRIFT_CPP}"
)

# Include each of the subdirectories
add_subdirectory(commandcenter)
add_subdirectory(musicservice)
add_subdirectory(weather)
add_subdirectory(imagematching)

# Each of the subdirectories depends on thrift
add_dependencies(commandcenter thrift-python)
add_dependencies(musicservice thrift-python)
add_dependencies(weather thrift-python)
add_dependencies(imagematching thrift-cpp)
