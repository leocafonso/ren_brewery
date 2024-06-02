# Clone

Clone the whole project/sdk:
    
    ```
    mkdir ren_sdk
    cd ren_sdk
    west init -m https://github.com/leocafonso/ren_brewery
    cd ren_brewery
    west update
    ```

Build:
Change the CMAKE_FIND_ROOT_PATH on the ren_brewery/samples/hello_world/Config.cmake to point to your compiler installation folder

    ```
    set(CMAKE_FIND_ROOT_PATH "your/path/arm-gnu-toolchain/bin")
    ```

Open the samples/hello_world and issue the following command:

    ```
    cmake -B build -DBUILD_CONFIG=test -GNinja -DCMAKE_TOOLCHAIN_FILE=gcc.cmake && ninja -C ./build/
    ```

