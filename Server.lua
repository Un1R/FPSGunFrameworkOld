local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FireEvent = ReplicatedStorage:WaitForChild("Framework"):FindFirstChild("Fire")
local SoundEvent = ReplicatedStorage:WaitForChild("Framework"):FindFirstChild("Sound")

FireEvent.OnServerEvent:Connect(function(_,Humanoid,dmg,char,gun,position)
	
	local gun1 = char:FindFirstChild(gun.Name)
	
	local origin = gun1.Handle.FP.Position
	local direction = (position - origin).Unit*300
	local result = workspace:Raycast(origin, direction)

	local intersection = result and result.Position or origin + direction
	local distance = (origin - intersection).Magnitude

	local bullet_clone = Instance.new("Part")
	bullet_clone.Anchored = true
	bullet_clone.CanCollide = false
	bullet_clone.Color = Color3.new(0.980392, 1, 0.843137)
	bullet_clone.Transparency = 0.84
	bullet_clone.Size = Vector3.new(0.1, 0.1, distance)
	bullet_clone.CFrame = CFrame.new(origin, intersection)*CFrame.new(0, 0, -distance/2)
	bullet_clone.Parent = workspace
	
	if result then
		local p = result.Instance
		
		if p:IsA("BasePart") and not p.Parent:FindFirstChild("Humanoid") or p:IsA("MeshPart") and not p.Parent:FindFirstChild("Humanoid") or p:IsA("UnionOperation") and not p.Parent:FindFirstChild("Humanoid") then local bullethole = game:GetService("ServerStorage"):FindFirstChild("BulletHole"):Clone() bullethole.Position = position bullethole.Parent = workspace:WaitForChild("BulletHoles") gun1.Handle["BulletHitSND"]:Play() end
		if not p.Parent then wait(0.05) bullet_clone:Destroy() return end
		if not p.Parent:IsA("Model") then wait(0.05) bullet_clone:Destroy() return end
		
		local hithumanoid = p.Parent:FindFirstChild("Humanoid") or p.Parent.Parent:FindFirstChild("Humanoid")
		
		if not hithumanoid then wait(0.05) bullet_clone:Destroy() return end
		if hithumanoid.Parent.Name == char.Name then wait(0.05) bullet_clone:Destroy() return end
		
		gun1.Handle["DamageSND"]:Play()
		hithumanoid:TakeDamage(dmg)
		
	end
	wait(0.05)
	bullet_clone:Destroy()
	
end)

SoundEvent.OnServerEvent:Connect(function(_,gun,sndn)
	
	gun.Handle[sndn]:Play()
	
end)
