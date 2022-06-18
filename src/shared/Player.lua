local BERRY_BLOSSOM_GROUP = 13050664;

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = {};
local mt = {__index = Player};

local ReplicatedStorage = game:GetService('ReplicatedStorage');
local Janitor = require(ReplicatedStorage.Packages.Janitor);
local Knit = require(ReplicatedStorage.Packages.Knit);

function Player.new(Player: Player)
    local self = setmetatable({}, mt);

    self.Player = Player;
    self._janitor = Janitor.new();

    local ReplicationService = Knit.GetService('ReplicationService');

    local function CharAdded(Char)
        self.Humanoid = Char:WaitForChild('Humanoid') :: Humanoid;
        self.Root = Char:WaitForChild('HumanoidRootPart') :: BasePart;

        -- Replicate by requesting the client for a result
        self._janitor:Add(ReplicationService.Client.ReplicateFinish:Connect(function(_, Result: CFrame?) 
            print(Result);
            if (Result and typeof(Result) == 'CFrame') then
                self.Root.RootJoint.C0 = Result;
            end;
            -- Request replication again
            ReplicationService.Client.RequestReplicate:FireFor({self.Player});
        end), "Disconnect");

        self._janitor:Add(self.Humanoid.Died:Connect(function() 
            self._janitor:Cleanup();
        end), "Disconnect");

        -- Begin requesting for replication
        ReplicationService.Client.RequestReplicate:FireFor({self.Player});
    end;

    if (Player.Character) then
        CharAdded(Player.Character);
    end;

    Player.CharacterAdded:Connect(CharAdded);

    return self;
end;

function Player:Destroy()
    self._janitor:Destroy();
end

return Player;