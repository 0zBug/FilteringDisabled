
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Edit = ReplicatedStorage.Edit
local InstanceEvent = ReplicatedStorage.Instance

local Ready
local History = {}

local Types = {
	["__newindex"] = function(Time, Part, Index, Value)
		if Part then
			if not History[Part] then
				History[Part] = {}
			end

			if not History[Part][Index] then
				History[Part][Index] = Time
			else
				if History[Part][Index] > Time or (os.clock() - History[Part][Index]) < 0.01 then
					return
				else
					History[Part][Index] = Time
				end
			end
			
			Part[Index] = Value
		end
	end,
	["Destroy"] = function(Time, Part)
		Part:Destroy()
	end,
	["Ready"] = function()
		Ready = true
	end
}

Edit.OnServerEvent:Connect(function(Player, Type, Time, Part, Index, Value)
	Types[Type](Time, Part, Index, Value)
end)

InstanceEvent.OnServerInvoke = function(Player, Mode, Type, Parent)
	print(Player, Type, Parent)

	local Parent = Parent or workspace
	local Part = Instance.new(Type, Parent)

	Ready = false
	repeat wait() Edit:FireClient(Player, Part) until Ready == true

	return Part
end
