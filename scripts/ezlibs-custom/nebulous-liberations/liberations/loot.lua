local Enemy = require("scripts/ezlibs-custom/nebulous-liberations/liberations/enemy")

local Loot = {
  HEART = {
    animation = "HEART",
    activate = function(instance, player_session)
      return Async.create_promise(function(resolve)
        player_session.player:message_with_mug("I found\na heart!").and_then(function()
          player_session:heal(player_session.max_health / 2)
          resolve()
        end)
      end)
    end
  },
  CHIP = {
    animation = "CHIP",
    activate = function(instance, player_session)
      return Async.create_promise(function(resolve)
        player_session.player:message_with_mug("I found a\nBattleChip!").and_then(function()
          resolve()
        end)
      end)
    end
  },
  ZENNY = {
    animation = "ZENNY",
    activate = function(instance, player_session)
      return Async.create_promise(function(resolve)
        player_session.player:message_with_mug("I found some\nMonies!").and_then(function()
          player_session.get_monies = true
          resolve()
        end)
      end)
    end
  },
  BUGFRAG = {
    animation = "BUGFRAG",
    activate = function(instance, player_session)
      return Async.create_promise(function(resolve)
        player_session.player:message_with_mug("I found a\nBugFrag!").and_then(function()
          resolve()
        end)
      end)
    end
  },
  ORDER_POINT = {
    animation = "ORDER_POINT",
    activate = function(instance, player_session)
      return Async.create_promise(function(resolve)
        player_session.player:message_with_mug("I found\nOrder Points!")

        local previous_points = instance.order_points
        instance.order_points = math.min(instance.order_points + 3, instance.MAX_ORDER_POINTS)

        local recovered_points = instance.order_points - previous_points
        player_session.player:message(recovered_points .. "\nOrder Pts Recovered!").and_then(function()
          resolve()
        end)
      end)
    end
  },
  INVINCIBILITY = {
    animation = "INVINCIBILITY",
    activate = function(instance, player_session)
      return Async.create_promise(function(resolve)
        player_session.player:message("Team becomes invincible for\n 1 phase!!").and_then(function()
          for _, other_session in pairs(instance.player_sessions) do
            other_session.invincible = true
          end

          resolve()
        end)
      end)
    end
  },
  MAJOR_HIT = {
    animation = "MAJOR_HIT",
    activate = function(instance, player_session)
      local co = coroutine.create(function()
        Async.await(player_session.player:message("Damages the closest Guardian the most!"))

        local enemy = player_session:find_closest_guardian()

        if not enemy then
          Async.await(player_session.player:message("No Guardians found"))
          return
        end

        Async.await(Enemy.destroy(instance, enemy))
      end)

      return Async.promisify(co)
    end
  },
  KEY = {
    animation = "KEY",
    activate = function(instance, player_session)
      return Async.create_promise(function(resolve)
        resolve()
      end)
    end
  },
  TRAP = {
    animation = "TRAP",
    activate = function(instance, player_session)
      return Async.create_promise(function(resolve)
        resolve()
      end)
    end
  },
}

Loot.DEFAULT_POOL = {
  Loot.HEART,
  -- Loot.CHIP,
  Loot.ZENNY,
  -- Loot.BUGFRAG,
  Loot.ORDER_POINT,
}

Loot.BONUS_POOL = {
  Loot.HEART,
  -- Loot.CHIP,
  Loot.ORDER_POINT,
  Loot.INVINCIBILITY,
  Loot.MAJOR_HIT,
  Loot.ZENNY,
}

Loot.TEST_POOL = {
  Loot.HEART,
  Loot.CHIP,
  Loot.ZENNY,
  Loot.BUGFRAG,
  Loot.ORDER_POINT,
}

local RISE_DURATION = .1

-- private functions

local function spawn_item_bot(bot_data, property_animation)
  local shadow_id = Net.create_bot(
    {
      area_id = bot_data.area_id,
      texture_path = "/server/assets/bots/item.png",
      animation_path = "/server/assets/bots/item.animation",
      animation = "SHADOW",
      warp_in = false,
      x = bot_data.x - 1 / 32,
      y = bot_data.y - 1 / 32,
      z = bot_data.z,
    }
  )

  local id = Net.create_bot(bot_data)

  Net.animate_bot_properties(id, property_animation)

  function cleanup()
    Net.remove_bot(shadow_id)
    Net.remove_bot(id)
  end

  return cleanup
end

-- public functions

-- returns a promise that resolves when the animation finishes
-- resolved value is a function that cleans up the bot
function Loot.spawn_item_bot(item, area_id, x, y, z)
  local bot_data = {
    area_id = area_id,
    texture_path = "/server/assets/bots/item.png",
    animation_path = "/server/assets/bots/item.animation",
    animation = item.animation,
    warp_in = false,
    x = x,
    y = y,
    z = z,
  }

  local property_animation = {
    {
      properties = {
        { property = "Z", ease = "Linear", value = z + 1 }
      },
      duration = RISE_DURATION
    },
  }

  -- return a promise that resolves when the animation finishes
  return Async.create_promise(function(resolve)
    local cleanup = spawn_item_bot(bot_data, property_animation)

    Async.sleep(RISE_DURATION).and_then(function()
      resolve(cleanup)
    end)
  end)
end

-- returns a promise that resolves when the animation finishes
-- resolved value is a function that cleans up the bot
function Loot.spawn_randomized_item_bot(loot_pool, item_index, area_id, x, y, z)
  local target_duration = 2
  local frame_duration = .075
  local total_frames = math.ceil(target_duration / frame_duration)

  local start_index = (item_index - total_frames - 2) % #loot_pool + 1

  local bot_data = {
    area_id = area_id,
    texture_path = "/server/assets/bots/item.png",
    animation_path = "/server/assets/bots/item.animation",
    animation = loot_pool[start_index].animation,
    warp_in = false,
    x = x,
    y = y,
    z = z,
  }

  local property_animation = {}

  local total_duration = 0
  local added_rise = false

  for i = 1, total_frames, 1 do
    local current_item_index = (start_index + i) % #loot_pool + 1

    local key_frame = {
      properties = {
        { property = "Animation", value = loot_pool[current_item_index].animation }
      },
      duration = frame_duration
    }

    total_duration = total_duration + frame_duration

    if not added_rise and total_duration >= RISE_DURATION then
      -- animate rising
      key_frame.properties[#key_frame.properties] = { property = "Z", ease = "Linear", value = z + 1 }
      added_rise = true
    end

    property_animation[#property_animation+1] = key_frame
  end

  -- return a promise that resolves when the animation finishes
  return Async.create_promise(function(resolve)
    local cleanup = spawn_item_bot(bot_data, property_animation)

    Async.sleep(total_duration).and_then(function()
      resolve(cleanup)
    end)
  end)
end

-- returns a promise, resolves when looting is completed
function Loot.loot_item_panel(instance, player_session, panel)
  local slide_time = .1

  local spawn_x = math.floor(panel.x) + .5
  local spawn_y = math.floor(panel.y) + .5
  local spawn_z = panel.z

  Net.slide_player_camera(
    player_session.player.id,
    spawn_x,
    spawn_y,
    spawn_z,
    slide_time
  )

  local loot = panel.loot

  -- prevent other players from looting this panel again
  panel.loot = nil

  local co = coroutine.create(function()
    Async.await(Async.sleep(slide_time))

    local remove_item_bot = Async.await(Loot.spawn_item_bot(loot, instance.area_id, spawn_x, spawn_y, spawn_z))

    Async.await(loot.activate(instance, player_session))

    remove_item_bot()
  end)

  return Async.promisify(co)
end

-- returns a promise, resolves when looting is completed
function Loot.loot_bonus_panel(instance, player_session, panel)
  local loot_index = math.random(#Loot.BONUS_POOL)

  local spawn_x = math.floor(panel.x) + .5
  local spawn_y = math.floor(panel.y) + .5
  local spawn_z = panel.z

  local co = coroutine.create(function()
    local remove_item_bot = Async.await(
      Loot.spawn_randomized_item_bot(
        Loot.BONUS_POOL,
        loot_index,
        instance.area_id,
        spawn_x,
        spawn_y,
        spawn_z
      )
    )

    local loot = Loot.BONUS_POOL[loot_index]
    Async.await(loot.activate(instance, player_session))

    remove_item_bot()
  end)

  return Async.promisify(co)
end

return Loot
