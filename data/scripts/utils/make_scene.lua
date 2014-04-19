
function setProperties( obj, props )
    -- print ( "Object : " .. props )
    for i,v in pairs(props) do 
        -- print ( "Set property " .. i  )
        obj[i]=v
    end
    return obj
end

function MakeTranslateContainer( tr )
    local cont = Sandbox.Container()
    local mod = Sandbox.TransformModificator()
    cont:AddModificator(mod)
    if tr then mod.Translate = tr end
    return {container = cont, transform = mod}
end

function MakeColorContainer( clr )
    local cont = Sandbox.Container()
    local mod = Sandbox.ColorModificator()
    cont:AddModificator(mod)
    if clr then mod.Color = clr end
    return {container = cont, color = mod}
end


function makeScene( container, descr_ )
    local descr = descr_ or container 
    local cnt = container 
    if not descr_ then
        cnt = Sandbox.Container()
    end
    if not cnt then
        print( "container error : " .. cnt )
        error()
    end
    for i,v in ipairs( descr ) do
        local obj_mt = v[1]
        if not obj_mt then
            print( "unknown object : " .. v[1] )
            error()
        end 
        local obj = obj_mt()
        if not obj then
            print( "failed to create object : " .. v[1] )
            error()
        end

        local args = v[2] or {}
        setProperties(obj,args)
        
        if not cnt then
            print( "container error : " .. cnt )
            error()
        end
        
        cnt:AddObject( obj )
        if v.childs then
            MakeScene( obj , v.childs)
        end
        local func = v[3]
        if func ~= nil then
            func( obj )
        end
    end
    return cnt
end