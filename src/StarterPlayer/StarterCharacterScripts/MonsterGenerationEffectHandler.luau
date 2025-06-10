--[[
	MonsterGenerationEffectHandler
	Handles visual effects and mesh positioning for monster generation
]]

local MonsterGenerationEffectHandler = {}
MonsterGenerationEffectHandler.__index = MonsterGenerationEffectHandler

-- Services
local GenerationService = game:GetService("GenerationService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Constants
local EFFECT_SIZE = Vector3.new(4, 4, 4)
local PULSE_SIZE = Vector3.new(6, 6, 6)
local SPAWN_HEIGHT = 3
local MESH_SCALE = 5.0
local EFFECT_COLOR = Color3.new(0, 1, 1)

-----------------------------------------------------------------------
-- Private Functions

local function createEffect(entityGUID, position)
	local part = Instance.new("Part")
	part.Name = "GenerationEffect_" .. entityGUID
	part.Size = EFFECT_SIZE
	part.Material = Enum.Material.ForceField
	part.BrickColor = BrickColor.new("Bright blue")
	part.Shape = Enum.PartType.Ball
	part.Anchored = true
	part.CanCollide = false
	part.Position = position
	part.Parent = workspace
	
	-- Add light
	local light = Instance.new("PointLight")
	light.Color = EFFECT_COLOR
	light.Brightness = 2
	light.Range = 10
	light.Parent = part
	
	-- Add particles
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	
	local particles = Instance.new("ParticleEmitter")
	particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particles.Lifetime = NumberRange.new(1.0, 2.0)
	particles.Rate = 50
	particles.SpreadAngle = Vector2.new(45, 45)
	particles.Speed = NumberRange.new(5, 10)
	particles.Color = ColorSequence.new(EFFECT_COLOR)
	particles.Parent = attachment
	
	-- Add spin animation
	local spinConnection = RunService.Heartbeat:Connect(function(dt)
		if part.Parent then
			part.CFrame = part.CFrame * CFrame.Angles(0, math.rad(120 * dt), 0)
		else
			spinConnection:Disconnect()
		end
	end)
	
	-- Add pulse animation
	local pulseTween = TweenService:Create(part, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		Size = PULSE_SIZE,
		Transparency = 0.3
	})
	pulseTween:Play()
	
	return part, spinConnection, pulseTween
end

local function cleanupEffect(effect)
	if not effect then return end
	
	if effect.connection then
		effect.connection:Disconnect()
	end
	if effect.tween then
		effect.tween:Cancel()
	end
	if effect.part and effect.part.Parent then
		effect.part:Destroy()
	end
end

local function positionMesh(mesh, promptPart)
	-- Scale mesh
	if mesh:IsA("Model") then
		mesh:ScaleTo(MESH_SCALE)
	else
		mesh.Size = mesh.Size * MESH_SCALE
	end
	
	-- Anchor all parts
	if mesh:IsA("Model") then
		for _, part in pairs(mesh:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end
	else
		mesh.Anchored = true
	end
	
	-- Position on top of stand
	local standTop = promptPart.Position.Y + (promptPart.Size.Y / 2)
	local meshSize = mesh:IsA("Model") and mesh:GetExtentsSize() or mesh.Size
	local targetY = standTop + (meshSize.Y / 2)
	local targetPosition = Vector3.new(promptPart.Position.X, targetY, promptPart.Position.Z)
	
	mesh:PivotTo(CFrame.new(targetPosition))
end

-----------------------------------------------------------------------
-- Constructor and Public Methods

function MonsterGenerationEffectHandler.new()
	local self = setmetatable({}, MonsterGenerationEffectHandler)
	self.generationEffects = {}
	return self
end

function MonsterGenerationEffectHandler:createEffect(entityGUID, promptPart)
	local spawnPosition = promptPart.Position + Vector3.new(0, SPAWN_HEIGHT, 0)
	local part, connection, tween = createEffect(entityGUID, spawnPosition)
	
	self.generationEffects[entityGUID] = {
		part = part,
		connection = connection,
		tween = tween
	}
	
	return spawnPosition
end

function MonsterGenerationEffectHandler:removeEffect(entityGUID)
	local effect = self.generationEffects[entityGUID]
	cleanupEffect(effect)
	self.generationEffects[entityGUID] = nil
end

function MonsterGenerationEffectHandler:handleGenerationResult(generationId, isIntermediate, entityGUID, promptPart)
	if not generationId then
		self:removeEffect(entityGUID)
		return
	end

	local success, mesh = pcall(function()
		return GenerationService:LoadGeneratedMeshAsync(generationId)
	end)

	if not success or not mesh then
		if not isIntermediate then
			self:removeEffect(entityGUID)
		end
		return
	end

	mesh.Name = "GeneratedEntity_" .. entityGUID
	mesh.Parent = workspace
	
	positionMesh(mesh, promptPart)

	if not isIntermediate then
		self:removeEffect(entityGUID)
	end
end

function MonsterGenerationEffectHandler:setupResultHandler(generationResultEvent, promptPart)
	generationResultEvent.OnClientEvent:Connect(function(generationId, isIntermediate, entityGUID)
		-- Only handle results for effects this handler instance created
		if self.generationEffects[entityGUID] then
			self:handleGenerationResult(generationId, isIntermediate, entityGUID, promptPart)
		end
	end)
end

function MonsterGenerationEffectHandler:cleanup()
	for entityGUID, _ in pairs(self.generationEffects) do
		self:removeEffect(entityGUID)
	end
end

return MonsterGenerationEffectHandler 