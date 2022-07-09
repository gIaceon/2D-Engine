--[[

	A CameraState which allows you to lerp the direction of the camera.

	HOW TO USE:
	The starting place has 4 points already made for you.
	To make more, simply duplicate (Ctrl+D) the point and rename it to the next number (ex. Point5)
	Then to change the Camera Direction it goes to, change the CameraDir attribute.

	If you do not have any points, this will behave like the Normal CameraState.
]]--

--#region GLOBALS
local CAMERA_DISTANCE_BACK = 50;
local CAMERA_DISTANCE_LEFTRIGHT = 4;
local CAMERA_UP = .75;
--#endregion

local module = {}
module.Name = script.Name;

local ReplicatedStorage = game:GetService('ReplicatedStorage');

local Spring = require(ReplicatedStorage.Packages:WaitForChild('Spring'));

local function Lerp(a: number, b: number, t: number)
	return a * (1-t) + b * t;
end;

function module:Init()
	self.SpringCamera = Spring.new(Vector3.new());
	self.SpringCamera._speed = 5;
	self.SpringCamera._damper = 1.25;

	self.closestPoint = nil;
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

	-- Fuzzy find the nearest point with recursion.
	local function FindPoint(Start: number)
		local MyPoint = workspace.Cam:FindFirstChild('Point'..tostring(Start));
		local MyPoint2 = workspace.Cam:FindFirstChild('Point'..tostring(Start + 1));

		if (not MyPoint) then
			-- We can't find the next point. This means the recursive function broke somehow.
			-- Just break out of it and use the default camera behavior.
			return nil, nil;
		end;

		-- Assume we hit the end of the points, and switch to using the points from before.

		local LastSet = MyPoint2 == nil;
		if (not MyPoint2) then
			MyPoint = workspace.Cam:FindFirstChild('Point'..tostring(Start - 1));
			MyPoint2 = workspace.Cam:FindFirstChild('Point'..tostring(Start));
		end;

		-- The character is not in the point
		if not (Char.Root.Position.Z < MyPoint.Position.Z and Char.Root.Position.Z > MyPoint2.Position.Z) then
			
			if (Start == 1 and Char.Root.Position.Z > MyPoint.Position.Z) then
				-- Character is behind the starting point.
				-- Its best to make sure this doesn't happen, but it can.
			else
				-- Go up a point if this isn't the last set of points.
				if (not LastSet) then
					return FindPoint(Start + 1);
				end;
			end;
		end;

		return MyPoint, MyPoint2;
	end;

	local Point1, Point2 = FindPoint(1);

	local Dir = Char.CAMERA_DIRECTION * CAMERA_DISTANCE_BACK;
	local LeftRight = (FACING * CAMERA_DISTANCE_LEFTRIGHT);

	if (Point1 and Point2) then
		local function Attribute(Name: string, Default: any?)
			return (Point1:GetAttribute(Name) or Default), (Point2:GetAttribute(Name) or Default);
		end;

		local Dir1: Vector3, Dir2: Vector3 = Attribute('CameraDir', Char.CAMERA_DIRECTION);

		-- The Y needs to be at the player's Y 
		-- and the X needs to be at 0 for the distance check to work properly.
		local Pos1 = Vector3.new(0, Char.Root.Position.Y, Point1.Position.Z);
		local Pos2 = Vector3.new(0, Char.Root.Position.Y, Point2.Position.Z);

		-- Get the distance from the first point and second point 
		-- Then get the distance from the first point and the player
		-- Use these values to lerp the points together.
		local Dist = (Pos1 - Pos2).Magnitude;

		-- Keeping this clamped for the values to be nice. 
		-- :Lerp() will cap it at one anyway, and I don't care.
		local DistFromPoint1 = math.clamp((Pos1 - Char.Root.Position).Magnitude, 0, Dist);

		-- Clamp the alpha at 0 or 1 if past the bounds of the point.
		local ForcedAlpha = nil;

		if (Char.Root.Position.Z > Pos1.Z) then
			ForcedAlpha = 0;
		end;
		if (Char.Root.Position.Z < Pos2.Z) then
			ForcedAlpha = 1;
		end;

		local Alpha = ForcedAlpha or (DistFromPoint1 / Dist);

		local CamDir = Dir1:Lerp(Dir2, Alpha);

		Dir = CamDir * CAMERA_DISTANCE_BACK;
		LeftRight = (FACING * CAMERA_DISTANCE_LEFTRIGHT);
	else
		print('NO POINT')
	end;

	self.SpringCamera.Target = LeftRight;

	local PointedToCF = CFrame.lookAt(
		(Char.Root.Position + Dir) + self.SpringCamera.Position,
		Char.Root.Position + self.SpringCamera.Position
	);

	return PointedToCF;
end;

return module;