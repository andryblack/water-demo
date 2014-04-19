
local ui = {}

ui.scene_factory = function (  )
	return Sandbox.Container()
end

function ui.setSceneRootFactory(f)
	ui.scene_factory = f
end


function ui.loadLayout(name,delegate)
	local widgets = MyGUI.LayoutManager.getInstancePtr():loadLayout(name)
	if not widgets then 
		return nil
	end
	
	if #widgets ~= 1 then
		error('layout must be constain one root widget')
	end

	local  w = widgets[1]

	for k,v in pairs(delegate) do
		local w_name, event_name = string.match(k,'on_([%w_]+)_(%w+)')
		if w_name and event_name then
			local bw = w:findWidget(w_name)
			if not bw then
				error('not found widget ' .. w_name)
			end
			print('bind ' .. w_name .. '#' .. event_name)
			local functions = {}
			functions.MouseButtonClick = function ( w )
				v(w)
			end
	
			local func = functions[event_name] or function( w, x, y, btn)
				--print('event')
				if btn == MyGUI.MouseButton.Left then
					v(w)
				end
			end 
			bw['event'..event_name](bw,func)
		else
			print('unknown delegate ' .. k,w_name,event_name)
		end
	end

	w.size = MyGUI.IntSize(application.size.width,application.size.height)

	return w
end

local stored_bg = nil

function ui.loadScreen( description )
	local bg = description.bg
	local root_scene = ui.scene_factory()
	if bg then
		local bg_obj = stored_bg or Sandbox.Background()
		if not bg_obj:Load(bg,application.resources) then
			error('failed load Background ' .. bg)
		end
		stored_bg = bg_obj
		root_scene:AddObject(bg_obj)
	else
		if stored_bg then
			stored_bg = nil
		end
	end

	local res = {}

	local layout = nil
	if description.layout then
		layout = ui.loadLayout(description.layout.name,description.layout.delegate)
		res.destroy_layout = description.layout.destroy
		if description.layout.show then
			description.layout.show(layout)
		end
	end

	

	res.root_scene = root_scene
	res.layout = layout
	

	application.scene:Clear()
	application.scene:AddObject(root_scene)

	if ui.current_screen then
		local crnt = ui.current_screen 
		if crnt.layout then
			if crnt.destroy_layout then
				crnt.destroy_layout(crnt.layout)
			else
				MyGUI.WidgetManager.getInstancePtr():destroyWidget(crnt.layout)
			end
		end
	end
	ui.current_screen = res

	res.findLayoutItem = function( screen, name )
		if not screen.layout then
			return nil
		end
		return screen.layout:findWidget(name)
	end

	return res
end

return ui