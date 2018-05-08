cmake_minimum_required(VERSION 3.0)
project(lucida_commandcenter)

# Force check the separation of source and build dir
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
  message(FATAL_ERROR "DO NOT BUILD in-tree.")
endif()

# Set the variables specific to this cmake config
set(
  APACHE_DIRECTORY "/etc/apache2"
  CACHE PATH ""
  PARENT_SCOPE
)

# Nothing to be done for building the command center
add_custom_target(commandcenter ALL)

# When installing the commandcenter, install the apache configs
install(
  FILES apache/conf/ports.conf
  DESTINATION ${APACHE_DIRECTORY}
)

install(
  FILES apache/conf/000-default.conf
  DESTINATION ${APACHE_DIRECTORY}/sites-available
)
