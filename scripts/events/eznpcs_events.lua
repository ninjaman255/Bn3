local eznpcs = require('scripts/ezlibs-scripts/eznpcs/eznpcs')
local eztriggers = require('scripts/ezlibs-scripts/eztriggers')
local ezmemory = require('scripts/ezlibs-scripts/ezmemory')
local ezmystery = require('scripts/ezlibs-scripts/ezmystery')
local ezweather = require('scripts/ezlibs-scripts/ezweather')
local ezshortcuts = require('scripts/ezlibs-custom/ezshortcuts')
local ezwarps = require('scripts/ezlibs-scripts/ezwarps/main')
local ezencounters = require('scripts/ezlibs-scripts/ezencounters/main')
local helpers = require('scripts/ezlibs-scripts/helpers')
local playerNaviCache = require('scripts/ezlibs-custom/player_navi_cache')

local bass = {
    texture = "/server/assets/ezlibs-assets/eznpcs/mug/bass.png",
    anim = "/server/assets/ezlibs-assets/eznpcs/mug/mug.animation"
}

local wily = {
    texture = "/server/assets/ezlibs-assets/eznpcs/mug/wily.png",
    anim = "/server/assets/ezlibs-assets/eznpcs/mug/mug.animation"
}

local lan = {
    texture = "/server/assets/ezlibs-assets/eznpcs/mug/Netto-EXE3.png",
    anim = "/server/assets/ezlibs-assets/eznpcs/mug/Netto-EXE3.animation",
}

local wily_lines = {
[[
Bass!
That is Dr. Hikari's 
greatest protection program...
"Guardian"!


If you destroy it, absorb it with your Ability Program...
You'll have even greater powers!
]],
[[
I desire only chaos and the 
destruction of Net society...
Why else would I desire to make you stronger?
]],
[[
It is your desire for revenge that brings us together.
What do I care if this aged body is destroyed...?
As long as you fulfill your desires I will be satisfied.
]],
[[
You again!
So you dared to pulse in!!
]],
[[
Hmm...And I was hoping that you'd delete each other...
]],
[[
Bass, the Guardian program that you destroyed...
It was the final protection placed on Alpha!
It takes a lot to destroy it, you know.
So I used your power.

It's the reason I used Gospel to make a copy of you!


Just to bring back Alpha!
]],
[[
Navis are, after all, just tools to use!!
Do you see it now?!
I would use anything to complete my plan!
]],
[[
Here it comes!!
Here it comes!!
Finally!!
Alpha's awakening! It's the end of Network society!
]]
}

local bass_lines = {
[[
Old man! What are you planning, making me stronger?
]],
[[
But you are mistaken...

It is not Net
society that I hate,
but you humans!
]],
[[
So you would sacrifice even your life for this?
You amuse me...


Just watch,old man! Watch me become even stronger!!
]],
[[
So this is the Guardian core.

If I abosorb this...

Nothing in Cyberworld will be
stronger than me!
Get Ability Program!
]],
[[
You again!? The Navi with the idiot of a human operator!
]],
[[
Humans think of Navis as merely a tools to be used.
Navis who don't realize that are just as foolish.
]],
[[
Silence!
Exactly what I would expect from a human...
Navis have no need for operators...


All we need is the strength to exist on our own!
Absolute power,so that we need cower before none.
I will weed out weak Navis who cannot fight on their own!
]],
[[
Hah!! You think that I retain such pathetic emotions!?
Time for you to be deleted!
]],
[[
I cannot...
I cannot have lost...
]],
[[
What...?!
]],
[[
Wily...You...
]],
[[
!!
]],
[[
Guraaagh!!


Graaaaaauggghh!
]]
}

local player_lines = {
[[
Wily!!
]],
[[
Bass!!


Humans aren't as
stupid as you
think they are!
]],
[[
Bass! Look back!
I know that you once felt it!
A feeling of trust
for Cossak!
]],
[[
Execute!
]],
[[
That dirty old man!
]],
[[
Woah!
]],
[[
Bass!
]]
}

local lan_lines = {
[[
I have never thought of %NAVI_NAME% as just a tool!!
We're true partners, who trust and respect each other!!
Even Cossak, who created you...
]],
[[
C'mon,%NAVI_NAME%!
Let's show him how
strong we are!
Battle routine,
set!
]]
}

local function format_message_tokens(msg, format_data)
    msg = msg:gsub("%%NAVI_NAME%%", format_data.player_name)
    return msg
end

local function wily_says(player_id, idx)
    return Async.message_player(player_id, wily_lines[idx], wily.texture, wily.anim)
end

local function bass_says(player_id, idx)
    return Async.message_player(player_id, bass_lines[idx], bass.texture, bass.anim)
end

local function make_player_says(player_id)
    local player_texture = playerNaviCache.player_navi_mug_texture_path[player_id]
    local player_anim = playerNaviCache.player_navi_mug_animation_path[player_id]

    return function(player_id, idx)
        return Async.message_player(player_id, player_lines[idx], player_texture, player_anim)
    end
end

local function lan_says(player_id, idx)
    local format_data = {
        player_name = playerNaviCache.player_navi_names[player_id]
    }

    return Async.message_player(player_id, format_message_tokens(lan_lines[idx], format_data), lan.texture, lan.anim)
end

local FinaleCutsceneTrigger = {
    name="FinaleCutsceneTrigger",
    action=function(player_id)
        local player_says = make_player_says(player_id)

        local bass_id = nil
        local wily_id = nil
        local bass_position = nil
        local player_pos_1 = nil
        local player_pos_2 = nil
        local camera_pos_1 = nil
        local camera_pos_2 = nil

        for _,v in ipairs(Net.list_bots("AlphaComp")) do
            if Net.get_bot_name(v) == "Bass" then
                bass_id = v
                bass_position = Net.get_bot_position(bass_id)
            end

            if Net.get_bot_name(v) == "Wily" then
                wily_id = v
            end
        end

        -- player position markers
        local temp = Net.get_object_by_name("AlphaComp", "FinalePlayerPos1")
        player_pos_1 = {x=temp.x,y=temp.y,z=temp.z}
        temp = Net.get_object_by_name("AlphaComp", "FinalePlayerPos2")
        player_pos_2 = {x=temp.x,y=temp.y,z=temp.z}

        -- camera pan markers
        temp = Net.get_object_by_name("AlphaComp", "CameraPos1")
        camera_pos_1 = {x=temp.x,y=temp.y,z=temp.z}
        temp = Net.get_object_by_name("AlphaComp", "CameraPos2")
        camera_pos_2 = {x=temp.x,y=temp.y,z=temp.z}

        -- alpha pillar setup
        local pillar = Net.get_object_by_name("AlphaComp", "AlphaPillar")

        Net.include_object_for_player(player_id, pillar.id);

        -- wily setup
        Net.set_bot_direction(wily_id, "Up Left")

        -- bass setup
        Net.move_bot(bass_id, bass_position.x, bass_position.y, bass_position.z)
        Net.animate_bot(bass_id, "IDLE_DL", true)
        Net.include_actor_for_player(player_id, bass_id);

        -- other asset preloading
        Net.provide_asset("AlphaComp", "/server/assets/cutscene/alpha_eat.ogg")
        Net.provide_asset("AlphaComp", "/server/assets/cutscene/bass_attack_stone.ogg")
        Net.provide_asset("AlphaComp", "/server/assets/cutscene/bass_charge.ogg")

        return async(function()
            Net.lock_player_input(player_id)

            -- animate the player running
            Net.animate_player_properties(player_id,{
                {
                    properties={{
                        property="X",
                        ease="Linear",
                        value=player_pos_2.x
                    },
                    {
                        property="Y",
                        ease="Linear",
                        value=player_pos_2.y
                    }},
                    duration=3.0
                }
            })

            Net.fade_player_camera(player_id, {r=0,g=0,b=0}, 0.5)
            await(Async.sleep(0.5))
            Net.animate_player_properties(player_id,{
                {
                    properties={{
                        property="X",
                        value=player_pos_1.x
                    },
                    {
                        property="Y",
                        value=player_pos_1.y
                    }}
                }
            })
            Net.move_player_camera(player_id, camera_pos_1.x, camera_pos_1.y, camera_pos_1.z)
            Net.fade_player_camera(player_id, {r=0,g=0,b=0,a=0}, 0.5)
            await(Async.sleep(0.5))
            await(wily_says(player_id, 1))
            await(bass_says(player_id, 1))
            await(wily_says(player_id, 2))
            await(bass_says(player_id, 2))
            await(wily_says(player_id, 3))
            await(bass_says(player_id, 3))
            Net.animate_bot_properties(bass_id, {
                {
                    properties={{
                        property="Animation",
                        value="IDLE_DL"
                    }},
                },
                {
                    properties={{
                        property="Animation",
                        value="EARTH_BREAKER_REVEAL_L"
                    }},
                    duration = 0.0
                },
                {
                    properties={
                        {
                            property="Animation",
                            value="EARTH_BREAKER_CHARGE_L"
                        },
                        {
                            property="Sound Effect",
                            value="/server/assets/cutscene/bass_charge.ogg"
                        }
                    },
                    duration = 0.15
                },
                {
                    properties={
                        {
                            property="Animation",
                            value="EARTH_BREAKER_L"
                        },
                        {
                            property="Sound Effect",
                            value="/server/assets/cutscene/bass_attack_stone.ogg"
                        }
                    },
                    duration = 0.15*20
                },
                {
                    properties={{
                        property="Animation",
                        value="EARTH_BREAKER_HIDE_L"
                    }},
                    duration = 2.1
                },
                {
                    properties={{
                        property="Animation",
                        value="IDLE_DL"
                    }},
                    duration = 0.083
                }
            })
            await(Async.sleep(3.366))
            -- TODO white explosion ball ALSO covers screen
            Net.fade_player_camera(player_id, {r=255,g=255,b=255}, 1.0)
            await(Async.sleep(1.0))
            Net.play_sound_for_player(player_id, "/server/assets/cutscene/bass_destroy_stone.ogg")
            Net.exclude_object_for_player(player_id, pillar.id);
            await(Async.sleep(0.6))
            local giga_freeze_id = Net.create_bot({area_id="AlphaComp", warp_in=false, texture_path="/server/assets/cutscene/gigafreeze.png", animation_path="/server/assets/cutscene/gigafreeze.animation", x=pillar.x, y=pillar.y, z=pillar.z, direction="Down Left", animation="IDLE_DL"})
            Net.fade_player_camera(player_id, {r=255,g=255,b=255,a=0}, 0.5)
            await(Async.sleep(0.5))
            await(bass_says(player_id, 4))

            Net.animate_bot_properties(bass_id, {
                {
                    properties={{
                        property="Animation",
                        value="IDLE_DL"
                    }},
                },
                {
                    properties={{
                        property="Animation",
                        value="ABILITY_GET_START"
                    }},
                    duration = 0.0
                },
                {
                    properties={{
                        property="Animation",
                        value="ABILITY_GET_ARM"
                    }},
                    duration = 11.0/60.0
                }
            })

            Net.animate_bot_properties(giga_freeze_id, {
                {
                    properties={{
                        property="Y",
                        ease="Linear",
                        value=pillar.y
                    }},
                    duration = 1.0
                },
                {
                    properties={{
                        property="Y",
                        ease="Linear",
                        value=bass_position.y
                    }},
                    duration = 3.0
                }
            })

            await(Async.sleep(3.0 + (11.0/60.0))) -- sum of the animation time
            Net.remove_bot(giga_freeze_id, false);
            Net.play_sound_for_player(player_id, "/server/assets/cutscene/bass_acquire_gigafreeze.ogg")
            await(player_says(player_id, 1))
            Net.animate_player_properties(player_id,{
                {
                    properties={{
                        property="X",
                        value=player_pos_1.x
                    },
                    {
                        property="Y",
                        value=player_pos_1.y
                    }},
                },
                {
                    properties={{
                        property="X",
                        ease="Linear",
                        value=player_pos_2.x
                    },
                    {
                        property="Y",
                        ease="Linear",
                        value=player_pos_2.y
                    }},
                    duration=2.0
                },
                {
                    properties={{
                        property="Animation",
                        value="IDLE_UR"
                    }},
                    duration = 0.0
                }
            })
            Net.slide_player_camera(player_id, camera_pos_2.x, camera_pos_2.y, camera_pos_2.z, 0.5)
            Net.set_bot_direction(wily_id, "Down Left")
            Net.set_song("AlphaComp", "/server/assets/cutscene/face_bass_music.ogg")
            await(wily_says(player_id, 4))
            Net.animate_bot_properties(bass_id, {
                {
                    properties={{
                        property="Animation",
                        value="ABILITY_GET_SLOW"
                    }},
                    duration = 0.0
                },
                {
                    properties={{
                        property="Y",
                        value=bass_position.y,
                        ease="Linear"
                    }},
                    duration = 1.0
                },
                {
                    properties={{
                        property="Y",
                        value=pillar.y,
                        ease="Linear"
                    }},
                    duration = 2.0
                }
            })
            await(Async.sleep(4.0))
            await(bass_says(player_id, 5))
            await(player_says(player_id, 2))
            await(bass_says(player_id, 6))
            await(lan_says(player_id, 1))
            await(bass_says(player_id, 7))
            await(player_says(player_id, 3))
            await(bass_says(player_id, 8))
            await(lan_says(player_id, 2))
            await(player_says(player_id, 4))
            -- TODO: stop BG music for player here
            Net.set_song("AlphaComp", "/server/assets/cutscene/silence.ogg")
            await(Async.initiate_encounter(player_id, "/server/assets/mobs/BassBn3.zip"))
            -- TODO: stop BG music for player here (2nd time)
            Net.set_song("AlphaComp", "/server/assets/cutscene/silence.ogg")
            Net.animate_bot(bass_id, "WOUNDED", true)
            await(bass_says(player_id, 9))
            await(wily_says(player_id, 5))
            await(bass_says(player_id, 10))
            Net.set_song("AlphaComp", "/server/assets/cutscene/after_bass_battle_music.ogg")
            await(wily_says(player_id, 6))
            await(bass_says(player_id, 11))
            await(wily_says(player_id, 7))
            await(player_says(player_id, 5))
            await(Async.sleep(0.5))
            Net.play_sound_for_player(player_id, "/server/assets/cutscene/quake.ogg")
            Net.shake_player_camera(player_id, 3.0, 6)
            await(Async.sleep(0.5))
            await(player_says(player_id, 6))
            await(bass_says(player_id, 12))
            -- TODO: make sure we can cancel a quake in newer versions of the client!!!
            -- Net.shake_player_camera(player_id, 0.0, 6001) -- stop the shake immediately
            await(wily_says(player_id, 8))
            await(Async.sleep(0.5))
            local bass_blob_id = Net.create_bot({area_id="AlphaComp", warp_in=false, texture_path="/server/assets/cutscene/alpha_blob.png", animation_path="/server/assets/cutscene/alpha_blob.animation", x=pillar.x, y=pillar.y, z=pillar.z, animation="IDLE_DL", direction="Down Left"})
            Net.animate_bot_properties(bass_blob_id, {
                {
                    properties={
                        {
                            property="Animation",
                            value="BASS_SWALLOW"
                        },
                        {
                            property="Sound Effect",
                            value="/server/assets/cutscene/alpha_eat.ogg"
                        }
                    },
                    duration = 0.0
                },
                {
                    properties={{
                        property="Animation",
                        value="BASS_CONSUME"
                    }},
                    duration = 0.3
                },
            })
            await(Async.sleep(0.3))
            Net.exclude_actor_for_player(player_id, bass_id);
            await(Async.sleep(0.6))
            await(bass_says(player_id, 12))
            Net.animate_bot_properties(bass_blob_id, {
                {
                    properties={
                        {
                            property="Animation",
                            value="BASS_LEAVE"
                        },
                        {
                            property="Sound Effect",
                            value="/server/assets/cutscene/alpha_eat.ogg"
                        }
                    },
                    duration = 0.0
                },
            })
            await(Async.sleep(0.5))
            Net.remove_bot(bass_blob_id, false);
            await(player_says(player_id, 7))
            Net.unlock_player_input(player_id)
            Net.unlock_player_camera(player_id)
        end)
    end
}
eztriggers.add_event(FinaleCutsceneTrigger)

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

local CreateCheckpoint = {
    name = "CreateCheckpoint",
    action = function(npc, player_id, dialogue, relay_object)
        return async(function()
            warn("made it to CreateCheckpoint")
            local player_pos = Net.get_player_position(player_id)
            ezshortcuts.create_checkpoint(player_id, player_pos.x, player_pos.y, player_pos.z, true)
        end)
    end
}

eznpcs.add_event(CreateCheckpoint)

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