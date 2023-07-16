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

local function RecursiveSearch(Instance)
    local Table = {}
    
    for _, Instance in next, Instance:GetChildren() do
        Table[Instance.Name] = setmetatable({}, {
            __index = function(self, Key)
                return rawget(self, Key) or pcall(function() local _ = Instance[Key] end) and Instance[Key]
            end,
            __newindex = function(self, Key, Value)
                Edit:FireServer("__newindex", os.clock(), Instance, Value)
                Instance[Key] = Value
            end
        })
    end
    
    return Table
end

local game = RecursiveSearch(game)

-- script here
