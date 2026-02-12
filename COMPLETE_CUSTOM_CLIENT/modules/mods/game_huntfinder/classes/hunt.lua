-- Classe de parse do Json
if not Hunt then
    Hunt = {
        Name = "",
        Level = 0,
        Type = {},
        XPHour = "",
        LootHour = "",
        Location = "",
        Vocation = {},
        PremiumRequired = false,
        RouteRequirements = "",
        RecommendedImbues = "",
        RecommendedSupplies = {},
        ValuableDrops = {},
        Monsters = {},
        WayPath = {},
        RoutePath = {},
        Equipments = {},
    }
    Hunt.__index = Hunt
end

function Hunt:new(data)
    return setmetatable({
        Name = data.Name,
        Level = tonumber(data.Level),
        Type = data.Type or {},
        XPHour = data["Xp/Hour"],
        LootHour = data["Loot/Hour"],
        Location = data.Location,
        Vocation = data.Vocation or {},
        PremiumRequired = data.PremiumRequired,
        RouteRequirements = data.RouteRequirements,
        RecommendedImbues = data.RecommendedImbues,
        RecommendedSupplies = data.RecommendedSupplies,
        ValuableDrops = data.ValuableDrops,
        Monsters = data.Monsters,
        WayPath = data.WayPath,
        RoutePath = data.RoutePath,
        Equipments = data.Equipments,
    }, Hunt)
end

function Hunt:getName() return self.Name end
function Hunt:getLevel() return self.Level end
function Hunt:getType() return self.Type end
function Hunt:getXPHour() return self.XPHour end
function Hunt:getLootHour() return self.LootHour end
function Hunt:getLocation() return self.Location end
function Hunt:getVocations() return self.Vocation end
function Hunt:getPremiumRequired() return self.PremiumRequired end
function Hunt:getRouteRequirements() return self.RouteRequirements end
function Hunt:getRecommendedImbues() return self.RecommendedImbues end
function Hunt:getRecommendedSupplies() return self.RecommendedSupplies end
function Hunt:getValuableDrops() return self.ValuableDrops end
function Hunt:getMonsters() return self.Monsters end
function Hunt:getWayPath() return self.WayPath end
function Hunt:getRoutePath() return self.RoutePath end
function Hunt:getEquipments() return self.Equipments end
function Hunt:getPosition() return self.WayPath.Position and self.WayPath.Position or {x = 0, y = 0, z = 0} end
function Hunt:getTemplePosition() return self.WayPath.TemplePosition and self.WayPath.TemplePosition or {x = 0, y = 0, z = 0} end
function Hunt:getCoordinates() return self.WayPath.Coordinates and self.WayPath.Coordinates or {} end
function Hunt:getRouteCoordinates() return self.RoutePath.Coordinates and self.RoutePath.Coordinates or {} end

function Hunt:getRecommendedImbuesByVocation(vocation)
    local find = self.RecommendedImbues[vocation]
    if find then
        return find
    end
    if vocation == "Druid" or vocation == "Sorcerer" then
        return self.RecommendedImbues["Mage"] or {}
    end
    return {}
end

function Hunt:getRecommendedSuppliesByVocation(vocation)
    local find = self.RecommendedSupplies[vocation]
    if find then
        return find
    end
    if vocation == "Druid" or vocation == "Sorcerer" then
        return self.RecommendedSupplies["Mage"] or {}
    end
    return {}
end

function Hunt:getEquipmentsByVocation(vocation)
    local find = self.Equipments[vocation]
    if find then
        return find
    end
    if vocation == "Druid" or vocation == "Sorcerer" then
        return self.Equipments["Mage"] or {}
    end
    return {}
end