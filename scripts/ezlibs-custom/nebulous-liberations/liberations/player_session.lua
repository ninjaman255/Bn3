local Ability = require("scripts/ezlibs-custom/nebulous-liberations/liberations/ability")
local PlayerSelection = require("scripts/ezlibs-custom/nebulous-liberations/liberations/player_selection")
local Loot = require("scripts/ezlibs-custom/nebulous-liberations/liberations/loot")
local EnemyHelpers = require("scripts/ezlibs-custom/nebulous-liberations/liberations/enemy_helpers")
local ParalyzeEffect = require("scripts/utils/paralyze_effect")
local RecoverEffect = require("scripts/utils/recover_effect")
local CustomEmotes = require("scripts/utils/custom_emotes")
local ezmemory = require("scripts/ezlibs-scripts/ezmemory")
local Emotes = require("scripts/libs/emotes")

local PlayerSession = {}

function PlayerSession:new(instance, player)
  local player_session = {
    instance = instance,
    player = player,
    health = 1,
    max_health = 1,
    paralyze_effect = nil,
    paralyze_counter = 0,
    battling = false,
    invincible = false,
    completed_turn = false,
    selection = PlayerSelection:new(instance, player.id),
    ability = Ability.resolve_for_player(player),
    disconnected = false,
    is_trapped = false,
    get_monies = false
  }

  setmetatable(player_session, self)
  self.__index = self
  return player_session
end

function PlayerSession:emote_state()
  if self.player:is_battling() then
    Net.set_player_emote(self.player.id, Emotes.PVP)
  elseif self.invincible then
    Net.set_player_emote(self.player.id, CustomEmotes.INVINCIBILE, true)
  elseif self.completed_turn then
    Net.set_player_emote(self.player.id, Emotes.ZZZ)
  elseif self.battling then
    Net.set_player_emote(self.player.id, Emotes.PVP)
  else
    Net.set_player_emote(self.player.id, CustomEmotes.BLANK, true)
  end
end

local order_points_mug_texture = "/server/assets/mugs/order pts.png"
local order_points_mug_animations = {
  "/server/assets/mugs/order pts 0.animation",
  "/server/assets/mugs/order pts 1.animation",
  "/server/assets/mugs/order pts 2.animation",
  "/server/assets/mugs/order pts 3.animation",
  "/server/assets/mugs/order pts 4.animation",
  "/server/assets/mugs/order pts 5.animation",
  "/server/assets/mugs/order pts 6.animation",
  "/server/assets/mugs/order pts 7.animation",
  "/server/assets/mugs/order pts 8.animation",
}

function PlayerSession:message_with_points(message)
  local mug_animation = order_points_mug_animations[self.instance.order_points + 1]
  return self.player:message(message, order_points_mug_texture, mug_animation)
end

function PlayerSession:question_with_points(question)
  local mug_animation = order_points_mug_animations[self.instance.order_points + 1]
  return self.player:question(question, order_points_mug_texture, mug_animation)
end

function PlayerSession:quiz_with_points(a, b, c)
  local mug_animation = order_points_mug_animations[self.instance.order_points + 1]
  return self.player:quiz(a, b, c, order_points_mug_texture, mug_animation)
end

function PlayerSession:get_ability_permission()
  local question_promise = self.player:question_with_mug(self.ability.question)

  question_promise.and_then(function(response)
    if response == 0 then
      -- No
      self.selection:clear()
      Net.unlock_player_input(self.player.id)
      return
    end

    -- Yes

    if self.instance.order_points < self.ability.cost then
      -- not enough order points
      self.player:message("Not enough Order Pts!")
      return
    end

    self.instance.order_points = self.instance.order_points - self.ability.cost
    self.ability.activate(self.instance, self)
  end)
end

function PlayerSession:get_pass_turn_permission()
  local question = "End without doing anything?"

  if self.health < self.max_health then
    question = "Recover HP?"
  end

  local question_promise = self.player:question_with_mug(question)

  question_promise.and_then(function(response)
    if response == 0 then
      -- No
      Net.unlock_player_input(self.player.id)
    elseif response == 1 then
      -- Yes
      self:pass_turn()
    end
  end)
end

function PlayerSession:initiate_encounter(encounter_path, data)
  self.battling = true
  return Async.create_promise(function(resolve)
    self.player:initiate_encounter(encounter_path, data).and_then(function(results)
      local total_enemy_health = 0
      for _, enemy in ipairs(results.enemies) do
        total_enemy_health = total_enemy_health + enemy.health
      end
      self.health = results.health
      ezmemory.set_player_max_health(self.player.id, self.max_health, true)
      ezmemory.set_player_health(self.player.id, self.health)
      Net.set_player_emotion(self.player.id, results.emotion)
      if self.health == 0 then
        self:paralyze()
      end
      self.battling = false
      if total_enemy_health > 0 then
        results.success = false
        self.player:message_with_mug("Oh, no!\nLiberation failed!").and_then(function()
          resolve(results)
        end)
      else
        results.success = true
        resolve(results)
      end
    end)
  end)
end

function PlayerSession:heal(amount)
  local previous_health = self.health

  self.health = math.min(math.ceil(self.health + amount), self.max_health)

  ezmemory.set_player_max_health(self.player.id, self.max_health, true)
  ezmemory.set_player_health(self.player.id, self.health)

  if previous_health < self.health then
    return RecoverEffect:new(self.player.id):remove()
  else
    return Async.create_promise(function(resolve)
      resolve()
    end)
  end
end

function PlayerSession:hurt(amount)
  if self.invincible or self.health == 0 or amount <= 0 then
    return
  end

  Net.play_sound_for_player(self.player.id, "/server/assets/sound effects/hurt.ogg")

  self.health = math.max(math.ceil(self.health - amount), 0)
  ezmemory.set_player_max_health(self.player.id, self.max_health, true)
  ezmemory.set_player_health(self.player.id, self.health)

  if self.health == 0 then
    Async.sleep(1).and_then(function()
      self:paralyze()
    end)
  end
end

function PlayerSession:paralyze()
  self.paralyze_counter = 2
  self.paralyze_effect = ParalyzeEffect:new(self.player.id)
  self.is_trapped = true
end

function PlayerSession:pass_turn()
  -- heal up to 50% of health
  self:heal(self.max_health / 2).and_then(function()
    self:complete_turn()
  end)
end

function PlayerSession:complete_turn()
  if self.disconnected then
    return
  end

  self.completed_turn = true
  self.selection:clear()
  Net.lock_player_input(self.player.id)

  self:emote_state()

  self.instance.ready_count = self.instance.ready_count + 1

  if self.instance.ready_count < #self.instance.players then
    Net.unlock_player_camera(self.player.id)
  end
end

function PlayerSession:give_turn()
  self.invincible = false

  if self.paralyze_counter > 0 then
    self.paralyze_counter = self.paralyze_counter - 1

    if self.paralyze_counter > 0 then
      -- still paralyzed
      self:complete_turn()
      return
    end

    -- release
    self.paralyze_effect:remove()
    self.paralyze_effect = nil

    -- heal 50% so we don't just start battles with 0 lol
    if not self.is_trapped then
      self:heal(self.max_health / 2)
    else
      self.is_trapped = false
    end
  end

  self.completed_turn = false
  Net.unlock_player_input(self.player.id)
end

function PlayerSession:find_closest_guardian()
  local closest_guardian
  local closest_distance = math.huge

  for _, enemy in ipairs(self.instance.enemies) do
    if enemy.is_boss then
      goto continue
    end

    local distance = EnemyHelpers.chebyshev_tile_distance(enemy, self.player.x, self.player.y)

    if distance < closest_distance then
      closest_distance = distance
      closest_guardian = enemy
    end

    ::continue::
  end

  return closest_guardian
end

function PlayerSession:liberate_panels(panels, results)
  local co = coroutine.create(function()
    -- allow time for the player to see the liberation range
    Async.await(Async.sleep(1))
    for _, panel in ipairs(panels) do
      self.instance:remove_panel(panel)
    end
    self.selection:clear()
    if results ~= nil and results.turns == 1 and not results.ran then
      Async.await(self.player:message_with_mug("One turn liberation!"))
    else
      Async.await(self.player:message_with_mug("Yeah!\nI liberated it!"))
    end
  end)
  return Async.promisify(co)
end

-- returns a promise that resolves after looting
function PlayerSession:loot_panels(panels)
  local co = coroutine.create(function()
    for _, panel in ipairs(panels) do
      if panel.loot then
        -- loot the panel if it has loot
        Async.await(Loot.loot_item_panel(self.instance, self, panel))
        if self.get_monies then
          local cash = Net.get_player_money(self.player.id)
          local bonus = 100
          if panel.custom_properties["Money"] then bonus = tonumber(panel.custom_properties["Money"]) end
          Async.await(self.player:message("Obtained "..tostring(bonus).." Monies!"))
          Net.set_player_money(self.player.id, cash + bonus)
          ezmemory.set_player_money(self.player.id, Net.get_player_money(self.player.id))
          self.get_monies = false
        end
      elseif panel.type == "Trap Panel" then
        if panel.custom_properties["Damage Trap"] == "true" then
          if panel.custom_properties["Trap Message"] ~= nil then
            Async.await(self.player:message_with_mug(panel.custom_properties["Trap Message"]))
          else
            Async.await(self.player:message_with_mug("Ah! A damage trap!"))
          end
          self:hurt(tonumber(panel.custom_properties["Damage Dealt"]))
        elseif panel.custom_properties["Stun Trap"] == "true" then
          if panel.custom_properties["Trap Message"] ~= nil then
            Async.await(self.player:message_with_mug(panel.custom_properties["Trap Message"]))
          else
            Async.await(self.player:message_with_mug("Ah! A paralysis trap!"))
          end
          self:paralyze()
        end
      end
    end
  end)

  return Async.promisify(co)
end

function PlayerSession:liberate_and_loot_panels(panels, results)
  return Async.create_promise(function(resolve)
    self:liberate_panels(panels, results).and_then(function()
      self:loot_panels(panels).and_then(resolve)
    end)
  end)
end

function PlayerSession:handle_disconnect()
  self.selection:clear()

  if self.completed_turn then
    self.instance.ready_count = self.instance.ready_count - 1
  end

  if self.paralyze_effect then
    self.paralyze_effect:remove()
  end

  self.disconnected = true
end

-- export
return PlayerSession