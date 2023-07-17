
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage.Modules

local Edit = ReplicatedStorage.Edit
local InstanceEvent = ReplicatedStorage.Instance

local Properties = require(Modules.Properties)

local function GetProperties(Instance)
    local Table = {}
    
    for Type, _ in next, Properties do
   		if Instance:IsA(Type) then
   			for Property, _ in next, Properties[Type] do
   				pcall(function()
		        	Table[Property] = Instance[Property]
		        end)
		    end
		end
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

local Create

local Instance = {
    new = function(...)
        return Create(InstanceEvent:InvokeServer("Instance", ...))
    end
}

local function Clone(Object, Parent)
	local CloneInstance = Instance.new(Object.ClassName, Parent)
	
	for Property, Value in next, GetProperties(Object) do
		pcall(function()
			if CloneInstance[Property] ~= Value and Property ~= "Parent" then
				CloneInstance[Property] = Value
			end
		end)
	end
	
	for _, Child in next, Object:GetChildren() do
		pcall(function()
			Clone(Child, CloneInstance.Object)
		end)
	end
	
	return CloneInstance
end

function Create(Instance)
	local Children = FormatChildren(Instance:GetChildren())
	local Properties = GetProperties(Instance)

    return setmetatable({
    	Destroy = function()
    		Edit:FireServer("Destroy", os.clock(), Instance)
    	end,
    	Remove = function()
    		Edit:FireServer("Destroy", os.clock(), Instance)
    	end,
    	Clone = function()
		    return Clone(Instance)
    	end,
    	GetChildren = function()
    		local Children = Instance:GetChildren()
    		local Table = {}
    		
    		for Index, Instance in next, Children do
    			Table[Index] = Create(Instance)
    		end
    		
   			return Table
    	end,
    	GetDescendants = function()
    		local Children = Instance:GetDescendants()
    		local Table = {}
    		
    		for Index, Instance in next, Children do
    			Table[Index] = Create(Instance)
    		end
    		
   			return Table
    	end,
    	IsA = function(Type)
    		return Instance:IsA(Type)
    	end,
    	isA = function(Type)
    		return Instance:IsA(Type)
    	end,
    	Object = Instance
    }, {
        __index = function(self, Key, ...)
        	local Item = pcall(function() _ = Instance[Key] end) and typeof(Instance[Key]) ~= "Instance" and Instance[Key]
        	
        	if Item and not rawget(self, Key) and not (Properties[Key] and typeof(Properties[Key]) ~= "Function") then
        		return function(...)
        			local args = {...}
        			table.remove(args, 1)
        			
        			local Result = Instance[Key](Instance, table.unpack(args))
        			
        			return typeof(Result) == "Instance" and Create(Result) or Result
        		end
        	elseif rawget(self, Key) then
        		return rawget(self, Key)
        	end

        	Item = Properties[Key] and Instance[Key] or Children[Key]

        	if typeof(Item) == "Instance" then
        		return Create(Item)
        	end
      		
            return Item
        end,
        __newindex = function(self, Key, Value)
        	Properties[Key] = Value
        	Edit:FireServer("__newindex", os.clock(), Instance, Key, Value)
        end
    })
end

Edit.OnClientEvent:Connect(function(Part)
    if Part then
        Edit:FireServer("Ready")
    end
end)

local game = Create(game)
