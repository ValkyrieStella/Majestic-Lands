minetest.override_chatcommand("spawn", {
    description = "Teleports you to spawn!",
    func = function(name)
        local static_spawnpoint = core.setting_get_pos("static_spawnpoint")
        if anticombatlog[name] then
            return false, "You cannot use /spawn while combat tagged"
        end 
        local player = minetest.get_player_by_name(name)
        if player then
            player:move_to(static_spawnpoint)
        end
    end,
}) -- teleport to hub