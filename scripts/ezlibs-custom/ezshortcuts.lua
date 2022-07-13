-- lib by TheMaverickProgrammer aka James King
-- 7/12/2022
-- adds shortcut spawn points (checkpoints) to player memory and optionally shows the marker for that player only

local helpers = require('scripts/ezlibs-scripts/helpers')
local ezmemory = require('scripts/ezlibs-scripts/ezmemory')

local ezshortcuts = {}
ezshortcuts._check_points = {} -- indexed by player ID. one checkpoint per server.
local EZSHORTCUTS = "ezshortcuts"

local texture_path = "/server/assets/"..EZSHORTCUTS.."/checkpoint.png"
local animation_path = "/server/assets/"..EZSHORTCUTS.."/checkpoint.animation"

local function printd(msg)
    print("["..EZSHORTCUTS.."] "..msg)
end

local function show_checkpoint_for_player_only(player_id, entry)
    entry.checkpoint_bot_id = Net.create_bot({
        area_id=entry.area_id,
        warp_in=false,
        texture_path=texture_path,
        animation_path=animation_path,
        animation="IDLE_DL",
        x=entry.x,
        y=entry.y,
        z=entry.z,
        direction="Down Left",
        solid=false
    })

    -- hide for every other player except this one
    for i, other_player_id in pairs(Net.list_players(entry.area_id)) do
        if other_player_id ~= player_id then
            Net.exclude_actor_for_player(other_player_id, entry.checkpoint_bot_id)
        end
    end
end

local function hide_other_checkpoint_bots(player_id)
    -- hide the other checkpoint bots
    for i, entry in pairs(ezshortcuts._check_points) do
        if entry.checkpoint_bot_id ~= nil then
            Net.exclude_actor_for_player(player_id, entry.checkpoint_bot_id)
        end
    end
end

function ezshortcuts.create_checkpoint(player_id,x,y,z,show_checkpoint)
    local area_id = Net.get_player_area(player_id)
    local entry = ezshortcuts._check_points[player_id]

    if entry ~= nil and entry.checkpoint_bot_id ~= nil then
        Net.remove_bot(entry.checkpoint_bot_id)
    end

    ezshortcuts._check_points[player_id] = {x=x, y=y, z=z,area_id=area_id,show_checkpoint=show_checkpoint}
    entry = ezshortcuts._check_points[player_id]

    if show_checkpoint then
        show_checkpoint_for_player_only(player_id, entry)
    end

    -- persist so when the player leaves the server they have a place to return
    local safe_secret = helpers.get_safe_player_secret(player_id)
    local player_memory = ezmemory.get_player_memory(safe_secret)
    if not player_memory[EZSHORTCUTS] then
        player_memory[EZSHORTCUTS] = {}
    end
    player_memory[EZSHORTCUTS] = entry
    ezmemory.save_player_memory(safe_secret)
end

function ezshortcuts.remove_checkpoint(player_id)
    local entry = ezshortcuts._check_points[player_id]

    if entry ~= nil and entry.checkpoint_bot_id ~= nil then
        Net.remove_bot(entry.checkpoint_bot_id)
    end

    ezshortcuts._check_points[player_id] = nil

    -- remove from persistent memory
    local safe_secret = helpers.get_safe_player_secret(player_id)
    local player_memory = ezmemory.get_player_memory(safe_secret)
    if not player_memory[EZSHORTCUTS] then
        player_memory[EZSHORTCUTS] = {}
    end
    player_memory[EZSHORTCUTS] = nil
    ezmemory.save_player_memory(safe_secret)

end

function ezshortcuts.handle_player_connect(player_id)
    hide_other_checkpoint_bots(player_id)

    local entry = ezshortcuts._check_points[player_id]

    if entry == nil then
        local safe_secret = helpers.get_safe_player_secret(player_id)
        local player_memory = ezmemory.get_player_memory(safe_secret)
        local saved_checkpoint = player_memory[EZSHORTCUTS]
        if saved_checkpoint then
            printd("Caching checkpoint for player "..player_id)
            ezshortcuts._check_points[player_id] = {
                x=saved_checkpoint.x,
                y=saved_checkpoint.y,
                z=saved_checkpoint.z,
                area_id=saved_checkpoint.area_id,
                show_checkpoint=saved_checkpoint.show_checkpoint
            }

            entry = ezshortcuts._check_points[player_id]
        end
    end

    if entry ~= nil then
        printd("Restoring player "..player_id.." at checkpoint ("..entry.x..","..entry.y..","..entry.z..") in area "..entry.area_id..".")
        Net.transfer_player(player_id, entry.area_id, false, entry.x, entry.y, entry.z, "Down")

        -- show checkpoint marker if user wants one
        if entry.show_checkpoint then
            show_checkpoint_for_player_only(player_id, entry)
        end
    end
end

Net:on("player_connect", function(event)
    -- { player_id: string }
    ezshortcuts.handle_player_connect(event.player_id)
end)

printd("Loaded")
return ezshortcuts