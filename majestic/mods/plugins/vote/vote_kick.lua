local function start_kick_vote(name, param)
	if not minetest.get_player_by_name(param) then
		minetest.chat_send_player(name, "There is no player called '" ..
				param .. "'")
	end

	vote.new_vote(name, {
		description = "Kick player " .. param,
		help = "/yes,  /no  or  /abstain",
		name = param,
		duration = 60,

		on_result = function(self, result, results)
			if result == "yes" then
				minetest.chat_send_all("Vote passed, " ..
						#results.yes .. " to " .. #results.no .. ", " ..
						self.name .. " will be kicked.")
				minetest.kick_player(self.name, "The vote to kick you passed")
			else
				minetest.chat_send_all("Vote failed, " ..
						#results.yes .. " to " .. #results.no .. ", " ..
						self.name .. " remains ingame.")
			end
		end,

		on_vote = function(self, name, value)
			minetest.chat_send_all(name .. " voted " .. value .. " to '" ..
					self.description .. "'")
		end
	})
end

minetest.register_chatcommand("vote_kick", {
	privs = {
		interact = true
	},
	func = start_kick_vote
})