local KEYS_LEFT = {
	Enum.KeyCode.A;
	Enum.KeyCode.Left;
};

local KEYS_RIGHT = {
	Enum.KeyCode.D;
	Enum.KeyCode.Right;
};

local KEYS_JUMP = {
	Enum.KeyCode.Space;
};

local KEYS_UP = {
	Enum.KeyCode.W;
	Enum.KeyCode.Up;
};

local KEYS_DOWN = {
	Enum.KeyCode.S;
	Enum.KeyCode.Down;
};

local KEYS_RUN = {
	Enum.KeyCode.LeftShift;
	Enum.KeyCode.RightShift;
};

local KEYS_ACT = {
	Enum.KeyCode.Q;
	Enum.KeyCode.Z;
};

local IN_AIR_STATES = {
	Enum.HumanoidStateType.Freefall;
	Enum.HumanoidStateType.Dead;
	Enum.HumanoidStateType.Jumping;
	Enum.HumanoidStateType.Flying;
	Enum.HumanoidStateType.Seated;
	Enum.HumanoidStateType.Swimming;
};

local CAM_UPD_DISTANCE = 2;

local NORMAL_SPEED = 20;
local MAX_SPEED = 40;
local MAX_SPEED_NO_SPRINT = 30;
local ADD_SPEED = .15;
local FRICTION = .4;

local UIS = game:GetService('UserInputService');
local CAS = game:GetService('ContextActionService');
local ReplicatedStorage = game:GetService('ReplicatedStorage');

local Knit = require(ReplicatedStorage.Packages:WaitForChild('Knit'));
local Janitor = require(ReplicatedStorage.Packages.Janitor);

local module = {};
module.Name = script.Name;

function module:Init()
	local CharacterController = Knit.GetController('CharacterController');
	
	self.MoveDirection = Vector3.new();
	
	self.IsLeft = false;
	self.IsRight = false;
	self.IsJumping = false;
	self.IsUp = false;
	self.IsDown = false;
	self.InAir = table.find(IN_AIR_STATES, CharacterController.Humanoid:GetState()) ~= nil;
	self.Run = false;
	self.Acting = false;
	
	self.CurrentMomentum = NORMAL_SPEED;
	self.SlidePower = 0;
	
	self._janitor = Janitor.new();
	
	local CurrentState = CharacterController.Humanoid:GetState();
	self.InAir = table.find(IN_AIR_STATES, CurrentState) ~= nil;
	
	CAS:BindAction('Left', function(_, state) 
		if (state == Enum.UserInputState.Begin) then
			self.IsLeft = true;
		else
			self.IsLeft = false;
		end;
		
		return Enum.ContextActionResult.Sink;
	end, false, unpack(KEYS_LEFT));
	
	CAS:BindAction('Right', function(_, state) 
		if (state == Enum.UserInputState.Begin) then
			self.IsRight = true;
		else
			self.IsRight = false;
		end;
		
		return Enum.ContextActionResult.Sink;
	end, false, unpack(KEYS_RIGHT));
	
	CAS:BindAction('Jumping', function(_, state) 
		if (state == Enum.UserInputState.Begin) then
			self.IsJumping = true;
		else
			self.IsJumping = false;
		end;
		
		return Enum.ContextActionResult.Sink;
	end, false, unpack(KEYS_JUMP));

	CAS:BindAction('Up', function(_, state) 
		if (self.InAir) then
			return Enum.ContextActionResult.Pass;
		end;
		
		if (state == Enum.UserInputState.Begin) then
			self.IsUp = true;
		else
			self.IsUp = false;
		end;
		
		CharacterController.UpDownChanged:Fire(self.IsUp, self.IsDown);
		
		return Enum.ContextActionResult.Sink;
	end, false, unpack(KEYS_UP));
	
	CAS:BindAction('Down', function(_, state) 
		if (self.InAir) then
			return Enum.ContextActionResult.Pass;
		end;
		
		if (state == Enum.UserInputState.Begin) then
			self.IsDown = true;
		else
			self.IsDown = false;
			CharacterController.CrouchedBeforeLand = false;
		end;
		
		CharacterController.UpDownChanged:Fire(self.IsUp, self.IsDown);
		
		return Enum.ContextActionResult.Sink;
	end, false, unpack(KEYS_DOWN));
	
	CAS:BindAction('Run', function(_, state)
		if (state == Enum.UserInputState.Begin) then
			self.Run = true;
		else
			self.Run = false;
		end;
	end, false, table.unpack(KEYS_RUN));
	
	-- CAS:BindAction('Act', function(_, state)
	-- 	if (state == Enum.UserInputState.Begin and not self.Acting) then
	-- 		self.Acting = true;
	-- 		self:Dive();
	-- 	end;
	-- end, false, unpack(KEYS_ACT));
	
	self.StateChange = CharacterController.Humanoid.StateChanged:Connect(function(old, new)
		if (table.find(IN_AIR_STATES, old) or new == Enum.HumanoidStateType.Running or new == Enum.HumanoidStateType.Landed) then
			self.InAir = false;
			
			CharacterController.CrouchedBeforeLand = false;
			CharacterController.OnLand:Fire();
			
			-- If we were looking up or down before, we should set these back again.
			
			self:ExitMoveState();
		end;
		
		if (table.find(IN_AIR_STATES, new)) then
			self.InAir = true;
		end;
	end);
	
	self:ExitMoveState();
end;

function module:Dive()
	local Char = Knit.GetController('CharacterController');
	
	Char.Humanoid.Jump = true;
	local Vel = Char:BodyVelocity{
		Lifetime = .2;
		MaxForce = Vector3.new(math.huge, math.huge, math.huge);
		P = 1500;
		Velocity = 
			Vector3.new(0, 120, Char.Humanoid.WalkSpeed)
			* Vector3.new(self.MoveDirection.X, 1, self.MoveDirection.X)
	};
	-- Char.SND:FindFirstChild('Audio/on2_leapjump'):Play();
	Char:PlayAnimation('up', .05, 1, 1);
	
	self._janitor:Add(task.spawn(function() 
		while Vel do
			Vel.Velocity = 
				Vector3.new(0, 120, Char.Humanoid.WalkSpeed) 
				* Vector3.new(0, 1, -self.MoveDirection.X);
			task.wait();
		end;
	end), true, 'UpdVel');
	
	self._janitor:Add(task.delay(.1, function() 
		self._janitor:Add(Char.OnLand:Connect(function()
			self._janitor:Remove('MoveFinished');
			self._janitor:Remove('UpdVel');
			Char._janitor:Remove('BodyVel');
			self.Acting = false;
			Char:StopAnimation('up');
			Char.SND:FindFirstChild('Audio/on2_leapjump'):Stop();
			Char.SND:FindFirstChild('button.wav'):Play();
			self:ExitMoveState();
		end), 'Disconnect', 'MoveFinished');
	end), true);
end;

function module:ExitMoveState()
	local CharacterController = Knit.GetController('CharacterController');
	
	for _,v in KEYS_UP do
		if UIS:IsKeyDown(v) then
			self.IsUp = true;
		end;
	end;

	for _,v in KEYS_DOWN do
		if UIS:IsKeyDown(v) then
			self.IsDown = true;
		end;
	end;
	
	for _,v in KEYS_LEFT do
		if UIS:IsKeyDown(v) then
			self.IsLeft = true;
		end;
	end;
	
	for _,v in KEYS_RIGHT do
		if UIS:IsKeyDown(v) then
			self.IsRight = true;
		end;
	end;
	
	for _,v in KEYS_RUN do
		if UIS:IsKeyDown(v) then
			self.Run = true;
		end;
	end;
	
	CharacterController.UpDownChanged:Fire(self.IsUp, self.IsDown);
end;

function module:Destroy()
	CAS:UnbindAction('Left');
	CAS:UnbindAction('Right');
	CAS:UnbindAction('Jumping');
	CAS:UnbindAction('Up');
	CAS:UnbindAction('Down');
	CAS:UnbindAction('Run');
	CAS:UnbindAction('Act');
	
	self.StateChange:Disconnect();
	self._janitor:Destroy();
end;

function module:Move(Char)	
	if (self.IsLeft) then
		-- Character is moving left
		self.MoveDirection = Char.CAMERA_DIRECTION * -1;
		Char.MovedLeftLast = true;
		Char.MovedRightLast = false;
	elseif (self.IsRight) then
		-- Character is moving right
		self.MoveDirection = Char.CAMERA_DIRECTION;
		Char.MovedRightLast = true;
		Char.MovedLeftLast = false;
	else
		-- Character is not moving at all
		local LastDir = 1;
		if (Char.MovedLeftLast) then
			LastDir = -1;
		end;
		
		self.SlidePower = math.clamp(self.SlidePower - FRICTION, 0, 2);
		self.MoveDirection = Char.CAMERA_DIRECTION * (self.SlidePower * LastDir);
		if (math.abs(self.MoveDirection.X) <= .2) then
			self.MoveDirection = Vector3.new();
		end;
	end;
	
	if (self.IsLeft or self.IsRight) and self.Run then
		-- Is moving and sprinting
		Char.CameraZoom = -2;
		self.SlidePower = 2;
		self.CurrentMomentum = math.clamp(self.CurrentMomentum + 2*ADD_SPEED, NORMAL_SPEED, MAX_SPEED);
	elseif (self.IsLeft or self.IsRight) and self.CurrentMomentum > MAX_SPEED_NO_SPRINT then
		-- Is moving and not sprinting, while speed is higher than no sprint max
		Char.CameraZoom = 0;
		self.SlidePower = 1;
		self.CurrentMomentum = math.clamp(self.CurrentMomentum - 2*ADD_SPEED, NORMAL_SPEED, MAX_SPEED);
	elseif (self.IsLeft or self.IsRight) then
		-- Is moving and not sprinting
		Char.CameraZoom = 0;
		self.SlidePower = 1;
		self.CurrentMomentum = math.clamp(self.CurrentMomentum + ADD_SPEED, NORMAL_SPEED, MAX_SPEED);
	else
		-- Not moving
		Char.CameraZoom = 0;
		self.CurrentMomentum = math.clamp(self.CurrentMomentum - 2*ADD_SPEED, NORMAL_SPEED, MAX_SPEED);
	end;
	
	if (self.IsLeft and self.IsRight) then
		-- Both left and right are pressed, do nothing.
		self.MoveDirection = Vector3.new();
		self.CurrentMomentum = math.clamp(self.CurrentMomentum - 2*ADD_SPEED, NORMAL_SPEED, MAX_SPEED);
	end;
	
	if (Char.CanJump) then
		Char.Humanoid.Jump = self.IsJumping;
	end;
	
	-- Don't look up or down if we suddenly have entered the air.
	if (self.InAir and (self.IsUp or self.IsDown)) then
		self.IsUp = false;
		self.IsDown = false;
		Char.UpDownChanged:Fire(self.IsUp, self.IsDown);
	end;
	
	-- Looking up and down should disable movement.
	-- Therefore, we just overwrite the MoveDirection if thats the case.
	if (self.IsUp and self.IsDown) then
		-- Do not set the camera here.
		self.MoveDirection = Vector3.new();
		self.CurrentMomentum = NORMAL_SPEED;
	else		
		if (self.IsUp) then
			-- Is looking up
			Char.CameraUpDown = CAM_UPD_DISTANCE;
			Char.CameraZoom = 0;
			self.MoveDirection = Vector3.new();
			self.CurrentMomentum = NORMAL_SPEED;
		elseif (self.IsDown) then
			-- Is looking down
			Char.CameraUpDown = -CAM_UPD_DISTANCE;
			Char.CameraZoom = 0;
			self.MoveDirection = Vector3.new();
			self.CurrentMomentum = NORMAL_SPEED;
		elseif (not self.IsUp and not self.IsDown) then
			-- Is not looking up or down
			Char.CameraUpDown = Char.CrouchedBeforeLand and -CAM_UPD_DISTANCE or 0;
		end;
		if (self.Acting) then
			Char.CameraUpDown = CAM_UPD_DISTANCE;
		end;
	end;
	
	Char.Humanoid.WalkSpeed = self.CurrentMomentum;
	
	return self.MoveDirection, self.IsLeft, self.IsRight;
end;

return module
