local dump = require('scripts/dump')

local debug = false -- Set to true if you want some debug prints.

function debugPrint(message)
    if debug then
        print(message)
    end
end

-- This script takes care of warping the player when he gets into contact with a warp
local warps = {};
local in_warp = {}

function handle_player_disconnect(player_id)
  -- cleanup
  in_warp[player_id] = nil
end

function handle_player_move(player_id, x, y, z)
    debugPrint('new check')
	local area_id = Net.get_player_area(player_id)
	local warpsForArea = warps[area_id]
	local didCollideWithWarp = false
	
	if warpsForArea == nil then
		return
	end
	
	for i, warp in pairs(warpsForArea) do
		if math.floor(x) == math.floor(warp.x) and math.floor(y) == math.floor(warp.y) and math.floor(z) == math.floor(warp.z) then
            debugPrint('collided with ' .. dump(warp))
			if in_warp[player_id] == true then
                debugPrint(player_id .. ' is still in warp')
				return
			end
			
			didCollideWithWarp = true

            local targetWarp = warps[warp.warp_to][warp.warp_name]
            debugPrint('target ' .. dump(targetWarp))

            Net.transfer_player(player_id, warp.warp_to, true, targetWarp.x, targetWarp.y, targetWarp.z, targetWarp.direction)				
			in_warp[player_id] = true	
			break		
		end
	end
	
	-- Prevent warping multiple times
	if didCollideWithWarp == false and in_warp[player_id] then
		in_warp[player_id] = false
        debugPrint('set in_warp to false ' .. player_id)
	end
end

local areas = Net.list_areas()

local warpsForArea
for _, area_id in ipairs(areas) do
	
	print('Loading warps for ' .. area_id)
	local object_ids = Net.list_objects(area_id)
    debugPrint(dump(Net.list_tilesets(area_id)))

    -- If it's never finding your warps, check the list_tilesets.
	local tileset = Net.get_tileset(area_id, "/server/assets/tiles/warp.tsx")
	
	if tileset ~= nil then
		local warp_gid = tileset.first_gid + 1
		
		for _, object_id in ipairs(object_ids) do
			local object = Net.get_object_by_id(area_id, object_id)
			-- Ignore Position Warps as these are handled client-side
			if object.data.gid == warp_gid and object.type ~= 'Position Warp' then
				print('Found warp for ' .. area_id .. ' name ' .. object.name)
                debugPrint(dump(object))
				if warps[area_id] == nil then			
					warpsForArea = {}
					warpsForArea[object.name] = {
					x = object.x + object.height / 2,
					y = object.y + object.height / 2, 
					z = object.z,
					name = object.name,
                    warp_to = object.custom_properties.warp_to or area_id,
                    warp_name = object.custom_properties.warp_name,
                    direction = object.custom_properties.direction
				  }
				  warps[area_id] = warpsForArea
				else
					warpsForArea = warps[area_id]
					warpsForArea[object.name] = {
						x = object.x + object.height / 2,
						y = object.y + object.height / 2,
						z = object.z,
						name = object.name,
                        warp_to = object.custom_properties.warp_to or area_id,
                        warp_name = object.custom_properties.warp_name,
                        direction = object.custom_properties.direction
					  }
					warps[area_id] = warpsForArea
				end
			end
		end
	else 
		print('[Warn] warp.lua - ' .. area_id .. ' doesn\'t include any warps. Skipping ...')
	end
end

debugPrint('all warps list: ' .. dump(warps))

