function(mg_cc_library)
    cmake_parse_arguments(MG_LIB
        "" # list of names of the boolean arguments (only defined ones will be true)
        "NAME;TYPE;" # list of names of mono-valued arguments
        "SRCS;DEFS;COPTS;DEPS;DEPS_DIR" # list of names of multi-valued arguments (output variables are lists)
        ${ARGN} # arguments of the function to parse, here we take the all original ones
    )
    set(NAME ${MG_LIB_NAME})
	message(${NAME})

    # Check if this is a header-only library
    set(MG_CC_SRCS "${MG_LIB_SRCS}")
    list(FILTER MG_CC_SRCS EXCLUDE REGEX "(.*\\.h|.*\\.inl)")
    if ("${MG_CC_SRCS}" STREQUAL "")
        set(MG_LIB_IS_INTERFACE 1)
    else()
        set(MG_LIB_IS_INTERFACE 0)
    endif()
    if(NOT ${MG_LIB_IS_INTERFACE})
        add_library(${NAME} ${MG_LIB_TYPE} "")
        target_sources(${NAME} PRIVATE ${MG_LIB_SRCS})
        
        message(${CMAKE_CURRENT_SOURCE_DIR})
        target_include_directories(${NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
        target_include_directories(${NAME} SYSTEM PRIVATE ${MG_LIB_DEPS_DIR})
        target_compile_definitions(${NAME} PRIVATE ${MG_LIB_DEFS})
        
		set_target_properties(${NAME} PROPERTIES
				CXX_STANDARD 17
		)

        target_link_libraries(${NAME} PUBLIC ${MG_LIB_DEPS})
        target_compile_options(${NAME} PRIVATE ${MG_LIB_COPTS})

    else()
        # Generating header-only library
        add_library(${NAME} INTERFACE)
        target_include_directories(${NAME} INTERFACE ${CMAKE_CURRENT_SOURCE_DIR})
        target_link_libraries(${NAME} INTERFACE ${MG_LIB_DEPS})
    endif()
endfunction()

function(mg_cc_executable)
    cmake_parse_arguments(MG_CC
        "" # list of names of the boolean arguments (only defined ones will be true)
        "NAME;" # list of names of mono-valued arguments
        "SRCS;COPTS;DEPS" # list of names of multi-valued arguments (output variables are lists)
        ${ARGN} # arguments of the function to parse, here we take the all original ones
    )
    set_target_properties(${NAME} PROPERTIES
       CXX_STANDARD 17
    )

    set(NAME ${MG_CC_NAME})
    add_executable(
        ${NAME}
        ${MG_CC_SRCS}
    )
    target_link_libraries(${NAME} PUBLIC ${MG_CC_DEPS})
    target_compile_options(${NAME} PRIVATE ${MG_CC_COPTS})
endfunction()