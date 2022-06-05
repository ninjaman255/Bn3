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

local GrantLiberationAbility = {
    name = "Grant Liberation Mission Ability",
    action = function(npc, player_id, dialogue, relay_object)
        return async(function()
            ezmemory.create_or_update_item("LongSwrd","A Long Sword Chip. Use it in Liberations!",true)
            local item_count = ezmemory.count_player_item(player_id, "LongSwrd")
            if item_count > 0 then ezmemory.remove_player_item(player_id, "LongSwrd", item_count) end

            ezmemory.create_or_update_item("WideSwrd","A Wide Sword Chip. Use it in Liberations!",true)
            item_count = ezmemory.count_player_item(player_id, "WideSwrd")
            if item_count > 0 then ezmemory.remove_player_item(player_id, "WideSwrd", item_count) end

            ezmemory.create_or_update_item("OldSaber","A Saber projection hilt, scarred with age. Use it in Liberations!",true)
            item_count = ezmemory.count_player_item(player_id, "OldSaber")
            if item_count > 0 then ezmemory.remove_player_item(player_id, "OldSaber", item_count) end

            ezmemory.create_or_update_item("HevyShld","A heavy shield, great for defense. Use it in Liberations!",true)
            item_count = ezmemory.count_player_item(player_id, "HevyShld")
            if item_count > 0 then ezmemory.remove_player_item(player_id, "HevyShld", item_count) end

            ezmemory.create_or_update_item("HexScyth","A wicked scythe which cleaves most anything. Use it in Liberations!",true)
            item_count = ezmemory.count_player_item(player_id, "HexScyth")
            if item_count > 0 then ezmemory.remove_player_item(player_id, "HexScyth", item_count) end

            ezmemory.create_or_update_item("NumGadgt","A gadget that's constantly calculating outcomes. Use it in Liberations!",true)
            item_count = ezmemory.count_player_item(player_id, "NumGadgt")
            if item_count > 0 then ezmemory.remove_player_item(player_id, "NumGadgt", item_count) end
            ezmemory.create_or_update_item("GutsHamr","A hammer that takes guts to wield. Use it in Liberations!",true)
            item_count = ezmemory.count_player_item(player_id, "GutsHamr")
            if item_count > 0 then ezmemory.remove_player_item(player_id, "GutsHamr", item_count) end

            ezmemory.create_or_update_item("ShdwShoe","Delicate shoes that let you walk on air. Wear them in Liberations!",true)
            item_count = ezmemory.count_player_item(player_id, "ShdwShoe")
            if item_count > 0 then ezmemory.remove_player_item(player_id, "ShdwShoe", item_count) end

            if dialogue.custom_properties["Ability Item"] ~= nil then ezmemory.give_player_item(player_id, dialogue.custom_properties["Ability Item"], 1) end
        end)
    end
}
eznpcs.add_event(GrantLiberationAbility)