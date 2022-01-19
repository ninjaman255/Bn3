function handle_tile_interaction(player_id, x, y, z)
end

function has_player(area_id, x, y, z)
  local player_ids = Net.list_players(area_id)

  for i = 1, #player_ids, 1 do
    local player_pos = Net.get_player_position(player_ids[i])

    if
      x == math.floor(player_pos.x) and
      y == math.floor(player_pos.y) and
      z == math.floor(player_pos.z)
    then
      -- block updates to this tile
      return true
    end
  end

  return false
end

