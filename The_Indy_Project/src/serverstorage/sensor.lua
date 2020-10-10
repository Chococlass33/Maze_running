local Sensor = {};
Sensor.__index = Sensor;

function Sensor.new(north, east, south, west, object)
    local newSensor = {};
    newSensor.object = object;
    setmetatable(newSensor,Sensor);
    newSensor.obstacles = {north,east,south,west};
    for i = 1, #newSensor.obstacles do
        if newSensor.obstacles[i] ~= nil then
            newSensor.obstacles[i].object.AncestryChanged:connect(function()
                if not newSensor.obstacles[i].object:IsDescendantOf(workspace) then
                    newSensor.obstacles[i] = nil;
                    print("destroyed");
                end
            end)
        end
    end
    return newSensor;
end

function Sensor:bind(func)
    self.object.Touched:Connect(func);
end

function Sensor:givedirection(parttouched)
    return self.obstacles;
end

function Sensor:addobstacle(direction,obstacle)
    self.obstacles[direction] = obstacle;
    obstacle.AncestryChanged:connect(function()
        if not obstacle:IsDescendantOf(game) then
            self.obstacles[direction] = nil;
        end
    end)
end

function Sensor:removeobstacle(direction)
    self.obstacles[direction] = nil;
end

return Sensor;