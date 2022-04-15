local BlcokedFunctions={['require']=true;['Kick']=true;['kick']=true;['clearAllChildren']=true;['remove']=true;['Remove']=true;['Destroy']=true;['destroy']=true;['ClearAllChildren']=true;}; -- blocked function names;
local blockednewindexes={function(Item,Property,New)
if(Item)then
if(Item:isA'Player')then
if(Property=='Parent')then
return(true);
end;
end;
end;
end;}; -- blocked newindex's
local __ENV = getfenv()
local _print = print
local real_tables = {}
local watchdog = {}
local f_over = {}
local mutes = {}
local dummyfunction=function()
-- trying to call blocked function --
end;
local function v(t)
for i, v in ipairs(t) do
local typ = type(v)
if (typ == "function") then
t[i] = watchdog.functionproxy(v)
elseif ((typ == "table") or (typ == "userdata")) then
t[i] = watchdog.tableproxy(v)
end
end
end
local function output(watchdogCallType, tab, fName, ...)
if (mutes[fName]) then
return
end
_print(watchdogCallType, tab, fName, ...)
end
function watchdog.functionproxy(func, tab, actualName)
return function(...)
local args = {...}
for i, v in ipairs(args) do
local r = real_tables[v]
if (r) then
args[i] = r
end
end
local fOutput = func
if (actualName) then
fOutput = "function: " .. actualName
end
output("[Watchdog]:", tab, fOutput, ...)
if(BlcokedFunctions[actualName])then
return(dummyfunction())
end
local toVer
if (f_over[fOutput]) then
toVer = table.pack(f_over[fOutput](table.unpack(args)))
else
toVer = table.pack(func(table.unpack(args)))
end
v(toVer)
return (table.unpack(toVer))
end
end
function watchdog.tableproxy(tab)
if (real_tables[tab]) then
tab = real_tables[tab]
end
local o
if (type(tab) == "userdata") then
o = newproxy(true)
else
o = setmetatable({}, {})
end
local o_mt = getmetatable(o)
o_mt.__index = function(self, k)
local index = tab[k]
local typ = type(index)
if (typ == "function") then
return (watchdog.functionproxy(index, self, k))
else
output("[watchdog index]:", self, k)
if ((typ == "table") or (typ == "userdata")) then
return (watchdog.tableproxy(index))
else
return (index)
end
end
end
o_mt.__newindex = function(self, k, v)
output("[watchdog newindex]:", self, k, v)
local shouldblock=false;
for _,a in next,blockednewindexes do
if(a(tab,k,v))then
shouldblock=true;
end;
end;
if(shouldblock)then
return;
end;
tab[k] = v
end
o_mt.__metatable = "Metatable locked."
o_mt.__tostring = function()
if (tab == __ENV) then
return ("__ENV")
else
return (tostring(tab))
end
end
real_tables[o] = tab
return (o)
end
watchdog.__ENV = watchdog.tableproxy(__ENV)
function watchdog.setFunctionOverride(name, f)
f_over[name] = f
end
function watchdog.mute(a)
mutes[a] = true
end
return function(fenvOverrides)
for k, v in next, fenvOverrides do
__ENV[k] = v
end
return (watchdog)
end
