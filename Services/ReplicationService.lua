local ReplicatedStorage = game:GetService'ReplicatedStorage';

local Knit = require(ReplicatedStorage.Packages.Knit);
local Janitor = require(ReplicatedStorage.Packages.Janitor);
local PlayerObj = require(ReplicatedStorage.Common.Player);

local ReplicationService = Knit.CreateService {
    Name = 'ReplicationService';
    Client = {
        RequestReplicate = Knit.CreateSignal(),
        ReplicateFinish = Knit.CreateSignal(),
    };
};

function ReplicationService:KnitStart()
    local function PlayerInit(Player: Player)
        self.Players[Player] = PlayerObj.new(Player);
    end;

    local function PlayerDestroy(Player: Player)
        if (self.Players[Player]) then
            self.Players[Player]:Destroy();
        end;
    end;

    game.Players.PlayerAdded:Connect(PlayerInit);
    game.Players.PlayerRemoving:Connect(PlayerDestroy);
end;

function ReplicationService:KnitInit()
    self.Players = {};
end;

return ReplicationService;