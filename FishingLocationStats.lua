-- Row-local statistics: ScrollBox initializes rows independently and out of order.
local _, FBI = ...;

local function Parent(index, level)
    for i = index - 1, 1, -1 do
        local record = FishingLocations:GetVisible(i);
        if record and record ~= 0 then
            local zone, fish, _, _, depth = FishingLocations:unpack(record);
            if depth < level then return zone, fish; end
        end
    end
end

local function LocationCount(marker, fish, mergeNames)
    local markers = { [marker] = true };
    if mergeNames then
        local name = FishingBuddy_Info.SubZones[marker];
        markers = (name and FBI.SubZoneMap[name]) or markers;
    end
    local count = 0;
    for location in pairs(markers) do
        local catches = FishingBuddy_Info.FishingHoles[location] or {};
        if fish then
            count = count + (catches[fish] or 0);
        else
            for _, quantity in pairs(catches) do count = count + quantity; end
        end
    end
    return count;
end

local function FishCount(fish)
    local total = 0;
    for _, count in pairs(FBI.ByFishie[fish] or {}) do total = total + count; end
    return total;
end

function FBI:GetLocationRowStats(index)
    local marker = FishingLocations:GetVisible(index);
    local zone, fish, _, _, level = FishingLocations:unpack(marker);
    if self:GetSettingBool("GroupByLocation") then
        local showZones = self:GetSettingBool("ShowLocationZones");
        if fish > 0 then
            local parent = Parent(index, level);
            if not parent or parent == 0 then return 0, nil; end
            return LocationCount(parent, fish, not showZones),
                LocationCount(parent, nil, not showZones);
        end
        if not showZones then return LocationCount(zone, nil, true), nil; end
        if level == 0 then return FishingBuddy_Info.FishTotals[zone] or 0, nil; end
        local parent = Parent(index, level);
        return LocationCount(zone), parent and FishingBuddy_Info.FishTotals[parent];
    end
    if fish > 0 then return FishCount(fish), nil; end
    local _, parentFish = Parent(index, level);
    if not parentFish or parentFish == 0 then return 0, nil; end
    return LocationCount(zone, parentFish), FishCount(parentFish);
end
