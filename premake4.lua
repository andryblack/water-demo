
math.randomseed(1234)

if os.is('macosx') then
	newoption {
	   	trigger     = "ios",
   		description = "build project for ios"
	}
end

local ProjectName = 'Water'

solution( ProjectName )
	configurations { 'Debug', 'Release' }
	
	--

	local platform_dir = unknown
	local os_map = { 
		macosx = 'osx' 
	}
	local platform_id = os.get()

	configuration "Debug"
         defines { "DEBUG" }
         flags { "Symbols" }
 
    configuration "Release"
         defines { "NDEBUG" }
         flags { "Optimize" }    

	configuration {}

	platform_dir = os_map[platform_id] or platform_id

	local function append_path( path, files ) 
		local f = {}
		for _,v in ipairs(files) do
			f[#f+1] = path .. v
		end
		return f
	end

	local sandbox_dir = '../sandbox'

	print('platform_dir:',platform_dir)

	location ( 'projects/' .. platform_dir ) 
	
	objdir( 'build/' .. platform_dir )

	language "C++"

	project 'GHL'
		kind 'StaticLib'

		local ghl_src = sandbox_dir .. '/GHL/src/'

		targetdir ('lib/' .. platform_dir)

		targetname ('GHL_' .. platform_dir)

		local zlib_files = { 'inffixed.h', 'inftrees.c', 'inftrees.h', 'adler32.c', 'crc32.c', 'crc32.h', 'crypt.h',
							 'deflate.c', 'deflate.h', 'inffast.c', 'inffast.h', 'inflate.c', 'inflate.h', 'ioapi.h',
							 'zconf.h', 'zip.c', 'zip.h', 'zlib.h', 'zutil.c', 'zutil.h'}

		files(append_path(ghl_src .. '/zlib/',zlib_files))

		local jpeg_files = {
			'jaricom.c', 'jcapimin.c', 'jcapistd.c', 'jcarith.c', 'jccoefct.c','jccolor.c',
			'jcdctmgr.c', 'jchuff.c', 'jcinit.c', 'jcmainct.c', 'jcmarker.c', 'jcmaster.c', 'jcomapi.c', 'jcparam.c',
			'jcprepct.c', 'jcsample.c', 'jctrans.c', 'jdapimin.c', 'jdapistd.c', 'jdarith.c', 'jdatadst.c', 'jdcoefct.c',
			'jdcolor.c', 'jddctmgr.c', 'jdhuff.c', 'jdinput.c', 'jdmainct.c', 'jdmarker.c', 'jdmaster.c', 'jdmerge.c',
			'jdpostct.c', 'jdsample.c', 'jdtrans.c', 'jerror.c', 'jfdctflt.c', 'jfdctfst.c', 'jfdctint.c', 'jidctflt.c',
			'jidctfst.c', 'jidctint.c', 'jmemmgr.c', 'jmemnobs.c', 'jquant1.c', 'jquant2.c', 'jutils.c',	'transupp.c' 
		}
		files(append_path(ghl_src .. '/image/jpeg/',jpeg_files))

		local png_files = {
			'png.c', 'pngerror.c', 'pngget.c', 'pngmem.c', 'pngpread.c', 'pngread.c', 'pngrio.c', 'pngrtran.c',
			'pngrutil.c', 'pngset.c', 'pngtrans.c', 'pngwio.c', 'pngwrite.c', 'pngwtran.c', 'pngwutil.c' 
		}
		files(append_path(ghl_src .. '/image/libpng/',png_files))

		files {
			sandbox_dir .. '/GHL/include/**.h',
			ghl_src .. '*.cpp',
			ghl_src .. '*.h',
			ghl_src .. 'image/*',
			ghl_src .. 'vfs/memory_stream.*',
			ghl_src .. 'sound/ghl_sound_decoder.h',
			ghl_src .. 'sound/ghl_sound_impl.h',
			ghl_src .. 'sound/sound_decoders.cpp',
			ghl_src .. 'sound/wav_decoder.*',
			ghl_src .. 'render/buffer_impl.*',
			ghl_src .. 'render/lucida_console_regular_8.*',
			ghl_src .. 'render/render_impl.*',
			ghl_src .. 'render/rendertarget_impl.*',
			ghl_src .. 'render/shader_impl.*',
			ghl_src .. 'render/texture_impl.*',
			ghl_src .. 'render/pfpl/*'
		}

		local use_openal = true
		local use_opengl = true

		local use_opengles = use_opengl and os.is('ios')

		if use_openal then
			files {
				ghl_src .. 'sound/openal/*'
			}
		end

		if use_opengl then
			files {
				ghl_src .. 'render/opengl/buffers_opengl.*',
				ghl_src .. 'render/opengl/glsl_generator.*',
				ghl_src .. 'render/opengl/render_opengl_api.h',
				ghl_src .. 'render/opengl/render_opengl_base.*',
				ghl_src .. 'render/opengl/rendertarget_opengl.*',
				ghl_src .. 'render/opengl/shader_glsl.*',
				ghl_src .. 'render/opengl/texture_opengl.*',
			}
			if use_opengles then
				files {
					ghl_src .. 'render/opengl/gles1_api.*',
					ghl_src .. 'render/opengl/gles2_api.*',
					ghl_src .. 'render/opengl/render_opengles.*',
				}
			else
				files {
					ghl_src .. 'render/opengl/dynamic/dynamic_gl.*',
					ghl_src .. 'render/opengl/render_opengl.*',
				}
			end
		end



		if os.is('macosx') then
			files { 
				ghl_src .. 'winlib/winlib_cocoa.*',
				ghl_src .. 'vfs/vfs_cocoa.*',
				ghl_src .. 'sound/cocoa/*'
			}
		elseif os.is('ios') then
			defines 'GHL_PLATFORM_IOS'
			files {
				ghl_src .. 'winlib/winlib_cocoatouch.*',
				ghl_src .. 'winlib/WinLibCocoaTouchContext.*',
				ghl_src .. 'winlib/WinLibCocoaTouchContext2.*',
				ghl_src .. 'vfs/vfs_cocoa.*',
				ghl_src .. 'sound/cocoa/*'
			}
		end

		includedirs {
			sandbox_dir .. '/GHL/include'
		}

		configuration "Debug"
   			targetsuffix "_d"
   			defines "GHL_DEBUG"

	project 'chipmunk'
		kind 'StaticLib'

		targetdir ('lib/' .. platform_dir)

		targetname ('chipmunk_' .. platform_dir)

		files {
			sandbox_dir .. '/chipmunk/include/**.h',
			sandbox_dir .. '/chipmunk/src/**.c'
		}

		includedirs {
			sandbox_dir .. '/chipmunk/include/chipmunk'
		}

		configuration "Debug"
   			targetsuffix "_d"

   	project 'lua'
   		kind 'StaticLib'

		targetdir ('lib/' .. platform_dir)

		targetname ('lua_' .. platform_dir)

		local lua_files = {
			'lapi.c', 'lauxlib.c', 'lbaselib.c', 'lbitlib.c', 'lcode.c', 'lcorolib.c', 'lctype.c',
			'ldblib.c', 'ldebug.c', 'ldo.c', 'ldump.c', 'lfunc.c', 'lgc.c', 'llex.c', 'lmathlib.c',
			'lmem.c', 'loadlib.c', 'lobject.c', 'lopcodes.c', 'lparser.c', 'lstate.c', 'lstring.c',
			'lstrlib.c', 'ltable.c', 'ltablib.c', 'ltm.c', 'lundump.c', 'lvm.c', 'lzio.c'
		}
		files(append_path(sandbox_dir .. '/lua/src/',lua_files))


		configuration "Debug"
   			targetsuffix "_d"
   	
   	project 'freetype'
   		kind 'StaticLib'
   		targetdir ('lib/' .. platform_dir)

		targetname ('freetype_' .. platform_dir)

		local freetype_files = {
			'autofit/afangles.c',
            'autofit/afcjk.c',
            'autofit/afdummy.c',
            'autofit/afglobal.c',
            'autofit/afhints.c',
            'autofit/afindic.c',
            'autofit/aflatin.c',
            'autofit/afloader.c',
            'autofit/afmodule.c',
            'autofit/afpic.c',
            'autofit/afwarp.c',

			'base/ftbase.c',
			'base/ftbitmap.c',
			'base/ftinit.c',
			'base/ftsystem.c',
			'base/ftwinfnt.c',

			'cff/cff.c',
			'raster/raster.c',
			'sfnt/sfnt.c',
			'smooth/smooth.c',
			'truetype/truetype.c',
			'type42/type42.c',
			'winfonts/winfnt.c'
		}
		files(append_path(sandbox_dir .. '/freetype/src/',freetype_files))

		defines 'FT2_BUILD_LIBRARY'
		defines 'DARWIN_NO_CARBON'

		includedirs {
			sandbox_dir .. '/include',
			sandbox_dir .. '/freetype/include'
		}

		configuration "Debug"
   			targetsuffix "_d"

	project 'MyGUI'

		kind 'StaticLib'

		targetdir ('lib/' .. platform_dir)

		targetname ('MyGUI_' .. platform_dir)

		files {
			sandbox_dir .. '/MyGUI/MyGUIEngine/**.h',
			sandbox_dir .. '/MyGUI/MyGUIEngine/**.cpp'
		}

		includedirs {
			sandbox_dir .. '/MyGUI/MyGUIEngine/include',
			sandbox_dir .. '/include',
			sandbox_dir .. '/freetype/include'
		}

		defines 'MYGUI_CONFIG_INCLUDE=<../../../sandbox/mygui/sb_mygui_config.h>'

		configuration "Debug"
   			targetsuffix "_d"

	project 'Sandbox'

		kind 'StaticLib'

		targetdir ('lib/' .. platform_dir)

		targetname ('Sandbox_' .. platform_dir)

		
		files {
			sandbox_dir .. '/include/**.h',
			sandbox_dir .. '/sandbox/**.h',
			sandbox_dir .. '/sandbox/**.cpp'
		}

		includedirs {
			sandbox_dir .. '/GHL/include',
			sandbox_dir .. '/include',
			sandbox_dir .. '/sandbox',
			sandbox_dir .. '/MyGUI/MyGUIEngine/include',
			sandbox_dir .. '/freetype/include'
		}

		defines 'MYGUI_CONFIG_INCLUDE=<mygui/sb_mygui_config.h>'

		configuration "Debug"
   			targetsuffix "_d"
   			defines 'SB_DEBUG'

	project( ProjectName )

		kind 'WindowedApp'

		targetdir ('bin/' .. platform_dir)

		libdirs { sandbox_dir .. '/lib' , sandbox_dir .. '/GHL/lib' }

		local libs_postfix = ''
		if os.is('macosx') then
			libs_postfix = '-OSX'
		end

		links { 'MyGUI', 
				'Sandbox', 
				'chipmunk', 
				'lua', 
				'freetype',
				'GHL'}

		if os.is('ios') then
			links {
				'Foundation.framework', 
				'QuartzCore.framework', 
				'AVFoundation.framework', 
				'UIKit.framework',  
				'OpenGLES.framework', 
				'OpenAL.framework',
				'AudioToolbox.framework',
				'CoreMotion.framework' }
		elseif os.is('macosx') then
			links { 
				'OpenGL.framework', 
				'OpenAL.framework',
				'Cocoa.framework',
				'AudioToolbox.framework' }
		end

		files {
			'src/**.h',
			'src/**.cpp'
		}

		resourcefolders {
			'data'
		}

		if os.is('macosx') then
			files { 
				'projects/osx/main.mm',
				'projects/osx/' .. ProjectName .. '_Mac-Info.plist'
			}
			prebuildcommands { "touch " .. path.getabsolute('data') }
		elseif os.is('ios') then
			files { 
				'projects/ios/main.mm',
				'projects/ios/'..ProjectName..'_iOS-Info.plist',
				'projects/ios/Default@2x.png',
				'projects/ios/Default-568h@2x.png',
			}
			prebuildcommands { "touch " .. path.getabsolute('data') }
		end

		includedirs {
			sandbox_dir .. '/chipmunk/include',
			sandbox_dir .. '/GHL/include',
			sandbox_dir .. '/include',
			sandbox_dir .. '/sandbox',
			sandbox_dir .. '/MyGUI/MyGUIEngine/include'
		}


		defines 'MYGUI_CONFIG_INCLUDE=<mygui/sb_mygui_config.h>'

		configuration "Debug"
   			defines 'SB_DEBUG'
	
