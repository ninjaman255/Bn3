local PanelEncounters = require("scripts/ezlibs-custom/nebulous-liberations/liberations/panel_encounters")

local function static_shape_generator(offset_x, offset_y, shape)
  return function()
    return shape, offset_x, offset_y
  end
end

local function liberate_and_loot(instance, player_session)
  local panels = player_session.selection:get_panels()

  player_session:liberate_and_loot_panels(panels).and_then(function()
    player_session:complete_turn()
  end)
end

local function initiate_encounter(instance, player_session)
  local data = {
    terrain = PanelEncounters.resolve_terrain(instance, player_session.player)
  }

  local encounter_path = PanelEncounters[instance.area_name]

  return player_session:initiate_encounter(encounter_path, data)
end

local function battle_to_liberate_and_loot(instance, player_session)
  initiate_encounter(instance, player_session).and_then(function(results)
    if results.success then
      liberate_and_loot(instance, player_session)
    else
      player_session:complete_turn()
    end
  end)
end

local Ability = {
  Guard = {}, -- passive, knightman's ability
  LongSwrd = {
    name = "LongSwrd",
    question = "Use LongSwrd?",
    cost = 1,
    generate_shape = static_shape_generator(0, 0, {
      {1},
      {1}
    }),
    activate = battle_to_liberate_and_loot
  },
  ScrenDiv = {
    name = "ScrenDiv",
    question = "Use ScrenDiv to liberate?",
    cost = 1,
    generate_shape = static_shape_generator(0, 0, {
      {1, 1, 1}
    }),
    activate = battle_to_liberate_and_loot
  },
  PanelSearch = {
    name = "PanelSearch",
    question = "Search in this area?",
    cost = 1,
    -- todo: this should stretch to select all item panels in a line with dark panels between?
    generate_shape = static_shape_generator(0, 0, {
      {1},
      {1},
      {1}
    }),
    activate = function (instance, player_session)
      -- todo: use Async.sleep in a coroutine+loop to adjust shape and play a sound
      -- https://www.youtube.com/watch?v=Q62Ek8_KP1Q&t=3887s
    end
  },
  -- Extra
  HexSickle = {
    name = "HexSickle",
    question = "Should I cut panels with HexSickle?",
    cost = 1,
    generate_shape = static_shape_generator(0, 1, {
      {1, 1, 1}
    }),
    activate = battle_to_liberate_and_loot
  },
}

local navi_ability_map = {
  Megaman = Ability.LongSwrd,
  Protoman = Ability.WideSwrd,
  Colonel = Ability.ScrenDiv,
  Knightman = Ability.Guard,
  Eraseman = Ability.HexSickle,
  Default = Ability.LongSwrd
}

function Ability.resolve_for_player(player)
  local navi_name = player.avatar_details.name
  local ability = navi_ability_map[navi_name]

  if ability then
    return ability
  end

  return navi_ability_map.Default
end

return Ability