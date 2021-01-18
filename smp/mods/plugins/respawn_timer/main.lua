local modname = minetest.get_current_modname()
conf = modlib.mod.configuration()
local timer = conf.timer
bone_names_by_model = {
    default = {"Head", "Body", "Arm_Right", "Arm_Left", "Leg_Right", "Leg_Left"}
}
local players = {}
local respawn_formspec_name = modname .. ":respawn"
respawn_formspec = "size[2,1]real_coordinates[true]button_exit[0,0;2,1;respawn;Respawn]"
inventory_formspec_dead = "size[2,1]real_coordinates[true]label[0.25,0.5;You died]"
local corpse = modname .. ":corpse"
minetest.register_entity(corpse, {
    initial_properties = {
        physical = true,
        collide_with_objects = true,
        collisionbox = {-0.5, 0.0, -0.5, 0.5, 1.0, 0.5},
        static_save = false
    },
    on_activate = function(self)
        self.object:set_armor_groups{immortal = 1}
        self.object:set_acceleration{x = 0, y = -9.81, z = 0}
    end,
    on_step = function(self)
        if not self._player then
            self.object:remove()
            return
        end
        -- Copy player appearance
        local anim = {self.object:get_animation()}
        local player_anim = {self._player:get_animation()}
        if not modlib.table.equals(anim, player_anim) then
            self.object:set_animation(unpack(player_anim))
        end
        local bone_names = bone_names_by_model[self._player:get_properties().mesh] or bone_names_by_model.default
        for _, bone_name in pairs(bone_names) do
            local position, rotation = self._player:get_bone_position(bone_name)
            if not (vector.equals(position, vector.new(0, 0, 0)) and vector.equals(rotation, vector.new(0, 0, 0))) then
                -- HACK as get_bone_position on the object somehow leads to an alteration
                local corpse_pos, corpse_rot = self.object:get_bone_position(bone_name)
                if not (vector.equals(position, corpse_pos) and vector.equals(rotation, corpse_rot)) then
                    self.object:set_bone_position(bone_name, position, rotation)
                end
            end
        end
        self.object:set_properties{collisionbox = self._player.collisionbox}
        self._player:set_attach(self.object, "", vector.new(0, 0, 0), vector.new(0, 0, 0))
        self._player:set_pos(self.object:get_pos())
    end
})
static_spawnpoint = minetest.settings:get"static_spawnpoint"
if static_spawnpoint then
    static_spawnpoint = minetest.string_to_pos(static_spawnpoint)
end
--+ Equivalent of `Server::findSpawnPos()`
function find_spawn_pos()
    -- TODO replicate random spawnpoint finding
    return static_spawnpoint or vector.new(0, 0, 0)
end
minetest.register_on_mods_loaded(function()
    -- HACK to route all on_respawnplayer callbacks over respawn(player)
    local ignore_next_on_player_hpchange = false
    registered_on_respawnplayers = minetest.registered_on_respawnplayers
    function minetest.register_on_respawnplayer(func)
        assert(type(func) == "function")
        table.insert(registered_on_respawnplayers, func)
    end
    minetest.registered_on_respawnplayers = {}
    function respawn(player)
        local name = player:get_player_name()
        local data = assert(players[name])
        -- Detach player from corpse
        player:set_detach()
        -- Remove corpse
        data.corpse:remove()
        -- Reset player properties
        player:set_properties{hp_max = data.hp_max, visual_size = data.visual_size}
        -- Execute on_respawnplayer callbacks
        local reposition
        for _, callback in ipairs(registered_on_respawnplayers) do
            reposition = reposition or callback(player)
        end
        player:set_pos(reposition and player:get_pos() or find_spawn_pos())

        -- Explicitly unignore next HP change
        ignore_next_on_player_hpchange = false
        -- Do stuff Minetest does on respawn
        player:set_hp(data.hp_max, "respawn")
        player:set_breath(player:get_properties().breath_max)
        -- Inventory formspec & hud flags
        player:set_inventory_formspec(data.inventory_formspec)
        player:hud_set_flags(data.hud_flags)
        players[name] = nil
    end
    local function add_corpse(player, props)
        local obj = minetest.add_entity(player:get_pos(), corpse)
        -- Preserve most player properties
        props.pointable = false
        props.physical = true
        props.collide_with_objects = true
        props.backface_culling = true
        obj:set_properties(props)
        -- Preserve animation
        obj:set_animation(player:get_animation())
        obj:get_luaentity()._player = player
        player:set_attach(obj, "", vector.new(0, 0, 0), vector.new(0, 0, 0))
        obj:set_yaw(player:get_look_horizontal())
        players[player:get_player_name()].corpse = obj
    end
    local function add_timer(name)
        hud_timers.add_timer(name, {
            name = timer.name,
            duration = timer.duration,
            color = timer.color,
            on_complete = function()
                players[name].can_respawn = true
                minetest.show_formspec(name, respawn_formspec_name, respawn_formspec)
            end
        })
    end
    -- HACK allow revoking interact
    minetest.registered_privileges.interact.give_to_singleplayer = false
    local function ghostify(player)
        local name = player:get_player_name()
        local player_props = player:get_properties()
        players[name] = {
            hp_max = player_props.hp_max,
            visual_size = player_props.visual_size,
            inventory_formspec = player:get_inventory_formspec(),
            hud_flags = player:hud_get_flags()
        }
        -- HACK to keep player dead
        add_corpse(player, player_props)
        ignore_next_on_player_hpchange = true
        player:set_properties{hp_max = 0, visual_size = {x = 0, y = 0, z = 0}}
        -- TODO revoke interact for better user experience at the expense of compatibility
        player:hud_set_flags{
            hotbar = false,
            healthbar = false,
            crosshair = false,
            wielditem = false,
            breathbar = false,
            minimap = false,
            minimap_radar = false
        }
        player:set_inventory_formspec(inventory_formspec_dead)
        -- HACK to close respawn formspec
        minetest.close_formspec(name, "")
        minetest.after(0.1, minetest.close_formspec, name, "")
    end
    -- HACK ghostify player on join
    table.insert(minetest.registered_on_joinplayers, 1, function(player)
        local name = player:get_player_name()
        if player:get_hp() == 0 then
            -- HACK ghostification has to happen AFTER the model has been set
            if player_api then
                player_api.player_attached[name] = false
                player_api.set_model(player, "character.b3d")
            end
            -- HACK ignore next on_dieplayer callback for player
            ignore_on_dieplayer[name] = true
            ghostify(player)
        end
    end)
    -- HACK add the timer AFTER the on_joinplayer callback by hud_timers has already executed
    minetest.register_on_joinplayer(function(player)
        if player:get_hp() == 0 then
            add_timer(player:get_player_name())
        end
    end)
    -- HACK override internal Minetest callbackto "ghostify" player on death and to prevent double execution
    local original = minetest.registered_on_player_hpchange
    function minetest.registered_on_player_hpchange(player, hp_change, reason)
        if ignore_next_on_player_hpchange then
            ignore_next_on_player_hpchange = false
            return hp_change
        end
        hp_change = original(player, hp_change, reason)
        if player:get_hp() == 0 and hp_change < 0 then
            return 0
        end
        local new_hp = player:get_hp() + hp_change
        if new_hp <= 0 then
            ghostify(player)
            add_timer(player:get_player_name())
            return hp_change
        end
        return hp_change
    end
    -- HACK override registered_on_dieplayers to prevent double execution
    ignore_on_dieplayer = {}
    minetest.register_on_respawnplayer(function(player)
        ignore_on_dieplayer[player:get_player_name()] = nil
    end)
    registered_on_dieplayers = minetest.registered_on_dieplayers
    function minetest.register_on_dieplayer(func)
        assert(type(func) == "function")
        table.insert(registered_on_dieplayers, func)
    end
    minetest.registered_on_dieplayers = {function(player, ...)
        local name = player:get_player_name()
        if ignore_on_dieplayer[name] then
            return
        end
        for _, on_dieplayer in ipairs(registered_on_dieplayers) do
            on_dieplayer(player, ...)
        end
        ignore_on_dieplayer[name] = true
    end}
    -- TODO override nodemeta & detached inventory callbacks to also disallow such inventory actions
    minetest.register_allow_player_inventory_action(function(player)
        if player:get_hp() == 0 then
            return 0
        end
    end)
    -- Disable chat & commands
    table.insert(minetest.registered_on_chat_messages, 1, function(name)
        if minetest.get_player_by_name(name):get_hp() == 0 then
            minetest.chat_send_player(name, "You can't use commands or chat while dead!")
            return true
        end
    end)
end)
-- Respawning
-- TODO provide alternative method in case this fails
modlib.minetest.register_form_listener(respawn_formspec_name, function(player)
    local playerdata = players[player:get_player_name()]
    if playerdata and playerdata.can_respawn then
        respawn(player)
    end
end)
