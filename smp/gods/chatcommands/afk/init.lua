local afklist = {}

minetest.register_chatcommand("afk", {     
params = "[Reason]",
description = "Sets your status as AFK",
func = function(name, param)

if afklist[name] then
return false, "You already are AFK."
end

afklist[name] = true
minetest.chat_send_all(name.." is now away \""..param.."\"!")
end,
})

minetest.register_chatcommand("back", {     
params = "",
description = "Removes your AFK status",
func = function(name, param)

if not afklist[name] then
return false, "You are not AFK."
end

afklist[name] = nil
minetest.chat_send_all(name.." has returned!")
end,
})
