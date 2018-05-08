cmake_minimum_required(VERSION 3.0)
project(lucida_musicservice)

# Force check the separation of source and build dir
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
  message(FATAL_ERROR "DO NOT BUILD in-tree.")
endif()

# Nothing to be done for building the music service
add_custom_target(musicservice ALL)
