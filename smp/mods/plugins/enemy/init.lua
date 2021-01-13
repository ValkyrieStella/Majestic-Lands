local enemystore = minetest.get_mod_storage()
local neutralstore = minetest.get_mod_storage()
local nt_pending = {}
local en_pending = {}

minetest.register_chatcommand("enemy", {     
    params = "<playername>",
    description = "Doing this will make you enemies with a faction",
    privs = {
        war = true,
    },
    func = function(name, param)

if param == "" then
return false, "You didn't provide a player name"
end

if not minetest.get_player_by_name(param) then
return false, "The player is not online"
end

if string.find(enemystore:get_string(name), "#"..param.."#", 1, true) then
return false, param.." is already your enemy!"
end

en_pending[param] = name
minetest.chat_send_player(param, "You received a enemy request from "..en_pending[param]..". Send /eok to accept it")
return true, "Your enemy request has been sent to "..param
end,
})

minetest.register_chatcommand("eok", {     
    params = "",
    description = "Accept a pending enemy request",
    func = function(name, param)
    
    if not en_pending[name] then
    return false, "You have no pending enemy request"
    end
    
    local pendname = en_pending[name]
    local of1 = enemystore:get_string(pendname)
    local of2 = enemystore:get_string(name)
    
    of1 = of1.."#"..name.."#"
    of2 = of2.."#"..pendname.."#"
    enemystore:set_string(pendname, of1)
    enemystore:set_string(name, of2)
    en_pending[name] = nil
    return true, minetest.chat_send_all(minetest.colorize("#FF00E0","[System] "..name.." became enemies with "..pendname.."!"))
    end,
    })

minetest.register_chatcommand("enemies", {     
    params = "",
    description = "Check the enemies of a player",
    func = function(name, param)
        
if not minetest.player_exists(param) then
return false, "This player doesn't exist"
end
        
local geten = enemystore:get_string(param)
        
if geten == "" then
return false, param.." has no enemies (yet)"
end

geten = geten:gsub("#"," ")
return true, "Enemies of "..param..":"..geten
end,
})