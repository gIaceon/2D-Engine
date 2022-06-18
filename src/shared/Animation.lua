local ANIM =  {
    air = 'rbxassetid://9817491405';
    look_down = 'rbxassetid://9807597212';
    look_up = 'rbxassetid://9807528697';
    roll = 'rbxassetid://9817254592';
    up = 'rbxassetid://9817659764';
};

local ReplicatedStorage = game:GetService('ReplicatedStorage');

local Janitor = require(ReplicatedStorage.Packages.Janitor);

local Animation = {};
Animation.__index = Animation;

function Animation.new(Humanoid: Humanoid)
    local self = setmetatable({}, Animation);

    self._anim = {};
    self._janitor = Janitor.new();

    for k,v in pairs(ANIM) do
        local inst = Instance.new("Animation");
        inst.AnimationId = v;
        inst.Name = k;
        self._janitor:Add(inst, "Destroy");

        local Animator: Animator = Humanoid:WaitForChild'Animator';
        
        local AnimLoaded = Animator:LoadAnimation(inst);
        self._anim[k] = AnimLoaded;
        self._janitor:Add(AnimLoaded, "Destroy");
    end;
    
    self.Current = nil;

    return self;
end;

function Animation:Play(Name: string, ...)
    self._anim[Name]:Play(...);
    return self._anim[Name];
end;

function Animation:Stop(Name: string)
    self._anim[Name]:Stop();
    return self._anim[Name];
end;

function Animation:Destroy()
    self._janitor:Destroy();
    table.clear(self._anim);
    table.clear(self);
    self = nil;
end;

return Animation;