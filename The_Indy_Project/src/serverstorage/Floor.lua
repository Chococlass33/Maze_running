local Floor = {};
Floor.__index = Floor;

function Floor.new(object)
    local floor = {};
    floor.object = object;
    setmetatable(floor,Floor);
    return floor;
end

function Floor:bind(func)
    self.object.Touched:Connect(func);
end

return Floor;
