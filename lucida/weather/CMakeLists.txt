cmake_minimum_required(VERSION 3.0)
project(lucida_weather)

# Force check the separation of source and build dir
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
  message(FATAL_ERROR "DO NOT BUILD in-tree.")
endif()

# Nothing to be done for building weather
add_custom_target(weather ALL)
