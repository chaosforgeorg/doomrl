dofile("lua/constants.lua")
DoomRL = {}
items = {}

csv,err = io.open("items.csv", "w")
if err then print("Can't open items.csv : "..err) end

function declare(v,i)
  _G[v] = i
end

function registeritem(ID,sID,name,level,weight,typ,flags)
  print(name)
  csv:write(ID..", "..name..", "..(level or 0)..", "..(weight or 0)..", "..typ.."\n");
end

dofile("lua/items.lua")

DoomRL.loaditems()

io.close(csv)
