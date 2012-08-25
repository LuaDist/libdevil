# Copyright (C) 2012 LuaDist
# Created by Peter Drahoš.
# Redistribution and use of this file is allowed according to the terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own license.

project ( libdevil C )
cmake_minimum_required ( VERSION 2.8 )
include ( cmake/dist.cmake )
include ( configure )

# macros
macro ( ADD_PREFIX prefix rootlist )
	set ( outlist )
	foreach ( root ${${rootlist}} )
		list ( APPEND outlist ${prefix}${root} )
	endforeach ( root )
	set ( ${rootlist} ${outlist} )
endmacro ( ADD_PREFIX )

find_package ( OpenGL )
find_package ( SDL )

if ( OPENGL_FOUND )
  set ( ILUT_USE_OPENGL 1 )
endif ( )
if ( SDL_FOUND )
  set ( ILUT_USE_SDL 1 )
endif ( )

# all is defined, so generate config.h
configure_file ( ${CMAKE_CURRENT_SOURCE_DIR}/config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/IL/config.h )
message ( "Configure: devil	 - done." )

# Discard config.h
file ( REMOVE ${CMAKE_CURRENT_SOURCE_DIR}/include/IL/config.h )
add_definitions ( -DHAVE_CONFIG_H )

find_package ( ZLIB REQUIRED )
find_package ( JPEG REQUIRED )
find_package ( PNG REQUIRED )
find_package ( TIFF REQUIRED )
find_path ( LCMS_INCLUDE_DIR NAMES lcms.h )
find_path ( MNG_INCLUDE_DIR NAMES libmng.h )
include_directories ( ${ZLIB_INCLUDE_DIR} ${JPEG_INCLUDE_DIR} ${LCMS_INCLUDE_DIR} 
  ${MNG_INCLUDE_DIR} ${PNG_INCLUDE_DIR} ${TIFF_INCLUDE_DIR} ${SDL_INCLUDE_DIR} )
find_library ( LCMS_LIBRARY NAMES lcms )
find_library ( MNG_LIBRARY NAMES mng )

include_directories ( include include/IL ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_BINARY_DIR}/IL/ )

# libil Library
include_directories ( src-IL/include )
file ( GLOB LIBIL_SRCS "src-IL/src/*.c" )
if ( NOT ALTIVEC_GCC )
  list ( REMOVE_ITEM LIBIL_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/src-IL/src/altivec_common.c 
    ${CMAKE_CURRENT_SOURCE_DIR}/src-IL/src/altivec_typeconversion.c )
endif ( )
set_source_files_properties ( src-il/src/il_jpeg.c PROPERTIES COMPILE_FLAGS "-DXMD_H" )
set_source_files_properties ( src-il/src/il_mng.c PROPERTIES COMPILE_FLAGS "-DXMD_H" )
add_library ( il ${LIBIL_SRCS} )
target_link_libraries ( il ${ZLIB_LIBRARY} ${JPEG_LIBRARY} ${LCMS_LIBRARY} ${MNG_LIBRARY} 
  ${PNG_LIBRARY} ${TIFF_LIBRARY} )
if ( MINGW )
  set_target_properties ( il PROPERTIES #LINK_FLAGS "-Wl,--add-stdcall-alias -Wl,--kill-at"
    LINK_FLAGS "-Wl,--add-stdcall-alias" #LINK_FLAGS "-Wl,--kill-at"
    CLEAN_DIRECT_OUTPUT 1 )
endif ( )

# libilu Library
include_directories ( src-ILU/include )
file ( GLOB LIBILU_SRCS "src-ILU/src/*.c" )
add_library ( ilu ${LIBILU_SRCS} )
target_link_libraries ( ilu il )
if ( MINGW )
  set_target_properties ( libilu PROPERTIES #LINK_FLAGS "-Wl,--add-stdcall-alias -Wl,--kill-at"
    LINK_FLAGS "-Wl,--add-stdcall-alias" #LINK_FLAGS "-Wl,--kill-at"
    CLEAN_DIRECT_OUTPUT 1 )
endif ( )

# libilut Library
#~ 	FIND_PACKAGE(OPENGL REQUIRED)
include_directories ( src-ILUT/include )
#TODO: hack for SDL support - until we have a sdl.rockspec...
include_directories ( ${LUADIST_INCDIR} )
file ( GLOB LIBILUT_SRCS "src-ILUT/src/*.c" )
add_library ( ilut ${LIBILUT_SRCS} )
target_link_libraries ( ilut il )
if ( MINGW )
  set_target_properties ( libilut PROPERTIES #LINK_FLAGS "-Wl,--add-stdcall-alias -Wl,--kill-at"
    LINK_FLAGS "-Wl,--add-stdcall-alias -L${LUADIST_LIBDIR}" #LINK_FLAGS "-Wl,--kill-at"
    CLEAN_DIRECT_OUTPUT 1 )
endif ( )

#TODO: SDL_LIB...
#~ 	TARGET_LINK_LIBRARIES(libilut libilu libil sdl ${OPENGL_LIBRARIES})
# install
install_library ( il )
install_library ( ilu )
install_library ( ilut )
install_header ( include/ )
install_header ( ${CMAKE_CURRENT_BINARY_DIR}/IL/config.h INTO IL )
install_data ( AUTHORS COPYING CREDITS ChangeLog NEWS README TODO )
