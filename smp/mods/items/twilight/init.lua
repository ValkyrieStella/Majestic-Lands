-----------------------
-- Tools --
-----------------------

minetest.register_tool("twilight:boots_twilight", {
	description = ("Twilight Boots (It's A Pickaxe)"),
	inventory_image = "twilight_inv_boots_twilight.png",
	light_source = 7, -- Texture will have a glow when dropped
	tool_capabilities = {
		full_punch_interval = 0.5,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=80, maxlevel=3},
		},
		damage_groups = {fleshy=5},
	},
	sound = {breaks = "default_tool_breaks"},
    groups = {pickaxe = 1}
    
})

-------------
-- Crafts --
-------------

minetest.register_craft({
	output = "twilight:boots_twilight",
	recipe = {
		{"default:diamondblock", "", "default:diamondblock"},
		{"default:goldblock", "", "default:goldblock"},
		{"", "", ""},
	}
})
