  
local current_day = 0
current_day = minetest.get_day_count()
minetest.register_globalstep(function()
  local time = minetest.get_timeofday() * 24000
  --if time == 6000 then
  if time >= 6000 and time <= 6500 then
    if current_day ~= minetest.get_day_count() then
        minetest.chat_send_all(minetest.colorize("#FF0000", "[SYSTEM] The sun is rising!"))
        current_day = minetest.get_day_count()
    end
  end
end)

-- Made by Jordach and ElCeejo