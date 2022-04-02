local eznpcs = require('scripts/ezlibs-scripts/eznpcs/eznpcs')
local ezmemory = require('scripts/ezlibs-scripts/ezmemory')
local ezmystery = require('scripts/ezlibs-scripts/ezmystery')
local ezweather = require('scripts/ezlibs-scripts/ezweather')
local ezwarps = require('scripts/ezlibs-scripts/ezwarps/main')
local ezencounters = require('scripts/ezlibs-scripts/ezencounters/main')
local helpers = require('scripts/ezlibs-scripts/helpers')

local EZCube = {
    name="Cube Interact",
    action=function (npc,player_id,dialogue,relay_object)
		if not relay_object then return end
		local item_count = ezmemory.count_player_item(player_id, relay_object.custom_properties["Unlock Item"])
		local necessary_count = 1
		if relay_object.custom_properties["Required Keys"] ~= nil then
			necessary_count = tonumber(relay_object.custom_properties["Required Keys"])
		end
		print(relay_object.custom_properties["Unlock Item"])
		if item_count >= necessary_count then
			local lockedGID = relay_object.custom_properties["Locked GID"]
			local area_id = Net.get_player_area(player_id)
			if lockedGID == nil then
				Net.set_object_custom_property(area_id, relay_object.id, "Locked GID", relay_object.data.gid)
				lockedGID = relay_object.data.gid
			end
			if relay_object.custom_properties["Unlock Message"] ~= nil then
				Net.message_player(player_id, relay_object.custom_properties["Unlock Message"])
			else
				Net.message_player(player_id, "You unlocked "..relay_object.name.." with "..relay_object.custom_properties["Unlock Item"].."!")
			end
			local unlock_data = {
				type = "tile",
				gid=relay_object.data.gid + relay_object.custom_properties["Unlock GID"],
				flipped_horizontally=relay_object.data.flipped_horizontally,
				flipped_vertically=relay_object.data.flipped_vertically
			}
			Net.set_object_data(area_id, relay_object.id, unlock_data)
			Async.sleep(tonumber(relay_object.custom_properties["Disappear Cooldown"])).and_then(function()
				local safe_secret = helpers.get_safe_player_secret(player_id)
				Net.exclude_object_for_player(player_id, relay_object.id)
				local player_area_memory = ezmemory.get_player_area_memory(safe_secret,area_id)
				player_area_memory.hidden_objects[tostring(relay_object.id)] = true
				ezmemory.save_player_memory(safe_secret)
				local relock_data = {
					type = "tile",
					gid=lockedGID,
					flipped_horizontally=relay_object.data.flipped_horizontally,
					flipped_vertically=relay_object.data.flipped_vertically
				}
				Net.set_object_data(area_id, relay_object.id, relock_data)
				if relay_object.custom_properties["Take Item"] == "true" then
					ezmemory.remove_player_item(player_id, relay_object.custom_properties["Unlock Item"], necessary_count)
				end
			end)
		elseif item_count > 1 and item_count < necessary_count then
			if relay_object.custom_properties["Locked Message"] ~= nil then
				Net.message_player(player_id, relay_object.custom_properties["Locked Message"])
			else
				if relay_object.name ~= "" then
					Net.message_player(player_id, "You don't have enough "..relay_object.custom_properties["Unlock Item"].." to unlock the "..relay_object.name.."...")
				else
					Net.message_player(player_id, "You don't enough "..relay_object.custom_properties["Unlock Item"].." to unlock this...")
				end
			end
		else
			if relay_object.custom_properties["Locked Message"] ~= nil then
				Net.message_player(player_id, relay_object.custom_properties["Locked Message"])
			else
				if relay_object.name ~= "" then
					Net.message_player(player_id, "You don't have the "..relay_object.custom_properties["Unlock Item"].." to unlock this "..relay_object.name.."...")
				else
					Net.message_player(player_id, "You don't have the "..relay_object.custom_properties["Unlock Item"].." for this...")
				end
			end
		end
		local next_dialogue_options = {
			wait_for_response=false,
			id=nil
		}
		return next_dialogue_options
    end
}
eznpcs.add_event(EZCube)