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

    local function CharAdded(Char)
        self.Humanoid = Char:WaitForChild('Humanoid') :: Humanoid;
        self.Root = Char:WaitForChild('HumanoidRootPart') :: BasePart;

        self._janitor:Add(self.Humanoid.Died:Connect(function() 
            self._janitor:Cleanup();
        end), "Disconnect");
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