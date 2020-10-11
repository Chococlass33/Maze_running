-- Contains an object representing a 3d map.
local serverstorage = game:GetService("ServerStorage")
local Obstacle = require(serverstorage.Obstacle)
local Sensor = require(serverstorage.Sensor)
local Floor = require(serverstorage.Floor)
local replicatedStorage = game:GetService("ReplicatedStorage");

local floorgenerator = {};
floorgenerator.__index = floorgenerator;

local function addxy(obj,x,y)
    local xinstance = Instance.new("NumberValue",obj)
    xinstance.Value = x;
    xinstance.Name = "x";
    local yinstance = Instance.new("NumberValue",obj)
    yinstance.Value = y;
    yinstance.Name = "y";

end

function floorgenerator.new(startx, starty, startz, pillarobj, wallobj, blockobj, floorobj, sensorobj, floorplan, squaresize)

    local map = setmetatable({},floorgenerator);
    

    map.startx = startx;
    map.starty = starty;
    map.startz = startz;
    map.pillarobj = pillarobj;
    map.wallobj = wallobj;
    map.blockobj = blockobj;
    map.floorobj = floorobj;
    map.sensorobj = sensorobj;
    map.floorplan = floorplan;


    if squaresize == nil then
        squaresize = 8;
    end

    map.squaresize = squaresize;

    -- Lists of objects to create

    map.obstacles = table.create(#floorplan);

    for i = 1, #floorplan do
        map.obstacles[i] = table.create(#floorplan[i]);
        for j = 1, #floorplan[i] do
            map.obstacles[i][j] = 0;
        end
    end
    
    -- List of Floor Objects

    map.floors = table.create(#floorplan);
    
    for i = 1, #floorplan do
        map.floors[i] = table.create(#floorplan[i]);
        for j = 1, #floorplan[i] do
            map.floors[i][j] = 0;
        end
    end

    -- List of Sensor Objects
    
    map.sensors = table.create(#floorplan);
    
    for i = 1, #floorplan do
        map.sensors[i] = table.create(#floorplan[i]);
        for j = 1, #floorplan[i] do
            map.sensors[i][j] = 0;
        end
    end

    -- List of Pickup Objects
    
    map.pickups = table.create(#floorplan);
    
    for i = 1, #floorplan do
        map.pickups[i] = table.create(#floorplan[i]);
        for j = 1, #floorplan[i] do
            map.pickups[i][j] = 0;
        end
    end

    -- Generate floor

    for i = 1, #floorplan do
        for j = 1, #floorplan[i] do
            if floorplan[i][j][1] ~= 4 then
                local temp = floorobj:clone();
                addxy(temp,i,j);
                local floor = Floor.new(temp);
                temp.Parent = workspace;
                local vector = Vector3.new(startx + i * squaresize,starty,startz + j * squaresize);
                temp.Position = vector;
                map.floors[i][j] = floor;
            end
        end
    end

    -- Generate pillars

    for i = 2, #floorplan,3 do
        for j = 2, #floorplan[i],3 do
            if floorplan[i][j][1] == 1 or floorplan[i][j][1] == 5 then
                local temp = pillarobj:clone();
                addxy(temp,i,j);
                local obstacle = Obstacle.new(temp, false);
                temp.Parent = workspace;
                local vector = Vector3.new(startx + i * squaresize,starty + temp.Size.Y/2,startz + j * squaresize);
                temp.Position = vector;

                map.obstacles[i][j] = obstacle;
            end
        end
    end

    -- Generate blocks

    for i = 3, #floorplan,3 do
        for j = 3, #floorplan[i],3 do
            if floorplan[i][j][1] == 3 then
                local temp = blockobj:clone();
                local obstacle = Obstacle.new(temp, false);
                temp.Parent = workspace;
                addxy(temp,i,j);
                local vector = Vector3.new(startx + i * squaresize + squaresize * 0.5,starty+ temp.Size.Y/2,startz + j * squaresize + squaresize * 0.5);
                temp.Position = vector;

                for k = -1, 2 do
                    for l = -1, 2 do
                        map.obstacles[i+k][j+l] = obstacle;
                    end
                end

            end
        end
    end

    -- Generate vertical walls

    for i = 3, #floorplan,3 do
        for j = 2, #floorplan[i],3 do
            if floorplan[i][j][1] == 2 or floorplan[i][j][1] == 6 then
                local temp = wallobj:clone();
                local obstacle = Obstacle.new(temp, floorplan[i][j][1] == 2);
                temp.Parent = workspace;
                addxy(temp,i,j);
                local vector = Vector3.new(startx + i * squaresize + squaresize * 0.5, starty + temp.Size.Y/2, startz + j * squaresize);
                temp.Position = vector;
                
                map.obstacles[i][j] = obstacle;
                map.obstacles[i+1][j] = obstacle;
            end
        end
    end

    -- Generate horizontal walls

    for i = 2, #floorplan,3 do
        for j = 3, #floorplan[i],3 do
            if floorplan[i][j][1] == 2 or floorplan[i][j][1] == 6 then
                local temp = wallobj:clone();
                local obstacle = Obstacle.new(temp, floorplan[i][j][1] == 2);
                temp.Parent = workspace;
                addxy(temp,i,j);
                local vector = Vector3.new(startx + i * squaresize, starty+ temp.Size.Y/2, startz + j * squaresize + squaresize * 0.5);
                temp.Rotation = Vector3.new(0,90,0);
                temp.Position = vector;
                
                map.obstacles[i][j] = obstacle;
                map.obstacles[i][j+1] = obstacle;
            end
        end
    end

    -- Generate Intersections, Connect to corresponding walls

    for i = 3, #floorplan-2, 3 do
        for j = 3, #floorplan[i]-2, 3 do
            if floorplan[i][j][1] == 0 then
                local temp = sensorobj:clone();
                local sensor = Sensor.new(map.obstacles[i+2][j],map.obstacles[i][j+2],map.obstacles[i-1][j],map.obstacles[i][j-1],temp);
                temp.Parent = workspace;
                addxy(temp,i,j);
                local vector = Vector3.new(startx + i * squaresize + squaresize * 0.5,starty+ temp.Size.Y/2,startz + j * squaresize + squaresize * 0.5);
                temp.Position = vector;
                map.sensors[i][j] = sensor;
                local function printdirections(directions)
                    print(directions);
                end
                sensor:bind(printdirections)
                print(sensor:givedirection());
            end
        end
    end

    map.sensorremote = Instance.new("RemoteFunction");
    map.sensorremote.Name = "GetSensors"
    
    function  map.givesensors()
        return map.sensors;
    end

    map.sensorremote.OnServerInvoke= map.givesensors;

    map.sensorremote.Parent = replicatedStorage;


    return map;
end



return floorgenerator;