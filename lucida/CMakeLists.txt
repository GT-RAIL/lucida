cmake_minimum_required(VERSION 2.8.3)
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

# First generate the thrift targets
add_custom_target(
  thrift ALL
  DEPENDS thrift-python thrift-java thrift-cpp
)
add_custom_target(
  thrift-python
  thrift --gen py -out . ${CMAKE_SOURCE_DIR}/lucidaservice.thrift
    && thrift --gen py -out . ${CMAKE_SOURCE_DIR}/lucidatypes.thrift
    && rm __init__.py
  WORKING_DIRECTORY ${LUCIDA_PYTHON_SITE_PACKAGES}
  SOURCES ${CMAKE_SOURCE_DIR}/lucidaservice.thrift ${CMAKE_SOURCE_DIR}/lucidatypes.thrift
)
add_custom_target(
  thrift-java
  thrift --gen java ${CMAKE_SOURCE_DIR}/lucidaservice.thrift
    && thrift --gen java ${CMAKE_SOURCE_DIR}/lucidatypes.thrift
    # TODO: Add more processing based on how the java files need to be compiled
  SOURCES ${CMAKE_SOURCE_DIR}/lucidaservice.thrift ${CMAKE_SOURCE_DIR}/lucidatypes.thrift
)
add_custom_target(
  thrift-cpp
  python -m thrift_compiler.main --gen cpp2 ${CMAKE_SOURCE_DIR}/lucidaservice.thrift
    && python -m thrift_compiler.main --gen cpp2 ${CMAKE_SOURCE_DIR}/lucidatypes.thrift
  SOURCES ${CMAKE_SOURCE_DIR}/lucidaservice.thrift ${CMAKE_SOURCE_DIR}/lucidatypes.thrift
)
set_property(
  DIRECTORY .
  APPEND
  PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${LUCIDA_PYTHON_SITE_PACKAGES}/lucidaservice" "${LUCIDA_PYTHON_SITE_PACKAGES}/lucidatypes" "gen-java" "gen-cpp2"
)
