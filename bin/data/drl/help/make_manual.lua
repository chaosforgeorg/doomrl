local manual_file = io.open( "../manual.txt", "w" )
local help_files = { "doomrl.txt", "intro.hlp", "start.hlp", "keys.hlp", "feedback.hlp", "credits.hlp", "disclaim.hlp" }

function write_to_manual( file_name )
	local file = io.open( file_name )
	for l in file:lines() do
		l = l:gsub( "{.", "" ):gsub( "}", "" )
		manual_file:write( l.."\n" )
	end
	manual_file:write( "\n\n=============================================================================\n\n" )
end

manual_file:write( "=============================================================================\n\n" )

for _,file in ipairs( help_files ) do
	write_to_manual( file )
end

manual_file:close()

