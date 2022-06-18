local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit);

Knit.AddServices(ServerStorage:WaitForChild('Services'));

Knit:Start():catch(warn);