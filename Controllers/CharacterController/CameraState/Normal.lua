-- The default CameraState.

--#region GLOBALS
local CAMERA_DISTANCE_BACK = 50;
local CAMERA_DISTANCE_LEFTRIGHT = 4;
local CAMERA_UP = .75;
--#endregion

local module = {}
module.Name = script.Name;

local ReplicatedStorage = game:GetService('ReplicatedStorage');

local Spring = require(ReplicatedStorage.Packages:WaitForChild('Spring'));

function module:Init()
	self.SpringCamera = Spring.new(Vector3.new());
	self.SpringCamera._speed = 5;
	self.SpringCamera._damper = 1.25;
end;

function module:Destroy()
	self.SpringCamera = nil;
end;

function module:Step(Char)
	local Zoom = -Char.CameraZoom + -Char.CameraWorldZoom;
	local UpDown = CAMERA_UP + Char.CameraUpDown;
	
	local FACING = Vector3.new(Zoom, UpDown);
	
	if (Char.MovedLeftLast) then
		FACING = Vector3.new(Zoom,UpDown,1);
	elseif (Char.MovedRightLast) then
		FACING = Vector3.new(Zoom,UpDown,-1);
	end;
	
	local Dir = Char.CAMERA_DIRECTION * CAMERA_DISTANCE_BACK;
	local LeftRight = (FACING * CAMERA_DISTANCE_LEFTRIGHT);
	self.SpringCamera.Target = LeftRight;

	local PointedToCF = CFrame.lookAt(
		(Char.Root.Position + Dir) + self.SpringCamera.Position,
		Char.Root.Position + self.SpringCamera.Position
	);

	return PointedToCF;
end;

return module;