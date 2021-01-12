local current_day = 0
current_day = minetest.get_day_count()
minetest.register_globalstep(function()
  local time = minetest.get_timeofday() * 24000
  --if time == 19500 then
  if time >= 19500 and time <= 20000 then
    if current_day ~= minetest.get_day_count() then
        minetest.chat_send_all(minetest.colorize("#FF0000", "[SYSTEM] Darkness has fallen!"))
        current_day = minetest.get_day_count()
    end
  end
end)

-- Made by Jordach and ElCeejo
