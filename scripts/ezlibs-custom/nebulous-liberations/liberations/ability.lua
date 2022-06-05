local PanelEncounters = require("scripts/ezlibs-custom/nebulous-liberations/liberations/panel_encounters")
local helpers = require('scripts/ezlibs-scripts/helpers')
local ezmemory = require('scripts/ezlibs-scripts/ezmemory')

local function static_shape_generator(offset_x, offset_y, shape)
  return function()
    return shape, offset_x, offset_y
  end
end

local function liberate_and_loot(instance, player_session, results, remove_traps, destroy_items)
  local panels = player_session.selection:get_panels()
  player_session:liberate_and_loot_panels(panels, results, remove_traps, destroy_items).and_then(function()
    player_session:complete_turn()
  end)
end

local function panel_search(instance, player_session, results, remove_traps, destroy_items)
  local panels = player_session.selection:get_panels()

  player_session:loot_panels(panels, remove_traps, destroy_items).and_then(function()
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

local function battle_to_liberate_and_loot(instance, player_session, r, remove_traps, destroy_items)
  initiate_encounter(instance, player_session).and_then(function(results)
    if results.success then
      liberate_and_loot(instance, player_session, results, remove_traps, destroy_items)
    else
      player_session:complete_turn()
    end
  end)
end

local Ability = {
  Guard = {name = "Guard"}, -- passive, knightman's ability
  Shadowstep = {name = "Shadowstep"}, --passive, Shadowman's ability
  LongSwrd = {
    name = "LongSwrd",
    question = "Use LongSwrd?",
    cost = 1,
    remove_traps = false,
    destroy_items = false,
    generate_shape = static_shape_generator(0, 0, {
      {1},
      {1}
    }),
    activate = battle_to_liberate_and_loot
  },
  WideSwrd = {
    name = "WideSwrd",
    question = "Use WideSwrd?",
    cost = 1,
    remove_traps = false,
    destroy_items = false,
    generate_shape = static_shape_generator(0, 0, {
      {1, 1, 1},
    }),
    activate = battle_to_liberate_and_loot
  },
  GutsWave = {
    name = "GutsWave",
    question = "Destroy with GutsWave?",
    cost = 1,
    remove_traps = false,
    destroy_items = true,
    generate_shape = static_shape_generator(0, 0, {
      {1},
      {1},
      {1},
      {1},
      {1}
    }),
    activate = liberate_and_loot
  },
  ScrenDiv = {
    name = "ScrenDiv",
    question = "Use ScrenDiv to liberate?",
    cost = 3,
    remove_traps = false,
    destroy_items = false,
    generate_shape = static_shape_generator(0, 0, {
      {1, 1, 1, 1, 1},
      {0, 1, 0, 0, 0},
      {0, 0, 1, 0, 0},
      {0, 0, 0, 1, 0},
      {1, 1, 1, 1, 1},
    }),
    activate = battle_to_liberate_and_loot
  },
  PanelSearch = {
    name = "PanelSearch",
    question = "Search in this area?",
    cost = 1,
    remove_traps = true,
    destroy_items = false,
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
  NumberSearch = {
    name = "NumberSearch",
    question = "Remove traps & get items?",
    cost = 1,
    remove_traps = true,
    destroy_items = false,
    generate_shape = static_shape_generator(0, 0, {
      {1, 1, 1},
      {1, 1, 1},
    }),
    activate = panel_search
  },
  -- Extra
  HexSickle = {
    name = "HexSickle",
    question = "Should I cut panels with HexSickle?",
    cost = 1,
    remove_traps = true,
    destroy_items = false,
    generate_shape = static_shape_generator(0, 1, {
      {1, 1, 1}
    }),
    activate = battle_to_liberate_and_loot
  },
}

local navi_ability_map = {
  LongSwrd = Ability.LongSwrd,
  WideSwrd = Ability.WideSwrd,
  OldSaber = Ability.ScrenDiv,
  HevyShld = Ability.Guard,
  HexScyth = Ability.HexSickle,
  NumGadgt = Ability.NumberSearch,
  GutsHamr = Ability.GutsWave
}

function Ability.resolve_for_player(player)
  local ability = Ability.LongSwrd
  for key,value in pairs(navi_ability_map) do
    if ezmemory.count_player_item(player.id, key) > 0 then
      ability = navi_ability_map[key]
      break
    end
  end

  return ability
end

return Ability