local PartSelectorUI = {}
PartSelectorUI.__index = PartSelectorUI

-- Constants
local COLORS = {
	BACKGROUND = Color3.fromRGB(60, 39, 15),
	GENERATE_BUTTON = Color3.fromRGB(100, 200, 100),
	TEXT = Color3.fromRGB(220, 220, 220),
	WHITE = Color3.new(1, 1, 1),
	PREVIEW_BACKGROUND = Color3.fromRGB(60, 39, 15),
	PREVIEW_GLOW = Color3.fromRGB(0, 255, 255)
}

local SIZES = {
	TITLE_HEIGHT = 30,
	GENERATE_BUTTON_WIDTH = 200,
	GENERATE_BUTTON_HEIGHT = 50,
	SPACING = 10,
	CORNER_RADIUS = 12,
	CAROUSEL_WIDTH = 120,
	CAROUSEL_HEIGHT = 140,
	CAROUSEL_IMAGE_SIZE = 80,
	CAROUSEL_BUTTON_SIZE = 25
}

function PartSelectorUI.new(screenGui, settings)
	local self = setmetatable({}, PartSelectorUI)

	self.ScreenGui = screenGui
	self.Container = self:createMainContainer(screenGui)
	self.DropdownsData = settings.DropdownsData
	self.PlaceholderImage = settings.PlaceholderImage
	self.OnGenerate = settings.OnGenerate
	self.IsPreviewMode = settings.IsPreviewMode or false

	-- Track selected parts for each category
	self.SelectedParts = {}
	for _, dropdown in ipairs(self.DropdownsData) do
		self.SelectedParts[dropdown.Title] = nil
	end

	-- Store UI elements for easy access
	self.Elements = {}

	self:buildUI()
	return self
end

function PartSelectorUI:createMainContainer(screenGui)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 1, 0)
	container.BackgroundTransparency = 1
	container.Visible = false
	container.Parent = screenGui
	
	if self.IsPreviewMode then
		-- Dark overlay
		local overlay = Instance.new("Frame")
		overlay.Size = UDim2.new(1, 0, 1, 0)
		overlay.BackgroundColor3 = Color3.new(0, 0, 0)
		overlay.BackgroundTransparency = 0.3
		overlay.BorderSizePixel = 0
		overlay.ZIndex = 1
		overlay.Parent = container
		
		-- Preview title
		local previewTitle = Instance.new("TextLabel")
		previewTitle.Size = UDim2.new(1, 0, 0, 60)
		previewTitle.Position = UDim2.new(0, 0, 0.15, 0)
		previewTitle.Text = "GENERATED MONSTER"
		previewTitle.TextColor3 = COLORS.PREVIEW_GLOW
		previewTitle.TextScaled = true
		previewTitle.BackgroundTransparency = 1
		previewTitle.Font = Enum.Font.GothamBold
		previewTitle.ZIndex = 3
		previewTitle.Parent = container
		
		local titleStroke = Instance.new("UIStroke")
		titleStroke.Color = COLORS.PREVIEW_GLOW
		titleStroke.Thickness = 2
		titleStroke.Transparency = 0.5
		titleStroke.Parent = previewTitle
	end
	
	return container
end

function PartSelectorUI:createUICorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or SIZES.CORNER_RADIUS)
	corner.Parent = parent
	return corner
end

function PartSelectorUI:createTitle(titleText, parent)
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, SIZES.TITLE_HEIGHT)
	title.Text = titleText
	title.TextScaled = true
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.Gotham
	title.TextColor3 = self.IsPreviewMode and COLORS.PREVIEW_GLOW or COLORS.TEXT
	title.Parent = parent
	
	if self.IsPreviewMode then
		local stroke = Instance.new("UIStroke")
		stroke.Color = COLORS.PREVIEW_GLOW
		stroke.Thickness = 1
		stroke.Transparency = 0.7
		stroke.Parent = title
	end
	
	return title
end

function PartSelectorUI:createCarouselSelector(titleText, options, placeholderImage)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, SIZES.CAROUSEL_WIDTH, 0, SIZES.CAROUSEL_HEIGHT)
	container.BackgroundTransparency = 1

	self:createTitle(titleText, container)
	
	-- Main carousel frame
	local carouselFrame = Instance.new("Frame")
	carouselFrame.Size = UDim2.new(1, 0, 0, SIZES.CAROUSEL_HEIGHT - SIZES.TITLE_HEIGHT)
	carouselFrame.Position = UDim2.new(0, 0, 0, SIZES.TITLE_HEIGHT)
	carouselFrame.BackgroundColor3 = self.IsPreviewMode and COLORS.PREVIEW_BACKGROUND or COLORS.BACKGROUND
	carouselFrame.BorderSizePixel = 0
	carouselFrame.Parent = container

	self:createUICorner(carouselFrame)
	
	if self.IsPreviewMode then
		local stroke = Instance.new("UIStroke")
		stroke.Color = COLORS.PREVIEW_GLOW
		stroke.Thickness = 2
		stroke.Transparency = 0.6
		stroke.Parent = carouselFrame
	end
	
	local currentIndex = 0
	
	-- Image display
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Size = UDim2.new(0, SIZES.CAROUSEL_IMAGE_SIZE, 0, SIZES.CAROUSEL_IMAGE_SIZE)
	imageLabel.Position = UDim2.new(0.5, -SIZES.CAROUSEL_IMAGE_SIZE/2, 0, 10)
	imageLabel.Image = placeholderImage
	imageLabel.BackgroundTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Parent = carouselFrame
	
	-- Navigation buttons (hidden in preview mode)
	local prevButton, nextButton
	if not self.IsPreviewMode then
		prevButton = Instance.new("TextButton")
		prevButton.Size = UDim2.new(0, SIZES.CAROUSEL_BUTTON_SIZE, 0, SIZES.CAROUSEL_BUTTON_SIZE)
		prevButton.Position = UDim2.new(0, 5, 1, -SIZES.CAROUSEL_BUTTON_SIZE - 5)
		prevButton.Text = "◀"
		prevButton.TextColor3 = COLORS.WHITE
		prevButton.TextScaled = true
		prevButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
		prevButton.Font = Enum.Font.GothamBold
		prevButton.BorderSizePixel = 0
		prevButton.ZIndex = 3
		prevButton.Parent = carouselFrame
		
		prevButton.MouseEnter:Connect(function()
			prevButton.BackgroundColor3 = Color3.fromRGB(80, 140, 220)
		end)
		prevButton.MouseLeave:Connect(function()
			prevButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
		end)
		
		self:createUICorner(prevButton, 8)
		
		nextButton = Instance.new("TextButton")
		nextButton.Size = UDim2.new(0, SIZES.CAROUSEL_BUTTON_SIZE, 0, SIZES.CAROUSEL_BUTTON_SIZE)
		nextButton.Position = UDim2.new(1, -SIZES.CAROUSEL_BUTTON_SIZE - 5, 1, -SIZES.CAROUSEL_BUTTON_SIZE - 5)
		nextButton.Text = "▶"
		nextButton.TextColor3 = COLORS.WHITE
		nextButton.TextScaled = true
		nextButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
		nextButton.Font = Enum.Font.GothamBold
		nextButton.BorderSizePixel = 0
		nextButton.ZIndex = 3
		nextButton.Parent = carouselFrame
		
		nextButton.MouseEnter:Connect(function()
			nextButton.BackgroundColor3 = Color3.fromRGB(80, 140, 220)
		end)
		nextButton.MouseLeave:Connect(function()
			nextButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
		end)
		
		self:createUICorner(nextButton, 8)
	end
	
	-- Update display function
	local function updateDisplay()
		if currentIndex > 0 and options[currentIndex] then
			imageLabel.Image = options[currentIndex].ImageId
			self.SelectedParts[titleText] = options[currentIndex]
		else
			imageLabel.Image = placeholderImage
			self.SelectedParts[titleText] = nil
		end
	end
	
	-- Button functionality
	if not self.IsPreviewMode and prevButton and nextButton then
		prevButton.MouseButton1Click:Connect(function()
			currentIndex = currentIndex - 1
			if currentIndex < 0 then
				currentIndex = #options
			end
			updateDisplay()
		end)
		
		nextButton.MouseButton1Click:Connect(function()
			currentIndex = currentIndex + 1
			if currentIndex > #options then
				currentIndex = 0
			end
			updateDisplay()
		end)
	end
	
	-- Store reference for SetSelection
	self.Elements[titleText] = {
		imageLabel = imageLabel,
		setIndex = function(index)
			currentIndex = index
			updateDisplay()
		end
	}
	
	updateDisplay()
	return container
end

function PartSelectorUI:createContainer()
	local rowContainer = Instance.new("Frame")
	
	local totalWidth = #self.DropdownsData * (SIZES.CAROUSEL_WIDTH + SIZES.SPACING) - SIZES.SPACING
	rowContainer.Size = UDim2.new(0, totalWidth, 0, SIZES.CAROUSEL_HEIGHT)
	rowContainer.Position = UDim2.new(0.5, -totalWidth // 2, 1, -SIZES.CAROUSEL_HEIGHT - 20)
	rowContainer.BackgroundTransparency = 1
	rowContainer.Parent = self.Container

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, SIZES.SPACING)
	layout.Parent = rowContainer

	return rowContainer
end

function PartSelectorUI:createGenerateButton()
	if self.IsPreviewMode then
		return nil
	end
	
	local generateButton = Instance.new("TextButton")
	generateButton.Size = UDim2.new(0, SIZES.GENERATE_BUTTON_WIDTH, 0, SIZES.GENERATE_BUTTON_HEIGHT)
	generateButton.Position = UDim2.new(0.5, -SIZES.GENERATE_BUTTON_WIDTH // 2, 1, -SIZES.CAROUSEL_HEIGHT - SIZES.GENERATE_BUTTON_HEIGHT - 30)
	generateButton.Text = "Generate"
	generateButton.Font = Enum.Font.GothamBold
	generateButton.TextScaled = true
	generateButton.BackgroundColor3 = COLORS.GENERATE_BUTTON
	generateButton.TextColor3 = COLORS.WHITE
	generateButton.ZIndex = 2
	generateButton.Parent = self.Container

	self:createUICorner(generateButton)

	generateButton.MouseButton1Click:Connect(function()
		if self.OnGenerate then
			self.OnGenerate(self.SelectedParts)
		end
	end)

	return generateButton
end

function PartSelectorUI:buildUI()
	local rowContainer = self:createContainer()

	for _, dropdown in ipairs(self.DropdownsData) do
		local carouselUI = self:createCarouselSelector(dropdown.Title, dropdown.Options, self.PlaceholderImage)
		carouselUI.Parent = rowContainer
	end

	self:createGenerateButton()
end

function PartSelectorUI:Show()
	self.Container.Visible = true
end

function PartSelectorUI:Hide()
	self.Container.Visible = false
end

function PartSelectorUI:GetSelectedParts()
	return self.SelectedParts
end

function PartSelectorUI:SetSelection(categoryTitle, optionIndex)
	local dropdownData = nil
	for _, dropdown in ipairs(self.DropdownsData) do
		if dropdown.Title == categoryTitle then
			dropdownData = dropdown
			break
		end
	end

	if not dropdownData or not dropdownData.Options[optionIndex] then
		return false
	end

	local option = dropdownData.Options[optionIndex]
	self.SelectedParts[categoryTitle] = option

	local elements = self.Elements[categoryTitle]
	if elements and elements.setIndex then
		elements.setIndex(optionIndex)
	end

	return true
end

return PartSelectorUI 