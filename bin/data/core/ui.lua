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
