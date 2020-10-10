local Obstacle = {};
Obstacle.__index = Obstacle;

function Obstacle.new(object, breaks)
    local obstacle = {};
    obstacle.object = object;
    setmetatable(obstacle,Obstacle);
    obstacle.breaks = breaks;
    return obstacle;
end

function Obstacle:bind(func)
    self.object.Touched:Connect(func);
end

return Obstacle;
