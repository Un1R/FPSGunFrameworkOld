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

	if CHILD:IsA("Tool") and CHILD:FindFirstChild("FRAMEWORK") and CHILD:FindFirstChild("Settings") and Character:WaitForChild("Humanoid").Health >= 1 then
		
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
		
		sharedSettingsModule = SettingsModule
				
		FrameworkGun.Parent = workspace.Camera
		
		AimTrack = FrameworkGun:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(game.Workspace.Camera:FindFirstChild(current_gun):WaitForChild("Animations"):FindFirstChild("Aim"))
		ReloadTrack = FrameworkGun:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(game.Workspace.Camera:FindFirstChild(current_gun):WaitForChild("Animations"):FindFirstChild("Reload"))
		
		ReloadTrack:AdjustSpeed(0.5)
		
		local Hold = FrameworkGunAnimations.Hold

		HoldTrack = FrameworkGun:WaitForChild("Humanoid"):FindFirstChild("Animator"):LoadAnimation(Hold)

		wait(0.2)

		HoldTrack:Play()

		GunUI.Enabled = true
		GunUI.Ammo.Text = CHILD:WaitForChild("AmmoMag").Value .. " / " .. CHILD:WaitForChild("AmmoMax").Value
		GunUI.GName.Text = current_gun

		CHILD:WaitForChild("AmmoMag").Changed:Connect(function()
			GunUI.Ammo.Text = CHILD:WaitForChild("AmmoMag").Value .. " / " .. CHILD:WaitForChild("AmmoMax").Value
		end)

		CHILD:WaitForChild("AmmoMax").Changed:Connect(function()
			GunUI.Ammo.Text = CHILD:WaitForChild("AmmoMag").Value .. " / " .. CHILD:WaitForChild("AmmoMax").Value
		end)

		RunService:BindToRenderStep("Gun - " .. current_gun .. " - " .. Player.Name,500,function()

			FrameworkGun:SetPrimaryPartCFrame(workspace.CurrentCamera.CFrame * SettingsModule.StartCFrame * SwayCFrame)

			local Rotation = workspace.CurrentCamera.CFrame:toObjectSpace(LastCameraCFrame)
			local X,Y,Z = Rotation:ToOrientation()
			SwayCFrame = SwayCFrame:Lerp(CFrame.Angles(math.sin(X) * SwayEffect, math.sin(Y)* SwayEffect, 0), 0.25)
			LastCameraCFrame = workspace.CurrentCamera.CFrame
			
			if sharedSettingsModule.Shooting == false and FireTrack then
				FireTrack:Stop()
			end

		end)

	end

end)

Character.ChildRemoved:Connect(function(CHILD)

	if CHILD:IsA("Tool") and CHILD:FindFirstChild("FRAMEWORK") and CHILD:FindFirstChild("Settings") and CHILD.Name == current_gun  and Character:WaitForChild("Humanoid").Health >= 1 then

		GunUI.Enabled = false
		RunService:UnbindFromRenderStep("Gun - " .. CHILD.Name .. " - " .. Player.Name)
		game.Workspace.Camera[CHILD.Name]:Destroy()
		current_gun = nil
		sharedSettingsModule.CanShoot = true
		sharedSettingsModule.Reloading = false
		sharedSettingsModule.Shooting = false
		CharHoldTrack:Stop()
		CharHoldTrack = nil
		CurrentAnims = nil

		Character:WaitForChild("GunEquipped").Value = false
		
	end

end)

Character:WaitForChild("Humanoid").Died:Connect(function()

	if current_gun then

		GunUI.Enabled = false
		RunService:UnbindFromRenderStep("Gun - " .. current_gun .. " - " .. Player.Name)
		game.Workspace.Camera[current_gun]:Destroy()
		Character:WaitForChild("Humanoid"):UnequipTools()	
		current_gun = nil
		sharedSettingsModule.CanShoot = true
		sharedSettingsModule.Reloading = false
		sharedSettingsModule.Shooting = false
		CharHoldTrack:Stop()
		CharHoldTrack = nil
		CurrentAnims = nil

		Character:WaitForChild("GunEquipped").Value = false

	end

end)

local RunTrack = nil


game:GetService("UserInputService").InputBegan:Connect(function(Input,InteractingWithText)

	if current_gun then
		RunTrack = workspace.Camera:FindFirstChild(current_gun):WaitForChild("Humanoid"):FindFirstChild("Animator"):LoadAnimation(workspace.Camera:FindFirstChild(current_gun):WaitForChild("Animations"):FindFirstChild("Run"))
	end
	
	if current_gun then
		FireTrack = workspace.Camera:FindFirstChild(current_gun):WaitForChild("Humanoid"):FindFirstChild("Animator"):LoadAnimation(workspace.Camera:FindFirstChild(current_gun):WaitForChild("Animations"):FindFirstChild("Fire"))
	end

	if InteractingWithText then return end

	if current_gun and Input.KeyCode == Enum.KeyCode.LeftShift or Input.KeyCode == Enum.KeyCode.RightShift then
		
		Running = true
		sharedSettingsModule.CanShoot = false

		Character:WaitForChild("Humanoid").WalkSpeed = 21
		
		FireTrack:Stop()
		HoldTrack:Stop()
		AimTrack:Stop()		
		RunTrack:Play()
		
		
	elseif current_gun and Input.UserInputType == Enum.UserInputType.MouseButton1 then
		--print("MB1 Pressed")
		--print(sharedSettingsModule.Shooting)
		if Running then
			
			sharedSettingsModule.Shooting = true
			Running = false
			sharedSettingsModule.CanShoot = true

			Character:WaitForChild("Humanoid").WalkSpeed = 10

			RunTrack:Stop()
			HoldTrack:Play()
			
		end
		
		if sharedSettingsModule.CanShoot == true and sharedSettingsModule.Reloading == false then
			
			local Gun01 = Character:FindFirstChild(current_gun)
			local Gun02 = workspace.Camera:FindFirstChild(current_gun)
			
			--print("MB_2")
			if Gun01:WaitForChild("AmmoMag").Value >= 1 then
				--print("MB_3")
				if sharedSettingsModule.FireMode == "Auto" then
										
					--print("MB_4")
					sharedSettingsModule.Shooting = true
					Running = false
					sharedSettingsModule.CanShoot = true

					Character:WaitForChild("Humanoid").WalkSpeed = 10
					
					RunTrack:Stop()
					
					if not Aiming then
						
						HoldTrack:Play()
						
					end
					
					repeat
						FireTrack:Play()
						game:GetService("ReplicatedStorage"):WaitForChild("Framework"):FindFirstChild("Sound"):FireServer(Character:FindFirstChild(current_gun),"FireSND")
						Gun01.Handle.Muzzle.FlashFX.Enabled = true
						Gun01.Handle.Muzzle["FlashFX[Flash]"].Enabled = true
						Gun01.Handle.Muzzle.Smoke.Enabled = true
						Gun02.Gun.Muzzle.FlashFX.Enabled = true
						Gun02.Gun.Muzzle["FlashFX[Flash]"].Enabled = true
						Gun02.Gun.Muzzle.Smoke.Enabled = true
						
						Gun01:WaitForChild("AmmoMag").Value -= 1
						
						
						FireEvent:FireServer(Character:WaitForChild("Humanoid"),sharedSettingsModule.Damage,Character,Character:FindFirstChild(current_gun),Mouse.Hit.p)
						
						wait(0.01)
						Gun01.Handle.Muzzle.FlashFX.Enabled = false
						Gun01.Handle.Muzzle["FlashFX[Flash]"].Enabled = false
						Gun01.Handle.Muzzle.Smoke.Enabled = false
						Gun02.Gun.Muzzle.FlashFX.Enabled = false
						Gun02.Gun.Muzzle["FlashFX[Flash]"].Enabled = false
						Gun02.Gun.Muzzle.Smoke.Enabled = false

						wait(sharedSettingsModule.FireRate)
					until not current_gun or sharedSettingsModule.Shooting == false or Character:WaitForChild("Humanoid").Health <= 0 or Running == true or Gun01:WaitForChild("AmmoMag").Value <= 0
					FireTrack:Stop()

				end
				
				
			end
			
		end
		
	elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and current_gun and not Running then
		
		game.Workspace.Camera.FieldOfView = 67
		
		Aiming = true
		AimTrack:Play()
		
	elseif current_gun and not sharedSettingsModule.Reloading == true and Input.KeyCode == Enum.KeyCode.R and Character:FindFirstChild(current_gun):WaitForChild("AmmoMag").Value < Character:FindFirstChild(current_gun):WaitForChild("AmmoMax").Value then
		sharedSettingsModule.Reloading = true
		sharedSettingsModule.CanShoot = false
		AimTrack:Stop()
		FireTrack:Stop()
		Running = false
		RunTrack:Stop()
		ReloadTrack:Play()
		Framework:WaitForChild("Sound"):FireServer(Character:FindFirstChild(current_gun),"ReloadSND")
		Character:WaitForChild("Humanoid").WalkSpeed = 10
		game.Workspace.Camera.FieldOfView = 70
		ReloadTrack.Stopped:Wait()
		Character:FindFirstChild(current_gun):WaitForChild("AmmoMag").Value = Character:FindFirstChild(current_gun):WaitForChild("AmmoMax").Value
		sharedSettingsModule.CanShoot = true
		sharedSettingsModule.Reloading = false
	end

end)

game:GetService("UserInputService").InputEnded:Connect(function(Input,InteractingWithText)

	if InteractingWithText then return end

	if current_gun and Input.KeyCode == Enum.KeyCode.LeftShift or Input.KeyCode == Enum.KeyCode.RightShift then
		
		Running = false
		sharedSettingsModule.CanShoot = true

		Character:WaitForChild("Humanoid").WalkSpeed = 10

		RunTrack:Stop()
		HoldTrack:Play()		
		
	elseif current_gun and Input.UserInputType == Enum.UserInputType.MouseButton1 then
		sharedSettingsModule.Shooting = false
		FireTrack:Stop()
		local gunha = Character:FindFirstChild(current_gun)

		gunha:WaitForChild("Handle").Muzzle.FlashFX.Enabled = false
		gunha:WaitForChild("Handle").Muzzle["FlashFX[Flash]"].Enabled = false
		gunha:WaitForChild("Handle").Muzzle.Smoke.Enabled = false
		
		game.Workspace.Camera:FindFirstChild(current_gun).Gun.Muzzle.FlashFX.Enabled = false
		game.Workspace.Camera:FindFirstChild(current_gun).Gun.Muzzle["FlashFX[Flash]"].Enabled = false
		game.Workspace.Camera:FindFirstChild(current_gun).Gun.Muzzle["Smoke"].Enabled = false
		FireTrack:Stop()

	elseif current_gun and not Running and Input.UserInputType == Enum.UserInputType.MouseButton2 then
		
		game.Workspace.Camera.FieldOfView = 70
		
		Aiming = false
		AimTrack:Stop()
		AimTrack:Stop()
		HoldTrack:Play()
	
	end

end)
