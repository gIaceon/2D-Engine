local ReplicatedStorage = game:GetService("ReplicatedStorage");

local Knit = require(ReplicatedStorage.Packages.Knit);
local Roact = require(ReplicatedStorage.Packages.Roact);
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring);
local Janitor = require(ReplicatedStorage.Packages.Janitor);

local Checkpoint = Roact.Component:extend('Checkpoint');

function Checkpoint:render()
	return Roact.createElement("Frame", {
		AnchorPoint = self.anchorstyle.anchorpoint,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.9),
		Size = UDim2.fromScale(0.6, 0.1),
	  }, {
		textLabel = Roact.createElement("TextLabel", {
		  Font = Enum.Font.Cartoon,
		  RichText = true,
		Text = self.styles.transparency:map(function(val) 
			return string.format(
				"<b><stroke thickness=\"4\" color=\"#000000\" transparency=\"%s\">Checkpoint Reached</stroke></b>",
				tostring(val)
			)
		end),
		  TextColor3 = Color3.fromRGB(255, 255, 255),
		  TextScaled = true,
		  TextSize = 14,
		  TextTransparency = self.styles.transparency;
		  TextWrapped = true,
		  BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		  BackgroundTransparency = 1,
		  BorderSizePixel = 0,
		  Size = UDim2.fromScale(1, 1),
		}, {
		  uIPadding = Roact.createElement("UIPadding", {
			PaddingBottom = UDim.new(0.1, 0),
			PaddingLeft = UDim.new(0.1, 0),
			PaddingRight = UDim.new(0.1, 0),
			PaddingTop = UDim.new(0.1, 0),
		  }),
		}),
	  })
end;

function Checkpoint:init(props)
	self.styles, self.api = RoactSpring.Controller.new{
		transparency = 1;
		config = RoactSpring.config.stiff;
	};
	self.anchorstyle, self.setanchor = RoactSpring.Controller.new{
		anchorpoint = Vector2.new(0.5, 0);
        config = RoactSpring.config.molasses;
	};

	self.doing = false;
end

function Checkpoint:didMount()
	local Gui = Knit.GetController('GuiController');
	local Sound = Knit.GetController('SoundController');
	
	self._janitor = Janitor.new();
	
	self._janitor:Add(Gui.ShowCheckpoint:Connect(function(duration) 
		if (self.doing) then 
			return;
		end;
		self.doing = true;

		Sound:PlaySound('UI.Tada');

		self.api:start {
			transparency = 0;
			config = {
				duration = (duration or 1);
				easing = RoactSpring.easings.easeOutCubic
			}
		};
		self.setanchor:start {
			anchorpoint = Vector2.new(0.5, 1);
			config = {
				duration = (duration or 1) * 2;
                easing = RoactSpring.easings.easeInQuad;
			};
		};
		task.delay((duration or 1), function() 
			self.api:start {
				transparency = 1;
				config = {
					duration = (duration or 1);
					easing = RoactSpring.easings.easeOutCubic
				}
			};

			task.delay(duration or 1, function()
                self.setanchor:start {
                    anchorpoint = Vector2.new(0.5, 0);
                    config = {
                        duration = 0;
                        easing = RoactSpring.easings.easeInQuad;
                    };
                };
				self.doing = false;
			end);
		end);
	end), "Disconnect");
end;

function Checkpoint:willUnmount()
	self._janitor:Destroy();
end;

return Checkpoint;