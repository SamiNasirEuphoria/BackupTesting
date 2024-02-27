cmake_minimum_required(VERSION 3.12)
project(StandaloneFileBrowser C)

set(CMAKE_C_STANDARD 11)

# Add other flags to the compiler
add_library(${PROJECT_NAME} SHARED library.c library.h)