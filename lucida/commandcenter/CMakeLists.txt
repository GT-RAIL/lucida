cmake_minimum_required(VERSION 3.0)
project(lucida_commandcenter)

# Force check the separation of source and build dir
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
  message(FATAL_ERROR "DO NOT BUILD in-tree.")
endif()

# Nothing to be done for building the command center
add_custom_target(commandcenter)

# When installing the commandcenter, install the apache configs
install(
  FILES apache/conf/ports.conf
  DESTINATION /etc/apache2
)

install(
  FILES apache/conf/000-default.conf
  DESTINATION /etc/apache2/sites-available
)
