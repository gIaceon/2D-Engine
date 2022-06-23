local ReplicatedStorage = game:GetService'ReplicatedStorage';

local Knit = require(ReplicatedStorage.Packages.Knit);
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local SoundController = Knit.CreateController {
    Name = script.Name;
    CurrentSong = nil;
};

function SoundController:SetZoneState(ZoneStateName: string)
    if (ZoneStateName == '__LAST') then
        ZoneStateName = self._lastZoneState;
    end;
    
    if (not table.find(self.ZoneStates, ZoneStateName)) then
        error(('%s is not a valid zone state!'):format(ZoneStateName));
    end;

    local Done = self:_InitializeMusic(ZoneStateName);
    if (Done) then
        self._lastZoneState = self._zoneState;
        self._zoneState = ZoneStateName;
    end;
end;

function SoundController:_InitializeMusic(ZoneStateName)
    local ZoneState = ZoneStateName;
    local ZoneStateSongs = self.Songs[ZoneState];

    assert(ZoneStateSongs, ('%s is not a valid zone state!'):format(ZoneState)); 

    local ChosenSong do
        local Tries = 0;
        local function Fetch()
            Tries += 1;
            if (Tries < 100) then -- stack overflow moment
                ChosenSong = ZoneStateSongs[math.random(1, #ZoneStateSongs)];
                if (ChosenSong == self.CurrentSong) then
                    -- Needed so that the fadeout doesnt fadeout the current song lol
                    Fetch();
                end;
            end;
        end;
        Fetch();
    end;
    
    assert(ChosenSong, 'ChosenSong was nil');

    local Song = ChosenSong:GetSound();
    assert(Song, 'Song was nil');

    if (
        self.CurrentSong 
        and self.CurrentSong.Special == true
        and self.CurrentSong:GetSound().Playing == true
    ) then
        return; -- The current song is special so dont skip it
    end;

    self._janitor:Cleanup();

    Song.Volume = 0;

    local function FadeOutMethod() -- Fadeout the currently playing song
        local Current = self.CurrentSong;

        if (not Current) then
            return;
        end;

        local Song = Current:GetSound();

        local Thread = task.delay(.5, function()
            Song:Stop();
        end);
        local Tween = game:GetService('TweenService'):Create(
            Song, 
            TweenInfo.new(.5), 
            {
                Volume = 0;
            }
        );
        Tween:Play();

        self._janitor:Add(Thread, true);
        -- self._janitor:Add(Tween, "Destroy");
    end;

    if (not ChosenSong.Looped == true) then
        self._janitor:Add(Song.Ended:Connect(function()
            task.wait(ChosenSong.EndDelay or 30); -- intermission
            self:_InitializeMusic(self._zoneState);
        end), "Disconnect");
    end;

    FadeOutMethod();

    local Tween = game:GetService('TweenService'):Create(
        Song, 
        TweenInfo.new(
            .5
        ), 
        {Volume = ChosenSong.Volume}
    );

    self._janitor:Add(Tween, "Destroy");

    Song:Play();
    Tween:Play();

    self.CurrentSong = ChosenSong;

    return true;
end;

function SoundController:PlaySound(Name: string)
    -- Parse the path with a string
    -- Input: UI.Click
    -- Output: self.Songs.UI.Click
    local ParsedPath do
        ParsedPath = self.Songs;
        for i, v in ipairs(string.split(Name, '.')) do
            if (ParsedPath[v]) then
                ParsedPath = ParsedPath[v];
                continue;
            else
                assert(i ~= 1, 'No valid Sound with group '..v);
                break;
            end;
        end;
    end;

    -- Get a random sound from the table
    local ChosenSound = ParsedPath[math.random(1, #ParsedPath)];
    local Sound = ChosenSound:GetSound();

    if (Sound) then
        Sound:Play();
        return Sound;
    end;
end

function SoundController:KnitStart()
    self:SetZoneState('None');
end;

function SoundController:KnitInit()
    self.Songs = require(ReplicatedStorage.Common.Sound);

    self.ZoneStates = {};

    for ZoneStateName, _ in pairs(self.Songs) do
        table.insert(self.ZoneStates, ZoneStateName);
    end;

    self._zoneState = 'None';
    self._lastZoneState = 'None';
    self._janitor = Janitor.new();
end;

return SoundController;