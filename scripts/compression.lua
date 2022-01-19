-- this script might be slow with enough players, but eh
-- add Rect objects with a custom bool property of Compress or Decompress

local colliders = {}
local compressed_players = {}

function handle_player_move(player_id, x, y, z)
  local area_id = Net.get_player_area(player_id)

  local area_colliders = colliders[area_id]

  for _, collider in ipairs(area_colliders) do
    if is_colliding(collider, x, y, z) then
      if collider.custom_properties.Compress then
        compress(player_id)
      elseif collider.custom_properties.Decompress then
        decompress(player_id)
      end

      break
    end
  end
end

function is_colliding(collider, x, y, z)
  return collider.z == z and
         x > collider.x and x < collider.x + collider.width and
         y > collider.y and y < collider.y + collider.height
end

function compress(player_id)
  if compressed_players[player_id] then
    -- already compressed
    return
  end

  Net.animate_player_properties(player_id, {
    {
      properties = {
        { property = "ScaleX", value = 3/8, ease = "Linear" },
        { property = "ScaleY", value = 3/8, ease = "Linear" }
      },
      duration = .25
    }
  })

  compressed_players[player_id] = true
end

function decompress(player_id)
  if not compressed_players[player_id] then
    -- not yet compressed
    return
  end

  Net.animate_player_properties(player_id, {
    {
      properties = {
        { property = "ScaleX", value = 1, ease = "Linear" },
        { property = "ScaleY", value = 1, ease = "Linear" }
      },
      duration = .25
    }
  })

  compressed_players[player_id] = nil
end

function handle_player_disconnect(player_id)
  compressed_players[player_id] = nil
end

for _, area_id in ipairs(Net.list_areas()) do
  local area_colliders = {}

  for _, object_id in ipairs(Net.list_objects(area_id)) do
    local object = Net.get_object_by_id(area_id, object_id)

    if object.custom_properties.Compress or object.custom_properties.Decompress then
      area_colliders[#area_colliders+1] = object
    end
  end

  colliders[area_id] = area_colliders
end
