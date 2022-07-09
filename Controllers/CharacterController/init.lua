local CAMERA_DISTANCE_BACK = 50;
local CAMERA_DISTANCE_LEFTRIGHT = 10;
local CAMERA_DEFAULT_TYPE = 'Lerped';

type MoveState = {
	Init: (self: MoveState) -> ();
	Destroy: (self: MoveState) -> ();
	Move: (self: MoveState, Char: any) -> (Vector3, boolean, boolean);
};

type CameraState = {
	Init: (self: CameraState) -> ();
	Destroy: (self: CameraState) -> ();
	Step: (self: CameraState, Char: any) -> (CFrame);
};

local ReplicatedStorage = game:GetService('ReplicatedStorage');
local RunService = game:GetService('RunService');
local CollectionService = game:GetService('CollectionService');
local TweenService = game:GetService('TweenService');

local Knit = require(ReplicatedStorage.Packages:WaitForChild('Knit'));
local Spring = require(ReplicatedStorage.Packages:WaitForChild('Spring'));
local Janitor = require(ReplicatedStorage.Packages:WaitForChild('Janitor'));
local Signal = require(ReplicatedStorage.Packages.Signal);
local Animation = require(ReplicatedStorage.Common.Animation);

local CharacterController = Knit.CreateController {
	Name = 'CharacterController';
	
	CAMERA_DIRECTION = Vector3.new(1, 0, 0);
	
	CharAdded = Signal.new();
	UpDownChanged = Signal.new();
	OnCrouch = Signal.new();
	OnLand = Signal.new();
	OnDeath = Signal.new();
	OnLookUp = Signal.new();
	
	ControlsEnabled = true;
	CanJump = true;
	
	MovedLeftLast = false;
	MovedRightLast = true;
	
	Crouching = false;
	CrouchedBeforeLand = false;
	
	MoveState = nil;
	CamState = nil;
	
	CameraZoom = 0;
	CameraWorldZoom = 0;
	CameraUpDown = 0;
	
	Dead = false;
};

local LastValidCameraCF = nil;
function CharacterController:OnFrame(dt)
	if (not self.Root or not self.Humanoid or self.Dead) then
		return;
	end;
	
	local MoveDir, IsLeft, IsRight = Vector3.new(), false, false;
	
	if (self.ControlsEnabled) then
		local MovementState: MoveState = self.MoveState
		if (MovementState) then
			MoveDir, IsLeft, IsRight = MovementState:Move(self);
		end;
	end;
	
	local RelativeMoveDirection = self.Camera.CFrame:VectorToObjectSpace(Vector3.new(MoveDir.X, 0, MoveDir.Z));
	RelativeMoveDirection = Vector3.new(RelativeMoveDirection.X, 0, RelativeMoveDirection.Z);
	self.RelativeMoveDirection = RelativeMoveDirection;
	
	-- Setting Camera
	local CameraCF = LastValidCameraCF or self.Camera.CFrame;
	local CamState: CameraState = self.CamState;
	if (CamState) then
		pcall(function() -- shitty hack
			CameraCF = CamState:Step(self);
		end);
		if (not CameraCF) then
			CameraCF = LastValidCameraCF;
		else
			LastValidCameraCF = CameraCF;
		end;
	end;
	self.Camera.CFrame = CameraCF;
	
	local Facing = 0;
	if (self.MovedLeftLast) then
		Facing = 1;
	elseif (self.MovedRightLast) then
		Facing = -1;
	end;
	
	self.SpringRotate.Target = Facing;
	
	local SmoothFacing = self.SpringRotate.Position;
	
	self.Root.RootJoint.C0 = self.RootC0 * CFrame.Angles(0, 0, math.rad(SmoothFacing * 45));
	self.Humanoid:Move(Vector3.new(0, 0, -MoveDir.X), false);

	self.Root.Orientation = Vector3.new(0, if (Facing == 1) then 180 else 0, 0);
	self.Root.Position = Vector3.new(self.Root:GetAttribute('Axis') or 0, self.Root.Position.Y, self.Root.Position.Z);
	self.Humanoid.AutoRotate = false;
end;

function CharacterController:BodyVelocity(prop)
	local BodyVel = Instance.new('BodyVelocity');
	for i,v in prop do
		if (i == 'Lifetime') then
			continue;
		end;
		BodyVel[i] = v;
	end;
	
	local Life = prop.Lifetime or math.huge;
	
	self._janitor:Remove('DEL_BODY_VEL');
	if (Life < math.huge) then
		self._janitor:Add(task.delay(Life, function() 
			self._janitor:Remove('BodyVel');
			--self._janitor:Remove('DEL_BODY_VEL');
		end), true, 'DEL_BODY_VEL')
	end;
	
	self._janitor:Remove('BodyVel');
	self._janitor:Add(BodyVel, 'Destroy', 'BodyVel');
	
	BodyVel.Parent = self.Root;
	
	return BodyVel;
end;

function CharacterController:PlayAnimation(Name, ...)
	-- local Anim = self.LoadedAnims[Name];
	-- if (Anim) then
	-- 	Anim:Play(...);
	-- 	return Anim;
	-- end;
	return self._anim:Play(Name, ...)
end;

function CharacterController:StopAnimation(Name)
	-- local Anim = self.LoadedAnims[Name];
	-- if (Anim) then
	-- 	Anim:Stop();
	-- 	return Anim;
	-- end;
	return self._anim:Stop(Name)
end;

function CharacterController:SetCamState(Name: string)
	print('Changing CamState to', Name,'from',self.CamState.Name);
	local Last = self.CamState;
	if (Last and Last.Destroy) then
		Last:Destroy();
	end;
	
	self.CamState = self.CamStates[Name];
	self.CamState:Init();
end;

function CharacterController:SetState(Name: string)
	print('Changing MoveState to', Name,'from',self.MoveState.Name);
	local Last = self.MoveState;
	if (Last and Last.Destroy) then
		Last:Destroy();
	end;

	self.MoveState = self.MoveStates[Name];
	self.MoveState:Init();
end;

function CharacterController:SetWorldProps()
	workspace.Gravity = 300;
end;

function CharacterController:KnitStart()	
	RunService:BindToRenderStep('Step', Enum.RenderPriority.Camera.Value + 1, function(dt)
		return self:OnFrame(dt);
	end);
	self:SetWorldProps();
	
	local Gui = Knit.GetController('GuiController');

	local function AddCharacter(Char)
		self.Character = Char;
		self.Root = self.Character:WaitForChild('HumanoidRootPart');
		self.Humanoid = self.Character:WaitForChild('Humanoid');
		self.RootC0 = self.Root:WaitForChild('RootJoint').C0;

		self.Root.Anchored = true;

		self.LoadedAnims = {};

		if (self._janitor) then
			self._janitor:Destroy();
		end;

		self._janitor = Janitor.new();

		-- for _,v in self._Anims do
		-- 	local Load = self.Humanoid:WaitForChild('Animator'):LoadAnimation(v);
		-- 	if (Load) then
		-- 		self.LoadedAnims[v.Name] = Load;
		-- 		self._janitor:Add(Load, "Destroy");
		-- 	end;
		-- end;

		self._anim = Animation.new(self.Humanoid);
		self._janitor:Add(self._anim, "Destroy");

		self._janitor:Add(self.UpDownChanged:Connect(function(Up, Down)
			if (Up and Down) then
				-- Do nothing here, the character is looking up and down
			else
				-- Player looking up animation
				if (Up) then
					self:PlayAnimation('look_up');
					self.OnLookUp:Fire();
				else
					self:StopAnimation('look_up');
				end;

				-- Player looking down animation
				-- Change the HipHeight to not float
				if (Down) then
					self:PlayAnimation('look_down');
					self.Humanoid.HipHeight = -1;
					self.OnCrouch:Fire(true);
					self.Crouching = true;
					self.CrouchedBeforeLand = true;
				else
					self:StopAnimation('look_down');
					self.Humanoid.HipHeight = 0;
					self.OnCrouch:Fire(false);
					self.Crouching = false;
				end;

				-- Remove ability to jump if looking up or down
				self.CanJump = not (Up or Down);
			end;
		end));

		self._janitor:Add(self.Humanoid.Died:Connect(function()
			self.Dead = true;

			self:SetState('None');
			self:SetCamState('None');

			self.Camera.CameraType = Enum.CameraType.Scriptable;
			self.Camera.CameraSubject = nil;
			self.Camera.CFrame = LastValidCameraCF;

			Gui.FadeOut:Fire(.6);
			self.OnDeath:Fire();
			
			if (self.Root) then
				self.Root.Velocity *= 4;
			end;
			
			task.delay(.2, function()
				Gui.HideDialog:Fire();
			end);
		end));
		
		Char:PivotTo(workspace:WaitForChild('GAME_START').CFrame);
		self.Root.Anchored = false;

		self:SetState('Normal');
		self:SetCamState(CAMERA_DEFAULT_TYPE);

		self.Dead = false;
		self.CameraWorldZoom = 0;

		Gui.FadeIn:Fire(.5);
		self.CharAdded:Fire(Char);
	end;
	
	AddCharacter(self.Player.Character or self.Player.CharacterAdded:Wait());
	self.Player.CharacterAdded:Connect(AddCharacter);
end;

function CharacterController:KnitInit()
	self.Player = game.Players.LocalPlayer;
	
	self.Camera = workspace.CurrentCamera;
	self.Camera.CameraType = Enum.CameraType.Scriptable;
	self.Camera.FieldOfView = 38;
	
	self.SpringRotate = Spring.new(-1);
	self.SpringRotate._speed = 35;
	self.SpringRotate._damper = 1;
	
	local PlayerScripts = require(self.Player.PlayerScripts:WaitForChild('PlayerModule'));
	local PlayerControls = PlayerScripts:GetControls();
	PlayerControls:Disable();
	
	self.MoveStates = {};
	for _,v in script.ControlState:GetChildren() do
		self.MoveStates[v.Name] = require(v);
	end;
	
	self.CamStates = {};
	for _,v in script.CameraState:GetChildren() do
		self.CamStates[v.Name] = require(v);
	end;
	
	self.CamState = self.CamStates.None;
	self.MoveState = self.MoveStates.None;
end;

return CharacterController;