
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Edit = ReplicatedStorage.Edit
local InstanceEvent = ReplicatedStorage.Instance

local Ready

local Types = {
	["__newindex"] = function(Part, Index, Value)
		Part[Index] = Value
	end,
	["Destroy"] = function(Part)
		Part:Destroy()
	end,
	["Ready"] = function()
		Ready = true
	end
}

Edit.OnServerEvent:Connect(function(Player, Type, Part, ...)
	print(Player, Type, Part, ...)
	
	Types[Type](Part, ...)
end)

InstanceEvent.OnServerInvoke = function(Player, Mode, Type, Parent)
	print(Player, Type, Parent)

	local Parent = Parent or workspace
	local Part = Instance.new(Type, Parent)

	Ready = false
	repeat wait() Edit:FireClient(Player, Part) until Ready == true 

	return Part
end
