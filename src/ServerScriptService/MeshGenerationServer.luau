local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GenerationService = game:GetService("GenerationService")

local meshGenerationEvent = ReplicatedStorage:WaitForChild("MeshGenerationEvent")
local generationResultEvent = ReplicatedStorage:WaitForChild("GenerationResultEvent")

meshGenerationEvent.OnServerEvent:Connect(function(player, prompt, entityGUID)
	local success, generationIdOrError, contextId = pcall(function()
		return GenerationService:GenerateMeshAsync(
			{["Prompt"] = prompt},
			player,
			{},
			function(intermediateType, intermediateGenerationId, intermediateContextId)
				-- Skip intermediate results
			end
		)
	end)

	if success then
		generationResultEvent:FireClient(player, generationIdOrError, false, entityGUID)
	else
		if generationIdOrError == "Rate limit exceeded" then
			warn("Rate limit exceeded for player:", player.Name)
		elseif generationIdOrError == "Moderation failure" then
			warn("Moderation failure for prompt:", prompt)
		elseif generationIdOrError == "Character limit exceeded" then
			warn("Character limit exceeded for prompt:", prompt)
		else
			warn("Failed to generate mesh:", generationIdOrError)
		end

		generationResultEvent:FireClient(player, nil, false, entityGUID)
	end
end) 