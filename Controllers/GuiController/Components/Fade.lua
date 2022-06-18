local ReplicatedStorage = game:GetService("ReplicatedStorage");

local Knit = require(ReplicatedStorage.Packages.Knit);
local Roact = require(ReplicatedStorage.Packages.Roact);
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring);
local Janitor = require(ReplicatedStorage.Packages.Janitor);

local Fade = Roact.Component:extend('Fade');

function Fade:render()
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(.5, .5);
		Position = UDim2.fromScale(.5, .5);
		BackgroundTransparency = self.styles.transparency;
		BackgroundColor3 = Color3.fromRGB();
		Size = UDim2.fromScale(1, 1);
		ZIndex = 200;
	}, {
		Roact.createElement("TextLabel", {
			Font = Enum.Font.Cartoon,
			Text = "2D Test",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			TextSize = 14,
			TextWrapped = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(0.8, 0, 0, 75),
			TextTransparency = self.styles.transparency
		})
	});
end;

function Fade:init(props)
	self.styles, self.api = RoactSpring.Controller.new{
		transparency = 0;
		config = RoactSpring.config.stiff;
	};
end

function Fade:didMount()
	local Gui = Knit.GetController('GuiController');
	
	self._janitor = Janitor.new();
	
	self._janitor:Add(Gui.HideAltText:Connect(function(duration) 
		self.api:start {
			transparency = 1;
			color = self.state.color;
			config = {
				duration = duration or 1;
				easing = RoactSpring.easings.easeOutCubic
			}
		};
	end), "Disconnect");
	
end;

function Fade:willUnmount()
	self._janitor:Destroy();
end;

return Fade;