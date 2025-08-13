ui.msg_feel = function(msg)
	if type(msg) ~= "string" then return end
	if level.feeling == "" then
		level.feeling = msg
	else
		level.feeling = level.feeling .. " " .. msg
	end
	ui.msg(msg)
end

ui.repeat_feel = function()
	ui.msg(level.feeling)
end

ui.clear_feel = function()
	level.feeling = ""
end

ui.confirm = function( query )
	local choice = {
		header = query,
		entries = { 
			{ name = "Cancel", value = 0, },
			{ name = "Confirm", value = 1,},
		},
		cancel = 0,
	}
	return ui.choice( choice ) == 1
end

ui.query = function( query )
	local choice = {
		header = query,
		entries = { 
			{ name = "Confirm", value = 1,},
			{ name = "Cancel", value = 0, },
		},
		escape = false,
	}
	return ui.choice( choice ) == 1
end


ui.continue = function( query )
	local choice = {
		header = query,
		entries = { 
			{ name = "Continue", value = 0, },
		},
		cancel = 0,
	}
	ui.choice( choice )
end