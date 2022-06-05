local cactikil_id = "com.discord.Konstinople#7692.enemy.cactikil" -- v1, EX
local cactroll_id = "com.discord.Konstinople#7692.enemy.cactroll" -- v1, EX
local cacter_id = "com.discord.Konstinople#7692.enemy.cacter" -- v1, EX
local powie_id = "com.discord.Konstinople#7692.enemy.powie" -- v1, EX
local powie2_id = "com.discord.Konstinople#7692.enemy.powie2" -- v1, EX
local powie3_id = "com.discord.Konstinople#7692.enemy.powie3"
local mettaur_id = "com.keristero.char.Mettaur" -- v1
local champy_id = "com.keristero.char.Champy" -- v1, v2
local chimpy_id = "com.keristero.char.Chimpy" -- v1
local chumpy_id = "com.keristero.char.Chumpy" -- v1
local canguard_id = "com.discord.Konstinople#7692.enemy.canodumb" -- v1, v1, v3, SP


--[[Test Block]]--
local spikey_id = "com.Dawn.mob.Spikey" -- V1, V2, V3

function package_requires_scripts()
    Engine.requires_character(cactikil_id)
    Engine.requires_character(cactroll_id)
    Engine.requires_character(cacter_id)
    Engine.requires_character(powie_id)
    Engine.requires_character(powie2_id)
    Engine.requires_character(powie3_id)
    Engine.requires_character(mettaur_id)
    Engine.requires_character(champy_id)
    Engine.requires_character(chimpy_id)
    Engine.requires_character(chumpy_id)
    Engine.requires_character(canguard_id)

--[[Test Block]]
    Engine.requires_character(spikey_id)
end

function package_init(package) 
    package:declare_package_id("com.discord.Konstinople#7692.encounter.acdc3.liberations")
end

function package_build(mob, data)
    print("Loading ACDC3 Liberation Encounter")
    print("Terrain = " .. data.terrain)

    if data.terrain == "advantage" then
        mob:enable_freedom_mission(3, false)

        for i = 1, 3 do
            local tile = mob:get_field():tile_at(4, i)
            tile:set_team(Team.Red, false)
            tile:set_facing(Direction.Right)
        end

        local choice = math.random(8)
        if choice == 1 then
            mob:create_spawner(spikey_id, Rank.V1):spawn_at(6, 1)
            mob:create_spawner(spikey_id, Rank.V2):spawn_at(5, 2)
            mob:create_spawner(spikey_id, Rank.V1):spawn_at(6, 3)
--[[        elseif choice == 2 then
            mob:create_spawner(champy_id, Rank.V1):spawn_at(5, 1)
            mob:create_spawner(champy_id, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(powie_id, Rank.V1):spawn_at(5, 3)
        elseif choice == 3 then
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(5, 1)
            mob:create_spawner(canguard_id, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(5, 3)
        elseif choice == 4 then
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(6, 1)
            mob:create_spawner(cactikil_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(6, 3)
        elseif choice == 5 then
            mob:create_spawner(cactikil_id, Rank.V1):spawn_at(5, 1)
            mob:create_spawner(champy_id, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(powie_id, Rank.V1):spawn_at(5, 3)
        elseif choice == 6 then
            mob:create_spawner(canguard_id, Rank.V1):spawn_at(5, 1)
            mob:create_spawner(powie_id, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(canguard_id, Rank.V1):spawn_at(5, 3)
        elseif choice == 7 then
            mob:create_spawner(canguard_id, Rank.V1):spawn_at(6, 1)
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(champy_id, Rank.V1):spawn_at(6, 3)
        elseif choice == 8 then
            mob:create_spawner(cactikil_id, Rank.V1):spawn_at(6, 1)
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(cactikil_id, Rank.V1):spawn_at(6, 3)]]--
        end
    elseif data.terrain == "disadvantage" then
        mob:enable_freedom_mission(3, false)

        for i = 1, 3 do
            local tile = mob:get_field():tile_at(3, i)
            tile:set_team(Team.Blue, false)
            tile:set_facing(Direction.Left)
        end

        local choice = math.random(8)
        if choice == 1 then
            mob:create_spawner(powie_id, Rank.V1):spawn_at(6, 1)
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(powie_id, Rank.V1):spawn_at(6, 3)
        elseif choice == 2 then
            mob:create_spawner(champy_id, Rank.V1):spawn_at(4, 1)
            mob:create_spawner(powie_id, Rank.V1):spawn_at(3, 3)
            mob:create_spawner(champy_id, Rank.V1):spawn_at(5, 2)
        elseif choice == 3 then
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(4, 1)
            mob:create_spawner(canguard_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(6, 3)
        elseif choice == 4 then
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(6, 1)
            mob:create_spawner(cactikil_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(6, 3)
        elseif choice == 5 then
            mob:create_spawner(cactikil_id, Rank.V1):spawn_at(4, 1)
            mob:create_spawner(champy_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(powie_id, Rank.V1):spawn_at(6, 3)
        elseif choice == 6 then
            mob:create_spawner(canguard_id, Rank.V1):spawn_at(4, 1)
            mob:create_spawner(powie_id, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(canguard_id, Rank.V1):spawn_at(3, 3)
        elseif choice == 7 then
            mob:create_spawner(canguard_id, Rank.V1):spawn_at(6, 1)
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(4, 2)
            mob:create_spawner(champy_id, Rank.V1):spawn_at(5, 3)
        elseif choice == 8 then
            mob:create_spawner(cactikil_id, Rank.V1):spawn_at(5, 1)
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(4, 2)
            mob:create_spawner(cactikil_id, Rank.V1):spawn_at(3, 3)
        end
    elseif data.terrain == "surrounded" then
        mob:enable_freedom_mission(3, true)
        mob:spawn_player(1, 3, 2)

        -- set behind tiles to blue
        for y = 1, 3 do
            for x = 1, 2 do
                local tile = mob:get_field():tile_at(x, y)
                tile:set_team(Team.Blue, false)
            end
        end

        -- set some tiles to red to give the player room
        for i = 1, 3 do
            local tile = mob:get_field():tile_at(4, i)
            tile:set_team(Team.Red, false)
            tile:set_facing(Direction.Right)
        end

        -- set spawn position?

        local choice = math.random(8)
        if choice == 1 then
            mob:create_spawner(powie_id, Rank.V1):spawn_at(1, 1)
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(powie_id, Rank.V1):spawn_at(6, 3)
        elseif choice == 2 then
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(6, 1)
            mob:create_spawner(canguard_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(1, 3)
        elseif choice == 3 then
            mob:create_spawner(canguard_id, Rank.V1):spawn_at(2, 1)
            mob:create_spawner(powie_id, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(canguard_id, Rank.V1):spawn_at(1, 3)
        elseif choice == 4 then
            mob:create_spawner(cactikil_id, Rank.V1):spawn_at(1, 1)
            mob:create_spawner(champy_id, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(powie_id, Rank.V1):spawn_at(1, 3)
        elseif choice == 5 then
            mob:create_spawner(champy_id, Rank.V1):spawn_at(2, 1)
            mob:create_spawner(powie_id, Rank.V1):spawn_at(1, 3)
            mob:create_spawner(champy_id, Rank.V1):spawn_at(6, 3)
        elseif choice == 6 then
            mob:create_spawner(cactikil_id, Rank.V1):spawn_at(6, 1)
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(2, 2)
            mob:create_spawner(cactikil_id, Rank.V1):spawn_at(1, 3)
        elseif choice == 7 then
            mob:create_spawner(canguard_id, Rank.V1):spawn_at(1, 1)
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(champy_id, Rank.V1):spawn_at(6, 3)
        elseif choice == 8 then
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(6, 1)
            mob:create_spawner(cactikil_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(1, 3)
        end
    else
        mob:enable_freedom_mission(3, false)

        local choice = math.random(8)
        if choice == 1 then
            mob:create_spawner(powie_id, Rank.V1):spawn_at(6, 1)
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(powie_id, Rank.V1):spawn_at(6, 3)
        elseif choice == 2 then
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(4, 1)
            mob:create_spawner(canguard_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(6, 3)
        elseif choice == 3 then
            mob:create_spawner(canguard_id, Rank.V1):spawn_at(5, 1)
            mob:create_spawner(powie_id, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(canguard_id, Rank.V1):spawn_at(4, 3)
        elseif choice == 4 then
            mob:create_spawner(cactikil_id, Rank.V1):spawn_at(5, 1)
            mob:create_spawner(champy_id, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(powie_id, Rank.V1):spawn_at(5, 3)
        elseif choice == 5 then
            mob:create_spawner(champy_id, Rank.V1):spawn_at(5, 1)
            mob:create_spawner(powie_id, Rank.V1):spawn_at(4, 3)
            mob:create_spawner(champy_id, Rank.V1):spawn_at(6, 3)
        elseif choice == 6 then
            mob:create_spawner(cactikil_id, Rank.V1):spawn_at(6, 1)
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(cactikil_id, Rank.V1):spawn_at(4, 3)
        elseif choice == 7 then
            mob:create_spawner(canguard_id, Rank.V1):spawn_at(6, 1)
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(4, 2)
            mob:create_spawner(champy_id, Rank.V1):spawn_at(5, 3)
        elseif choice == 8 then
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(6, 1)
            mob:create_spawner(cactikil_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(mettaur_id, Rank.V1):spawn_at(6, 3)
        end
    end
end
