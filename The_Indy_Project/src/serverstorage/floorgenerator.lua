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

function floorgenerator.new(startx, starty, startz, pillarobj, wallobj, blockobj, floorobj, sensorobj, floorplan, door)

    local map = setmetatable({},floorgenerator);
    
    map.sensorfolder = Instance.new("Folder");
    map.sensorfolder.Name = "sensorfolder";
    map.sensorfolder.Parent = workspace;
    map.floorfolder = Instance.new("Folder");
    map.floorfolder.Name = "floorfolder";
    map.floorfolder.Parent = workspace;
    map.obstaclefolder = Instance.new("Folder");
    map.obstaclefolder.Name = "obstaclefolder";
    map.obstaclefolder.Parent = workspace;
    

    map.startx = startx;
    map.starty = starty;
    map.startz = startz;
    map.pillarobj = pillarobj;
    map.wallobj = wallobj;
    map.blockobj = blockobj;
    map.floorobj = floorobj;
    map.sensorobj = sensorobj;
    map.floorplan = floorplan;
    map.players = {};

    local squaresize = 8


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
                temp.Parent = map.floorfolder;
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
                temp.Parent = map.obstaclefolder;
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
                temp.Parent = map.obstaclefolder;
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
                temp.Parent = map.obstaclefolder;
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
                temp.Parent = map.obstaclefolder;
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
                temp.Parent = map.sensorfolder;
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

    -- RemoteFunction to return the list of sensors
    map.sensorremote = Instance.new("RemoteFunction");
    map.sensorremote.Name = "GetSensors"
    
    function  map.givesensors()
        return map.sensors;
    end

    map.sensorremote.OnServerInvoke= map.givesensors;

    map.sensorremote.Parent = replicatedStorage;

    local function doorteleport(player)
        local temp = {};
        for i = 1, #map.sensors do
            for j = 1, #map.sensors[i] do
                if map.sensors[i][j] ~= 0 then
                    table.insert(temp, map.sensors[i][j])
                end
            end
        end

        local camerascript = serverstorage.camera:Clone()
        local controlscript = serverstorage.control:Clone()
        camerascript.Parent = player.Character;
        controlscript.Parent = player.Character;
        player.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0);
        local rand = math.random(#temp)
        player.Character.HumanoidRootPart.CFrame = CFrame.new(temp[rand].object.Position);
    end

    door.Touched:Connect(function(obj)
        local player = game.Players:GetPlayerFromCharacter(obj.Parent);
        if player and not map.players[player] then
            map.players[player] = player;
            doorteleport(player);
            wait(3);
            map.players[player] = nil;
        end
    end)

    return map;
end



return floorgenerator;