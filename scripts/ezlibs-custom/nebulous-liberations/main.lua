-- random may be called in required scripts, need to set the seed
math.randomseed(os.time())

local LibPlugin = {}

local Player = require("scripts/ezlibs-custom/nebulous-liberations/player")
local Instance = require("scripts/ezlibs-custom/nebulous-liberations/liberations/instance")
local Parties = require("scripts/libs/parties")

local waiting_area_map = {}

local respawn_table = {}

local gate_to_area_map = {}

local instances = {}
local players = {}

local function find_available_instance_id(start_id)
  local number = 1
  local instance_id = start_id

  while instances[instance_id] do
    number = number + 1
    instance_id = start_id .. number
  end

  return instance_id
end

local function transfer_players_to_new_instance(base_area, player_ids)
  local instance_id = find_available_instance_id(player_ids[1])
  local instance_players = {}

  for _, player_id in ipairs(player_ids) do
    instance_players[#instance_players+1] = players[player_id]
  end

  local instance = Instance:new(base_area, instance_id, instance_players)
  local spawn = instance:get_spawn_position()
  for _, player in ipairs(instance_players) do
    Net.transfer_player(player.id, instance_id, true, spawn.x, spawn.y, spawn.z)
    spawn = instance:get_next_spawn_from_object(spawn.id)
    player.activity = instance
  end

  instance:begin()

  instances[instance_id] = instance
end

function LibPlugin.start_game_for_player(player_id, liberation_id)
  local party = Parties.find(player_id)
  if party == nil then
    transfer_players_to_new_instance(liberation_id, { player_id })
  else
    transfer_players_to_new_instance(liberation_id, party.members)
  end
end

local function detect_door_interaction(player_id, object_id, button)
	if button ~= 0 then return end
	local missionArea = gate_to_area_map[object_id]
	local player = players[player_id]
	if missionArea ~= nil then
		player:question_with_mug("Start mission?").and_then(function(response)
		  if response == 1 then
			  LibPlugin.start_game_for_player(player_id, missionArea)
		  end
	  end)
	end
end

local function leave_party(player)
  local party = Parties.find(player.id)

  if not party then
    return
  end

  Parties.leave(player.id)

  -- let everyone know you left
  local name = Net.get_player_name(player.id)

  for _, member_id in ipairs(party.members) do
    local member = players[member_id]
    member:message(name .. " has left your party.")
  end

  if #party.members == 1 then
    local last_member = players[party.members[1]]
    last_member:message("Party disbanded!")
  end
end

local function remove_instance(area_id)
  local instance = instances[area_id]
  local respawn_area = respawn_table[Net.get_area_name(area_id)]
  local spawn = nil
  if respawn_area ~= nil then
    spawn = Net.get_object_by_name(respawn_area, "Liberation Respawn")
  else
    respawn_area = "default"
    spawn = Net.get_spawn_position("default")
  end
  for _, player in ipairs(instance:get_players()) do
    Net.transfer_player(player.id, respawn_area, true, spawn.x, spawn.y, spawn.z)

    player.activity = nil
  end

  instance:clean_up().and_then(function()
    instances[area_id] = nil
  end)
end

-- handlers
function LibPlugin.on_tick(elapsed)
  Parties.on_tick(elapsed)

  local dead_instances = {}

  for area_id, instance in pairs(instances) do
    instance:on_tick(elapsed)

    if #instance:get_players() == 0 and not instance:cleaning_up() then
      dead_instances[#dead_instances + 1] = area_id
    end
  end

  for i, area_id in ipairs(dead_instances) do
    remove_instance(area_id)
  end
end

function LibPlugin.handle_tile_interaction(player_id, x, y, z, button)
  local area_id = Net.get_player_area(player_id)

  if waiting_area_map[area_id] ~= nil and button == 0 then
    local player = players[player_id]

    player:quiz("Leave party", "Close").and_then(function(response)
      if response == 0 then
        leave_party(player)
      end
    end)
  elseif instances[area_id] ~= nil then
    instances[area_id]:handle_tile_interaction(player_id, x, y, z, button)
  end
end

function LibPlugin.handle_object_interaction(player_id, object_id, button)
  local area_id = Net.get_player_area(player_id)
  if waiting_area_map[area_id] ~= nil then
    detect_door_interaction(player_id, object_id, button)
  elseif instances[area_id] ~= nil then
    instances[area_id]:handle_object_interaction(player_id, object_id, button)
  end
end

function LibPlugin.handle_actor_interaction(player_id, other_player_id, button)
  local area_id = Net.get_player_area(player_id)

  if waiting_area_map[area_id] == nil or button ~= 0 then return end

  if Net.is_bot(other_player_id) then return end

  local player = players[player_id]
  local name = Net.get_player_name(other_player_id)

  if Parties.is_in_same_party(player_id, other_player_id) then
    player:message_with_mug(name .. " is already in our party.")
    return
  end

  -- checking for an invite
  if Parties.has_request(player_id, other_player_id) then
    -- other player has a request for us
    player:question_with_mug("Join " .. name .. "'s party?").and_then(function(response)
      if response == 1 then
        Parties.accept(player_id, other_player_id)
      end
    end)

    return
  end

  -- try making a party request
  if Parties.has_request(other_player_id, player_id) then
    player:message_with_mug("We already asked " .. name .. " to join our party.")
    return
  end

  player:question_with_mug("Recruit " .. name .. "?").and_then(function(response)
    if response == 1 then
      -- create a request
      Parties.request(player_id, other_player_id)
    end
  end)
end

function LibPlugin.handle_textbox_response(player_id, response)
  local player = players[player_id]

  player:handle_textbox_response(response)
end

function LibPlugin.handle_battle_results(player_id, stats)
  local player = players[player_id]
  if player then
    player:handle_battle_results(stats)
  end
end

function LibPlugin.handle_player_avatar_change(player_id, details)
  local player = players[player_id]

  player.avatar_details = details

  if player.activity then
    player.activity:handle_player_avatar_change(player_id)
  end
end

function LibPlugin.handle_player_transfer(player_id)
  local player = players[player_id]

  local player_pos = Net.get_player_position(player_id)
  player.x = player_pos.x
  player.y = player_pos.y
  player.z = player_pos.z

  if player.activity then
    player.activity:handle_player_transfer(player_id)
  end
end

function LibPlugin.handle_player_request(player_id)
  players[player_id] = Player:new(player_id)
end

function LibPlugin.handle_player_disconnect(player_id)
  local player = players[player_id]
  player:handle_disconnect()

  leave_party(player)
  players[player_id] = nil
end

function LibPlugin.handle_player_move(player_id, x, y, z)
    local player = players[player_id]
    player.x = x
    player.y = y
    player.z = z
end

local areas = Net.list_areas()
for i, area_id in next, areas do
    local objects = Net.list_objects(area_id)
    local custom_parameters = Net.get_area_custom_properties(area_id)
    if custom_parameters["Respawn Area"] then
      respawn_table[area_id] = custom_parameters["Respawn Area"]
      if custom_parameters["Waiting Area"] then
        waiting_area_map[custom_parameters["Waiting Area"]] = area_id
      else
        waiting_area_map[custom_parameters["Respawn Area"]] = area_id
      end
    end
    for index, value in ipairs(objects) do
      local object = Net.get_object_by_id(area_id, value)
      if object.custom_properties["Liberation Map File Name"] then
        gate_to_area_map[value] = object.custom_properties["Liberation Map File Name"]
      end
    end
end

return LibPlugin