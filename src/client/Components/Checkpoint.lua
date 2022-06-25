local ReplicatedStorage = game:GetService('ReplicatedStorage');
local Component = require(ReplicatedStorage.Packages.Component);
local Knit = require(ReplicatedStorage.Packages.Knit);
local Janitor = require(ReplicatedStorage.Packages.Janitor);
local Switch = require(ReplicatedStorage.Common.Switch);
local Case = Switch.Case;
local Default = Switch.Default;

local Checkpoint = Component.new {
	Tag = script.Name;
};

function Checkpoint:Construct()
	local Char = Knit.GetController('CharacterController');
	local Gui = Knit.GetController('GuiController');
	
	self._janitor = Janitor.new();
	self._janitor:Add(self.Instance.Touched:Connect(function(p)
		if (p.Parent == game.Players.LocalPlayer.Character) then
			local h = game.Players.LocalPlayer.Character.Humanoid;
			if (h.Health == 0) then
				return;
			end;
			
			if (workspace.GAME_START.Position ~= self.Instance.At.WorldPosition) then
				workspace.GAME_START.Position = self.Instance.At.WorldPosition;
				Gui.ShowCheckpoint:Fire(.5);
			end;
		end;
	end), 'Disconnect'); 
end;

function Checkpoint:Stop()
	self._janitor:Destroy();
end;

return Checkpoint;
