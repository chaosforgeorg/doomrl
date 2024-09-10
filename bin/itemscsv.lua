dofile("lua/constants.lua")
drl = {}
items = {}

csv,err = io.open("items.csv", "w")
if err then print("Can't open items.csv : "..err) end

function declare(v,i)
  _G[v] = i
end

function register_item(ID,sID,name,level,weight,typ,flags)
  print(name)
  csv:write(ID..", "..name..", "..(level or 0)..", "..(weight or 0)..", "..typ.."\n");
end

dofile("lua/items.lua")

drl.register_items()

io.close(csv)
