--Creates a top-down camera for each player. Should be used as a     LocalScript
 
--Get service needed for events used in this script
local RunService = game:GetService("RunService")	
 
-- Variables for the camera and player
local camera = workspace.CurrentCamera
local player = game.Players.LocalPlayer
 
-- Constant variable used to set the camera’s offset from the player
local CAMERA_OFFSET = Vector3.new(-1,200,0)

-- Enables the camera to do what this script says
camera.CameraType = Enum.CameraType.Scriptable 
  
-- Called every time the screen refreshes
local function onRenderStep()
	-- Check the player's character has spawned
	if player.Character then
		if player.Character:FindFirstChild("HumanoidRootPart") then
			local playerPosition = player.Character.HumanoidRootPart.Position
			local cameraPosition = playerPosition + CAMERA_OFFSET
			
			-- make the camera follow the player
			camera.CFrame = CFrame.new(cameraPosition, playerPosition)
		end
	end
end
 
RunService:BindToRenderStep("Camera", Enum.RenderPriority.Camera.Value, onRenderStep)