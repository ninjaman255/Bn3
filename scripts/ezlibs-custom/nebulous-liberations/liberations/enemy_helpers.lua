local RecoverEffect = require("scripts/utils/recover_effect")
local Direction = require("scripts/libs/direction")

local EnemyHelpers = {
  guardian_minimap_marker = { r = 230, g = 50, b = 40 },
  boss_minimap_color = { r = 170, g = 50, b = 170 }
}

local direction_suffix_map = {
  [Direction.DOWN_LEFT] = "DL",
  [Direction.DOWN_RIGHT] = "DR",
  [Direction.UP_LEFT] = "UL",
  [Direction.UP_RIGHT] = "UR",
}

function EnemyHelpers.play_attack_animation(enemy)
  local direction = Net.get_bot_direction(enemy.id)
  local suffix = direction_suffix_map[direction]

  local animation = "ATTACK_" .. suffix

  Net.animate_bot(enemy.id, animation)
end

function EnemyHelpers.update_name(enemy)
  Net.set_bot_name(enemy.id, enemy.name .. ": " .. enemy.health)
end

function EnemyHelpers.heal(enemy, amount)
  local previous_health = enemy.health

  enemy.health = math.min(math.ceil(enemy.health + amount), enemy.max_health)

  EnemyHelpers.update_name(enemy)

  if previous_health < enemy.health then
    return RecoverEffect:new(enemy.id):remove()
  else
    return Async.create_promise(function(resolve)
      resolve()
    end)
  end
end

function EnemyHelpers.face_position(enemy, x, y)
  x = x - (enemy.x + .5)
  y = y - (enemy.y + .5)

  Net.set_bot_direction(enemy.id, Direction.diagonal_from_offset(x, y))
end

function EnemyHelpers.can_move_to(instance, x, y, z)
  local panel = instance:get_panel_at(x, y, z)

  return panel and (
    panel.type == "Dark Panel" or
    panel.type == "Item Panel" or
    panel.type == "Trap Panel"
  )
end

-- takes instance to move player cameras
-- x, y, z should be floored
function EnemyHelpers.move(instance, enemy, x, y, z, direction)
  x = math.floor(x)
  y = math.floor(y)

  local slide_time = .5
  local hold_time = .25
  local startup_time = .25
  local animation_time = .042

  local co = coroutine.create(function()
    Async.await(Async.sleep(hold_time))

    for _, player in ipairs(instance.players) do
      Net.slide_player_camera(player.id, x + .5, y + .5, z, slide_time)
    end

    local area_id = Net.get_bot_area(enemy.id)

    -- create blur
    local blur_bot_id = Net.create_bot({
      texture_path = "/server/assets/bots/blur.png",
      animation_path = "/server/assets/bots/blur.animation",
      area_id = area_id,
      warp_in = false,
      x = enemy.x + .5 + (1 / 32),
      y = enemy.y + .5 + (1 / 32),
      z = enemy.z + 1
    })

    -- animate blur
    Net.animate_bot(blur_bot_id, "DISAPPEAR")

    Async.await(Async.sleep(animation_time))

    -- move this bot off screen
    local area_width = Net.get_width(area_id)
    Net.transfer_bot(enemy.id, area_id, false, area_width + 100, 0, 0)

    Async.await(Async.sleep(slide_time + startup_time))

    -- animate blur
    Net.transfer_bot(
      blur_bot_id,
      area_id,
      false,
      x + .5 + (1 / 32),
      y + .5 + (1 / 32),
      z + 1
    )
    Net.animate_bot(blur_bot_id, "APPEAR")

    Async.await(Async.sleep(animation_time))

    if direction then
      Net.set_bot_direction(enemy.id, direction)
    end

    -- move the enemy
    Net.transfer_bot(enemy.id, area_id, false, x + .5, y + .5, z)

    -- delete the blur bot
    Net.remove_bot(blur_bot_id)

    Async.await(Async.sleep(hold_time))

    enemy.x = x
    enemy.y = y
    enemy.z = z
  end)

  return Async.promisify(co)
end

function EnemyHelpers.offset_position_with_direction(position, direction)
  position = {
    x = position.x,
    y = position.y,
    z = position.z
  }

  if direction == Direction.DOWN_LEFT then
    position.y = position.y + 1
  elseif direction == Direction.DOWN_RIGHT then
    position.x = position.x + 1
  elseif direction == Direction.UP_LEFT then
    position.x = position.x - 1
  elseif direction == Direction.UP_RIGHT then
    position.x = position.y - 1
  end

  return position
end

function EnemyHelpers.chebyshev_tile_distance(enemy, x, y)
  local xdiff = math.abs(enemy.x - math.floor(x))
  local ydiff = math.abs(enemy.y - math.floor(y))
  return math.max(xdiff, ydiff)
end

-- uses chebyshev_tile_distance
function EnemyHelpers.find_closest_player_session(instance, enemy)
  local closest_session
  local closest_distance = math.huge

  for _, player_session in pairs(instance.player_sessions) do
    local player = player_session.player

    if player_session.health == 0 or player.z ~= enemy.z then
      goto continue
    end

    local distance = EnemyHelpers.chebyshev_tile_distance(enemy, player.x, player.y)

    if distance < closest_distance then
      closest_distance = distance
      closest_session = player_session
    end

    ::continue::
  end

  return closest_session
end

function EnemyHelpers.sync_health(enemy, results)
  for _, data in ipairs(results.enemies) do
    if enemy.battle_name == data.id then
      enemy.health = data.health
      EnemyHelpers.update_name(enemy)
      break
    end
  end
end

return EnemyHelpers
