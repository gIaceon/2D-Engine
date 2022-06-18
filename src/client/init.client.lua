local ReplicatedStorage = game:GetService('ReplicatedStorage');
local Knit = require(ReplicatedStorage:WaitForChild('Packages'):WaitForChild('Knit'));

Knit.AddControllers(ReplicatedStorage:WaitForChild('Controllers'));

Knit:Start():andThen(function()
    for _, Comp in ipairs(script.Components:GetChildren()) do
        require(Comp);
    end;
end):catch(warn);