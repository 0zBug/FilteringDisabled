
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage.Modules

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

local Properties = require(Modules.Properties)

local function GetProperties(Instance)
    local Table = {}
    
    for _, Property in next, Properties[Instance.ClassName] do
        Table[Property] = {}
    end
    
    return setmetatable(Table, {
        __index = function(self, Key)
            return Instance[Key]
        end
    })
end

local function FormatChildren(Children)
	local Table = {}

	for _, Instance in next, Children do
		pcall(function()
			Table[Instance.Name] = Instance
		end)
	end
	
	return Table
end

local function Combine(a, b)
	for Index, Value in next, b do
		a[Index] = Value
	end
	
	return a
end

local function Create(Instance)
	local Children = FormatChildren(Instance:GetChildren())
	local Properties = GetProperties(Instance)

    return setmetatable({}, {
        __index = function(self, Key, ...)
        	local Item = pcall(function() _ = Instance[Key] end) and typeof(Instance[Key]) ~= "Instance" and Instance[Key]
        	
        	if Item then
        		return function(...)
        			local args = {...}
        			table.remove(args, 1)
        			
        			return Instance[Key](Instance, table.unpack(args))
        		end
        	end
        	
        	Item = Item and Item or Properties[Key] or Children[Key]
        	
        	if typeof(Item) == "Instance" then
        		return Create(Item)
        	end
      		
            return Item
        end,
        __newindex = function(self, Key, Value)
        	Edit:FireServer("__newindex", os.clock(), Instance, Key, Value)
        end
    })
end

local game = Create(game)

-- script here
