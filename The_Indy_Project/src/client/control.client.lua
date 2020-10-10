local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

repeat wait() until player.Character

local movementFunctions = {}
local currentDirection = 1

local directionTable = {Vector3.new(0,0,1), Vector3.new(1,0,0), Vector3.new(0,0,-1), Vector3.new(-1,0,0)}

local function turn(direction)
    
end