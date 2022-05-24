local CustPlugin = {} --Required! Doesn't have to be called this, but DOES need to exist!

local ezcheckpoints = require('scripts/ezlibs-custom/ezcheckpoints')

local nebulibs = require('scripts/ezlibs-custom/nebulous-liberations/main') --Required! Include Nebulous Liberations!

local plugins = {nebulibs, ezcheckpoints} --Required! Make sure you list all the plugins you're including here!



--Required! Pass handlers on to all the libraries we are using!
--Make them properties of what we called the blank object at the top!
function CustPlugin.handle_battle_results(player_id, stats)
  for i,plugin in ipairs(plugins)do
    if plugin.handle_battle_results then
      plugin.handle_battle_results(player_id, stats)
    end
  end
end

function CustPlugin.handle_custom_warp(player_id, object_id)
  for i,plugin in ipairs(plugins)do
      if plugin.handle_custom_warp then
          plugin.handle_custom_warp(player_id, object_id)
      end
  end
end

function CustPlugin.handle_player_move(player_id, x, y, z)
  for i,plugin in ipairs(plugins)do
      if plugin.handle_player_move then
          plugin.handle_player_move(player_id, x, y, z)
      end
  end
end

function CustPlugin.handle_player_request(player_id, data)
  for i,plugin in ipairs(plugins)do
      if plugin.handle_player_request then
          plugin.handle_player_request(player_id, data)
      end
  end
end

function CustPlugin.handle_tile_interaction(player_id, x, y, z, button)
  for i,plugin in ipairs(plugins)do
      if plugin.handle_tile_interaction then
          plugin.handle_tile_interaction(player_id, x, y, z, button)
      end
  end
end

function CustPlugin.handle_post_selection(player_id, post_id)
  for i,plugin in ipairs(plugins)do
      if plugin.handle_post_selection then
          plugin.handle_post_selection(player_id, post_id)
      end
  end
end

function CustPlugin.handle_board_close(player_id)
  for i,plugin in ipairs(plugins)do
      if plugin.handle_board_close then
          plugin.handle_board_close(player_id)
      end
  end
end

function CustPlugin.handle_player_avatar_change(player_id, details)
  for i,plugin in ipairs(plugins)do
      if plugin.handle_player_avatar_change then
          plugin.handle_player_avatar_change(player_id, details)
      end
  end
end

function CustPlugin.handle_player_join(player_id)
  for i,plugin in ipairs(plugins)do
      if plugin.handle_player_join then
          plugin.handle_player_join(player_id)
      end
  end
end

function CustPlugin.handle_actor_interaction(player_id, actor_id, button)
  for i,plugin in ipairs(plugins)do
      if plugin.handle_actor_interaction then
          plugin.handle_actor_interaction(player_id,actor_id, button)
      end
  end
end

function CustPlugin.on_tick(delta_time)
  for i,plugin in ipairs(plugins)do
      if plugin.on_tick then
          plugin.on_tick(delta_time)
      end
  end
end

function CustPlugin.handle_player_disconnect(player_id)
  for i,plugin in ipairs(plugins)do
      if plugin.handle_player_disconnect then
          plugin.handle_player_disconnect(player_id)
      end
  end
end
function CustPlugin.handle_object_interaction(player_id, object_id, button)
  for i,plugin in ipairs(plugins)do
      if plugin.handle_object_interaction then
          plugin.handle_object_interaction(player_id,object_id, button)
      end
  end
end
function CustPlugin.handle_player_transfer(player_id)
  for i,plugin in ipairs(plugins)do
      if plugin.handle_player_transfer then
          plugin.handle_player_transfer(player_id)
      end
  end
end
function CustPlugin.handle_textbox_response(player_id, response)
  for i,plugin in ipairs(plugins)do
      if plugin.handle_textbox_response then
          plugin.handle_textbox_response(player_id, response)
      end
  end
end

--Required! Return the object!
return CustPlugin
