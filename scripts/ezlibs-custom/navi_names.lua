local naviNamePlugin = {}

naviNamePlugin.player_navi_names = {}

Net:on("player_avatar_change", function(event)
    naviNamePlugin.player_navi_names[event.player_id] = event.name
    print(event.name)
end)

return naviNamePlugin