local TOTAL_EXPLOSIONS = 3
local EXPLOSION_DURATION = .6
local EXPLOSION_AXIS_RANGE = .5

local function update_tracked_position(exploding_effect)
  local actor_id = exploding_effect.tracked_actor_id

  if Net.is_bot(actor_id) then
    exploding_effect.area_id = Net.get_bot_area(actor_id)
    exploding_effect.position = Net.get_bot_position(actor_id)
  elseif Net.is_player(actor_id) then
    exploding_effect.area_id = Net.get_player_area(actor_id)
    exploding_effect.position = Net.get_player_position(actor_id)
  end
end

local function explode(self, explosion_bot_id)
  update_tracked_position(self)

  local offset_x = (math.random() * 2 - 1) * EXPLOSION_AXIS_RANGE
  local offset_y = (math.random() * 2 - 1) * EXPLOSION_AXIS_RANGE

  Net.transfer_bot(
    explosion_bot_id,
    self.area_id,
    false,
    self.position.x + offset_x,
    self.position.y + offset_y,
    self.position.z
  )

  if self.done then
    Net.remove_bot(explosion_bot_id)
    return
  end

  Net.play_sound(self.area_id, "/server/assets/sound effects/explode.ogg")

  if math.random(2) == 1 then
    Net.animate_bot(explosion_bot_id, "EXPLODE")
  else
    Net.animate_bot(explosion_bot_id, "SMOKE")
  end

  -- explode again
  Async.sleep(EXPLOSION_DURATION)
    .and_then(function()
      explode(self, explosion_bot_id)
    end)
end

local function spawn(self, area_id, position)
  for i = 1, TOTAL_EXPLOSIONS, 1 do
    local explosion_bot_id = Net.create_bot({
      texture_path = "/server/assets/bots/explosion.png",
      animation_path = "/server/assets/bots/explosion.animation",
      area_id = self.area_id,
      warp_in = false,
      x = self.position.x,
      y = self.position.y,
      z = self.position.z,
    })

    if i > 1 then
      Async.sleep((i - 1) * EXPLOSION_DURATION / TOTAL_EXPLOSIONS)
        .and_then(function()
          explode(self, explosion_bot_id)
        end)
    else
      explode(self, explosion_bot_id)
    end
  end
end

local ExplodingEffect = {}

function ExplodingEffect:new(actor_id)
  local exploding_effect = {
    tracked_actor_id = actor_id,
    position = nil,
    area_id = nil,
    done = false
  }

  setmetatable(exploding_effect, self)
  self.__index = self

  update_tracked_position(exploding_effect)
  spawn(exploding_effect)

  return exploding_effect
end

function ExplodingEffect:remove()
  self.done = true
end

return ExplodingEffect
