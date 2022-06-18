local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService")

local Component = require(ReplicatedStorage.Packages:WaitForChild('Component'));
local Knit = require(ReplicatedStorage.Packages:WaitForChild("Knit"));
local Janitor = require(ReplicatedStorage.Packages.Janitor);
local Zone = require(ReplicatedStorage.Common.Zone);

local MusicZone = Component.new{
    Tag = 'MusicZone';
};

function MusicZone:Construct()
    self.Zone = Zone.new(self.Instance);
    self.Janitor = Janitor.new();

    self.SongToPlayInZoneEntry = self.Instance:GetAttribute('Song');
    self.SongToPlayZoneExit = self.Instance:GetAttribute('ExitSong');
    print('hi')
    self.Janitor:Add(self.Instance:GetAttributeChangedSignal('Song'):Connect(function()
        self.SongToPlayInZoneEntry = self.Instance:GetAttribute('Song');
    end), "Disconnect");

    self.Janitor:Add(self.Zone.localPlayerEntered:Connect(function()
        local MusicController = Knit.GetController('SoundController');
        print('a');
        MusicController:SetZoneState(self.SongToPlayInZoneEntry);
    end), "Disconnect");

    self.Janitor:Add(self.Zone.localPlayerExited:Connect(function()
        local MusicController = Knit.GetController('SoundController');
        print('b', self.SongToPlayZoneExit);
        MusicController:SetZoneState(self.SongToPlayZoneExit);
    end), "Disconnect");
end;

function MusicZone:Destroy()
    self.Janitor:Destroy();
end;

return MusicZone;