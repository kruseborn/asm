if(WIN32)
    set(CPP_FLAGS ${MSVC_FLAGS})
    set(VULKAN_LIB "$ENV{VULKAN_SDK}/Lib/vulkan-1.lib")
    set(PLATFORM_LIB "")
else()
    if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
        add_compile_options (-fdiagnostics-color=always)
    elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
        add_compile_options (-fcolor-diagnostics)
    endif ()
    if(CMAKE_BUILD_TYPE MATCHES Debug)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -std=c++17")
    else()
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -O2 -std=c++17")
    endif()

    set(CPP_FLAGS ${LLVM_FLAGS})
endif()
