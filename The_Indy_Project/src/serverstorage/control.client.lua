local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local getsensor = ReplicatedStorage:WaitForChild("GetSensors");

repeat wait() until player.Character

local movementFunctions = {}
local currentDirection = 1;
local wantedDirection = 1;
local lasthitsensor = {0,0};
local sensors = workspace:WaitForChild("sensorfolder"):GetChildren();

local directionTable = {Vector3.new(0,0,-1), Vector3.new(1,0,0), Vector3.new(0,0,1), Vector3.new(-1,0,0)}

function movementFunctions:changedirection(north, east, south, west)

    print("Changed direction");
    local table = {north,east,south,west}
    print("north, east, south, west")
    print(north)
    print(east)
    print(south)
    print(west)

    local direction = nil;

    local reversedirection = currentDirection - 2

    if reversedirection <= 0 then 
        reversedirection = reversedirection + 4 
    end

    if wantedDirection ~= nil then
        if table[wantedDirection] == true and wantedDirection ~= reversedirection then
            direction = wantedDirection;
            wantedDirection = nil;
        end
    end

    if direction == nil then
        if table[currentDirection] == true and currentDirection ~= reversedirection then
            direction = currentDirection;
        end
    end


    if direction == nil then
        local tally = 0;
        for i = 1, #table do
            if table[i] == true then
                tally = tally + 1;
            end
        end

        if tally >= 2 then
            for i =#table, 1, -1 do
                if table[i] == true and i ~= reversedirection then
                    direction = i;
                end
            end
        else
            for i = 1, #table do
                if table[i] == true then
                    direction = i;
                end
            end
        end
    end
    
    print("direction")
    print(direction)

    if direction ~= nil then
    
        local newdir = direction - currentDirection;
        if newdir < 0 then
            newdir = 4 + newdir;
        end
        local y = player.Character;
        if y then
            local x = y.HumanoidRootPart;
            local vel = math.abs(x.Velocity.X + x.Velocity.Z)
            local xzdirections = {{0,-1},{1,0},{0,1},{-1,0}}
            x.Velocity = Vector3.new(-vel * directionTable[direction].Z,x.Velocity.Y, vel * directionTable[direction].X);
        end
        currentDirection = direction;
    
    end

    

end

function movementFunctions:changewantedDirection(direction,inputstate)
    if inputstate == Enum.UserInputState.Begin then
        wantedDirection = direction;
    end
end
for i = 1, #sensors do
    sensors[i].Touched:Connect(function(obj)
        if obj:IsDescendantOf(player.Character) and obj.Name == "HumanoidRootPart"then
            if lasthitsensor ~= sensors[i] then
                movementFunctions:changedirection(sensors[i].north.Value,sensors[i].east.Value,sensors[i].south.Value,sensors[i].west.Value)
                lasthitsensor = sensors[i]
            end
        end
    end);
end

function movementFunctions:bindtosensors()
    
end

local function start()
    ContextActionService:BindAction("North",function(actionName, inputState, inputObject) movementFunctions:changewantedDirection(1,inputState) end,true,Enum.KeyCode.W)
    ContextActionService:BindAction("East",function(actionName, inputState, inputObject) movementFunctions:changewantedDirection(2,inputState) end,true,Enum.KeyCode.D)
    ContextActionService:BindAction("South",function(actionName, inputState, inputObject) movementFunctions:changewantedDirection(3,inputState) end,true,Enum.KeyCode.S)
    ContextActionService:BindAction("West",function(actionName, inputState, inputObject) movementFunctions:changewantedDirection(4,inputState) end,true,Enum.KeyCode.A)
    
    game:GetService("RunService").RenderStepped:Connect(function()
        player:Move(directionTable[currentDirection], true)
    end)
end

start();

