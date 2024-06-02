cmake_minimum_required(VERSION 3.13)

project(test
    VERSION     1.0
    DESCRIPTION "kconfig test project"
)

# This sets the languages the project is going to be using, if C++ support is desired add CXX to the list.
enable_language(C ASM)

# This sets the language standard globally and whether the standard is a requirement.
# This may not be required, however due to the non-backward compatible nature of C and C++ it is preferred.
# C11 is a good first choice for projects as it provides useful additions like atomics, however it does away
# with optional features like VLAs, so C99 or lower might be preferable when working with legacy projects.
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# This controls the inclusion of the GNU extensions to the C language globally, OFF is preferred for more
# standard and portable C however GNU extensions can provide useful things on top of the base standard.
# Resources: https://gcc.gnu.org/onlinedocs/gcc/C-Extensions.html
set(CMAKE_C_EXTENSIONS OFF)



set(BUILD_CONFIG_DIR ${CMAKE_SOURCE_DIR})
# Create a custom executable filename variable by appending the ELF extension to the project name
set(EXECUTABLE ${PROJECT_NAME}.elf)
set(PROJECT_ROOT                ${CMAKE_SOURCE_DIR}/../..)
list(APPEND CMAKE_MODULE_PATH   ${PROJECT_ROOT}/cmake)

message(${PROJECT_ROOT})

include(kconfig)

if (DEFINED ENV{RootDirPath})
    SET(RootDirPath "$ENV{RootDirPath}")
else()
    SET(RootDirPath "${CMAKE_CURRENT_BINARY_DIR}/../../../..")
endif()

message(${CONFIG_BOARD})
add_executable(${EXECUTABLE} main.c)

target_include_directories(${EXECUTABLE} PUBLIC ${AUTOCONF_DIR})
target_include_directories(${EXECUTABLE} PRIVATE ${PROJECT_ROOT}/boards/${CONFIG_BOARD}/bsp)
target_include_directories(${EXECUTABLE} PRIVATE ${PROJECT_ROOT}/boards/${CONFIG_BOARD}/ra_gen)
target_include_directories(${EXECUTABLE} PRIVATE inc)

# Add additional warning options for the executable target, enabling them for our sources, but not third
# party libraries.
# All of these provide much more safety if not ignored.
# Resources: https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html
target_compile_options(${EXECUTABLE}
PRIVATE
    -Wall
    -Wextra
    -Wshadow
    -Wconversion
    -Wdouble-promotion
)

# This creates a custom command that prints out the firmware binary size information.
# Text is the code, data stores variables that have a non-zero initial value and have to be stored in flash,
# bss stores zero initial values that only take up ram.
# dec and hex are just the cumulative size in decimal and hexadecimal notation respectively.
# Example:
# text	   data	    bss	    dec	    hex	filename
# 3432	     20	   1572	   5024	   13a0	most_commented_embedded_cmakelists.elf
# Resources: https://mcuoneclipse.com/2013/04/14/text-data-and-bss-code-and-data-size-explained/
add_custom_command(TARGET ${EXECUTABLE}
    POST_BUILD
    COMMAND ${CMAKE_SIZE_UTIL} ${EXECUTABLE}
)

# Create a custom command to generate binary and hex files.
# These can be used depending on which method of loading the firmware to the MCU is used.
add_custom_command(TARGET ${EXECUTABLE}
    POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex ${EXECUTABLE} ${PROJECT_NAME}.hex
    COMMAND ${CMAKE_OBJCOPY} -O binary ${EXECUTABLE} ${PROJECT_NAME}.bin
)

add_subdirectory(${RootDirPath}/modules/ra_package modules/ra_package)
add_subdirectory(${RootDirPath}/modules/cmsis modules/cmsis)