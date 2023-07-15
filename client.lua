
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Edit = ReplicatedStorage.Edit
local InstanceEvent = ReplicatedStorage.Instance

local Instance = {
	new = function(...)
		return InstanceEvent:InvokeServer("Instance", ...)
	end
}

Edit.OnClientEvent:Connect(function(Part)
	if Part then
		Edit:FireServer("Ready")
	end
end)

local newindex
newindex = hookmetamethod(game, "__newindex", function(self, ...)
	if checkcaller() then
    	Edit:FireServer("__newindex", self, ...)
    end

    return newindex(self, ...)
end)

-- script here