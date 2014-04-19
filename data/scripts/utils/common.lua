

function new( object )
	local obj = object[1]
	for k,v in pairs(object) do
		if not (k==1) then
			obj[k]=v
		end
	end
	return obj
end

function pause( timeout )
	local time = 0
	while time < timeout do
		time = time + coroutine.yield()
	end
end

