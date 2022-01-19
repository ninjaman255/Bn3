local player_count = 0

function handle_player_connect()
  player_count = player_count + 1
  print_player_count()
end

function handle_player_disconnect()
  player_count = player_count - 1
  print_player_count()
end

function print_player_count()
  print("Player Count: " .. player_count)
end
