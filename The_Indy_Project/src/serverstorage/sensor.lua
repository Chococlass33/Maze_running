local Sensor = {};
Sensor.__index = Sensor;

function Sensor.new(north, east, south, west, object)
    local newSensor = setmetatable({},Sensor);
    newSensor.object = object;
    newSensor.obstacles = {north,east,south,west};
    newSensor.directions = table.create(4);
    newSensor.directions[1] = Instance.new("BoolValue")
    newSensor.directions[1].Name = "north";
    newSensor.directions[1].Value = north == 0;
    newSensor.directions[1].Parent = object;
    newSensor.directions[2] = Instance.new("BoolValue")
    newSensor.directions[2].Name = "east";
    newSensor.directions[2].Value = east == 0;
    newSensor.directions[2].Parent = object;
    newSensor.directions[3] = Instance.new("BoolValue")
    newSensor.directions[3].Name = "south";
    newSensor.directions[3].Value = south == 0;
    newSensor.directions[3].Parent = object;
    newSensor.directions[4] = Instance.new("BoolValue")
    newSensor.directions[4].Name = "west";
    newSensor.directions[4].Value = west == 0;
    newSensor.directions[4].Parent = object;

    for i = 1, #newSensor.obstacles do
        if newSensor.obstacles[i] ~= 0 then
            newSensor.obstacles[i].object.AncestryChanged:connect(function()
                if not newSensor.obstacles[i].object:IsDescendantOf(workspace) then
                    newSensor.obstacles[i] = 0;
                    newSensor.directions[i].Value = true;
                    print("destroyed");
                end
            end)
        end
    end
    return newSensor;
end

function Sensor:bind(func)
    self.object.Touched:Connect(function(f)
        return func(self:givedirection());
    end)
end

function Sensor:givedirection()
    return self.obstacles;
end

function Sensor:addobstacle(direction,obstacle)
    self.obstacles[direction] = obstacle;
    obstacle.object.AncestryChanged:connect(function()
        if not obstacle.object:IsDescendantOf(game) then
            self.obstacles[direction] = 0;
            self.directions[direction].Value = false;
        end
    end)
end

function Sensor:removeobstacle(direction)
    self.obstacles[direction] = 0;
end

return Sensor;