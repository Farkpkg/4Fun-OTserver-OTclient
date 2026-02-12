if not MapFinder then
    MapFinder = {
        widget = nil
    }
    MapFinder.__index = MapFinder
end

local self = MapFinder

function MapFinder.init()
    self.widget = HuntFinder.widget:recursiveGetChildById('minimap')
    RealMap.setRegion(self.widget)
    RealMap.setCameraPosition(self.widget, g_game.getLocalPlayer():getPosition())
    RealMap.setCrossPosition(self.widget, g_game.getLocalPlayer():getPosition())
    RealMap.setZoom(self.widget, 2)

---@diagnostic disable-next-line: inject-field
    self.widget.view = "minimap"
    self.widget:setCurrentView(self.widget.view)
    self.widget:setBackgroundColor("#274DA6")
    self.widget:setDrawWaypoints(true)

    self.widget.onFloorChange = function(widget, newPos, oldPos)
        self:onFloorChange(widget, newPos, oldPos)
    end

    self.widget:clearWaypoints()
    self.widget:clearRoutePath()
    self.widget:resetCustomMouseEvent()
    self.widget:setDrawRegions(false)
end

function MapFinder:clear()
    if not self.widget then
        return
    end

    self.widget:destroyChildren()
    self.widget = nil
end

function MapFinder:onFloorChange(widget, newPos, oldPos)
    if newPos.z > 7 then
        self.widget.view = "minimap"
        self.widget:setBackgroundColor("#000000ff")
    else
        self.widget.view = "minimap"
        self.widget:setBackgroundColor("#274DA6")
    end
    self.widget:setCurrentView(self.widget.view)
end

function MapFinder:setHuntPosition(position)
    if (position.x == 0 and position.y == 0 and position.z == 0) then
        return
    end
    RealMap.setCameraPosition(self.widget, position)

    MapFinder:onFloorChange(self.widget, position, {x = 0, y = 0, z = 0})
end

function MapFinder:setPath(coordinates)
    if table.size(coordinates) == 0 then
        return
    end

    self.widget:clearWaypoints()
    for floor, coordinate in pairs(coordinates) do
        if tonumber(floor) then
            self.widget:makeWaypoints(coordinate, tonumber(floor))
        end
    end
end


function MapFinder:setRoutePath(routePath)
    if table.size(routePath) == 0 then
        return
    end

    self.widget:clearRoutePath()
    for floor, coordinate in pairs(routePath) do
        if tonumber(floor) then
            self.widget:makeRouth(coordinate, tonumber(floor))
        end
    end
end
