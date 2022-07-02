local Emotes = require("scripts/libs/emotes")
local Direction = require("scripts/libs/direction")

local bot_list = {}
local texture_path= "/server/assets/NebuLibsAssets/bots/prog.png"
local animation_path = "/server/assets/NebuLibsAssets/bots/prog.animation"
local mug_texture_path= "/server/assets/NebuLibsAssets/mugs/prog.png"
local mug_animation_path = "/server/assets/NebuLibsAssets/mugs/prog.animation"
local player_states = {}
local explanation_timers = {}

local function message_player(player_id, message)
  Net.message_player(player_id, message, mug_texture_path, mug_animation_path)
end

local function quiz_player(player_id, a, b, c)
  Net.quiz_player(player_id, a, b, c, mug_texture_path, mug_animation_path)
end

local function update_state(handlers, player_id, ...)
  local state = player_states[player_id]
  local handler = handlers[state]
  local next_state = nil

  if type(handler) == "function" then
    next_state = handler(player_id, ...)
  else
    next_state = handler
  end

  player_states[player_id] = next_state
end

local function list_options(player_id)
  quiz_player(player_id, "Liberations", "Parties", "Nothing")
end

local function loop_help(player_id)
  message_player(player_id, "IS THERE ANYTHING ELSE YOU WOULD LIKE TO KNOW?")
  list_options(player_id)
end

Net:on("actor_interaction", function(event)
  local button = event.button
  if button ~= 0 then return end
  local function includes(table, value)
    for _, v in ipairs(table) do
      if value == v then
        return true
      end
    end
  end
  local other_id = event.actor_id
  if not includes(bot_list, other_id) then return end
  local player_id = event.player_id
  if player_states[player_id] ~= nil then return end

  Net.lock_player_input(player_id)
  Net.set_bot_direction(other_id, Direction.from_points(Net.get_bot_position(other_id), Net.get_player_position(player_id)))
  player_states[player_id] = "start"
  message_player(player_id, "I'M THE TUTORIAL PROG. FOR BASIC INFORMATION YOU CAN VISIT ME!\n\n\nWHAT WOULD YOU LIKE TO KNOW?")
  list_options(player_id)
end)

local LIBERATIONS_HELP_TEXT = [[
LIBERATION MISSIONS ARE A GAME MODE ADDED IN MMBN5.
THE GOAL OF A LIBERATION MISSION IS TO DEFEAT THE BOSS AT THE END OF THE AREA.
IN THE WAY OF YOUR PATH ARE PURPLE TILES CALLED DARK PANELS. TO LIBERATE A PANEL YOU MUST WIN A BATTLE WITHIN THREE TURNS.
]]

local PARTIES_INTRO_TEXT = [[
PARTIES ALLOW YOU TO PLAY LIBERATION MISSIONS IN A GROUP. TO START A PARTY, WALK UP TO ANOTHER PLAYER AND PRESS interact. YOU WILL SEE A MENU THAT LOOKS LIKE THIS:
]]

local PARTIES_RECRUIT_TEXT = [[
IF YOU SELECT YES, THE OTHER PLAYER WILL SEE A ? ABOVE YOUR HEAD. LIKE THIS:
]]

local PARTIES_RESPONSE_TEXT = [[
WHEN YOU SEE A PLAYER WITH A ? ABOVE THEIR HEAD, INTERACTING WITH THAT PLAYER WILL ALLOW YOU TO RESPOND TO THEIR REQUEST. IF YOU ACCEPT YOU WILL BE ADDED TO THEIR PARTY AND BOTH MEMBERS WILL BE NOTIFIED THROUGH THIS INDICATOR:
]]

local response_handlers = {
  ["start"] = "help choice",

  ["help choice"] = function(player_id, response)
    if response == 0 then
      -- liberations
      message_player(player_id, LIBERATIONS_HELP_TEXT)
      loop_help(player_id)
      return "liberations"
    elseif response == 1 then
      -- parties
      local mugshot = Net.get_player_mugshot(player_id)
      message_player(player_id, PARTIES_INTRO_TEXT) -- parties intro
      Net.question_player(player_id, "Recruit Anon?", mugshot.texture_path, mugshot.animation_path) -- recruit example
      message_player(player_id, PARTIES_RECRUIT_TEXT) -- recruit
      return "parties intro"
    else
      -- close
      Net.unlock_player_input(player_id)
      return nil
    end
  end,

  ["liberations"] = "start",

  -- parties
  ["parties intro"] = "recruit example",
  ["recruit example"] = "recruit",
  ["recruit"] = function(player_id)
    Net.exclusive_player_emote(player_id, player_id, Emotes.QUESTION)
    explanation_timers[player_id] = 2
    return "recruit"
  end,
  ["recruit responding"] = function(player_id)
    Net.exclusive_player_emote(player_id, player_id, Emotes.HAPPY)
    explanation_timers[player_id] = 2
    return "recruit responding"
  end,

  ["loop"] = "start"
  -- [nil] = nil
}

Net:on("textbox_response", function(event)
  local player_id = event.player_id
  local response = event.response
  update_state(response_handlers, player_id, response)
end)

local timer_handlers = {
  ["recruit"] = function(player_id)
    message_player(player_id, PARTIES_RESPONSE_TEXT)
    return "recruit responding"
  end,
  ["recruit responding"] = function(player_id)
    loop_help(player_id)
    return "start"
  end,
}

Net:on("tick", function(event)
  local elapsed = event.delta_time
  for player_id, time in pairs(explanation_timers) do
    local remaining_time = time - elapsed

    if remaining_time < 0 then
      update_state(timer_handlers, player_id)
      explanation_timers[player_id] = nil
    else
      explanation_timers[player_id] = time - elapsed
    end
  end
end)

Net:on("player_disconnect", function(event)
  local player_id = event.player_id
  player_states[player_id] = nil
  explanation_timers[player_id] = nil
end)

local areas = Net.list_areas()
for i, area_id in next, areas do
  local objects = Net.list_objects(area_id)
  for index, value in ipairs(objects) do
    local object = Net.get_object_by_id(area_id, value)
    if object.type == "Liberation Tutorial" then
      local bot = Net.create_bot({
        area_id = area_id,
        texture_path = texture_path,
        animation_path = animation_path,
        x = object.x,
        y = object.y,
        z = object.z,
        direction = object.custom_properties["Direction"] or Direction.DOWN_RIGHT,
        solid = true
      })
      bot_list[#bot_list + 1] = bot
    end
  end
end