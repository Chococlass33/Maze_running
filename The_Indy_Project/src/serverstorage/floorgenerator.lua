-- Contains an object representing a 3d map.

local floorgenerator = {};
floorgenerator.__index = floorgenerator;


function floorgenerator:generate(startx, starty, startz, pillarobj, wallobj, blockobj, floorobj, sensorobj, floorplan, squaresize)

    local map = {};
    setmetatable(map,floorgenerator);

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
                temp.Parent = workspace;
                local vector = Vector3.new(startx + i * squaresize,starty,startz + j * squaresize);
                temp.Position = vector;
                map.floors[i][j] = temp;
            end
        end
    end

    -- Generate pillars

    for i = 2, #floorplan,3 do
        for j = 2, #floorplan[i],3 do
            if floorplan[i][j][1] == 1 or floorplan[i][j][1] == 5 then
                local temp = pillarobj:clone();
                temp.Parent = workspace;
                local vector = Vector3.new(startx + i * squaresize,starty + temp.Size.Y/2,startz + j * squaresize);
                temp.Position = vector;

                map.obstacles[i][j] = temp;
            end
        end
    end

    -- Generate blocks

    for i = 1, #floorplan,3 do
        for j = 1, #floorplan[i],3 do
            if floorplan[i][j][1] == 3 then
                local temp = blockobj:clone();
                temp.Parent = workspace;
                local vector = Vector3.new(startx + i * squaresize - squaresize * 0.5,starty+ temp.Size.Y/2,startz + j * squaresize - squaresize * 0.5);
                temp.Position = vector;

                for k = 0, 2 do
                    for l = 0, 2 do
                        map.obstacles[i+k][j+l] = temp;
                    end
                end

            end
        end
    end

    -- Generate vertical walls

    for i = 1, #floorplan,3 do
        for j = 2, #floorplan[i],3 do
            if floorplan[i][j][1] == 2 or floorplan[i][j][1] == 6 then
                local temp = wallobj:clone();
                temp.Parent = workspace;
                local vector = Vector3.new(startx + i * squaresize - squaresize * 0.5, starty + temp.Size.Y/2, startz + j * squaresize);
                temp.Position = vector;
                
                map.obstacles[i][j] = temp;
                map.obstacles[i+1][j] = temp;
            end
        end
    end

    -- Generate horizontal walls

    for i = 2, #floorplan,3 do
        for j = 1, #floorplan[i],3 do
            if floorplan[i][j][1] == 2 or floorplan[i][j][1] == 6 then
                local temp = wallobj:clone();
                temp.Parent = workspace;
                local vector = Vector3.new(startx + i * squaresize, starty+ temp.Size.Y/2, startz + j * squaresize - squaresize * 0.5);
                temp.Rotation = Vector3.new(0,90,0);
                temp.Position = vector;
                
                map.obstacles[i][j] = temp;
                map.obstacles[i][j+1] = temp;
            end
        end
    end

    -- Generate Intersections, Connect to corresponding wall

    for i = 3, #floorplan,3 do
        for j = 3, #floorplan[i],3 do
            if floorplan[i][j][1] == 0 then
                local temp = sensorobj:clone();
                temp.Parent = workspace;
                local vector = Vector3.new(startx + i * squaresize + squaresize * 0.5,starty+ temp.Size.Y/2,startz + j * squaresize + squaresize * 0.5);
                temp.Position = vector;
                map.sensors[i][j] = sensorobj;
            end
        end
    end

    return map;
end

return floorgenerator;