"""Run with Python and lupa available on PYTHONPATH."""
from pathlib import Path
from lupa.lua51 import LuaRuntime

root = Path(__file__).resolve().parents[1]
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute('''
FBI = {settings={GroupByLocation=true, ShowLocationZones=true},
    SubZoneMap={Coast={[101]=true,[201]=true}},
    ByFishie={[1]={[101]=30,[102]=10,[201]=60}, [2]={[101]=70,[102]=40}}};
function FBI:GetSettingBool(key) return self.settings[key] end
FishingBuddy_Info = {SubZones={[101]="Coast",[102]="Lake",[201]="Coast"},
    FishingHoles={[101]={[1]=30,[2]=70},[102]={[1]=10,[2]=40},[201]={[1]=60}},
    FishTotals={[100]=150,[101]=100,[102]=50,[200]=60,[201]=60}};
FishingLocations = {rows={}};
function FishingLocations:GetVisible(index) return self.rows[index] end
function FishingLocations:unpack(row) return unpack(row) end
function check(index, expected, denominator)
    local count,total=FBI:GetLocationRowStats(index);
    assert(count==expected, tostring(count).." != "..expected);
    assert(total==denominator, tostring(total).." != "..tostring(denominator));
end
''')
lua.execute(root.joinpath('FishingLocationStats.lua').read_text(), 'test', lua.globals().FBI)
lua.execute('''
FishingLocations.rows={{100,0,1,1,0},{101,0,1,1,1},{0,1,0,0,2},
    {0,2,0,0,2},{102,0,1,1,1},{0,1,0,0,2},{0,3,0,0,2}};
-- Initialize children out of order, as the ScrollBox does.
check(6,10,50); check(3,30,100); check(4,70,100);
check(2,100,150); check(1,150,nil); check(7,0,50);
FBI.settings.ShowLocationZones=false;
FishingLocations.rows={{101,0,1,1,0},{0,1,0,0,1},{0,2,0,0,1}};
check(2,90,160); check(3,70,160); check(1,160,nil);
FBI.settings.GroupByLocation=false;
FishingLocations.rows={{0,1,1,1,0},{101,0,0,0,1},{201,0,0,0,1}};
check(1,100,nil); check(2,30,100); check(3,60,100);
-- Updated catches are reflected immediately, without a stale cached total.
FishingBuddy_Info.FishingHoles[101][1]=35; FBI.ByFishie[1][101]=35;
check(2,35,105);
''')
for name in ('FishingLocationStats.lua', 'FishingLocationsFrame.lua'):
    lua.execute('assert(loadstring(...))', root.joinpath(name).read_text())
print('Passed 13 contextual row checks and Lua 5.1 syntax checks.')
