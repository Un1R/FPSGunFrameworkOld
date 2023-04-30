local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Framework = ReplicatedStorage:WaitForChild("Framework")
local Guns = Framework:WaitForChild("Guns")

local FireEvent = Framework:WaitForChild("Fire")

local current_gun = nil

local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local GunUI = PlayerGui:WaitForChild("GunUI")

local sharedSettingsModule

local Mouse = Player:GetMouse()

local HoldTrack
local FireTrack = nil
local AimTrack = nil
local ReloadTrack = nil

local CharHoldTrack

local Running = false
local Aiming = false

local CharAnims = Character:WaitForChild("GunAnimations")
local CurrentAnims

--// Framework
local SwayEffect = 0.8
local SwayCFrame = CFrame.new()
local LastCameraCFrame = CFrame.new()

Character.ChildAdded:Connect(function(CHILD)

	wait(0.1)

	if CHILD:IsA("Tool") and CHILD:FindFirstChild("FRAMEWORK_I") and CHILD:FindFirstChild("Settings") and Character:WaitForChild("Humanoid").Health >= 1 then
		
		PlayerGui:WaitForChild("Cursor"):WaitForChild("Frame").Visible = true
		PlayerGui:WaitForChild("Cursor"):WaitForChild("Frame2").Visible = false
		PlayerGui:WaitForChild("Cursor"):WaitForChild("Frame2").TextLabel.Text = "Item"

		for _,i in ipairs(CHILD:GetDescendants()) do
			
			if i:IsA("BasePart") or i:IsA("MeshPart") or i:IsA("UnionOperation") then
				
				i.Transparency = 1
				
			end
			
		end
		
		current_gun = CHILD.Name
		
		CurrentAnims = current_gun
		
		CharHoldTrack = Character:WaitForChild("Humanoid"):FindFirstChild("Animator"):LoadAnimation(CharAnims[CurrentAnims]:FindFirstChild("Hold"))
		
		CharHoldTrack:Play()
		
		Character:WaitForChild("GunEquipped").Value = true

		local FrameworkGun = Guns:FindFirstChild(current_gun):Clone()
		local FrameworkGunAnimations = FrameworkGun:FindFirstChild("Animations")

		local SettingsModule = require(CHILD:WaitForChild("Settings"))
						
		FrameworkGun.Parent = workspace.Camera
		
		local Hold = FrameworkGunAnimations.Hold

		HoldTrack = FrameworkGun:WaitForChild("Humanoid"):FindFirstChild("Animator"):LoadAnimation(Hold)

		wait(0.2)

		HoldTrack:Play()

		RunService:BindToRenderStep("Item - " .. current_gun .. " - " .. Player.Name,500,function()

			FrameworkGun:SetPrimaryPartCFrame(workspace.CurrentCamera.CFrame * SettingsModule.StartCFrame * SwayCFrame)

			local Rotation = workspace.CurrentCamera.CFrame:toObjectSpace(LastCameraCFrame)
			local X,Y,Z = Rotation:ToOrientation()
			SwayCFrame = SwayCFrame:Lerp(CFrame.Angles(math.sin(X) * SwayEffect, math.sin(Y)* SwayEffect, 0), 0.25)
			LastCameraCFrame = workspace.CurrentCamera.CFrame
			
			

		end)

	end

end)

Character.ChildRemoved:Connect(function(CHILD)

	if CHILD:IsA("Tool") and CHILD:FindFirstChild("FRAMEWORK_I") and CHILD:FindFirstChild("Settings") and CHILD.Name == current_gun  and Character:WaitForChild("Humanoid").Health >= 1 then

		RunService:UnbindFromRenderStep("Item - " .. CHILD.Name .. " - " .. Player.Name)
		game.Workspace.Camera[CHILD.Name]:Destroy()
		current_gun = nil
		CharHoldTrack:Stop()
		CharHoldTrack = nil
		CurrentAnims = nil
		Character:WaitForChild("GunEquipped").Value = false

	end

end)
