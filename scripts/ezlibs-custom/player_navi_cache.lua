local playerNaviCachePlugin = {}

playerNaviCachePlugin.player_navi_names = {}
playerNaviCachePlugin.player_navi_texture_path = {}
playerNaviCachePlugin.player_navi_animation_path = {}
playerNaviCachePlugin.player_navi_mug_texture_path = {}
playerNaviCachePlugin.player_navi_mug_animation_path = {}
playerNaviCachePlugin.player_navi_element = {}
playerNaviCachePlugin.player_navi_max_health = {}

Net:on("player_avatar_change", function(event)
    local mug_data = Net.get_player_mugshot(event.player_id)

    playerNaviCachePlugin.player_navi_names[event.player_id] = event.name
    playerNaviCachePlugin.player_navi_texture_path[event.player_id] = event.texture_path
    playerNaviCachePlugin.player_navi_animation_path[event.player_id] = event.animation_path
    playerNaviCachePlugin.player_navi_mug_texture_path[event.player_id] = mug_data.texture_path
    playerNaviCachePlugin.player_navi_mug_animation_path[event.player_id] = mug_data.animation_path
    playerNaviCachePlugin.player_navi_element[event.player_id] = event.element
    playerNaviCachePlugin.player_navi_max_health[event.player_id] = event.max_health

    print("Player Navi Cache Plugin ran")
end)

return playerNaviCachePlugin