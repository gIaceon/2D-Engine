local ReplicatedStorage = game:GetService('ReplicatedStorage');
local Component = require(ReplicatedStorage.Packages.Component);
local Knit = require(ReplicatedStorage.Packages.Knit);
local Janitor = require(ReplicatedStorage.Packages.Janitor);

local KillPart = Component.new {
	Tag = script.Name;
};

function KillPart:Construct()
	self._janitor = Janitor.new();
	
	self._janitor:Add(self.Instance.Touched:Connect(function(p)
		if (p.Parent == game.Players.LocalPlayer.Character) then
			local h = game.Players.LocalPlayer.Character.Humanoid;
			if (h.Health ~= 0) then
				h.Health = 0;
			end;
		end;
	end));
end;

function KillPart:Stop()
	self._janitor:Destroy();
end;

return KillPart;
