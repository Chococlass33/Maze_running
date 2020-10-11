local Floor = {};
Floor.__index = Floor;

function Floor.new(object)
    local floor = setmetatable({},Floor);
    floor.object = object;
    return floor;
end

function Floor:bind(func)
    self.object.Touched:Connect(func);
end

return Floor;
