local EnemyHelpers = require("scripts/ezlibs-custom/nebulous-liberations/liberations/enemy_helpers")
local EnemySelection = require("scripts/ezlibs-custom/nebulous-liberations/liberations/enemy_selection")
local Preloader = require("scripts/ezlibs-custom/nebulous-liberations/liberations/preloader")
local Direction = require("scripts/libs/direction")

Preloader.add_asset("/server/assets/bots/beast breath.png")
Preloader.add_asset("/server/assets/bots/beast breath.animation")

local BigBrute = {}

function BigBrute:new(instance, position, direction)
  local bigbrute = {
    instance = instance,
    id = nil,
    battle_name = "BigBrute",
    health = 120,
    max_health = 120,
    x = math.floor(position.x),
    y = math.floor(position.y),
    z = math.floor(position.z),
    selection = EnemySelection:new(instance),
    encounter = "/server/assets/encounters/big_brute_encounter.zip"
  }

  setmetatable(bigbrute, self)
  self.__index = self

  local shape = {
    {1, 1, 1},
    {1, 0, 1},
    {1, 1, 1}
  }

  bigbrute.selection:set_shape(shape, 0, -2)
  bigbrute:spawn(direction)

  return bigbrute
end

function BigBrute:spawn(direction)
  self.id = Net.create_bot({
    texture_path = "/server/assets/bots/bigbrute.png",
    animation_path = "/server/assets/bots/bigbrute.animation",
    area_id = self.instance.area_id,
    direction = direction,
    warp_in = false,
    x = self.x + .5,
    y = self.y + .5,
    z = self.z
  })
  Net.set_bot_minimap_color(self.id, EnemyHelpers.guardian_minimap_marker)
end

function BigBrute:get_death_message()
  return "Gyaaaaahh!!"
end

local function sign(a)
  if a < 0 then
    return -1
  end

  return 1
end

local function find_offset(self, xstep, ystep, limit)
  local offset = 0
  -- adding them, as only one should be set, and the other should be set to 0
  local step = math.abs(xstep + ystep)

  for i = limit, 1, -step do
    if EnemyHelpers.can_move_to(self.instance, self.x + xstep * i, self.y + ystep * i, self.z) then
      offset = step * i
      break
    end
  end

  return offset
end

local function attempt_axis_move(self, player, diff, xfilter, yfilter)
  return Async.create_promise(function(resolve)
    local step = sign(diff)
    local limit = math.min(math.abs(diff), 2)
    local offset = find_offset(self, step * xfilter, step * yfilter, limit)

    if offset == 0 then
      resolve(false)
      return
    end

    local targetx = self.x + step * offset * xfilter
    local targety = self.y + step * offset * yfilter

    EnemyHelpers.face_position(self, targetx + .5, targety + .5)

    local target_direction = Direction.diagonal_from_offset(
      player.x - (targetx + .5),
      player.y - (targety + .5)
    )

    EnemyHelpers.move(self.instance, self, targetx, targety, self.z, target_direction).and_then(function()
      resolve(true)
    end)
  end)
end

local function attempt_move(self)
  local co = coroutine.create(function()
    local closest_session = EnemyHelpers.find_closest_player_session(self.instance, self)

    if not closest_session then
      -- all players left
      return
    end

    local player = closest_session.player

    local distance = EnemyHelpers.chebyshev_tile_distance(self, player.x, player.y)

    if distance > 4 then
      -- too far to target
      return
    end

    local xdiff = math.floor(player.x) - self.x
    local ydiff = math.floor(player.y) - self.y

    if (ydiff == 0 or math.abs(xdiff) < math.abs(ydiff)) and xdiff ~= 0 then
      -- travel along the x axis
      if not Async.await(attempt_axis_move(self, player, xdiff, 1, 0)) then
        -- failed, try the other axis
        Async.await(attempt_axis_move(self, player, ydiff, 0, 1))
      end
    elseif ydiff ~= 0 then
      -- travel along the y axis
      if not Async.await(attempt_axis_move(self, player, ydiff, 0, 1)) then
        -- failed, try the other axis
        Async.await(attempt_axis_move(self, player, xdiff, 1, 0))
      end
    end
  end)

  return Async.promisify(co)
end

local function attempt_attack(self)
  local co = coroutine.create(function()
    self.selection:move(self, Net.get_bot_direction(self.id))

    local caught_sessions = self.selection:detect_player_sessions()

    if #caught_sessions == 0 then
      return
    end

    local closest_session = EnemyHelpers.find_closest_player_session(self.instance, self)
    EnemyHelpers.face_position(self, closest_session.player.x, closest_session.player.y)

    self.selection:indicate()

    Async.await(Async.sleep(1))

    EnemyHelpers.play_attack_animation(self)

    local spawned_bots = {}

    for _, player_session in ipairs(caught_sessions) do
      local player = player_session.player

      spawned_bots[#spawned_bots+1] = Net.create_bot({
        texture_path = "/server/assets/bots/beast breath.png",
        animation_path = "/server/assets/bots/beast breath.animation",
        animation = "ANIMATE",
        area_id = self.instance.area_id,
        warp_in = false,
        x = player.x + 1 / 32,
        y = player.y + 1 / 32,
        z = player.z
      })
    end

    Async.await(Async.sleep(.5))

    for _, player in ipairs(self.instance.players) do
      Net.shake_player_camera(player.id, 2, .5)
    end

    for _, player_session in ipairs(caught_sessions) do
      player_session:hurt(20)
    end

    Async.await(Async.sleep(.5))

    for _, bot_id in ipairs(spawned_bots) do
      Net.remove_bot(bot_id, false)
    end

    Async.await(Async.sleep(1))

    self.selection:remove_indicators()
  end)

  return Async.promisify(co)
end

function BigBrute:take_turn()
  return Async.create_promise(function(resolve)
    attempt_move(self).and_then(function()
      attempt_attack(self).and_then(resolve)
    end)
  end)
end

return BigBrute
