function handle_object_interaction(player_id, object_id, button)
  if button ~= 0 then return end

  local area_id = Net.get_player_area(player_id)

  local object = Net.get_object_by_id(area_id, object_id)
  local flavorText = object.custom_properties.Flavor

  if flavorText ~= nil then
    Net.message_player(player_id, flavorText)
  end
end