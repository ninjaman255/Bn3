--== Script for user posts on BBS ==--
-- Create a tile object
--
-- Properties for Minimap:
--   Type: Board
--
-- Required Custom Properties:
--   BBS: bool (true)
--   Name: name (make sure this is unique)
--   Color: color
--   Post Limit: int
--
-- Optional Custom Properties:
--   Character Limit: int
--
-- Required libs:
--   json.lua by rxi (store as scripts/libs/json.lua)

local json = require("scripts/libs/json")
local SAVE_LOCATION = "scripts/bbs/data.json"
local TITLE_LIMIT = 14
local AUTHOR_LIMIT = 7

-- storing last time players checked BBS to display the NEW icon
local last_read_time = {}
local player_states = {}
local save_data = {}
local saving = false
local pending_save = false

Async.read_file(SAVE_LOCATION).and_then(function(value)
  local status, err = pcall(function ()
    if value ~= "" then
      save_data = json.decode(value)
    end
  end)

  if not status then
    print("Failed to read data from \"" .. SAVE_LOCATION .. "\":")
    print(err)
  end
end)

function handle_player_connect(player_id)
  last_read_time[player_id] = os.time()
end

function handle_player_disconnect(player_id)
  -- free memory
  last_read_time[player_id] = nil
  player_states[player_id] = nil
end

function handle_object_interaction(player_id, object_id)
  local area = Net.get_player_area(player_id)
  local object = Net.get_object_by_id(area, object_id)

  if not object or not object.custom_properties.BBS then
    return
  end

  local name = object.custom_properties.Name
  local color_string = object.custom_properties.Color

  local color = {
    r = tonumber(string.sub(color_string, 4, 5), 16),
    g = tonumber(string.sub(color_string, 6, 7), 16),
    b = tonumber(string.sub(color_string, 8, 9), 16)
  }

  local posts = {
    {
      id = "POST",
      read = true,
      title = "POST"
    },
  }

  local last_time = last_read_time[player_id]
  local board_data = save_data[name]

  if board_data then
    -- show pinned posts at the top
    for i = #board_data.posts, 1, -1 do
      local post = board_data.posts[i]

      if post.pin then
        -- shallow copy to prevent mutation
        post = shallow_copy(post)

        post.title = "PIN: " .. string.sub(post.title, 1, TITLE_LIMIT - 5)

        -- mark post as read if we've checked the board after this was posted
        if last_time == nil or post.time < last_time then
          post.read = true
        end

        posts[#posts+1] = post
      end
    end

    -- show normal posts
    for i = #board_data.posts, 1, -1 do
      local post = board_data.posts[i]

      if not post.pin then
        -- shallow copy to prevent mutation
        post = shallow_copy(post)

        -- mark post as read if we've checked the board after this was posted
        if last_time == nil or post.time < last_time then
          post.read = true
        end

        posts[#posts+1] = post
      end
    end
  end

  Net.open_board(player_id, name, color, posts)

  -- track what board the player is looking at
  player_states[player_id] = {
    status = "READING",
    area_id = area,
    board_id = object.id,
    board_name = name
  }
end

function shallow_copy(original)
  local copy = {}

  for key, value in pairs(original) do
    copy[key] = value
  end

  return copy
end

function handle_post_selection(player_id, post_id)
  if not player_states[player_id] then
    return
  end

  if post_id == "POST" then
    send_post_form(player_id)
  else
    show_post(player_id, post_id)
  end
end

function send_post_form(player_id)
  local player_state = player_states[player_id]

  local board = Net.get_object_by_id(player_state.area_id, player_state.board_id)

  Net.prompt_player(player_id, board.custom_properties["Character Limit"])

  player_state.status = "EDITING"
end

function show_post(player_id, post_id)
  local board_name = player_states[player_id].board_name

  local posts = save_data[board_name].posts
  local post

  for _, p in ipairs(posts) do
    if p.id == post_id then
      post = p
      break
    end
  end

  if post then
    Net.message_player(player_id, post.body)
  end
end

function handle_textbox_response(player_id, response)
  local player_state = player_states[player_id]

  if not player_state then
    return
  end

  if player_state.status == "EDITING" then
    if not contains_only_whitespace(response) then
      player_state.submission_text = response
      player_state.status = "SUBMITTING"
      Net.question_player(player_id, "Do you want to submit?")
      return
    end
  elseif player_state.status == "SUBMITTING" then
    if response == 1 then
      -- player said yes
      Net.message_player(player_id, "Title:")
      Net.prompt_player(player_id, TITLE_LIMIT, sanitize_title(player_state.submission_text, TITLE_LIMIT))
      player_state.status = "INFORMED_OF_INPUT"
      return
    end
  elseif player_state.status == "INFORMED_OF_INPUT" then
    player_state.status = "TITLING"
    return
  elseif player_state.status == "TITLING" then
    player_state.submission_title = response
    create_post(player_id, player_state)
  end

  player_state.status = "READING"
end

function create_post(player_id, player_state)
  local board = Net.get_object_by_id(player_state.area_id, player_state.board_id)
  local board_data = save_data[player_state.board_name]

  if not board_data then
    -- start storing posts for this board if there's no data
    board_data = {
      posts = {},
      next_id = 1
    }
  end

  local player_name = Net.get_player_name(player_id)
  local character_limit = tonumber(board.custom_properties["Character Limit"])

  local title = player_state.submission_title

  if contains_only_whitespace(title) then
    title = player_state.submission_text
  end

  local post = {
    time = os.time(),
    author = sanitize_title(player_name, AUTHOR_LIMIT),
    title = sanitize_title(title, TITLE_LIMIT),
    id = tostring(board_data.next_id),
    body = string.sub(player_state.submission_text, 1, character_limit)
  }

  board_data.next_id = board_data.next_id + 1

  local post_limit = tonumber(board.custom_properties["Post Limit"])

  if #board_data.posts >= post_limit then
    -- remove the oldest non pinned post
    for i, old_post in ipairs(board_data.posts) do
      if not old_post.pin then
        table.remove(board_data.posts, i)
        break
      end
    end
  end

  push_post(player_state.board_name, player_state.area_id, post)

  board_data.posts[#board_data.posts+1] = post
  save_data[player_state.board_name] = board_data
  save()
end

function contains_only_whitespace(text)
  return not string.find(text, "[^ \t\r\n]")
end

function sanitize_title(text, limit)
  return string.sub(string.gsub(text, "[\t\r\n]", " ", limit), 1, limit)
end

function push_post(board_name, area_id, post)
  local next_id = nil

  local board_data = save_data[board_name]

  if board_data then
    local posts = save_data[board_name].posts

    for i = #posts, 1, -1 do
      local post = posts[i]

      if not post.pin then
        next_id = post.id
        break
      end
    end
  end

  local push_func

  if next_id then
    push_func = Net.prepend_posts
  else
    push_func = Net.append_posts
  end

  local new_posts = { post }

  for i, player_id in ipairs(Net.list_players(area_id)) do
    push_func(player_id, new_posts, next_id)
  end
end

function handle_board_close(player_id)
  last_read_time[player_id] = os.time()
end

function save()
  if saving then
    pending_save = true
    return
  end

  saving = true

  Async.write_file(SAVE_LOCATION, json.encode(save_data)).and_then(function()
    saving = false

    if pending_save then
      pending_save = false
      save()
    end
  end)
end
