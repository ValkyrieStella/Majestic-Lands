minetest.register_on_player_hpchange(function(player)
    minetest.chat_send_all("HP of player " .. player:get_player_name() .. " has changed")
end)

minetest.register_on_dieplayer(function(player, reason)
    minetest.chat_send_all("Player " .. player:get_player_name() .. " died, reason: " .. minetest.write_json(reason))
end)

minetest.register_on_respawnplayer(function(player)
    minetest.chat_send_all("Player " .. player:get_player_name() .. " respawned")
end)