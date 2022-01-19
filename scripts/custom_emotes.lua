
    local color = {
      r = 0,
      g = 0,
      b = 0
    }
  
    local Emotes = {
      { id = "0",title = "Angry", author = "", read = true, emote_number = 0 },
      { id = "1",title = "blank", author = "", read = true,emote_number = 1 },
      { id = "2",title = "Sad", author = "",   read = true,emote_number = 2 },
      { id = "3",title = "Drunk", author = "",  read = true,emote_number = 3},
      { id = "4",title = "Shocked", author = "", read = true,emote_number = 4 },
      { id = "5",title = "Crying", author = "", read = true,emote_number = 5 },
      { id = "6",title = "Flabberghasted", author = "",read = true, emote_number = 6 },
      { id = "7",title = "Happy", author = "",  read = true,emote_number = 7},
      { id = "8",title = "Drool", author = "", read = true,emote_number = 8 },
      { id = "9",title = "Scared", author = "", read = true,emote_number = 9 },
      { id = "10",title = "Dab", author = "",   read = true,emote_number = 10 },
      { id = "11",title = "Wise Guy", author = "",  read = true,emote_number = 11},
      { id = "12",title = "Seen A Ghost", author = "", read = true,emote_number = 12 },
      { id = "13",title = "Pissed", author = "", read = true,emote_number = 13 },
      { id = "14",title = "UWU", author = "",   read = true,emote_number = 14 },
      { id = "15",title = "Zipped Mouth", author = "",  read = true,emote_number = 15},
      { id = "16",title = "Boomer", author = "",  read = true,emote_number = 16},
      { id = "17",title = "Disapproving", author = "",  read = true,emote_number = 17},
      { id = "18",title = "rowlet", author = "",  read = true,emote_number = 18},
      { id = "19",title = "Exclamation", author = "",  read = true,emote_number = 19},
      { id = "20",title = "Circusman", author = "",  read = true,emote_number = 20},
    }
  
    for i, Emotes in ipairs(Emotes) do
        Emotes[1] = { id = i -1, title = Emotes.title, author = Emotes.author, read = true}
      end
  
      function handle_post_selection(player_id,post_id)
        Net.set_player_emote(player_id, tonumber(post_id), true)
        Net.close_bbs(player_id)
        print(post_id)
      end
  
    for i, s in ipairs(Emotes) do
      if s.title == post_id then
        Emotes = s
        break
      end
    end
    
    function handle_tile_interaction(player_id, x, y, z, button)
      if button ~= 1 then return end
      print("hello")
      Net.open_board(player_id, "Emotes", color, Emotes)
    end