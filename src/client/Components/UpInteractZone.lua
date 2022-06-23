local ReplicatedStorage = game:GetService('ReplicatedStorage');
local Component = require(ReplicatedStorage.Packages.Component);
local Knit = require(ReplicatedStorage.Packages.Knit);
local Janitor = require(ReplicatedStorage.Packages.Janitor);
local Switch = require(ReplicatedStorage.Common.Switch);
local Case = Switch.Case;
local Default = Switch.Default;
local Func = Switch.OneValueEvaluate;

local UpInteractZone = Component.new {
	Tag = script.Name;
};

function UpInteractZone:Construct()
	local Char = Knit.GetController('CharacterController');
	
	self._janitor = Janitor.new();
	self._janitor:Add(self.Instance.Touched:Connect(function()end), 'Disconnect'); 
	-- for a touch intersect
	
	self._janitor:Add(Char.OnLookUp:Connect(function() 
		local TouchingParts: { BasePart } = self.Instance:GetTouchingParts();
		for _,v in TouchingParts do
			if (v == Char.Root) then
				self:Activate();
			end;
		end;
	end), 'Disconnect')
end;

function UpInteractZone:Activate()
	local Char = Knit.GetController('CharacterController');
	local Gui = Knit.GetController('GuiController');
	
	if (not Gui.CanPresent) then
		return;
	end;
	
	Gui.CanPresent = false;
	
	Switch(self.Instance:GetAttribute('OnUp'), Func) {
        --#region                  CASES
        [Case 'Test'] = function()
            Gui.OnReadDialog:Fire(
				'Test Dialog',
				'This is the <b>UpInteractZone</b> component. You can add functions in the component file in <b>StarterPlayer/StartPlayerScripts/Client/Components/UpInteractZone</b>!',
				{
					Speed = 2;
					Sound = 'UI.ErrTalk';
				}
			);
        end;
        
		[Default] = function()
			Gui.OnReadDialog:Fire(
				'Handler',
				string.format('No case %q', tostring(self.Instance:GetAttribute('OnUp'))),
				{
					Speed = 2;
					Sound = 'UI.ErrTalk';
				}
			);
		end;
        --#endregion
	};
	
	task.wait(3);
	Gui.CanPresent = true;
end;

function UpInteractZone:Stop()
	self._janitor:Destroy();
end;

return UpInteractZone;
