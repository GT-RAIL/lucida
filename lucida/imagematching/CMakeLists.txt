cmake_minimum_required(VERSION 3.0)
project(lucida_imagematching)

# Force check the separation of source and build dir
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
  message(FATAL_ERROR "DO NOT BUILD in-tree.")
endif()

# Set variables necessary for this cmake
set(
  THRIFT_CPP "$ENV{LUCIDA_BUILD}/gen-cpp2"
  CACHE PATH ""
  PARENT_SCOPE
)
set(
  THRIFT_CPP_INCLUDE "$ENV{LUCIDA_BUILD}/gen-cpp2/include/gen-cpp2"
  CACHE PATH ""
  PARENT_SCOPE
)
set(BUILD_TESTING ${BUILD_TESTING} PARENT_SCOPE)


# Image matching depends on its subdirectories
add_custom_target(imagematching ALL)

# Add the subdirectories
add_subdirectory(opencv_imm) # Exposes the opencv_imm executable

# The subdirectories can only be built if the overall is built
add_dependencies(opencv_imm imagematching)
