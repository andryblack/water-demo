
require ("utils/load_table")



function loadImage( config , dir, dname)
    --print( "loadImege",config,dir,dname)

    local file = config.file
    if not file then file = dname end
    local fname = file
    if dir then fname = dir .. "/" .. fname end
    local img = nil
    if config.rect then
        local tex = application.resources:GetTexture( fname , true )
        if not tex then error( "not found texture "..fname ) end
        local r = config.rect
        img = Sandbox.Image( tex, r[1], r[2], r[3], r[4] )
    else
        img = application.resources:GetImage( fname , true )
        if not img then error( "not found image "..fname ) end
    end
    if config.hotspot then
        img.Hotspot = Sandbox.Vector2f( config.hotspot[1],config.hotspot[2])
    end
    if config.smooth then
        img.Texture.Filtered = true
    end
    if config.size then
        img:SetSize( config.size[1],config.size[2] )
    end
    return img
end

function loadImagesFormat( format, from, to , options )
    local imgs = {}
    if not options then options = {} end
    for i = from,to do
        options.file = string.format(format,i)
        imgs[#imgs+1] = loadImage( options )
    end
    return imgs
end 

local function make_image( config, textures , src,name)
    assert(config.texture,'not found required attribute "texture" in ' .. src .. ' for image ' .. name)
    local tex = textures[config.texture]
    assert(tex, 'failed load ' .. src .. ' not found texture ' .. config.texture .. ' for image ' .. name)
    local rect = config.rect or {0,0,tex.Width,tex.Height}
    local img = Sandbox.Image(tex,rect[1],rect[2],rect[3],rect[4])
    print('create image ' .. name .. '{',rect[1],rect[2],rect[3],rect[4],'}')
    if config.hotspot then
        img.Hotspot = Sandbox.Vector2f( config.hotspot[1],config.hotspot[2])
    end
    if config.size then
        img:SetSize( config.size[1],config.size[2] )
    end
    return img
end 

function loadImages( dir, file )
    local mt = {}
    function mt.load_group( name )
        return loadImages(dir .. '/' .. name, 'images.lua' )
    end
    local src = dir.."/"..file
    local t = loadTable(src,{__index=mt})
    if t then
        local r = {}
        local textures = t.textures
        if textures then
            local loaded = {}
            for k,v in pairs(textures) do
                local tex = application.resources:GetTexture( dir .. '/' .. k .. '.' .. v.type, not v.premultiplied )
                assert(tex,'failed load texture ' .. k .. ' from ' .. src)
                if v.smooth then
                    tex.Filtered = true
                end
                if v.tiled then
                    tex.Tiled = true
                end
                loaded[k]=tex
            end
            r.textures = loaded
        end
        local images = t.images 
        if images then
            local loaded = {}
            for k,v in pairs(images) do
                loaded[k]=make_image(v,r.textures,src,k)
            end
            for k,v in pairs(loaded) do
                r[k] = v
            end
        end
        -- copy all other
        for k,v in pairs(t) do
            if k~='textures' and k~='images' then
                r[k]=v
            end
        end
        return r
    else
        error('failed load ' .. src)
        return nil
    end
end

