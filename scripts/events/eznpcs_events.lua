local eznpcs = require('scripts/ezlibs-scripts/eznpcs/eznpcs')
local ezmemory = require('scripts/ezlibs-scripts/ezmemory')
local ezmystery = require('scripts/ezlibs-scripts/ezmystery')
local ezweather = require('scripts/ezlibs-scripts/ezweather')
local ezwarps = require('scripts/ezlibs-scripts/ezwarps/main')
local ezencounters = require('scripts/ezlibs-scripts/ezencounters/main')
local helpers = require('scripts/ezlibs-scripts/helpers')

local AlphaFight = {
    name="AlphaFight",
    action=function (npc,player_id,dialogue,relay_object)
        return async(function()
            await(Async.message_player(player_id, "FOOOOOOOODDDDDD", "/server/assets/ezlibs-assets/eznpcs/mug/alpha.png", "/server/assets/ezlibs-assets/eznpcs/mug/mug.animation"))
            await(Async.initiate_encounter(player_id, "/server/assets/mobs/Alpha.zip"))
        end)
    end
}
eznpcs.add_event(AlphaFight)

local StartLiberationAlpha1 ={
    name = "StartLiberationAlpha1",
    action = function(npc, player_id, dialogue, relay_object)
        return async(function()
            return LibPlugin.start_game_for_player(player_id, "AlphaLib1")
        end)
    end
}
eznpcs.add_event(StartLiberationAlpha1)