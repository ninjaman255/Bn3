local ParalyzeEffect = {}

local SFX_PATH = "/server/assets/sound effects/paralyze.ogg"

function ParalyzeEffect:new(actor_id, area_wide_sfx)
  local paralyze_effect = {
    bot_id = nil
  }

  setmetatable(paralyze_effect, self)
  self.__index = self

  local area_id, position

  if Net.is_bot(actor_id) then
    area_id = Net.get_bot_area(actor_id)
    position = Net.get_bot_position(actor_id)
  elseif Net.is_player(actor_id) then
    area_id = Net.get_player_area(actor_id)
    position = Net.get_player_position(actor_id)
  end

  if area_wide_sfx then
    Net.play_sound(area_id, SFX_PATH)
  elseif Net.is_player(actor_id) then
    Net.play_sound_for_player(actor_id, SFX_PATH)
  end

  paralyze_effect.bot_id = Net.create_bot({
    texture_path = "/server/assets/bots/paralyze.png",
    animation_path = "/server/assets/bots/paralyze.animation",
    animation = "THIN",
    area_id = area_id,
    warp_in = false,
    x = position.x + 1 / 32,
    y = position.y + 1 / 32,
    z = position.z,
  })

  return paralyze_effect
end

function ParalyzeEffect:remove()
  Net.remove_bot(self.bot_id)
end

return ParalyzeEffect
