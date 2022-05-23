local ezmemory = require('scripts/ezlibs-scripts/ezmemory')
local helpers = require('scripts/ezlibs-scripts/helpers')

local ezcheckpoints = {}
local checkpoints_hidden_till_rejoin_for_player = {}

function ezcheckpoints.handle_player_join(player_id)
    checkpoints_hidden_till_rejoin_for_player[player_id] = {}
    --Pretend to do a transfer too, to hide data in entry map
    ezcheckpoints.handle_player_transfer(player_id)
end

function ezcheckpoints.handle_player_disconnect(player_id)
    checkpoints_hidden_till_rejoin_for_player[player_id] = {}
end

function ezcheckpoints.handle_player_transfer(player_id)
    local area_id = Net.get_player_area(player_id)
    if checkpoints_hidden_till_rejoin_for_player[player_id][area_id] then
        print("area id is "..area_id)
        for object_id, is_hidden in pairs(checkpoints_hidden_till_rejoin_for_player[player_id][area_id]) do
            Net.exclude_object_for_player(player_id, object_id)
        end
    else
        checkpoints_hidden_till_rejoin_for_player[player_id][area_id] = {}
    end
end

function ezcheckpoints.handle_object_interaction(player_id, object_id, button)
    if button ~= 0 then return end
    local area_id = Net.get_player_area(player_id)
    local checkpoint_object = Net.get_object_by_id(area_id, object_id)
    if checkpoint_object.type ~= "Checkpoint" then return end
    local required_item = checkpoint_object.custom_properties["Unlock Item"]
    local dialogue_type = checkpoint_object.custom_properties["Dialogue Type"]
    local dialogue_check = not dialogue_type or dialogue_type and dialogue_type ~= "None"
    if not required_item then return end
    local item_count = 0
    if string.lower(required_item) == "money" then
        item_count = Net.get_player_money(player_id)
    else
        item_count = ezmemory.count_player_item(player_id, required_item)
    end
	local necessary_count = 1
    local is_hide_forever = checkpoint_object.custom_properties["Once"] == "true"
    if checkpoint_object.custom_properties["Required Keys"] ~= nil then
        necessary_count = tonumber(checkpoint_object.custom_properties["Required Keys"])
    end
    if item_count >= necessary_count then
        Net.lock_player_input(player_id)
        local lockedGID = checkpoint_object.custom_properties["Locked GID"]
        if lockedGID == nil then
            Net.set_object_custom_property(area_id, checkpoint_object.id, "Locked GID", checkpoint_object.data.gid)
            lockedGID = checkpoint_object.data.gid
        end
        if dialogue_check then
            if checkpoint_object.custom_properties["Unlock Message"] ~= nil then
                Net.message_player(player_id, checkpoint_object.custom_properties["Unlock Message"])
            else
                Net.message_player(player_id, "You unlocked "..checkpoint_object.name.." with "..checkpoint_object.custom_properties["Unlock Item"].."!")
            end
        end
        local unlock_data = {
            type = "tile",
            gid=checkpoint_object.data.gid + checkpoint_object.custom_properties["Unlock GID"],
            flipped_horizontally=checkpoint_object.data.flipped_horizontally,
            flipped_vertically=checkpoint_object.data.flipped_vertically
        }
        Net.set_object_data(area_id, checkpoint_object.id, unlock_data)
        Async.sleep(tonumber(checkpoint_object.custom_properties["Disappear Cooldown"])).and_then(function()
            if is_hide_forever then
                local safe_secret = helpers.get_safe_player_secret(player_id)
                local player_area_memory = ezmemory.get_player_area_memory(safe_secret,area_id)
                player_area_memory.hidden_objects[tostring(checkpoint_object.id)] = true
                ezmemory.save_player_memory(safe_secret)
            end
            checkpoints_hidden_till_rejoin_for_player[player_id][area_id][tostring(checkpoint_object.id)] = true
            Net.exclude_object_for_player(player_id, checkpoint_object.id)
            local relock_data = {
                type = "tile",
                gid=lockedGID,
                flipped_horizontally=checkpoint_object.data.flipped_horizontally,
                flipped_vertically=checkpoint_object.data.flipped_vertically
            }
            Net.set_object_data(area_id, checkpoint_object.id, relock_data)
            if checkpoint_object.custom_properties["Take Item"] == "true" then
                if required_item == "money" then
                    ezmemory.spend_player_money(player_id, necessary_count)
                else
                    ezmemory.remove_player_item(player_id, checkpoint_object.custom_properties["Unlock Item"], necessary_count)
                end
            end
            Net.unlock_player_input(player_id)
        end)
    elseif item_count > 1 and item_count < necessary_count then
        if dialogue_check then
            if checkpoint_object.custom_properties["Locked Message"] ~= nil then
                Net.message_player(player_id, checkpoint_object.custom_properties["Locked Message"])
            else
                if checkpoint_object.name ~= "" then
                    Net.message_player(player_id, "You don't have enough "..checkpoint_object.custom_properties["Unlock Item"].." to unlock the "..checkpoint_object.name.."...")
                else
                    Net.message_player(player_id, "You don't enough "..checkpoint_object.custom_properties["Unlock Item"].." to unlock this...")
                end
            end
        end
    else
        if dialogue_check then
            if checkpoint_object.custom_properties["Locked Message"] ~= nil then
                Net.message_player(player_id, checkpoint_object.custom_properties["Locked Message"])
            else
                if checkpoint_object.name ~= "" then
                    Net.message_player(player_id, "You don't have the "..checkpoint_object.custom_properties["Unlock Item"].." to unlock this "..checkpoint_object.name.."...")
                else
                    Net.message_player(player_id, "You don't have the "..checkpoint_object.custom_properties["Unlock Item"].." for this...")
                end
            end
        end
    end
end

return ezcheckpoints