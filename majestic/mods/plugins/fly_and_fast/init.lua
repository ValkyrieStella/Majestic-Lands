local cooldowns = {}

minetest.register_chatcommand("fly", {
    description = "Gives A User Access To Flight",     
func = function(name, param)
    local cd = cooldowns[name] or 0
if os.time() < cd then
return false, "You cannot use this command now."
end

cooldowns[name] = os.time() + 60
    local privs = minetest.get_player_privs(name)
    privs.fly = true
    minetest.set_player_privs(name, privs)
    minetest.chat_send_all(minetest.colorize("#FF00E0", "[SYSTEM] " .. name .. " now has fly!"))
end,
})

minetest.register_chatcommand("fast", {
    description = "Gives A User Access To Fast",     
func = function(name, param)
    local cd = cooldowns[name] or 0
if os.time() < cd then
return false, "You cannot use this command now."
end

cooldowns[name] = os.time() + 60
    local privs = minetest.get_player_privs(name)
    privs.fast = true
    minetest.set_player_privs(name, privs)
    minetest.chat_send_all(minetest.colorize("#FF00E0", "[SYSTEM] " .. name .. " now has fast!"))
end,
})


