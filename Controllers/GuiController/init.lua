local ReplicatedStorage = game:GetService('ReplicatedStorage');
local RunService = game:GetService('RunService');

local Knit = require(ReplicatedStorage.Packages:WaitForChild('Knit'));
local Roact = require(ReplicatedStorage.Packages.Roact);
local Signal = require(ReplicatedStorage.Packages.Signal);

local GuiController = Knit.CreateController {
	Name = "GuiController";
	
	FadeIn = Signal.new();
	FadeOut = Signal.new();
	HideAltText = Signal.new();
	OnReadDialog = Signal.new();
	HideDialog = Signal.new();
	ShowCheckpoint = Signal.new();
	
	CanPresent = true;
};

function GuiController:KnitStart()
	task.delay(4, function()
		self.HideAltText:Fire();
	end);
end;

function GuiController:KnitInit()
	self.Components = {};

	for i,v in ipairs(script.Components:GetChildren()) do
		self.Components[v.Name] = require(v);
	end;
	
	self.Gui = Roact.createElement(
		self.Components.Main, {
			Components = self.Components
		}
	);

	self.GuiMount = Roact.mount(
		self.Gui,
		game.Players.LocalPlayer.PlayerGui
	);
end;


return GuiController;
