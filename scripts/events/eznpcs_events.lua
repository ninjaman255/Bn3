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
            Async.initiate_encounter(player_id, "/server/assets/mobs/Alpha.zip")
        end)
    end
}
eznpcs.add_event(AlphaFight)