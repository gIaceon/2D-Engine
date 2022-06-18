local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Roact = require(ReplicatedStorage.Packages.Roact);
local Knit = require(ReplicatedStorage.Packages.Knit);

local function App(props)
	local Gui = Knit.GetController('GuiController');
	return Roact.createElement("ScreenGui", {
		IgnoreGuiInset = true;
		ResetOnSpawn = false;
		Name = 'MAIN';
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	}, {
		Check = Roact.createElement(props.Components.Check, {
			on = Gui.FadeIn;
			off = Gui.FadeOut;
			tilesize = 350;
			color = Color3.fromRGB(43, 255, 138)
		});
		Fade = Roact.createElement(props.Components.Fade, {

		});
	});
end;

return App;