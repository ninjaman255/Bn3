local Direction = require("scripts/ezlibs-scripts/direction")

local player_elements = {}
local dive_locations = {}

Net:on("player_avatar_change", function(event)
    -- health, max_health, and element will be updated on the player before this function executes
    -- { player_id: string, texture_path: string, animation_path: string, name: string, element: string, max_health: number, prevent_default: Function }
    print(event.player_id, event)
    player_elements[event.player_id] = event.element
    if event.element ~= "AQUA" and dive_locations[event.player_id] then
        local area = Net.get_player_area(event.player_id)
        Net.transfer_player(event.player_id, area, true, dive_locations[event.player_id].x, dive_locations[event.player_id].y, dive_locations[event.player_id].z)
    end
end)

Net:on("tile_interaction", function(event)
    -- { player_id: string }
    local area = Net.get_player_area(event.player_id)
    local properties = Net.get_area_custom_properties(area)
    if properties["Swimming Allowed"] == "true" then
        if player_elements[event.player_id] == "AQUA" then
            try_jump(event,2)
        end
    end
end)

Net:on("player_area_transfer", function(event)
    dive_locations[event.player_id] = nil
end)

Net:on("player_disconnect", function(event)
    dive_locations[event.player_id] = nil
end)

function try_jump(event,jump_distance)
    return async(function()
        local area = Net.get_player_area(event.player_id)
        local player_direction = Net.get_player_direction(event.player_id)
        local direction_vector = Direction.to_vector(player_direction)
        local player_pos = Net.get_player_position(event.player_id)
        local jump_distance_x = (direction_vector.x*jump_distance)
        local jump_distance_y = (direction_vector.y*jump_distance)
        local new_x = player_pos.x+jump_distance_x
        local new_y = player_pos.y+jump_distance_y
        local tile_ahead = Net.get_tile(area, new_x, new_y, event.z)
        local tile_below = Net.get_tile(area, new_x, new_y, event.z - 1)
        local tile_above = Net.get_tile(area, new_x, new_y, event.z + 1)
        local jumping_up = false
        local jumping_down = false
        if tile_ahead then
            if tile_below then
                jumping_down = tile_ahead.gid == 0 and tile_below.gid ~= 0
            end
            if tile_above then
                jumping_up = tile_ahead.gid == 0 and tile_above.gid ~= 0 and jumping_down == false
            end
        end
        if not (jumping_up or jumping_down) then
            return
        end
        local jump_height = 2
        if jumping_down then
            jump_height = 1
        end
        local jump_time = 0.5
        local keyframes = { {
            properties = { 
                {
                    property = "Z",
                    ease = "Out",
                    value = player_pos.z
                },
                {
                    property = "X",
                    ease = "Linear",
                    value = player_pos.x
                },
                {
                    property = "Y",
                    ease = "Linear",
                    value = player_pos.y
                }
            },
            duration = 0.0
        } }
        keyframes[#keyframes + 1] = {
            properties = { 
                {
                    property = "Z",
                    ease = "Out",
                    value = player_pos.z+jump_height
                },
                {
                    property = "X",
                    ease = "Linear",
                    value = player_pos.x+(jump_distance_x/2)
                },
                {
                    property = "Y",
                    ease = "Linear",
                    value = player_pos.y+(jump_distance_y/2)
                }
            },
            duration = jump_time/2
        }
        local new_z = player_pos.z-1
        if jumping_down then
            new_z = player_pos.z-1
        elseif jumping_up then
            new_z = player_pos.z+1
        end
        Net.provide_asset_for_player(event.player_id, "/server/assets/dive.png")
        Net.provide_asset_for_player(event.player_id, "/server/assets/dive.animation")
        keyframes[#keyframes + 1] = {
            properties = { 
                {
                    property = "Z",
                    ease = "In",
                    value = new_z
                },
                {
                    property = "X",
                    ease = "Linear",
                    value = player_pos.x+jump_distance_x
                },
                {
                    property = "Y",
                    ease = "Linear",
                    value = player_pos.y+jump_distance_y
                }
            },
            duration = jump_time/2
        }
        Net.animate_player_properties(event.player_id, keyframes)
        if jumping_down then
            dive_locations[event.player_id] = {x=player_pos.x,y=player_pos.y,z=player_pos.z}
            --animate splash falling in
            await(Async.sleep(jump_time))
            local splash_bot_id = Net.create_bot({
                texture_path = "/server/assets/dive.png",
                animation_path = "/server/assets/dive.animation",
                area_id = area,
                x = new_x,
                y = new_y,
                z = player_pos.z,
                warp_in= false
            })
            Net.play_sound_for_player(event.player_id,"/server/assets/dive_down.ogg")
            Net.animate_bot(splash_bot_id, "DOWN_SPLASH", false)
            await(Async.sleep(0.53))
            Net.remove_bot(splash_bot_id,false)
        end
        if jumping_up then
            dive_locations[event.player_id] = nil
            --animate splash jumping out
            local splash_bot_id = Net.create_bot({
                texture_path = "/server/assets/dive.png",
                animation_path = "/server/assets/dive.animation",
                area_id = area,
                x = player_pos.x,
                y = player_pos.y,
                z = player_pos.z+1,
                warp_in= false
            })
            Net.animate_bot(splash_bot_id, "UP_SPLASH", false)
            Net.play_sound_for_player(event.player_id,"/server/assets/dive_up.ogg")
            await(Async.sleep(jump_time))
            Net.remove_bot(splash_bot_id,false)
        end
    end)
end


return {}
