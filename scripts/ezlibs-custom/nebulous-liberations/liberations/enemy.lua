-- enemy implementations are in the enemies folder
-- enemy shape:
-- {
--   id, -- id of the spawned bot
--   battle_name, -- name of the virus for syncing hp
--   name?, -- reserved, will automatically be set on creation
--   is_boss?, -- reserved, will automatically be set on creation
--   health,
--   max_health,
--   x, -- should be floored, but spawned bots should be centered on tiles (x + .5)
--   y, -- should be floored, but spawned bots should be centered on tiles (y + .5)
--   z, -- should be floored
--   mug? = {
--     texture_path
--     animation_path
--   }
--   encounter = asset_path
-- }
--   :new(instance, position, direction)
--   :take_turn() -- promise
--   :get_death_message() -- string

local BlizzardMan = require("scripts/ezlibs-custom/nebulous-liberations/liberations/enemies/blizzardman")
local BigBrute = require("scripts/ezlibs-custom/nebulous-liberations/liberations/enemies/bigbrute")
local ExplodingEffect = require("scripts/utils/exploding_effect")

local Enemy = {}

local name_to_enemy = {
  BlizzardMan = BlizzardMan,
  BigBrute = BigBrute,
}

function Enemy.from(instance, position, direction, name)
  local enemy = name_to_enemy[name]:new(instance, position, direction)
  enemy.name = enemy.name or name
  
  Net.set_bot_name(enemy.id, enemy.name .. ": " .. enemy.health)

  return enemy
end

function Enemy.is_alive(enemy)
  return Net.is_bot(enemy.id)
end

function Enemy.destroy(instance, enemy)
  if not Enemy.is_alive(enemy) then
    -- already died
    return Async.create_promise(function(resolve)
      resolve()
    end)
  end

  -- remove from the instance
  for i, stored_enemy in pairs(instance.enemies) do
    if enemy == stored_enemy then
      table.remove(instance.enemies, i)
      break
    end
  end

  local co = coroutine.create(function()

    -- begin exploding the enemy
    local explosions = ExplodingEffect:new(enemy.id)

    -- moving every player's camera to the enemy
    local slide_time = .2
    local hold_time = 3
    local extra_explosion_time = .5

    local lock_tracker = {}

    for _, player in ipairs(instance.players) do
      lock_tracker[player.id] = Net.is_player_input_locked(player.id)
      Net.lock_player_input(player.id)

      Net.slide_player_camera(player.id, enemy.x + .5, enemy.y + .5, enemy.z, slide_time)
      Net.move_player_camera(player.id, enemy.x + .5, enemy.y + .5, enemy.z, hold_time)

      Net.slide_player_camera(player.id, player.x, player.y, player.z, slide_time)
      Net.unlock_player_camera(player.id)
    end

    Async.await(Async.sleep(slide_time))

    -- display death message
    local message = enemy:get_death_message()
    local texture_path = enemy.mug and enemy.mug.texture_path
    local animation_path = enemy.mug and enemy.mug.animation_path
    if message then
      for _, player in ipairs(instance.players) do
        player:message(message, texture_path, animation_path)
      end
    end

    Async.await(Async.sleep(hold_time - extra_explosion_time))

    -- remove from the server
    Net.remove_bot(enemy.id)

    Async.await(Async.sleep(extra_explosion_time))

    -- stop explosions
    explosions:remove()

    -- padding time to fix issues with unlock_player_camera
    -- also looks nice with items
    local unlock_padding = .3

    Async.await(Async.sleep(slide_time + unlock_padding))


    -- unlock players who were not locked
    for _, player in ipairs(instance.players) do
      if not lock_tracker[player.id] then
        Net.unlock_player_input(player.id)
      end
    end
  end)

  return Async.promisify(co)
end

return Enemy
