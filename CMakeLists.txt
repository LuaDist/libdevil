
	PROJECT(libdevil)
	CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
	INCLUDE(dist.cmake)

# macros
	MACRO(ADD_PREFIX prefix rootlist)
		SET(outlist )
		FOREACH(root ${${rootlist}})
			LIST(APPEND outlist ${prefix}${root})
		ENDFOREACH(root)
		SET(${rootlist} ${outlist})
	ENDMACRO(ADD_PREFIX)

###########################################################################################

# generating config.h file:
MESSAGE("Configure: devil - generating config.h:")
	INCLUDE (CheckIncludeFiles)
	INCLUDE (CheckFunctionExists)
	INCLUDE (CheckSymbolExists)
	INCLUDE (CheckLibraryExists)
	INCLUDE (CheckTypeSize)
	INCLUDE (CheckCCompilerFlag)
	INCLUDE (TestBigEndian)

	CHECK_C_COMPILER_FLAG("-faltivec -maltivec" ALTIVEC_GCC)

	IF(CMAKE_SYSTEM_PROCESSOR STREQUAL "ppc" )
		SET(GCC_PCC_ASM 1)
	ENDIF()

	IF(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64" )
		SET(GCC_X86_64_ASM 1)
	ENDIF()

	IF(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86" )
		SET(GCC_X86_ASM 1)
	ENDIF()

	CHECK_INCLUDE_FILES(dlfcn.h HAVE_DLFCN_H)
	CHECK_INCLUDE_FILES(inttypes.h HAVE_INTTYPES_H)
	CHECK_INCLUDE_FILES(memory.h HAVE_MEMORY_H)
	CHECK_INCLUDE_FILES(stdint.h HAVE_STDINT_H)
	CHECK_INCLUDE_FILES(stdlib.h HAVE_STDLIB_H)
	CHECK_INCLUDE_FILES(strings.h HAVE_STRINGS_H)
	CHECK_INCLUDE_FILES(string.h HAVE_STRING_H)
	CHECK_INCLUDE_FILES(sys/stat.h HAVE_SYS_STAT_H)
	CHECK_INCLUDE_FILES(sys/types.h HAVE_SYS_TYPES_H)
	CHECK_INCLUDE_FILES(unistd.h HAVE_UNISTD_H)

	#TODO:
	#Support Allegro API
	#undef ILUT_USE_ALLEGRO

	CHECK_INCLUDE_FILES(d3d8.h ILUT_USE_DIRECTX8)
	CHECK_INCLUDE_FILES(d3d9.h ILUT_USE_DIRECTX9)
#~ 	CHECK_INCLUDE_FILES(GL/gl.h ILUT_USE_OPENGL)	
#~ 	CHECK_INCLUDE_FILES(SDL.h ILUT_USE_SDL)
	
	FIND_PACKAGE(OpenGL)
	FIND_PACKAGE(SDL)
	
	IF(OPENGL_FOUND)
		SET(ILUT_USE_OPENGL 1)
	ENDIF()
	IF(SDL_FOUND)
		SET(ILUT_USE_SDL 1)
	ENDIF()

	SET(IL_USE_JPEGLIB_UNMODIFIED 1)

	#LCMS include without lcms/ support
	#undef LCMS_NODIRINCLUDE

	IF(APPLE)
		SET(MAX_OS_X 1)
	ENDIF()

	CHECK_FUNCTION_EXISTS(memalign MEMALIGN)
	CHECK_FUNCTION_EXISTS(mm_malloc MM_MALLOC)

	SET(PACKAGE "DevIL")
	SET(PACKAGE_BUGREPORT "")
	SET(PACKAGE_NAME "")
	SET(PACKAGE_STRING "")
	SET(PACKAGE_TARNAME "")
	SET(PACKAGE_VERSION "")

	CHECK_FUNCTION_EXISTS(posix_memalign POSIX_MEMALIGN)

	CHECK_C_COMPILER_FLAG("-msse" SSE)
	CHECK_C_COMPILER_FLAG("-msse2" SSE2)
	CHECK_C_COMPILER_FLAG("-msse3" SSE3)

	#TODO:
	SET(STDC_HEADERS 1)

	CHECK_FUNCTION_EXISTS(valloc VALLOC)

	#TODO:
	SET(VECTORMEM 1)

	SET(VERSION "1.6.8")

	TEST_BIG_ENDIAN(WORDS_BIGENDIAN)

	#TODO:
	#Define to 1 if the X Window System is missing or not being used.
	#undef X_DISPLAY_MISSING

	# all is defined, so generate config.h
	CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/IL/config.h)

MESSAGE("Configure: devil	 - done.")
# end of generating config.h file:

# Discard config.h
FILE(REMOVE ${CMAKE_CURRENT_SOURCE_DIR}/include/IL/config.h)

ADD_DEFINITIONS(-DHAVE_CONFIG_H)

###########################################################################################

FIND_PACKAGE(ZLIB REQUIRED)
FIND_PACKAGE(JPEG REQUIRED)
FIND_PACKAGE(PNG REQUIRED)
FIND_PACKAGE(TIFF REQUIRED)

FIND_PATH( LCMS_INCLUDE_DIR NAMES lcms.h )
FIND_PATH( MNG_INCLUDE_DIR NAMES libmng.h)

INCLUDE_DIRECTORIES(
	${ZLIB_INCLUDE_DIR}
	${JPEG_INCLUDE_DIR}
	${LCMS_INCLUDE_DIR}
	${MNG_INCLUDE_DIR}
	${PNG_INCLUDE_DIR}
	${TIFF_INCLUDE_DIR}
	${SDL_INCLUDE_DIR}
	)

FIND_LIBRARY( LCMS_LIBRARY NAMES lcms)
FIND_LIBRARY( MNG_LIBRARY NAMES mng)

#################
INCLUDE_DIRECTORIES(include include/IL ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_BINARY_DIR}/IL/)

# libil Library

	INCLUDE_DIRECTORIES(src-IL/include)

	FILE(GLOB LIBIL_SRCS "src-IL/src/*.c")
	IF(NOT ALTIVEC_GCC)
		LIST(REMOVE_ITEM LIBIL_SRCS 
			${CMAKE_CURRENT_SOURCE_DIR}/src-IL/src/altivec_common.c 
			${CMAKE_CURRENT_SOURCE_DIR}/src-IL/src/altivec_typeconversion.c 
		)
	ENDIF()

	SET_SOURCE_FILES_PROPERTIES(src-il/src/il_jpeg.c PROPERTIES COMPILE_FLAGS "-DXMD_H" )
	SET_SOURCE_FILES_PROPERTIES(src-il/src/il_mng.c PROPERTIES COMPILE_FLAGS "-DXMD_H" )

	ADD_LIBRARY(il SHARED ${LIBIL_SRCS})
	TARGET_LINK_LIBRARIES (il
					${ZLIB_LIBRARY}
					${JPEG_LIBRARY}
					${LCMS_LIBRARY}
					${MNG_LIBRARY}
					${PNG_LIBRARY}
					${TIFF_LIBRARY}
					)
	IF(MINGW)
		SET_TARGET_PROPERTIES(il PROPERTIES
					#LINK_FLAGS "-Wl,--add-stdcall-alias -Wl,--kill-at"
					LINK_FLAGS "-Wl,--add-stdcall-alias"
					#LINK_FLAGS "-Wl,--kill-at"
					CLEAN_DIRECT_OUTPUT 1)
	ENDIF()
	
# libilu Library

	INCLUDE_DIRECTORIES(src-ILU/include)

	FILE(GLOB LIBILU_SRCS "src-ILU/src/*.c")

	ADD_LIBRARY(ilu SHARED ${LIBILU_SRCS})
	TARGET_LINK_LIBRARIES(ilu il)	
	
	IF(MINGW)
		SET_TARGET_PROPERTIES(libilu PROPERTIES

			#LINK_FLAGS "-Wl,--add-stdcall-alias -Wl,--kill-at"
			LINK_FLAGS "-Wl,--add-stdcall-alias"
			#LINK_FLAGS "-Wl,--kill-at"
			CLEAN_DIRECT_OUTPUT 1)
	ENDIF()
	
# libilut Library
#~ 	FIND_PACKAGE(OPENGL REQUIRED)

	INCLUDE_DIRECTORIES(src-ILUT/include)


	#TODO: hack for SDL support - until we have a sdl.rockspec...
	INCLUDE_DIRECTORIES(${LUADIST_INCDIR})

	FILE(GLOB LIBILUT_SRCS "src-ILUT/src/*.c")

	ADD_LIBRARY(ilut SHARED ${LIBILUT_SRCS})
	TARGET_LINK_LIBRARIES(ilut il)	

	IF(MINGW)
		SET_TARGET_PROPERTIES(libilut PROPERTIES
			#LINK_FLAGS "-Wl,--add-stdcall-alias -Wl,--kill-at"
			LINK_FLAGS "-Wl,--add-stdcall-alias -L${LUADIST_LIBDIR}"
			#LINK_FLAGS "-Wl,--kill-at"
			CLEAN_DIRECT_OUTPUT 1)
	ENDIF()

	#TODO: SDL_LIB...
#~ 	TARGET_LINK_LIBRARIES(libilut libilu libil sdl ${OPENGL_LIBRARIES})



# install
	INSTALL(TARGETS il ilu ilut  DESTINATION ${INSTALL_LIB})
	INSTALL(DIRECTORY include/ DESTINATION ${INSTALL_INC})
	INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/IL/config.h DESTINATION ${INSTALL_INC}/IL)
	INSTALL(FILES AUTHORS COPYING CREDITS ChangeLog NEWS README TODO DESTINATION ${INSTALL_DOC})



