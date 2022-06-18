local ReplicatedStorage = game:GetService('ReplicatedStorage');
local Component = require(ReplicatedStorage.Packages.Component);
local Knit = require(ReplicatedStorage.Packages.Knit);
local Janitor = require(ReplicatedStorage.Packages.Janitor);

local Hide = Component.new {
	Tag = script.Name;
};

function Hide:Construct()
	self._janitor = Janitor.new();
	
	self.Instance.Transparency = 1;
end;

function Hide:Stop()
	self._janitor:Destroy();
end;

return Hide;
