# generating config.h file:
message ( "Configure: devil - generating config.h:" )
include ( CheckIncludeFiles )
include ( CheckFunctionExists )
include ( CheckSymbolExists )
include ( CheckLibraryExists )
include ( CheckTypeSize )
include ( CheckCCompilerFlag )
include ( TestBigEndian )
check_c_compiler_flag ( "-faltivec -maltivec" ALTIVEC_GCC )
if ( CMAKE_SYSTEM_PROCESSOR STREQUAL "ppc" )
  set ( GCC_PCC_ASM 1 )
endif ( )
if ( CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64" )
  set ( GCC_X86_64_ASM 1 )
endif ( )
if ( CMAKE_SYSTEM_PROCESSOR STREQUAL "x86" )
  set ( GCC_X86_ASM 1 )
endif ( )
check_include_files ( dlfcn.h HAVE_DLFCN_H )
check_include_files ( inttypes.h HAVE_INTTYPES_H )
check_include_files ( memory.h HAVE_MEMORY_H )
check_include_files ( stdint.h HAVE_STDINT_H )
check_include_files ( stdlib.h HAVE_STDLIB_H )
check_include_files ( strings.h HAVE_STRINGS_H )
check_include_files ( string.h HAVE_STRING_H )
check_include_files ( sys/stat.h HAVE_SYS_STAT_H )
check_include_files ( sys/types.h HAVE_SYS_TYPES_H )
check_include_files ( unistd.h HAVE_UNISTD_H )
#TODO:
#Support Allegro API
#undef ILUT_USE_ALLEGRO
check_include_files ( d3d8.h ILUT_USE_DIRECTX8 )
check_include_files ( d3d9.h ILUT_USE_DIRECTX9 )
#~ 	CHECK_INCLUDE_FILES(GL/gl.h ILUT_USE_OPENGL)	
#~ 	CHECK_INCLUDE_FILES(SDL.h ILUT_USE_SDL)


set ( IL_USE_JPEGLIB_UNMODIFIED 1 )
#LCMS include without lcms/ support
#undef LCMS_NODIRINCLUDE
if ( APPLE )
  set ( MAX_OS_X 1 )
endif ( )

#TODO:
set ( STDC_HEADERS 1 )
check_function_exists ( valloc VALLOC )
#TODO:
set ( VECTORMEM 1 )
set ( VERSION "1.6.8" )
test_big_endian ( WORDS_BIGENDIAN )
#TODO:
#Define to 1 if the X Window System is missing or not being used.
#undef X_DISPLAY_MISSING

check_function_exists ( memalign MEMALIGN )
check_function_exists ( mm_malloc MM_MALLOC )
set ( PACKAGE "DevIL" )
set ( PACKAGE_BUGREPORT "" )
set ( PACKAGE_NAME "" )
set ( PACKAGE_STRING "" )
set ( PACKAGE_TARNAME "" )
set ( PACKAGE_VERSION "" )
check_function_exists ( posix_memalign POSIX_MEMALIGN )
check_c_compiler_flag ( "-msse" SSE )
check_c_compiler_flag ( "-msse2" SSE2 )
check_c_compiler_flag ( "-msse3" SSE3 )