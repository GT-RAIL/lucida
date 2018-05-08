cmake_minimum_required(VERSION 3.0)
project(lucida_imagematching_opencv)

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

# Set the custom target for this file that all the parents will depend on
add_custom_target(opencv_imm)

# Set the definitions. Debug needs to be specified
set(GCC_COMPILE_FLAGS "-fPIC -Wall")
if(CMAKE_BUILD_TYPE MATCHES Debug|DEBUG|debug)
  set(GCC_COMPILE_FLAGS "${GCC_COMPILE_FLAGS} -g3")
else()
  set(GCC_COMPILE_FLAGS "${GCC_COMPILE_FLAGS} -O3")
endif()

# check c++14/c++14
include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++14" _COMPILER_SUPPORTS_CXX14)
CHECK_CXX_COMPILER_FLAG("-std=c++11" _COMPILER_SUPPORTS_CXX11)
if(_COMPILER_SUPPORTS_CXX14)
  set(GCC_COMPILE_FLAGS "${GCC_COMPILE_FLAGS} -std=c++14")
elseif(_COMPILER_SUPPORTS_CXX11)
  set(GCC_COMPILE_FLAGS "${GCC_COMPILE_FLAGS} -std=c++11")
else()
  message(FATAL_ERROR "The compiler ${CMAKE_CXX_COMPILER} has no C++14/C++11 support. Please use a different C++ compiler.")
endif()

# Ultimately, set the compile flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${GCC_COMPILE_FLAGS}")

# Set the include directories
include_directories(
  ${THRIFT_CPP_INCLUDE}/../
)

# Add the opencv_imm executable
set_source_files_properties(
    ${THRIFT_CPP}/LucidaService_client.cpp
    ${THRIFT_CPP}/lucidaservice_constants.cpp
    ${THRIFT_CPP}/LucidaService.cpp
    ${THRIFT_CPP}/LucidaService_processmap_binary.cpp
    ${THRIFT_CPP}/LucidaService_processmap_compact.cpp
    ${THRIFT_CPP}/lucidaservice_types.cpp
    ${THRIFT_CPP}/lucidatypes_constants.cpp
    ${THRIFT_CPP}/lucidatypes_types.cpp
  PROPERTIES
    GENERATED true
)
add_executable(imm_server
  ${THRIFT_CPP}/LucidaService_client.cpp
  ${THRIFT_CPP}/lucidaservice_constants.cpp
  ${THRIFT_CPP}/LucidaService.cpp
  ${THRIFT_CPP}/LucidaService_processmap_binary.cpp
  ${THRIFT_CPP}/LucidaService_processmap_compact.cpp
  ${THRIFT_CPP}/lucidaservice_types.cpp
  ${THRIFT_CPP}/lucidatypes_constants.cpp
  ${THRIFT_CPP}/lucidatypes_types.cpp
  server/IMMHandler.cpp
  server/IMMServer.cpp
  server/Image.cpp
)

# Make sure that the parent dependencies are built before the executable
add_dependencies(imm_server opencv_imm)

# Add the target link libraries
target_link_libraries(imm_server
  -lopencv_core
  -lopencv_highgui
  -lopencv_imgproc
  -lopencv_nonfree
  -lopencv_flann
  -lopencv_objdetect
  -lopencv_features2d
  -lopencv_gpu
  -lrt
  -lprotobuf
  -ltesseract
  -pthread
  -lmongoclient
  -lboost_program_options
  -lboost_filesystem
  -lboost_system
  -lboost_thread
  -lboost_regex
  -lthrift
  -lfolly
  -lwangle
  -lzstd
  -lglog
  -lthriftcpp2
  -lgflags
  -lthriftprotocol
  -lssl
  -lcrypto
)

# Set the install location
install(
  TARGETS imm_server
  RUNTIME DESTINATION $ENV{LUCIDA_BIN}
)

# Build the test if it is enabled
if(BUILD_TESTING)
  add_executable(imm_test
    ${THRIFT_CPP}/LucidaService_client.cpp
    ${THRIFT_CPP}/lucidaservice_constants.cpp
    ${THRIFT_CPP}/LucidaService.cpp
    ${THRIFT_CPP}/LucidaService_processmap_binary.cpp
    ${THRIFT_CPP}/LucidaService_processmap_compact.cpp
    ${THRIFT_CPP}/lucidaservice_types.cpp
    ${THRIFT_CPP}/lucidatypes_constants.cpp
    ${THRIFT_CPP}/lucidatypes_types.cpp
    test/IMMClient.cpp
  )
  add_dependencies(imm_test opencv_imm)
  target_link_libraries(imm_test
    -lopencv_core
    -lopencv_highgui
    -lopencv_imgproc
    -lopencv_nonfree
    -lopencv_flann
    -lopencv_objdetect
    -lopencv_features2d
    -lopencv_gpu
    -lrt
    -lprotobuf
    -ltesseract
    -pthread
    -lmongoclient
    -lboost_program_options
    -lboost_filesystem
    -lboost_system
    -lboost_thread
    -lboost_regex
    -lthrift
    -lfolly
    -lwangle
    -lzstd
    -lglog
    -lthriftcpp2
    -lgflags
    -lthriftprotocol
    -lssl
    -lcrypto
  )
endif()
