local flavorTextMap = {
  ["/server/assets/tiles/coffee.tsx"] = "A cafe sign.\nYou feel welcomed.",
  ["/server/assets/tiles/gate.tsx"] = "The gate needs a key to get through.",
  ["/server/assets/tiles/BattleMachineBN4.tsx"] = "Oh cool! This is a battle machine normally used in tournements in the real world! I wonder what this is doing in the cyberworld?",
  ["/server/assets/tiles/nebula_door.tsx"] = "DANGER! DANGER! DANGER! AUTHORIZED PERSONEL ONLY!",
  ["/server/assets/tiles/evildoor_40x74.tsx"] = "DANGER! DANGER! DANGER! AUTHORIZED PERSONEL ONLY!"
}

local Area1 = "default"


function handle_object_interaction(player_id, object_id)
  local area_id = Net.get_player_area(player_id)

  local object = Net.get_object_by_id(area_id, object_id)
  local tileGid = object.data.gid;
  local tileset = Net.get_tileset_for_tile(area_id, tileGid)


  local flavorText = flavorTextMap[tileset.path]
  local area = area_id

  if area == Area1 and tileset == flavorTextMap["/server/assets/tiles/evildoor_40x74.tsx"] then
    flavorText["/server/assets/tiles/evildoor_40x74.tsx"] = "FOR TOURNEMENT USE ONLY PLEASE PRESENT YOUR TOURNEMENT ID!"
else if area == nil then return
end
end

  if flavorText ~= nil then
    Net.message_player(player_id, flavorText)
  end
end
