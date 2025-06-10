--[[
	MonsterGenerator Class
	Handles the UI and generation logic for monster creation stands
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local PartSelector = require(script.Parent:WaitForChild("PartSelectorUI"))
local MonsterGenerationEffectHandler = require(script.Parent:WaitForChild("MonsterGenerationEffectHandler"))

-- Create or get RemoteEvents for mesh generation
local meshGenerationEvent = ReplicatedStorage:FindFirstChild("MeshGenerationEvent")
local generationResultEvent = ReplicatedStorage:FindFirstChild("GenerationResultEvent")

-- Constants
local PLACEHOLDER_IMAGE = "rbxassetid://121612080312701"

-- Part options data
local PART_OPTIONS = {
	Head = {
		{ImageId = "rbxassetid://93847088397769", Description = "a big glowing eye with a small horn"},
		{ImageId = "rbxassetid://94190549591539", Description = "a cracked bone helmet with glowing lines"},
		{ImageId = "rbxassetid://91866943221889", Description = "a mossy head with wooden antlers"},
		{ImageId = "rbxassetid://104076390739937", Description = "a shiny metal dome with lights and glass"},
	},
	Torso = {
		{ImageId = "rbxassetid://124917998954324", Description = "a hard shell body with spikes"},
		{ImageId = "rbxassetid://91835122516962", Description = "a jelly-like body"},
		{ImageId = "rbxassetid://88682378795344", Description = "a stone body with glowing runes"},
		{ImageId = "rbxassetid://72464524220648", Description = "a body covered in mushrooms and spores"},
	},
	Legs = {
		{ImageId = "rbxassetid://79747465874239", Description = "short tentacles with suction pads"},
		{ImageId = "rbxassetid://94891642073516", Description = "bug-like legs with hard joints"},
		{ImageId = "rbxassetid://114693346600636", Description = "a floating disc instead of legs"},
		{ImageId = "rbxassetid://112293541957007", Description = "strong legs with big hooves"},
	},
	Arms = {
		{ImageId = "rbxassetid://107030012912607", Description = "two claws, one bigger than the other"},
		{ImageId = "rbxassetid://107102544041017", Description = "long vine arms with small thorns"},
		{ImageId = "rbxassetid://125681034954938", Description = "robotic arms with clamps"},
		{ImageId = "rbxassetid://130215016160808", Description = "bat wings that work as arms"},
	},
}

-----------------------------------------------------------------------
-- MonsterGenerator Class

local MonsterGenerator = {}
MonsterGenerator.__index = MonsterGenerator

function MonsterGenerator.new(promptPart)
	local self = setmetatable({}, MonsterGenerator)

	-- Instance-specific state
	self.promptPart = promptPart
	self.prompt = promptPart:WaitForChild("PromptParent"):WaitForChild("ProximityPrompt")
	self.player = Players.LocalPlayer
	self.generationCompleted = false
	self.savedOptions = nil
	self.ui = nil
	self.previewUI = nil
	self.generationHandler = MonsterGenerationEffectHandler.new()

	-- Create unique ScreenGui for this stand
	local standId = HttpService:GenerateGUID(false)
	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "MonsterStandGui_" .. standId
	self.screenGui.ResetOnSpawn = false
	self.screenGui.Parent = self.player:WaitForChild("PlayerGui")

	self:setupEventHandlers()
	return self
end

function MonsterGenerator:buildPromptFromOptions(options)
	local parts = {}
	for _, category in ipairs({"Head", "Torso", "Legs", "Arms"}) do
		if options[category] then
			table.insert(parts, options[category].Description)
		end
	end
	return "A monster creature with " .. table.concat(parts, ", ")
end

function MonsterGenerator:createUI(isPreviewMode)
	local dropdownsData = {}
	for _, category in ipairs({"Head", "Torso", "Legs", "Arms"}) do
		table.insert(dropdownsData, {
			Title = category,
			Options = PART_OPTIONS[category]
		})
	end

	return PartSelector.new(self.screenGui, {
		PlaceholderImage = PLACEHOLDER_IMAGE,
		DropdownsData = dropdownsData,
		IsPreviewMode = isPreviewMode,
		OnGenerate = not isPreviewMode and function(options)
			self:handleGeneration(options)
		end or nil
	})
end

function MonsterGenerator:handleGeneration(options)
	-- Auto-select random options for unselected categories
	for _, category in ipairs({"Head", "Torso", "Legs", "Arms"}) do
		if not options[category] then
			local randomIndex = math.random(1, #PART_OPTIONS[category])
			self.ui:SetSelection(category, randomIndex)
			options[category] = PART_OPTIONS[category][randomIndex]
		end
	end

	local entityGUID = HttpService:GenerateGUID(false)
	local promptText = self:buildPromptFromOptions(options)

	print("Generated prompt:", promptText)

	self.generationHandler:createEffect(entityGUID, self.promptPart)
	meshGenerationEvent:FireServer(promptText, entityGUID)

	self.generationCompleted = true
	self.savedOptions = options

	self.ui:Hide()
	self:showPreview(options)
end

function MonsterGenerator:showPreview(options)
	if self.previewUI then
		self.previewUI:Hide()
	end

	self.previewUI = self:createUI(true)

	-- Set selections to match generated options
	for category, option in pairs(options) do
		if PART_OPTIONS[category] then
			for index, partOption in ipairs(PART_OPTIONS[category]) do
				if partOption.ImageId == option.ImageId then
					self.previewUI:SetSelection(category, index)
					break
				end
			end
		end
	end

	self.previewUI:Show()
end

function MonsterGenerator:hidePreview()
	if self.previewUI then
		self.previewUI:Hide()
	end
end

function MonsterGenerator:getOrCreateUI()
	if not self.ui then
		self.ui = self:createUI(false)
	end
	return self.ui
end

function MonsterGenerator:setupEventHandlers()
	-- Setup generation result handler
	if generationResultEvent then
		self.generationHandler:setupResultHandler(generationResultEvent, self.promptPart)
	end

	-- Show UI when prompt becomes visible
	self.prompt.PromptShown:Connect(function()
		if not self.generationCompleted then
			self:getOrCreateUI():Show()
		elseif self.savedOptions then
			self:showPreview(self.savedOptions)
		end
	end)

	-- Hide UI when prompt disappears
	self.prompt.PromptHidden:Connect(function()
		if self.ui and not self.generationCompleted then
			self.ui:Hide()
		end
		self:hidePreview()
	end)
end

return MonsterGenerator 