local function create_custom_bot(id, name, area_id, texture_path, animation_path, x, y, z, solid)
  local bot = {
    _id = id,
    x = x,
    y = y,
    z = z,
    path = {},
    _path_target_index = 1,
    talking_to = nil,
    speed = 1.2,
    size = .35,
    _solid = solid,
    mug_texture_path = nil,
    mug_animation_path = nil,
    on_interact = nil,
    on_response = nil,
    on_tick = nil,
    on_disconnect = nil,
    on_transfer = nil
  }

  function bot:tick(delta_time)
    if self.talking_to ~= nil then
      return
    end

    -- this code block prevents NPCs from walking through players...
    local area_id = Net.get_bot_area(self._id);
    local player_ids = Net.list_players(area_id)

    for i = 1, #player_ids, 1 do
      local player_pos = Net.get_player_position(player_ids[i])

      if
        math.abs(player_pos.x - self.x) < self.size and
        math.abs(player_pos.y - self.y) < self.size and
        player_pos.z == self.z
      then
        Net.move_bot(self._id, self.x, self.y, self.z)
        return
      end
    end

    -- this code block follows paths (if previous block doesnt return early)
    local target = self.path[self._path_target_index]

    if target then
      local angle = math.atan(target.y - self.y, target.x - self.x)

      local vel_x = math.cos(angle) * self.speed
      local vel_y = math.sin(angle) * self.speed

      self.x = self.x + vel_x * delta_time
      self.y = self.y + vel_y * delta_time

      local distance = math.sqrt((target.x - self.x) ^ 2 + (target.y - self.y) ^ 2)

      Net.move_bot(self._id, self.x, self.y, self.z)

      if distance < self.speed * delta_time then
        self._path_target_index = self._path_target_index % #self.path + 1
      end
    end

    if self["on_tick"] then
       self:on_tick(delta_time)
    end
  end

  function bot:handle_player_join(player_id)
    if self["on_player_join"] then
      self:on_player_join(player_id)
    end
  end

  function bot:message_player(player_id, message)
    Net.message_player(player_id, message, self.mug_texture_path, self.mug_animation_path)
  end

  function bot:question_player(player_id, message)
    Net.question_player(player_id, message, self.mug_texture_path, self.mug_animation_path)
  end

  function bot:quiz_player(player_id, option_a, option_b, option_c)
    Net.quiz_player(player_id, option_a, option_b, option_c, self.mug_texture_path, self.mug_animation_path)
  end

  function bot:face_player(player_id)
    local dir = Net.get_player_direction(player_id)
    local my_dir

    if dir == "Up Left" then
      my_dir = "Down Right"
    elseif dir == "Up" then
      my_dir = "Down"
    elseif dir == "Up Right" then
      my_dir = "Down Left"
    elseif dir == "Right" then
      my_dir = "Left"
    elseif dir == "Down Right" then
      my_dir = "Up Left"
    elseif dir == "Down" then
      my_dir = "Up" 
    elseif dir == "Down Left" then 
      my_dir = "Up Right"
    elseif dir == "Left" then 
      my_dir = "Right"
    end 

    Net.set_bot_direction(self._id, my_dir)
  end

  function bot:face(direction)
    Net.set_bot_direction(self._id, direction)
  end
    
  function bot:handle_actor_interaction(player_id, other_id)
    if other_id ~= self._id then
      return
    end

    if self["on_interact"] then
      self:on_interact(player_id)
    end
  end

  function bot:handle_player_response(player_id, response)
    if self["on_response"] then
      self:on_response(player_id, response)
    end
  end

  function bot:handle_player_disconnect(player_id)
    if self["on_disconnect"] then
      self:on_disconnect(player_id)
    end
  end

  function bot:handle_player_transfer(player_id)
    if self["on_transfer"] then
      self:on_transfer(player_id)
    end
  end

  Net.create_bot(id, {
    name = name,
    area_id = area_id,
    texture_path = texture_path,
    animation_path = animation_path,
    x = x,
    y = y,
    z = z,
    solid = solid
  })

  return bot
end

return create_custom_bot
