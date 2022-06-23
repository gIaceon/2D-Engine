-- If you would like to use any of this music, 
-- shoot me a message w/ your universe id and I'll allow the audio ;)

local Song = {};
local MT = {__index = Song};

local HttpService = game:GetService('HttpService');
local SoundService = game:GetService('SoundService')
local ReplicatedStorage = game:GetService('ReplicatedStorage');

local Janitor = require(ReplicatedStorage.Packages:WaitForChild('Janitor'));

function Song.new(ID: number, Volume: number?, Looped: boolean?, EndDelay: number?, Special: boolean?)
    local self = setmetatable({}, MT);

    assert(ID ~= nil, 'Song.new missing argument #1 ID');

    self.ID = ID;
    self.Volume = Volume or .5;
    self.Looped = Looped;
    self.EndDelay = EndDelay;
    self.Special = Special == true;
    self.Janitor = Janitor.new();

    if (not SoundService:FindFirstChild('song')) then
        local song = Instance.new('SoundGroup');
        song.Name = 'song';
        song.Parent = SoundService;
    end;

    self:MakeInstance();

    return self;
end;

function Song:MakeInstance()
    self.Janitor:Cleanup();
    
    local Sound = Instance.new('Sound');
    Sound.Looped = true;
    Sound.Volume = self.Volume;
    Sound.SoundId = 'rbxassetid://'..tostring(self.ID);
    Sound.Looped = self.Looped == true;
    Sound.SoundGroup = game:GetService('SoundService'):WaitForChild('song');
    Sound.Name = HttpService:GenerateGUID();
    Sound.Parent = workspace;

    self.Janitor:Add(Sound, "Destroy");
    self.Sound = Sound;

    return Sound;
end;

function Song:GetSound()
    assert(self.Sound, 'Cannot retrieve nil sound.');

    return self.Sound;
end;

function Song:Destroy()
    self.Janitor:Destroy();
    table.clear(self);
end;

local Sound = {};

function Sound.new(ID: number, Volume: number?, Looped: boolean?)
    local self = setmetatable({}, MT);

    assert(ID ~= nil, 'Sound.new missing argument #1 ID');

    self.ID = ID;
    self.Volume = Volume or .5;
    self.Looped = Looped;
    self.Janitor = Janitor.new();

    self:MakeInstance();

    return self;
end;

function Sound:MakeInstance()
    self.Janitor:Cleanup();
    
    local Sound = Instance.new('Sound');
    Sound.Looped = true;
    Sound.Volume = self.Volume;
    Sound.SoundId = 'rbxassetid://'..tostring(self.ID);
    Sound.Looped = self.Looped == true;
    Sound.SoundGroup = game:GetService('SoundService'):WaitForChild('sound');
    Sound.Name = HttpService:GenerateGUID();
    Sound.Parent = workspace;

    self.Janitor:Add(Sound, "Destroy");
    self.Sound = Sound;

    return Sound;
end;

return {
    Outside = {
        Song.new(9157533939, .5, true, 0, false);
    };
    Test = {
        Song.new(9079410464, .5, true, 0, false);
    };
    None = {
        Song.new(0, 0, true, 0, false);
    };

    -- SFX
    UI = {
        Click = {
            Sound.new(12221976, .5, false);
        };
        Text = {
            Sound.new(8549394881, .5, false);
        };
        ErrTalk = {
            -- Sound.new(6861689542, .5, false);
            -- Sound.new(5342465893, .5, false);
            -- Sound.new(8549394881, .5, false);
            -- Sound.new(3620844678, .5, false);
            Sound.new(5640721576, 2, false);
        };
    };

    SFX = {
        Boing = {
            Sound.new(9111926008, .5, false);
        };
    };
};