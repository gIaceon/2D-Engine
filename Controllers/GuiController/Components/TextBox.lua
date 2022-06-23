local ReplicatedStorage = game:GetService("ReplicatedStorage");

local Knit = require(ReplicatedStorage.Packages.Knit);
local Roact = require(ReplicatedStorage.Packages.Roact);
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring);
local Janitor = require(ReplicatedStorage.Packages.Janitor);

local TextBox = Roact.Component:extend('TextBox');

type DialogConfig = {
	Speed: number;
	Sound: string;
};

local DefaultConfig: DialogConfig = {
	Speed = 1;
	Sound = 'UI.Text';
};

function TextBox:render()
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.05),
		Size = UDim2.fromScale(0.7, 0.3),
		BackgroundTransparency = self.styles.transparency;
	}, {
		tex = Roact.createElement("TextLabel", {
			Font = Enum.Font.Cartoon,
			RichText = true,
			Text = self.text,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true;
			BackgroundTransparency = self.styles.transparency,
			TextStrokeTransparency = self.styles.transparency,
			TextTransparency = self.styles.transparency;
			TextWrapped = true,
			BackgroundColor3 = Color3.fromRGB(66, 66, 66),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.025, 0.1),
			Size = UDim2.fromScale(0.95, 0.5),
			MaxVisibleGraphemes = self.maxVisibleGrapheme;
		}, {
			uICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0.1, 0),
			}),
			uIPadding = Roact.createElement("UIPadding", {
				PaddingBottom = UDim.new(0.2, 0),
				PaddingLeft = UDim.new(0.05, 0),
				PaddingRight = UDim.new(0.05, 0),
				PaddingTop = UDim.new(0.2, 0),
			}),
		}),

		uIScale = Roact.createElement("UIScale", {
			Scale = 0.95,
		}),

		uICorner1 = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0.1, 0),
		}),

		uIStroke = Roact.createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.fromRGB(75, 75, 75),
			Thickness = 4.3,
			Transparency = self.styles.transparency;
		}),

		name = Roact.createElement("TextLabel", {
			Font = Enum.Font.Cartoon,
			RichText = true,
			Text = self.name,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 40,
			TextWrapped = true,
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Color3.fromRGB(66, 66, 66),
			BackgroundTransparency = 1,
			TextTransparency = self.styles.transparency;
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.95),
			Size = UDim2.fromScale(0.95, 0.3),
		}),
	})
end;

function TextBox:init(props)
	self.text, self.updateText = Roact.createBinding('');
	self.name, self.updateName = Roact.createBinding('');
	self.maxVisibleGrapheme, self.updMaxVisibleGrapheme = Roact.createBinding(0);
	self.styles, self.api = RoactSpring.Controller.new{
		transparency = 1;
		config = RoactSpring.config.stiff;
	};
	self:setState {
		InDialog = false;
	};
	self.transitioning = false;
end

function TextBox:didMount()
	local Gui = Knit.GetController('GuiController');
	local Char = Knit.GetController('CharacterController');
	local SoundController = Knit.GetController('SoundController');
	
	self._janitor = Janitor.new();
	
	self._janitor:Add(Gui.HideDialog:Connect(function()
		self.api:start {
			transparency = 1;
			color = self.state.color;
			config = {
				duration = .35;
				easing = RoactSpring.easings.easeOutCubic
			}
		};
		self._janitor:Remove('UpdDiag');
		task.wait(.35);
		self:setState {
			InDialog = false;
		};
		self.transitioning = false;
	end))
	
	self._janitor:Add(Gui.OnReadDialog:Connect(function(name, diag, Config: DialogConfig?)
		if (not Config) then
			Config = DefaultConfig;
		end;

		if (self.state.InDialog and not self.transitioning) then
			self.transitioning = true;
			self.api:start {
				transparency = 1;
				color = self.state.color;
				config = {
					duration = .35;
					easing = RoactSpring.easings.easeOutCubic
				}
			};
			self._janitor:Remove('UpdDiag');
			task.wait(.35);
			self.transitioning = false;
		elseif (self.transitioning) then
			return;
		end;
		
		self:setState {
			InDialog = true;
		};
		
		self.updateName(name);
		self.updateText(diag);
		self.updMaxVisibleGrapheme(0);
		self._janitor:Remove('UpdDiag');
		self._janitor:Add(task.spawn(function() 
			self.api:start {
				transparency = 0;
				color = self.state.color;
				config = {
					duration = .35;
					easing = RoactSpring.easings.easeOutCubic
				}
			};
			task.wait(.4);
			
			local function removeTags(str)
				-- replace line break tags (otherwise grapheme loop will miss those linebreak characters)
				str = str:gsub("<br%s*/>", "\n")
				return (str:gsub("<[^<>]->", ""))
			end;

			local displayText = removeTags(diag);

			local index = 0
			for first, last in utf8.graphemes(displayText) do 
				local grapheme = displayText:sub(first, last) 
				index += 1

				SoundController:PlaySound(Config.Sound);

				if grapheme ~= " " then
					self.updMaxVisibleGrapheme(index);
					
					task.wait(.05 * 1/Config.Speed);
				end
				
				if (table.find({
					'.', ' ', '?', '!'
				},grapheme)) then
					task.wait(.1 * 1/Config.Speed);
				end;
			end;
			task.wait(4);
			self.api:start {
				transparency = 1;
				color = self.state.color;
				config = {
					duration = 1;
					easing = RoactSpring.easings.easeOutCubic
				}
			};
			self:setState {
				InDialog = false;
			};
		end), true, 'UpdDiag');
	end));
end;

function TextBox:willUnmount()
	self._janitor:Destroy();
end;

return TextBox;