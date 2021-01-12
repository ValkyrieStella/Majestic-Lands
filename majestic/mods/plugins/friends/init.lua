local friendstore = minetest.get_mod_storage()
local fr_pending = {}

minetest.register_chatcommand("friend", {     
params = "<playername>",
description = "Sends a friend request to the player",
func = function(name, param)

if param == "" then
return false, "You didn't provide a player name"
end

if not minetest.get_player_by_name(param) then
return false, "The player is not online"
end

if string.find(friendstore:get_string(name), "#"..param.."#", 1, true) then
return false, param.." is already your friend"
end

fr_pending[param] = name
minetest.chat_send_player(param, "You received a friend request from "..fr_pending[param]..". Send /fok to accept it")
return true, "Your friend request has been sent to "..param
end,
})


minetest.register_chatcommand("fok", {     
params = "",
description = "Accept a pending friend request",
func = function(name, param)

if not fr_pending[name] then
return false, "You have no pending friend request"
end

local pendname = fr_pending[name]
local of1 = friendstore:get_string(pendname)
local of2 = friendstore:get_string(name)

of1 = of1.."#"..name.."#"
of2 = of2.."#"..pendname.."#"
friendstore:set_string(pendname, of1)
friendstore:set_string(name, of2)
fr_pending[name] = nil
return true, minetest.chat_send_all(minetest.colorize("#FF00E0","[System] "..name.." became friends with "..pendname.."!"))
end,
})


minetest.register_chatcommand("friends", {     
params = "",
description = "Check the friends of a player",
func = function(name, param)

if not minetest.player_exists(param) then
return false, "This player doesn't exist"
end

local getfl = friendstore:get_string(param)

if getfl == "" then
return false, param.." has no friends (yet)"
end

getfl = getfl:gsub("#"," ")
return true, "Friends of "..param..":"..getfl
end,
})
