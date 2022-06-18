local ReplicatedStorage = game:GetService("ReplicatedStorage");

local Knit = require(ReplicatedStorage.Packages.Knit);
local Roact = require(ReplicatedStorage.Packages.Roact);
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring);
local Janitor = require(ReplicatedStorage.Packages.Janitor);

local Check = Roact.Component:extend('Check');

local TEXTS = {
	'';
    'Want to add your own death text?\nCheck out ReplicatedStorage/Controllers/GuiController/Components/Check: line 10!';
};

function Check:render()	
	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 100,
	}, {
		frame = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.fromScale(1, 1),
		}, {
			uIGradient = Roact.createElement("UIGradient", {
				Color = self.colorstyles.color:map(function(val)
                    return ColorSequence.new(val);
                end),
				Rotation = 270,
				--Transparency = NumberSequence.new({
				--	NumberSequenceKeypoint.new(self.state., 0),
				--	NumberSequenceKeypoint.new(1, 1),
				--}),
				-- Is a ref
				Transparency = self.styles.transparency:map(function(val)
					return NumberSequence.new({
						NumberSequenceKeypoint.new(0, val),
						NumberSequenceKeypoint.new(1, 1)
					});
				end);
			}),
		}),

		imageLabel = Roact.createElement("ImageLabel", {
			Image = "rbxassetid://7859835019",
			ResampleMode = Enum.ResamplerMode.Pixelated,
			ScaleType = Enum.ScaleType.Tile,
			TileSize = UDim2.fromOffset(self.state.tilesize, self.state.tilesize),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = self.movestyle.pos,
			Size = UDim2.fromScale(5, 5),
			ImageTransparency = self.styles.transparency,
		}),
		
		Roact.createElement("TextLabel", {
			Font = Enum.Font.Cartoon,
			Text = self.text,
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
			TextTransparency = self.styles.transparency;
			ZIndex = 40;
		})
	});
end;

function Check:init(props)
	self.styles, self.api = RoactSpring.Controller.new{
		transparency = 0;
		config = RoactSpring.config.stiff;
	};
	self:setState{
		tilesize = props.tilesize;
		-- color = props.color;
	};

    self.colorstyles, self.colorapi = RoactSpring.Controller.new{
        color = props.color;
        config = RoactSpring.config.default;
    };
	
	self.movestyle, self.moveapi = RoactSpring.Controller.new{
		pos = UDim2.new(.5, 0, .5, 0);
	};
	
	self.moveapi:start {
		reset = true,
		from = {pos = UDim2.new(.5, 0, .5, 0)},
		to = {pos = UDim2.new(.5, props.tilesize, .5, props.tilesize)},
		loop = true,
		config = {
			duration = 15;
			easing = RoactSpring.easings.linear
		},
	};
	
	self.text, self.updtext = Roact.createBinding("");
end

function Check:didMount()
	local Gui = Knit.GetController('GuiController');
	local Char = Knit.GetController('CharacterController');
	
	self._janitor = Janitor.new();
	
	self._janitor:Add(Gui.FadeIn:Connect(function(duration)
		self.api:start {
			transparency = 1;
			config = {
				duration = duration;
				easing = RoactSpring.easings.easeInCubic;
			};
		};
        self.colorapi:start {
            color = Color3.fromRGB(43, 255, 138);
            config = {
                duration = duration / 2;
            };
        };
	end), "Disconnect");
	
	self._janitor:Add(Gui.FadeOut:Connect(function(duration)
		self.api:start {
			transparency = 0;
			config = {
				duration = duration;
				easing = RoactSpring.easings.easeOutCubic;
			};
		};
        self.colorapi:start {
            color = Color3.fromRGB(255, 43, 43);
            config = {
                duration = duration / 2;
            };
        };
	end), "Disconnect");
	
	self._janitor:Add(Char.OnDeath:Connect(function()
		local function chose()
			local a = (TEXTS[math.random(1, #TEXTS)]);
			if (a == self.text:getValue()) then
				chose()
			end;
			return a;
		end;
		self.updtext(chose());
	end));
end;

function Check:willUnmount()
	self._janitor:Destroy();
end;

return Check;