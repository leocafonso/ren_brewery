# Get the user configuration settings
# this file should define path for toolchain binary path
set(CMAKE_FIND_ROOT_PATH "C:\\Program Files (x86)\\Arm GNU Toolchain arm-none-eabi\\13.2 Rel1\\bin")

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(TOOLCHAIN_PREFIX arm-none-eabi-)

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_C_COMPILER ${CMAKE_FIND_ROOT_PATH}/${TOOLCHAIN_PREFIX}gcc.exe)
set(CMAKE_ASM_COMPILER ${CMAKE_FIND_ROOT_PATH}/${TOOLCHAIN_PREFIX}gcc.exe)
set(CMAKE_CXX_COMPILER ${CMAKE_FIND_ROOT_PATH}/${TOOLCHAIN_PREFIX}g++.exe)

find_path(COMPILER_DIR ${CMAKE_C_COMPILER})
get_filename_component(TOOLCHAIN_DIR ${COMPILER_DIR} DIRECTORY)

set(CMAKE_OBJCOPY ${CMAKE_FIND_ROOT_PATH}/${TOOLCHAIN_PREFIX}objcopy)
set(CMAKE_SIZE_UTIL ${CMAKE_FIND_ROOT_PATH}/${TOOLCHAIN_PREFIX}size)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# This sets a custom microcontroller specific compiler flags variable.
# First, the cpu variant is set and then the compiler is told to emit thumb instructions.
# Resources: https://gcc.gnu.org/onlinedocs/gcc/ARM-Options.html
set(MCU_OPTIONS
    -mcpu=cortex-m33
    -mthumb
)

# This sets up a variable containing extra functionality compiler flags.
# The flags added here ensure that all objects are placed in separate linker sections. The importance of
# this will be clear further down.
set(EXTRA_OPTIONS
    -fdata-sections
    -ffunction-sections
)

# Set up the compiler optimization options custom variable
set(OPTIMIZATION_OPTIONS
    # Conditionally set compiler optimization level to -Og when building with the Debug configuration.
    # As most microcontrollers are rather limited in terms of flash size and cpu speed, the default
    # optimization level of -O0 is not suitable. -Og is an optimization level created for the best tradeoff
    # between size, speed and debugging viability.
    $<$<CONFIG:Debug>:-Og>
    # Other configurations use their default compiler optimization levels, -O2 for the Release configuration
    # and -Os for the MinSizeRel configuration.
    # Resources:
    # https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#build-configurations
    # https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html
)

# Preprocessor flags for generating dependency information
# Resource: https://gcc.gnu.org/onlinedocs/gcc/Preprocessor-Options.html
set(DEPENDENCY_INFO_OPTIONS
    # Tell the preprocessor to generate dependency files for Make-compatible build systems instead of full
    # preprocessor output, while removing mentions to system header files.
    # If we need the preprocessor output ourselves we can pass the -E argument to the compiler instead.
    -MMD
    # This option instructs the preprocessor to add a phony target for each dependency other than the main
    # file to work around errors the build system gives if you remove header files without updating it.
    -MP
    # This specifies that we want the dependency files to be generated with the same name as the corresponding
    # object file.
    -MF "$(@:%.o=%.d)"
)

# Create a custom variable containing compiler flags for generating debug information
# Resource: https://gcc.gnu.org/onlinedocs/gcc/Debugging-Options.html
set(DEBUG_INFO_OPTIONS
    # The -g flag along with a number tells the compiler to produce the debugging output and the level of detail
    -g3
    # This configures the debug output format and version, it's best to use dwarf version 2 for best debugger
    # compatibility
    -gdwarf-2
)

# Global linker options
add_link_options(
    # Pass the MCU options to the linker as well
    ${MCU_OPTIONS}

    # Here the linkerscript of the chip is passed. The linkerscript tells the linker where to store
    # the objects in memory. Resources:
    # https://blog.thea.codes/the-most-thoroughly-commented-linker-script/
    # https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_chapter/ld_3.html
    -T${CMAKE_SOURCE_DIR}/script/fsp.ld

    # This tells the linker to include the nano variant of the newlib standard library which is optimized
    # for minimal binary size and RAM use. The regular newlib variant is used simply by not passing this.
    --specs=nano.specs

    # This directive instructs the linker to generate a mapfile. Mapfiles contain information about the final
    # layout of the firmware binary and are an invaluable resource for development.
    # Recommended reading: https://interrupt.memfault.com/blog/get-the-most-out-of-the-linker-map-file
    -Wl,-Map=${PROJECT_NAME}.map,--cref

    # This is the linker flag for removing the unused sections from the final binary, it works in conjunction
    # with -fdata-sections and -ffunction-sections compiler flags to remove all unused objects from the final binary.
    -Wl,--gc-sections
)

# SET(MCU_FLAGS "-mcpu=cortex-m33 -mthumb")
# SET(CMAKE_BUILD_FLAGS "-O2 -g -mfpu=vfp -mfloat-abi=soft -Wa,-meabi=5 --specs=nano.specs -fno-common -pedantic -Wall -Wextra -Wno-missing-field-initializers -ffunction-sections -fdata-sections")

# SET(CMAKE_C_FLAGS "${MCU_FLAGS} ${CMAKE_BUILD_FLAGS}"  CACHE INTERNAL "c compiler flags")

# Define the flags for compilation
set(MCU_FLAGS "-mcpu=cortex-m33" "-mthumb")
set(BUILD_FLAGS "-O2" "-g" "-mfpu=vfp" "-mfloat-abi=soft" "-Wa,-meabi=5" "--specs=nano.specs" 
                "-fno-common" "-Wall" "-Wextra" "-Wno-missing-field-initializers" 
                "-ffunction-sections" "-fdata-sections")

# Define linker-specific flags
set(LINKER_FLAGS "-Wl,--gc-sections")

# Apply compile and linker options
add_compile_options(${MCU_FLAGS} ${BUILD_FLAGS})
add_link_options(${LINKER_FLAGS})

# This call tells the linker to link the standard library components to all the libraries and executables
# added after the call.
# The order of the standard library calls is important as the linker evaluates arguments one by one.
# -lc is the libc containing most standard library features
# -lm is the libm containing math functionality
# -lnosys provides stubs for the syscalls, essentially placeholders for what would be operating system calls
link_libraries("-lm")