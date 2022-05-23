local Emotes = require("scripts/libs/emotes")

local Parties = {}

local parties = {} -- { members }[]
local pending_requests = {} -- { requester, recruit, elapsed }[]
local tick_timer = 0
local REQUEST_EMOTE = Emotes.QUESTION
local ACCEPT_EMOTE = Emotes.HAPPY

local function internal_find(player_id)
  for party_index, party in ipairs(parties) do
    for i, member_id in ipairs(party.members) do
      if player_id == member_id then
        return {
          party_index = party_index,
          player_index = i
        }
      end
    end
  end

  return nil
end

function Parties.find(player_id)
  local party_info = internal_find(player_id)

  if party_info then
    return parties[party_info.party_index]
  end

  return nil
end

function Parties.is_in_same_party(player_a, player_b)
  local party_info = internal_find(player_a)

  if party_info == nil then
    return nil
  end

  local party = parties[party_info.party_index]

  for _, member_id in ipairs(party.members) do
    if member_id == player_b then
      return true
    end
  end

  return false
end

function Parties.on_tick(elapsed)
  tick_timer = tick_timer + elapsed

  -- tick once per second
  if tick_timer < 1 then return end

  local dead_requests = {}

  -- find dead requests and refresh emotes
  for i, request in ipairs(pending_requests) do
    request.elapsed = request.elapsed + tick_timer

    if request.elapsed < 5 then
      Net.exclusive_player_emote(request.recruit, request.requester, REQUEST_EMOTE)
    else
      dead_requests[#dead_requests + 1] = i
    end
  end

  -- reverse loop remove dead requests
  for i=1, #dead_requests do
    local request_index = dead_requests[#dead_requests + 1 - i]
    table.remove(pending_requests, request_index)
  end

  tick_timer = 0
end

function Parties.request(requester, recruit)
  Net.exclusive_player_emote(recruit, requester, REQUEST_EMOTE)
  pending_requests[#pending_requests + 1] = {
    requester = requester,
    recruit = recruit,
    elapsed = 0
  }
end

local function internal_find_request(requester, recruit)
  for i, request in ipairs(pending_requests) do
    if request.requester == requester and request.recruit == recruit then
      return i
    end
  end
  return nil
end

function Parties.has_request(recruit, requester)
  return internal_find_request(requester, recruit) ~= nil
end

function Parties.accept(recruit, requester)
  local request_index = internal_find_request(requester, recruit)
  table.remove(pending_requests, request_index)

  Net.exclusive_player_emote(recruit, requester, ACCEPT_EMOTE)
  Net.exclusive_player_emote(requester, recruit, ACCEPT_EMOTE)
  Net.exclusive_player_emote(recruit, recruit, ACCEPT_EMOTE)
  Net.exclusive_player_emote(requester, requester, ACCEPT_EMOTE)

  -- leave existing party to join the new one
  Parties.leave(recruit)

  local party_info = internal_find(requester)

  if party_info == nil then
    parties[#parties + 1] = {
      members = {
        requester,
        recruit
      }
    }
  else
    local party = parties[party_info.party_index]
    party.members[#party.members + 1] = recruit
  end
end

function Parties.leave(player_id)
  local party_info = internal_find(player_id)

  if party_info == nil then
    return
  end

  local party = parties[party_info.party_index]

  -- find a party we may be in and leave it
  table.remove(party.members, party_info.player_index)

  if #party.members == 1 then
    table.remove(parties, party_info.party_index)
  end
end

return Parties
