local Area1 = "default"
local Area2 = "ACDC3"
local Area3 = "ACDC2"
local Area4 = "Yoka1"
local Area5 = "Yoka2"
local Area6 = "ACDCSqr"
local Area7 = "Beachside"
local Area8 = "YokaSqr"
local Area9 = "Scilab2"
local Area10 = "ShademanComp1"
local Area11 = "ShademanComp2"
local Area12 = "AlphaComp"
local Area13 = "Scilab1"
local Area14 = "Beachside2"
local Area15 = "Hades"
local Area16 = "Undernet1"
local Area17 = "Undernet2"
local Area18 = "Undernet3"
local Area19 = "Undernet4"
local Area20 = "Undernet5"
local Area21 = "Undernet6"
local Area22 = "Undernet7"
--
local create_custom_bot = require('/scripts/bot/create_custom_bot')
--local CameraFade = require("scripts/libs/camera").Fade

--
local Lonely_pos = Net.get_object_by_name(Area6, "lonely")
local lonely = create_custom_bot("lonely", "Lonely", "ACDCSqr", "/server/assets/tiles/bots&animations/Green Normal Navi/Green_Normal.png", "/server/assets/tiles/bots&animations/Green Normal Navi/character.animation", 9.5, 1.5, 1.0, true)
lonely.mug_texture_path = "/server/assets/tiles/bots&animations/Green Normal Navi/Happy.png"
lonely.mug_animation_path = "/server/assets/tiles/bots&animations/Green Normal Navi/Happy.animation"
Net.set_bot_direction("lonely", "Down Left")
print("lonely made")
--
local Progineer1_pos = Net.get_object_by_name(Area1, "progineer1")
local progineer1 = create_custom_bot("progineer1", "Progineer1", Area1, "/server/assets/tiles/bots&animations/Engineer Prog/engineerprog.png", "/server/assets/tiles/bots&animations/Engineer Prog/engineerprog.animation", Progineer1_pos.x, Progineer1_pos.y, 2.0, true)
progineer1.mug_texture_path = "/server/assets/tiles/bots&animations/Engineer Prog/mug.png"
progineer1.mug_animation_path = "/server/assets/tiles/bots&animations/Engineer Prog/mug.animation"
Net.set_bot_direction("progineer1", "Down Left")
print("progineer1 made")
--
local Progineer2_pos = Net.get_object_by_name(Area8, "progineer2")
local progineer2 = create_custom_bot("progineer2", "Progineer2", Area8, "/server/assets/tiles/bots&animations/Engineer Prog/engineerprog.png", "/server/assets/tiles/bots&animations/Engineer Prog/engineerprog.animation", Progineer2_pos.x, Progineer2_pos.y, 9.0, true)
progineer2.mug_texture_path = "/server/assets/tiles/bots&animations/Engineer Prog/mug.png"
progineer2.mug_animation_path = "/server/assets/tiles/bots&animations/Engineer Prog/mug.animation"
Net.set_bot_direction("progineer2", "Down Left")
print("progineer2")
--
local Progineer3_pos = Net.get_object_by_name(Area7, "progineer3")
local progineer3 = create_custom_bot("progineer3", "Progineer3", "Beachside", "/server/assets/tiles/bots&animations/Engineer Prog/engineerprog.png", "/server/assets/tiles/bots&animations/Engineer Prog/engineerprog.animation", 4.5, 6.5, 2.0, true)
progineer3.mug_texture_path = "/server/assets/tiles/bots&animations/Engineer Prog/mug.png"
progineer3.mug_animation_path = "/server/assets/tiles/bots&animations/Engineer Prog/mug.animation"
Net.set_bot_direction("progineer3", "Down Left")
print("progineer3 made")
--
local Progineer4_pos = Net.get_object_by_name(Area9, "progineer4")
local progineer4 = create_custom_bot("progineer4", "Progineer4", "Scilab2", "/server/assets/tiles/bots&animations/Engineer Prog/engineerprog.png", "/server/assets/tiles/bots&animations/Engineer Prog/engineerprog.animation", 25.5, 27.5, 2.0, true)
progineer4.mug_texture_path = "/server/assets/tiles/bots&animations/Engineer Prog/mug.png"
progineer4.mug_animation_path = "/server/assets/tiles/bots&animations/Engineer Prog/mug.animation"
Net.set_bot_direction("progineer4", "Down Left")
print("progineer4 made")

--
local Alpha_pos = Net.get_object_by_name(Area12, "alpha")
local alpha = create_custom_bot("alpha", "Alpha", Area12, "/server/assets/tiles/bots&animations/AlphaOW/alphaOW.png", "/server/assets/tiles/bots&animations/AlphaOW/alphaOW.animation", 7.5,4.4, 1.0, true)
alpha.mug_texture_path = nil
alpha.mug_animation_path = nil
Net.set_spawn_direction = "Down Left"
print("alpha Made")
--
bots = {
    lonely,
    progineer1,
    progineer2,
    progineer3,
    progineer4,
    alpha,
--
}

function tick(delta_time)
    for i = 1, #bots do
        if bots[i].talking_to == nil then
            bots[i]:tick(delta_time)
        end
    end
end

-- events
function handle_actor_interaction(player_id, other_id)
    print("actor interaction " .. player_id .. " " .. other_id)
    for i = 1, #bots do
        bots[i]:handle_actor_interaction(player_id, other_id)
    end
end

progineer1.state = {}
progineer2.state = {}
progineer3.state = {}
progineer4.state = {}
lonely.state = {}
progineer1.has_been_introduced = {}
progineer2.has_been_introduced = {}
progineer3.has_been_introduced = {}
progineer4.has_been_introduced = {}
lonely.SpookLevel = {}

function lonely:on_interact(player_id)
    --lonely:message_player(player_id, "Im so Lonely\x01...\x01I'm Mr. Lonely\x01...\x01I have nobody for my own.")
   --[[ if self.Spooklevel ~= 1 then
        --
        lonely.mug_texture_path = "/server/assets/tiles/bots&animations/Green Normal Navi/Spooked.png"
        lonely.mug_animation_path = "/server/assets/tiles/bots&animations/Green Normal Navi/Spooked.animation"
        --
        --]]
    self:message_player(player_id,"I Just saw a bunch of people on my way to the square! it seems like each day after you showed up more and more navis started popping up out of the wood works")
        --self.SpookLevel[player_id] = 1
        self.state[player_id] = 0

end

function progineer1:on_interact(player_id)
    if not self.has_been_introduced[player_id] then
        self:message_player(player_id, "Oh! its been a while, you probably dont remember me. Ive ran these here metro lines for years and with the recent advancements in technology and my recent promotion i now can teleport you.")
        progineer1.has_been_introduced[player_id] = true
        progineer2.has_been_introduced[player_id] = true
        progineer3.has_been_introduced[player_id] = true
        progineer4.has_been_introduced[player_id] = true
        self.state[player_id] = 0
    else
        self.state[player_id] = 1
    end
    self:quiz_player(player_id, "Yoka", "Sci-Lab", "Beachside")
end


function progineer2:on_interact(player_id)
    if not self.has_been_introduced[player_id] then
        self:message_player(player_id, "Oh! its been a while, you probably dont remember me. Ive ran these here metro lines for years and with the recent advancements in technology and my recent promotion i now can teleport you.")
        progineer1.has_been_introduced[player_id] = true
        progineer2.has_been_introduced[player_id] = true
        progineer3.has_been_introduced[player_id] = true
        progineer4.has_been_introduced[player_id] = true
        self.state[player_id] = 0
    else
        self.state[player_id] = 1
    end
    self:quiz_player(player_id, "ACDC", "Sci-Lab", "Beachside")
end



function progineer3:on_interact(player_id)
    if not self.has_been_introduced[player_id] then
        self:message_player(player_id, "Oh! its been a while, you probably dont remember me. Ive ran these here metro lines for years and with the recent advancements in technology and my recent promotion i now can teleport you.")
        progineer1.has_been_introduced[player_id] = true
        progineer2.has_been_introduced[player_id] = true
        progineer3.has_been_introduced[player_id] = true
        progineer4.has_been_introduced[player_id] = true
        self.state[player_id] = 0
    else
        self.state[player_id] = 1
    end
    self:quiz_player(player_id, "ACDC", "Sci-Lab", "Yoka")
end



function progineer4:on_interact(player_id)
    if not self.has_been_introduced[player_id] then
        self:message_player(player_id, "Oh! its been a while, you probably dont remember me. Ive ran these here metro lines for years and with the recent advancements in technology and my recent promotion i now can teleport you.")
        progineer1.has_been_introduced[player_id] = true
        progineer2.has_been_introduced[player_id] = true
        progineer3.has_been_introduced[player_id] = true
        progineer4.has_been_introduced[player_id] = true
        self.state[player_id] = 0
    else
        self.state[player_id] = 1
    end
    self:quiz_player(player_id, "ACDC", "Beach", "Yoka")
end

function handle_textbox_response(player_id, response)
    for i = 1, #bots do
        bots[i]:handle_player_response(player_id, response)
    end
end


--Test Block Phase 2
--function lonely:on_response(player_id, response)
    --if not self.state[player_id] then
        -- we're not talking to you
       -- return
    --end

    --if self.state[player_id] ~= 1 then
        -- player responds to two messages before the "fine evening?" question
        --self.state[player_id] = self.state[player_id] + 1
        --return
    --end

    --[[if response == 0 then

        --
        lonely.mug_texture_path = "/server/assets/tiles/bots&animations/Green Normal Navi/Cry.png"
        lonely.mug_animation_path = "/server/assets/tiles/bots&animations/Green Normal Navi/Cry.animation"
        --

        self:message_player(player_id,"Oh ok, great I truely have lost it havent I...")
    elseif response == 1 then

        --
        lonely.mug_texture_path = "/server/assets/tiles/bots&animations/Green Normal Navi/Quizically.png"
        lonely.mug_animation_path = "/server/assets/tiles/bots&animations/Green Normal Navi/Quizically.animation"
        --

        self:message_player(player_id,"Theres no way thats true, I woke up from a long Update cycle and went about my daily routine to visit my friends at the square. As I walked I noticed noone was walking the paths, which was offputting, but it was early morning so that made sense. I enter the metro to head to the Square in ACDC Area,  but when I finally arrived at the square it's dead, noone here, vendor was gone, the shortcut was gone. It was like a ghost town. The Progineer seems like he had an update too, but otherwise noone else was around. This is the first time ive seen someone else in many years, I thought my mind was just playing tricks on me the last time i saw you")
    end
    self.state[player_id] = nil
end]]--
-- Test Block End

function progineer1:on_response(player_id, response)
    if not self.state[player_id] then
        -- we're not talking to you
        return
    end

    if self.state[player_id] ~= 1 then
        -- player responds to two messages before the "fine evening?" question
        self.state[player_id] = self.state[player_id] + 1
        return
    end
    
    if response == 0 then
        Net.transfer_player(player_id, Area8, true, 12.5, 7.5, 9.0, "Down Left")
    elseif response == 1 then
        Net.transfer_player(player_id, Area9, true, 25.5, 28.5, 2.0, "Down Left")
    elseif response == 2 then
        Net.transfer_player(player_id, Area7, true, 4.5, 7.5, 2.0, "Down Left")
    end
    self.state[player_id] = nil
end
    
function progineer2:on_response(player_id, response)
    if not self.state[player_id] then
        -- we're not talking to you
        return
    end

    if self.state[player_id] ~= 1 then
        -- player responds to two messages before the "fine evening?" question
        self.state[player_id] = self.state[player_id] + 1
        return
    end
    
    if response == 0 then
        Net.transfer_player(player_id, Area1, true, 16.5, 23.5, 2.0, "Down Left")
    elseif response == 1 then
        Net.transfer_player(player_id, Area9, true, 25.5, 28.5, 2.0, "Down Left")
    elseif response == 2 then
        Net.transfer_player(player_id, Area7, true, 4.5, 7.5, 2.0, "Down Left")
    end
    self.state[player_id] = nil -- set to nil to free memory, this should be done on disconnect as well
end

function progineer3:on_response(player_id, response)
    if not self.state[player_id] then
        -- we're not talking to you
        return
    end

    if self.state[player_id] ~= 1 then
        -- player responds to two messages before the "fine evening?" question
        self.state[player_id] = self.state[player_id] + 1
        return
    end
    
    if response == 0 then
        Net.transfer_player(player_id, Area1, true, 16.5, 23.5, 2.0, "Down Left")
    elseif response == 1 then
        Net.transfer_player(player_id, Area9, true, 25.5, 28.5, 2.0, "Down Left")
    elseif response == 2 then
        Net.transfer_player(player_id, Area8, true, 12.5, 7.5, 9.0, "Down Left")
    end
    self.state[player_id] = nil -- set to nil to free memory, this should be done on disconnect as well
end

function progineer4:on_response(player_id, response)
    if not self.state[player_id] then
        -- we're not talking to you
        return
    end

    if self.state[player_id] ~= 1 then
        -- player responds to two messages before the "fine evening?" question
        self.state[player_id] = self.state[player_id] + 1
        return
    end
    
    if response == 0 then
        Net.transfer_player(player_id, Area1, true, 16.5, 23.5, 2.0, "Down Left")
    elseif response == 1 then
        Net.transfer_player(player_id, Area7, true, 4.5, 7.5, 2.0, "Down Left")
    elseif response == 2 then
        Net.transfer_player(player_id, Area8, true, 12.5, 7.5, 9.0, "Down Left")
    end
    self.state[player_id] = nil -- set to nil to free memory, this should be done on disconnect as well
end

function handle_player_transfer(player_id)
    for i = 1, #bots do
        bots[i]:handle_player_transfer(player_id)
    end
end

function handle_player_disconnect(player_id)
    for i = 1, #bots do
        bots[i]:handle_player_disconnect(player_id)
    end
end

--function handle_player_join(player_id)

--end

function handle_player_join(player_id)
    return
end
