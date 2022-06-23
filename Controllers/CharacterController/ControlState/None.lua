-- MoveState used for disabling controls.


local module = {}
module.Name = script.Name;

function module:Init()
	
end;

function module:Destroy()
	
end;

function module:Move(Char)
	return Vector3.new(), false, false; -- Return no movement
end;

return module
