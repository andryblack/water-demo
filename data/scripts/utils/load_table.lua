function loadTable( file , mt)
	local data = {}
    if mt then
        setmetatable(data,mt)
    end
    local f,e = loadfile(file,"bt",data)
    if not f then error(e, 2) end
    if type(f) ~= "function" then
    	error("expected function, got " .. type(f) .. "(" .. tostring(f) .. ")" ,2)
    end
    local d = f()
    if mt then
        setmetatable(data,nil)
    end
    if d ~= nil then
    	for k,v in pairs(d) do
    		data[k]=v
    	end
    end
    return data
end


