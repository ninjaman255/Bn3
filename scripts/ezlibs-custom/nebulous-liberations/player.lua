local ezmemory = require("scripts/ezlibs-scripts/ezmemory")
local helpers = require('scripts/ezlibs-scripts/helpers')

-- private functions

local function create_textbox_promise(self)
  if self.disconnected then
    return Async.create_promise(function(resolve)
      resolve()
    end)
  end

  return Async.create_promise(function(resolve)
    table.insert(self.textbox_promise_resolvers, resolve)
  end)
end

-- public
local Player = {}

function Player:new(player_id)
  local position = Net.get_player_position(player_id)

  local player = {
    id = player_id,
    activity = nil,
    mug = Net.get_player_mugshot(player_id),
    textbox_promise_resolvers = {},
    resolve_battle = nil,
    avatar_details = nil,
    x = position.x,
    y = position.y,
    z = position.z,
    disconnected = false
  }

  setmetatable(player, self)
  self.__index = self

  return player
end

-- all messages to this player should be made through the session while the session is alive
function Player:message(message, texture_path, animation_path)
  Net.message_player(self.id, message, texture_path, animation_path)

  return create_textbox_promise(self)
end

-- all messages to this player should be made through the session while the session is alive
function Player:message_with_mug(message)
  return self:message(message, self.mug.texture_path, self.mug.animation_path)
end

-- all questions to this player should be made through the session while the session is alive
function Player:question(question, texture_path, animation_path)
  Net.question_player(self.id, question, texture_path, animation_path)

  return create_textbox_promise(self)
end

-- all questions to this player should be made through the session while the session is alive
function Player:question_with_mug(question)
  return self:question(question, self.mug.texture_path, self.mug.animation_path)
end

-- all quizzes to this player should be made through the session while the session is alive
function Player:quiz(a, b, c, texture_path, animation_path)
  Net.quiz_player(self.id, a, b, c, texture_path, animation_path)

  return create_textbox_promise(self)
end

function Player:is_battling()
  return self.resolve_battle ~= nil
end

local function create_default_results()
  -- { health: number, score: number, time: number, ran: bool, emotion: number }
  --Add 1 turn liberations. They clear like dark hole defeats.
  --If time is under a certain threshold (10000ms?) but not 0, then activate the conditional.
  --Else only clear the one tile, assuming victory.
  return {
    health = 1,
    score = 0,
    time = 0,
    ran = true,
    emotion = 0
  }
end

-- all encounters to this player should be made through the session while the session is alive
function Player:initiate_encounter(asset_path, data)
  if self.disconnected then
    return Async.create_promise(function(resolve)
      resolve(create_default_results())
    end)
  end

  if self:is_battling() then
    error("This player is already in a battle")
  end
  
  Net.initiate_encounter(self.id, asset_path, data)

  return Async.create_promise(function(resolve)
    self.resolve_battle = resolve
  end)
end

-- will throw if a textbox is sent to the player using Net directly
function Player:handle_textbox_response(response)
  local resolve = table.remove(self.textbox_promise_resolvers, 1)
  --may cause silent errors in liberation stuff.
  --maybe undo this change (if resolve ~= nil) when debugging.
  if resolve ~= nil then
    resolve(response)
  else
    print('resolve was nil')
  end
end

function Player:handle_battle_results(stats)
  if not self.resolve_battle then
    return
  end
  local resolve = self.resolve_battle
  self.resolve_battle = nil 
  for index, value in ipairs(stats) do
    print(value)
  end
  -- stats = { health: number, score: number, time: number, ran: bool, emotion: number, turns: number, enemies: { id: String, health: number }[] }
  print("battle turn count is "..stats.turns)

  resolve(stats)
end

function Player:handle_disconnect()
  self.disconnected = true

  for _, resolve in ipairs(self.textbox_promise_resolvers) do
    resolve()
  end

  if self.resolve_battle then
    self:handle_battle_results(create_default_results())
  end

  self.textbox_promise_resolvers = nil

  if self.activity then
    self.activity:handle_player_disconnect(self.id)
  end
end

function Player:boot_to_lobby(isVictory, mapName)
  self.activity:handle_player_disconnect(self.id)
  self.activity = nil
  local area_id = Net.get_player_area(self.id)
  local respawn_area = Net.get_area_custom_property(area_id, "Respawn Area")
  local spawn = nil
  if respawn_area ~= nil then
    spawn = Net.get_object_by_name(respawn_area, "Liberation Respawn")
  else
    respawn_area = "default"
    spawn = Net.get_spawn_position("default")
  end
  Net.transfer_player(self.id, respawn_area, true, spawn.x, spawn.y, spawn.z)
  if isVictory then
    local gate_to_remove = nil
    for index, value in ipairs(Net.list_objects(respawn_area)) do
      local prospective_gate = Net.get_object_by_id(respawn_area, value)
      if prospective_gate.custom_properties["Liberation Map Name"] == mapName then
        gate_to_remove = prospective_gate
        break
      end
    end
    if gate_to_remove ~= nil then
      local safe_secret = helpers.get_safe_player_secret(self.id)
      local player_area_memory = ezmemory.get_player_area_memory(safe_secret,respawn_area)
      player_area_memory.hidden_objects[tostring(gate_to_remove.id)] = true
      ezmemory.save_player_memory(safe_secret)
    end
  end
  ezmemory.set_player_max_health(self.id, ezmemory.get_player_max_health(self.id), true)
  ezmemory.set_player_health(self.id, 9999)
end

return Player