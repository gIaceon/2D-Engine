local ReplicatedStorage = game:GetService('ReplicatedStorage');
local Component = require(ReplicatedStorage.Packages.Component);
local Knit = require(ReplicatedStorage.Packages.Knit);

local Test = Component.new {
	Tag = script.Name;
};

Test.RenderPriority = Enum.RenderPriority.Camera.Value + 1;

function Test:Construct()
	
end;

function Test:Stop()
	
end;

function Test:RenderSteppedUpdate(dt: number)
	local Char = Knit.GetController('CharacterController');
	local Root = Char.Root;
	if (Root) then
		local DiffPos = (self.Instance.Position - Root.Position).Y
		--if (DiffPos <= 3.1 or DiffPos <= -3) then
		--	self.Instance.CanCollide = false;
		--else
		--	self.Instance.CanCollide = true;
		--end;
		if (Char.CrouchedBeforeLand) then
			self.Instance.CanCollide = false;
		else
			if (DiffPos < 0) then
				self.Instance.CanCollide = DiffPos >= -3.5;
			elseif (DiffPos >= 0) then
				self.Instance.CanCollide = DiffPos >= 99;
			end;
		end;
	end;
end;

return Test;
