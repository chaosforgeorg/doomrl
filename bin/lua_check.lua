dofile "lua/functions.lua"
dofile "lua_check_config.lua"

function table.set( t, k, v )
	if not t[k] then t[k] = {} end
	t[k][v] = true
end

local ns_functions = {} 
local ns_methods   = {} 
local ns_fields    = {}
local ns_globals   = {}

local ns_names = { 
	fields = ns_fields, 
	methods = ns_methods, 
	globals = ns_globals, 
	functions = ns_functions 
}

function load_namespace( t )
	for k,_ in pairs(_G[t]) do
		table.set(ns_functions,t,k)
	end
end


function parse_error( file, line_no, msg, line )
	io.write( file..":"..line_no..": "..msg.." > "..line.."\n" )
end

function make_alias( alias, original )
	if not ns_methods[ original ]   then ns_methods[ original ] = {}   end
	if not ns_functions[ original ] then ns_functions[ original ] = {} end
	if not ns_fields[ original ]    then ns_fields[ original ] = {}    end
	ns_methods  [ alias ] = ns_methods  [ original ] 
	ns_functions[ alias ] = ns_functions[ original ] 
	ns_fields   [ alias ] = ns_fields   [ original ] 
end

function parse_command( command, file, line_no )
	local name, sets = command:match("^%s*([%a_]+)%s*=%s*([%a_,%(%){} ]+)%s*$")
	if not name then 
		parse_error( file, line_no, "malformed lua_check command", command )
		return
	end
	local cmd, val = sets:match("^%s*([%a_]+)%(%s*([%a_]+)%s*%)%s*$")
	if cmd then
		if cmd == "alias" then
			make_alias( name, val )
			return
		end
		parse_error( file, line_no, "unknown lua_check command", sets )
		return
	end
	
	sets = sets:split(",")
	for _,v in ipairs(sets) do
		local tab, values = v:match("^%s*([%a]+)%s*{([%a_ ]+)}%s*$")
		if not tab then 
			parse_error( file, line_no, "malformed lua_check parameter", v )
			return
		end
		local ids = values:split("%s+")
		if not ns_names[tab] then 
			parse_error( file, line_no, "unknown lua_check parameter class", v )
			return
		end
		for _,id in ipairs(ids) do
			table.set( ns_names[tab], name, id )
		end
	end
end


function parse( files, parse_func, ... )
	if type(files) == "string" then 
		files = { files }
	end
	for _,file_name in ipairs(files) do
		local file = io.open( file_name )
		local line_no = 0
		if file == nil then
			io.write("File "..file_name.." not found!")
			return
		end
		for line in file:lines() do	
			line_no = line_no + 1
			parse_func( line, file_name, line_no, ... ) 
		end
		file:close()
	end
end

function parse_config_line( line )
	local match = line:match( "^([%w_]+)%s*= [%d%+%w_]+;")
	if not match then return end
	ns_globals[ match ] = true
end

function parse_require_line( line )
	local match = line:match( "^require%( \"doomrl:([%w/_]+)\" %)")
	if not match then return end
	table.insert( lua_files, "lua/"..match..".lua" )
end

function parse_pascal_line( line, file_name, file_line, target )
	if line:match( "%s*//" ) then return end
	local namespace, func_name, namespace2, func_name2 = line:match( 
		"SetTableFunction%(%s*'(%a+)',%s*'([%a_]+)'%s*,%s*@lua_(%a+)_([%a_]+)%s*%)"
	)
	if not namespace then return end
	if string.lower(namespace) ~= namespace2 then
		parse_error( file_name,file_line,"namespace mismatch",line)
	end
	if func_name ~= func_name2 then
		parse_error( file_name,file_line,"function mismatch",line)
	end
	
	if func_name == "new" then
		table.set( ns_functions, namespace, func_name )
	else
		table.set( target, namespace, func_name )
	end
end

function parse_lua_methods( line, file, line_no )
	local command = line:match("%-%-%[lua_check%] (.*)")
	if command then parse_command( command, file, line_no ) end
	
	local namespace, div, func_name = line:match( "function ([%a_]+)([%.:])([%w_]+)" ) 
	if not namespace then return end
	if div == "." then 
		table.set( ns_functions, namespace, func_name )
	else
		table.set( ns_methods, namespace, func_name )
	end
end


parse( lua_files, parse_require_line )
parse( lua_config_files, parse_config_line )

parse( pascal_method_files, parse_pascal_line, ns_methods )
parse( pascal_function_files, parse_pascal_line, ns_functions )
parse( lua_files, parse_lua_methods )


for k,_ in pairs(ns_globals) do 
	local target, name, field = parse_globals(k)
	if target then
		table.set( ns_names[target], name, field )
	end
end

function perform_merge( target, to, from )
	if not target[from] then return end
	if not target[to] then target[to] = {} end
	table.merge( target[to], target[from] ) 
end

for _,v in ipairs(parse_merges) do 
	perform_merge( ns_methods, v[1], v[2] )
	perform_merge( ns_fields, v[1], v[2] )
end

for _,v in ipairs(parse_libraries) do 
	load_namespace( v )
end

------------------------------------------------------------

function print_table_values( t )
	if not t then return end
	for k, v in pairs( t ) do
		io.write(v.." ")
	end
end

function print_table_keys( t )
	if not t then return end
	for k, v in pairs( t ) do
		io.write(k.." ")
	end
end

function code_line( line )
	if line:match("%.%.%.") or line:match("X\.X") or line:match("^%-%-") then return nil end
	line = line:gsub( "%-%-.*", "" )
	line = line:gsub( "\".*\"", "\"\"" )
	return line
end

function parse_field( line, file_name, file_line )
	local function check( ns, d, field, where, name ) 
		if not where[ ns ] then
			if ns_fields[ ns ] or ns_methods[ ns ] or ns_functions[ ns ] then
				parse_error( file_name, file_line, "unknown "..name.." '"..field.."'",ns..d..field )
			else
				parse_error( file_name, file_line, "unknown namespace '"..ns.."'",ns..d..field )
			end
			return
		end
		if not where[ ns ][ field ] then
			parse_error( file_name, file_line, "unknown "..name.." '"..field.."'",ns..d..field )
		end
	end
	line = code_line( line )
	if not line then return end
	while line do
		local t,d,f = line:match( "([%a_]+)([%.:])([%w_]+)")
		if not t then return end
		local _,ending = line:find(t..d..f)
		line = line:sub( ending-#f+1 )
		
		local func = line:match( "^"..f.."%w*[%({]")
		if d == ":" then
			check( t, d, f, ns_methods, "method" )
		else
			if func then
				check( t, d, f, ns_functions, "function" )
			else
				if t == "DoomRL" and line:match( "^"..f.."%s*= nil") then
					check( t, d, f, ns_functions, "function" )
				else
					check( t, d, f, ns_fields, "field" )
				end
			end
		end
	end
end

parse( lua_files, parse_field )
