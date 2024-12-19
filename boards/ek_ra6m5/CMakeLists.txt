target_include_directories(${EXECUTABLE} PRIVATE bsp)
target_include_directories(${EXECUTABLE} PRIVATE ra_gen)

#source directories
file(GLOB_RECURSE board_files 
"${CMAKE_CURRENT_SOURCE_DIR}/ra_gen/*.c")

set(srcs ${board_files})

target_sources(${EXECUTABLE} PRIVATE ${srcs})
