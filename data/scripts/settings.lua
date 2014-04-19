
print( "Hello from lua" )
print( "settings.width " , settings.width )
print( "settings.height " , settings.height )
print( "settings.fullscreen " , settings.fullscreen )

width = math.max( settings.width, settings.height)
height = math.min( settings.width, settings.height )

settings.width = width
settings.height = height

if platform.os == "iOS" then
    settings.fullscreen = true
else
	
    settings.width = 1024
    settings.height = 768
    settings.fullscreen = false
end

language = "ru"