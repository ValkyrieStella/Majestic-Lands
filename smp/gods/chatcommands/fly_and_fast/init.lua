minetest.register_chatcommand("fly", {
    description = "Gives A User Access To Flight",     
func = function(name, param)
    local privs = minetest.get_player_privs(name)
    privs.fly = true
    minetest.set_player_privs(name, privs)
    minetest.chat_send_all(minetest.colorize("#FF00E0", name.." now has fly!"))
end,
})

minetest.register_chatcommand("fast", {
    description = "Gives A User Access To Fast",     
func = function(name, param)
    local privs = minetest.get_player_privs(name)
    privs.fast = true
    minetest.set_player_privs(name, privs)
    minetest.chat_send_all(minetest.colorize("#FF00E0", name.." now has fast!"))
end,
})

