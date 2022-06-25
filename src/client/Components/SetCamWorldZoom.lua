local ReplicatedStorage = game:GetService('ReplicatedStorage');
local Component = require(ReplicatedStorage.Packages.Component);
local Knit = require(ReplicatedStorage.Packages.Knit);
local Janitor = require(ReplicatedStorage.Packages.Janitor);
local Switch = require(ReplicatedStorage.Common.Switch);
local Case = Switch.Case;
local Default = Switch.Default;

local SetCamWorldZoom = Component.new {
	Tag = script.Name;
};

function SetCamWorldZoom:Construct()
	local Char = Knit.GetController('CharacterController');
	
	self._janitor = Janitor.new();
	self._janitor:Add(self.Instance.Touched:Connect(function(p)
		if (p.Parent == game.Players.LocalPlayer.Character) then
			local h = game.Players.LocalPlayer.Character.Humanoid;
			if (h.Health == 0) then
				return;
			end;
			Char.CameraWorldZoom = self.Instance:GetAttribute('To');
		end;
	end), 'Disconnect'); 
end;

function SetCamWorldZoom:Stop()
	self._janitor:Destroy();
end;

return SetCamWorldZoom;
