require( "utils/load_image" )
require( "utils/load_table" )

local sb = Sandbox

function loadFont( path , dir, smooth, font )
	if dir then
		path = dir .. "/" .. path
	end
    local data = loadTable(path .. ".lua")
    local tex = application.resources:GetTexture(path)
    tex.Filtered = smooth
    local hsy_ = 0
    local fnt = font or sb.BitmapFont()
    fnt:Reserve(#data.chars)
    fnt:SetHeight(data.height)
    if data.description then
    	fnt:SetSize(data.description.size)
    else
    	fnt:SetSize(data.height)
    end
    if data.metrics then
    	fnt:SetBaseline(data.metrics.height-data.metrics.ascender)
    	if data.metrics.x_height then
    		fnt:SetXHeight(data.metrics.x_height)
    	end
    else
    	fnt:SetBaseline(0)
    end
	for i,v in ipairs(data.chars) do 
		local img = sb.Image(tex,v.x,v.y,v.w,v.h)
		local hsx = 0
		local hsy = hsy_
		if v.ox then hsx = hsx - v.ox end
		if v.oy then hsy = hsy + v.oy end
		img.Hotspot = sb.Vector2f( hsx,hsy )
		local asc = v.width
		--v.fwidth or ( ( table.monospace or  ) + table.extra_x )
		--local offset = vec( 0,0)
		fnt:AddGlypth( img, v.code or v.char , asc  )
	end
	if table.kernings then
		for i,v in ipairs(data.kernings) do
			fnt:AddKerningPair(v.from,v.to,v.offset)
		end
	end
    return fnt
end