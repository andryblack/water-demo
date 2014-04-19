
function LoadTranslation( name )
    
    local data = {}
    local f,e = loadfile("texts/"..language.."/"..name..".lua","bt",data)
    if not f then error(e, 2) end
    f()
    
    local res = function( text )
        local str = data[text]
        if str == nil then 
            print (" error, unknown string_id : " .. text )
            error( e,2 ) 
        end
        return str
    end
    
    return res
end