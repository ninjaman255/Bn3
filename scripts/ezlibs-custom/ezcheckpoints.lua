local ezmemory = require('scripts/ezlibs-scripts/ezmemory')
local helpers = require('scripts/ezlibs-scripts/helpers')

local ezcheckpoints = {}

Net:on("object_interaction", function(event)
    local button = event.button
    if button ~= 0 then return end
    local player_id = event.player_id
    local object_id = event.object_id
    local area_id = Net.get_player_area(player_id)
    local checkpoint_object = Net.get_object_by_id(area_id, object_id)
    if checkpoint_object.type ~= "Checkpoint" then return end
    local required_item = checkpoint_object.custom_properties["Unlock Item"]
    local dialogue_type = checkpoint_object.custom_properties["Dialogue Type"]
    local password = checkpoint_object.custom_properties["Password"]
    local take_item = checkpoint_object.custom_properties["Take Item"] == "true"
    local dialogue_check = not dialogue_type or dialogue_type and dialogue_type ~= "None"
    if not required_item then return end
    local item_count = 0

    if string.lower(required_item) == "money" then
        item_count = Net.get_player_money(player_id)
    else
        item_count = ezmemory.count_player_item(player_id, required_item)
    end
    local necessary_count = 1
    local is_hide_forever = false
    if checkpoint_object.custom_properties["Once"] ~= nil then
        is_hide_forever = tostring(checkpoint_object.custom_properties["Once"])
    end
    if checkpoint_object.custom_properties["Required Keys"] ~= nil then
        necessary_count = tonumber(checkpoint_object.custom_properties["Required Keys"])
    end

    if password ~= nil then
        return async(function() --You needed to use this to create a promise, you can see how it does so in helpers.
            local checkpassword = await(Async.prompt_player(player_id))
            if checkpassword == password then
                Net.lock_player_input(player_id)
                local lockedGID = checkpoint_object.custom_properties["Locked GID"]
                if lockedGID == nil then
                    Net.set_object_custom_property(area_id, checkpoint_object.id, "Locked GID",
                        checkpoint_object.data.gid)
                    lockedGID = checkpoint_object.data.gid
                end
                if dialogue_check then
                    if checkpoint_object.custom_properties["Unlock Message"] ~= nil then
                        Net.message_player(player_id, checkpoint_object.custom_properties["Unlock Message"])
                    else
                        Net.message_player(player_id,
                            "You unlocked " ..
                            checkpoint_object.name ..
                            " with " .. checkpoint_object.custom_properties["Unlock Item"] .. "!")
                    end
                end
                local unlock_data = {
                    type = "tile",
                    gid = checkpoint_object.data.gid + checkpoint_object.custom_properties["Unlock GID"],
                    flipped_horizontally = checkpoint_object.data.flipped_horizontally,
                    flipped_vertically = checkpoint_object.data.flipped_vertically
                }
                Net.set_object_data(area_id, checkpoint_object.id, unlock_data)
                Async.sleep(tonumber(checkpoint_object.custom_properties["Disappear Cooldown"])).and_then(function()
                    if is_hide_forever == "true" then
                        ezmemory.hide_object_from_player(player_id, area_id, object_id) --Hide permanently if needed
                    else
                        ezmemory.hide_object_from_player_till_disconnect(player_id, area_id, object_id)
                    end --Otherwise hide it until disconnect
                    local relock_data = {
                        type = "tile",
                        gid = lockedGID,
                        flipped_horizontally = checkpoint_object.data.flipped_horizontally,
                        flipped_vertically = checkpoint_object.data.flipped_vertically
                    }
                    Net.set_object_data(area_id, checkpoint_object.id, relock_data)
                    Net.unlock_player_input(player_id)
                end)
            end
        end)
    elseif item_count >= necessary_count then
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
                Net.message_player(player_id,
                    "You unlocked " ..
                    checkpoint_object.name .. " with " .. checkpoint_object.custom_properties["Unlock Item"] .. "!")
            end
        end
        local unlock_data = {
            type = "tile",
            gid = checkpoint_object.data.gid + checkpoint_object.custom_properties["Unlock GID"],
            flipped_horizontally = checkpoint_object.data.flipped_horizontally,
            flipped_vertically = checkpoint_object.data.flipped_vertically
        }
        Net.set_object_data(area_id, checkpoint_object.id, unlock_data)
        Async.sleep(tonumber(checkpoint_object.custom_properties["Disappear Cooldown"])).and_then(function()
            if is_hide_forever == "true" then
                ezmemory.hide_object_from_player(player_id, area_id, object_id) --Hide permanently if needed
            else
                ezmemory.hide_object_from_player_till_disconnect(player_id, area_id, object_id)
            end --Otherwise hide it until disconnect
            local relock_data = {
                type = "tile",
                gid = lockedGID,
                flipped_horizontally = checkpoint_object.data.flipped_horizontally,
                flipped_vertically = checkpoint_object.data.flipped_vertically
            }
            Net.set_object_data(area_id, checkpoint_object.id, relock_data)
            if take_item then
                if required_item == "money" then
                    ezmemory.spend_player_money(player_id, necessary_count)
                else
                    ezmemory.remove_player_item(player_id, checkpoint_object.custom_properties["Unlock Item"],
                        necessary_count)
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
                    Net.message_player(player_id,
                        "You don't have enough " ..
                        checkpoint_object.custom_properties["Unlock Item"] ..
                        " to unlock the " .. checkpoint_object.name .. "...")
                else
                    Net.message_player(player_id,
                        "You don't enough " .. checkpoint_object.custom_properties["Unlock Item"] .. " to unlock this...")
                end
            end
        end
    else
        if dialogue_check then
            if checkpoint_object.custom_properties["Locked Message"] ~= nil then
                Net.message_player(player_id, checkpoint_object.custom_properties["Locked Message"])
            else
                if checkpoint_object.name ~= "" then
                    Net.message_player(player_id,
                        "You don't have the " ..
                        checkpoint_object.custom_properties["Unlock Item"] ..
                        " to unlock this " .. checkpoint_object.name .. "...")
                else
                    Net.message_player(player_id,
                        "You don't have the " .. checkpoint_object.custom_properties["Unlock Item"] .. " for this...")
                end
            end
        end
    end
end)

return ezcheckpoints
