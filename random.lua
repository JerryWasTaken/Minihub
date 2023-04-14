repeat
wait()
until game:IsLoaded()

rconsoleclear()

local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character, Root, Humanoid = nil,nil,nil
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vehicle = require(ReplicatedStorage.Game.Vehicle).GetLocalVehiclePacket
local Specs = require(ReplicatedStorage.Module.UI).CircleAction.Specs
local PathfindingService = game:GetService("PathfindingService")
local Puzzle = getupvalue(require(ReplicatedStorage.Game.Robbery.PuzzleFlow).Init, 3)
local Jewelry = workspace.Jewelrys:GetChildren()[1]
local FreeVehicles = {"Camaro"}
local BlacklistVehicles = {}
local Stepped = {}

function RegisterCharacter(Char)
    Character, Root, Humanoid = Char, Char:WaitForChild("HumanoidRootPart", 2873), Char:WaitForChild("Humanoid", 2873)
    Humanoid.Died:Connect(function()
        Character, Root, Humanoid = nil,nil,nil
    end)
end

RegisterCharacter(Player.Character)
Player.CharacterAdded:Connect(RegisterCharacter)

require(game.ReplicatedStorage.Game.Paraglide).IsFlying = function()
    return tostring(getfenv(2).script) == "Falling"
end

function humanoid()
    if not Player.Character.Humanoid then
         repeat
             wait()
         until Player.Character.Humanoid
         return Player.Character.Humanoid.Sit
     else
         return Player.Character.Humanoid.Sit
    end
 end

 function Humanoid()
    if not Player.Character.Humanoid then
         repeat
             wait()
         until Player.Character.Humanoid
         return Player.Character.Humanoid
     else
         return Player.Character.Humanoid
    end
 end

function tp(ud)
    local StartPos = Root.Position
    local Dir = (ud - StartPos)
    for Lerp = 0, Dir.Magnitude, 4 do
        if game.Players.LocalPlayer.PlayerGui.MainGui.CellTime.Visible == true then
            return
        end
        Root.CFrame = CFrame.new(StartPos) + (Dir.Unit * Lerp)
        Root.Velocity, Root.RotVelocity = Vector3.new(), Vector3.new()
        wait()
    end
    Root.CFrame = CFrame.new(ud)
end

local function GoToNew()
    pcall(
        function()
            if queued == false then
                queued = true
                if syn then
                    syn.queue_on_teleport(
                        crossServerSettings ..
                            " loadstring(game:HttpGet('https://raw.githubusercontent.com/Gork3m/Jailbricked/master/ArrestFarm.lua'))()"
                    )
                else
                    queue_on_teleport(
                        crossServerSettings ..
                            " loadstring(game:HttpGet('https://raw.githubusercontent.com/Gork3m/Jailbricked/master/ArrestFarm.lua'))()"
                    )
                end
            end
        end
    )
end

loadstarted = os.time()
local function checkTimeout()
    if os.time() - loadstarted > 100 then
        GoToNew()
    end
end

while game == nil do
    wait(0.1)
    checkTimeout()
end

while game:GetService("Players") == nil do
    wait(0.1)
    checkTimeout()
end

while game:GetService("Players").LocalPlayer == nil do
    wait(0.1)
    checkTimeout()
end

while game:GetService("Players").LocalPlayer.Character == nil do
    wait(0.1)
    checkTimeout()
end

while game:GetService("Players").LocalPlayer.Character.HumanoidRootPart == nil do
    wait(0.1)
    checkTimeout()
end

function teleport(cframe, type)
    if type == "above" then
        repeat
            Escape()
        until not rayCast(Character.Head.Position + Vector3.new(0, 3, 0), Vector3.new(0, 1000, 0))
        local StartPos = Vector3.new(Root.Position.X, 400, Root.Position.Z)
        local Dir = (Vector3.new(cframe.X, 400, cframe.Z) - StartPos)
        for loop = 0, Dir.Magnitude, 4 do
            if game.Players.LocalPlayer.PlayerGui.MainGui.CellTime.Visible == true then
                return
            end
            Root.CFrame = CFrame.new(StartPos) + Dir.Unit * loop
            Root.Velocity,Root.RotVelocity = Vector3.new(),Vector3.new()
            wait()
        end
        Root.CFrame = CFrame.new(cframe.Position, cframe.p + cframe.LookVector)
    elseif type == "Player" then
        local StartPos = Root.Position
        local Dir = (cframe.p - StartPos)
        for Lerp = 0, Dir.Magnitude, 4 do
            if humanoid() then
                attemptJump()
            end
            if game.Players.LocalPlayer.PlayerGui.MainGui.CellTime.Visible == true then
                return
            end
            Root.CFrame = CFrame.new(StartPos) + (Dir.Unit * Lerp) + cframe.LookVector
            Root.Velocity, Root.RotVelocity = Vector3.new(), Vector3.new()
            wait()
        end
        Root.CFrame = CFrame.new(cframe.Position, cframe.p + cframe.LookVector)
    elseif type == "vehicle" then
        if not Character:FindFirstChild("InVehicle") then
            findEnterVehicle()
        end
        local vehicle = Vehicle().Model
        local Part = vehicle.PrimaryPart
        local StartPos = Vector3.new(Part.Position.X, 400, Part.Position.Z)
        local Dir = (Vector3.new(cframe.X, 400, cframe.Z) - StartPos)
        vehicle:SetPrimaryPartCFrame(CFrame.new(Part.Position + Vector3.new(0, 500, 0)))
        for Lerp = 0, Dir.Magnitude, 16.5 do
            Part.CFrame = CFrame.new(StartPos + (Dir.Unit * Lerp), Vector3.new(cframe.Position.X, Part.Position.Y, cframe.Position.Z) + cframe.LookVector)
            Part.Velocity, Part.RotVelocity = Vector3.new(), Vector3.new()
            wait()
        end
        vehicle:SetPrimaryPartCFrame(CFrame.new(cframe.Position, cframe.p + cframe.LookVector))
    elseif type == "Sell" then
        if not Character:FindFirstChild("InVehicle") then
            findEnterVehicle()
        end
        if game.Players.LocalPlayer.PlayerGui.MainGui.CellTime.Visible == true then
            return
        end
        if Character:FindFirstChild("Handcuffs") then
            Character.Handcuffs.AncestryChanged:Wait()
            return
        end
        local vehicle = Vehicle().Model
        local Part = vehicle.PrimaryPart
        local StartPos = Vector3.new(Part.Position.X, 25, Part.Position.Z)
        local Dir = (Vector3.new(cframe.X, 25, cframe.Z) - StartPos)
        vehicle:SetPrimaryPartCFrame(CFrame.new(Part.Position + Vector3.new(0, 500, 0)))
        for Lerp = 0, Dir.Magnitude, 10 do
            Part.CFrame = CFrame.new(StartPos + (Dir.Unit * Lerp), Vector3.new(cframe.Position.X, Part.Position.Y, cframe.Position.Z) + cframe.LookVector)
            Part.Velocity, Part.RotVelocity = Vector3.new(), Vector3.new()
            wait()
        end
        vehicle:SetPrimaryPartCFrame(CFrame.new(cframe.Position, cframe.p + cframe.LookVector))
    elseif type == "Instant" then
        repeat
            Root.CFrame = CFrame.new(210.559357, 62.6357574, 1189.24231)
            wait(0.3)
        until (Root.Position - Vector3.new(211.285919, 62.6357574, 1189.2406)).Magnitude < 5
        teleport(CFrame.new(224.413406, 62.4052505, 1116.89038), "Player")
        teleport(CFrame.new(177.133148, 62.6849442, 1114.54492), "Player")
    elseif type == "path" then
        for i,v in pairs(cframe) do
            tp(v + Vector3.new(0, 3, 0))
        end
    end
end

function rayCast(Pos, Dir)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {Character, workspace:FindFirstChild("Rain"), workspace.Trains}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    workspace.ChildAdded:Connect(function(child) -- if it starts raining, add rain to collision ignore list
        if child.Name == "Rain" then 
            table.insert(raycastParams.FilterDescendantsInstances, child);
        end;
    end);
    Player.CharacterAdded:Connect(function(character) -- when the player respawns, add character back to collision ignore list
        table.insert(raycastParams.FilterDescendantsInstances, character);
    end);
	return workspace:Raycast(Pos, Dir, raycastParams)
end

function PathFind(Start, Destination, Params)
    Params = Params or {}
    local DefaultParams = {
        AgentCanJump = true,
        AgentHeight = 5,
        AgentRadius = 2,
        WaypointSpacing = 4
    }
    for k, v in pairs(DefaultParams) do
        Params[k] = Params[k] or DefaultParams[k]
    end
    local Path = PathfindingService:CreatePath(Params)
    local success = pcall(function()
        Path:ComputeAsync(Start, Destination)
    end)
    if success then
        if Path.Status == Enum.PathStatus.Success then
            return Path:GetWaypoints()
        else
            return nil
        end
    else
        return nil
    end
end

function FindEscape()
	local topRoofPosition = rayCast(Root.Position + Vector3.new(0, 1000, 0), Vector3.new(0, -2000, 0)).Position
	local Path = PathFind(topRoofPosition, Root.Position)
	if Path then
		local Waypoints = Path
		local escapePath = {}
		for i = #Waypoints, 1, -1 do
			table.insert(escapePath, Waypoints[i].Position)
			if not rayCast(Waypoints[i].Position, Vector3.new(0, 1000, 0)) then
                table.insert(escapePath, Waypoints[i].Position + Vector3.new(5, 0, 0))
				return escapePath
			end
		end
    else
        return nil
	end
end

function Escape()
    if Character:FindFirstChild("Humanoid").Health == 0 then
        repeat
            wait()
        until humanoid()
        --wait(8)
    end
	if not rayCast(Character.Head.Position + Vector3.new(0, 3, 0), Vector3.new(0, 1000, 0)) then return end
    local escapePath = FindEscape()
    if escapePath then
        teleport(escapePath, "path")
        return true
    else
        return false
    end
end

function isVehicle(v)
    return v and v:FindFirstChild("Engine") and v:FindFirstChild("Seat") and v.Seat:FindFirstChild("PlayerName") and v.Seat:FindFirstChild("Player")
end

function getNearestVehicle(minDistance)
    local nearest,minDistance = nil, minDistance or 9e9
    for i, v in pairs(workspace.Vehicles:GetChildren()) do
        if table.find(FreeVehicles, v.Name) and not table.find(BlacklistVehicles, v) and isVehicle(v) and v.Seat.Player.Value == false then
            if not rayCast(v.Seat.Position + Vector3.new(0, 3, 0), Vector3.new(0, 1000, 0)) then                
                local distance = (v.Engine.Position - Root.Position).Magnitude
                if distance < minDistance then
                    nearest,minDistance = v,distance
                end
            end
        end
    end
    return nearest
end

function getNearestSpawn()
    local nearest,minDistance = nil, 9e9
    for i, v in pairs(workspace.VehicleSpawns:GetChildren()) do
        if table.find(FreeVehicles, v.Name) and v:FindFirstChild("Region") then
            local distance = (v.Region.Position - Root.Position).Magnitude
            if table.find(FreeVehicles, v.Name) and distance < minDistance then
                if not rayCast(v.Region.Position + Vector3.new(0, 3, 0), Vector3.new(0, 1000, 0)) then                
                    nearest,minDistance = v,distance
                end
            end
        end
    end
    return nearest
end

function findEnterVehicle()
    local keys, network = loadstring(game:HttpGet("https://raw.githubusercontent.com/JerryWasTaken/Minihub/main/Keys.lua"))()
    if Character:FindFirstChild("InVehicle") then return end
    if Character:FindFirstChild("Handcuffs") then return end
    local nearestSpawn = getNearestSpawn()
    local nearestVehicle = getNearestVehicle()
    local SpawnDistance = (nearestSpawn.Region.Position - Root.Position).Magnitude
    local VehicleDistance do
        if nearestVehicle ~= nil then
            VehicleDistance = (nearestVehicle.Engine.Position - Root.Position).Magnitude
        end
    end
    if nearestVehicle == nil or (VehicleDistance - 300 > SpawnDistance) then            
        repeat
            if (nearestSpawn.Region.Position - Root.Position).Magnitude > 10 then
                teleport(nearestSpawn.Region.CFrame, "above")
            end
            wait(0.5)
        until getNearestVehicle(10) or Character:FindFirstChild("Handcuffs")
    else
        teleport(nearestVehicle.Camera.CFrame, "above")
    end
    if Character:FindFirstChild("Handcuffs") then
        return
    end
    if nearestVehicle then
        local skipThisCar = false
        local EnterAttempts = 0
        local TeleportAttempts = 0
        repeat
            if not nearestVehicle then
                repeat wait() until nearestVehicle
            end
            repeat wait() until Humanoid 
            for i,v in pairs(Specs) do
                if (v.Name == "Hijack") and v.Part == nearestVehicle:FindFirstChild("Seat") then
                    v:Callback(true)
                end
            end
            network:FireServer(keys.EnterCar, nearestVehicle, nearestVehicle.Seat)
            wait()
            wait(0.1)
            if Player.PlayerGui.NotificationGui.ContainerNotification.Message.Text:match("Cannot use vehicle here") and game:GetService("Players").LocalPlayer.PlayerGui.NotificationGui.Enabled then
                Player.PlayerGui.NotificationGui.Enabled = false
                table.insert(BlacklistVehicles, nearestVehicle)
            end
            for i,v in pairs(Player.PlayerGui:GetDescendants()) do
                if v:IsA("TextLabel") then
                    if v.Text:match("That vehicle is locked") and v.Visible then
                        table.insert(BlacklistVehicles, nearestVehicle)
                        v.Visible = false
                        break
                    end
                end
            end
        until table.find(BlacklistVehicles, v) or not isVehicle(nearestVehicle) or nearestVehicle.Seat.Player.Value or Character:FindFirstChild("Handcuffs")
	end
end

function attemptSell()
    local attempts = 0
    if not Player.PlayerGui.RobberyMoneyGui.Enabled then return end
    repeat
        teleport(CFrame.new(2280, 23, -2064), "vehicle")
        wait(1)
        teleport(CFrame.new(2227, 19, -2455), "Sell")
        wait(2.5)
		teleport(CFrame.new(2292, 19, -2588), "Sell")
		wait(3)
		teleport(CFrame.new(2227, 19, -2455), "Sell")
        wait(2)
		teleport(CFrame.new(2280, 23, -2064), "Sell")
        wait(1)
        if isBagFull() then
            attempts = attempts + 1
        end
    until not isBagFull() or not Player.PlayerGui.RobberyMoneyGui.Enabled
    if attempts == 3 then
        game.Players.LocalPlayer.Character:BreakJoints()
        wait(8)
        return
    end
end

local function Ub(mc)
    local nc = game:GetService("Teams").Police:GetPlayers()
    for oc = 1, #nc do
        local pc = nc[oc]
        if pc.Character and pc.Character:FindFirstChild("HumanoidRootPart") and pc.Character:FindFirstChild("Humanoid") then
            local qc = pc.Character.HumanoidRootPart.Position
            if (Root.Position - qc).Magnitude < mc then
                return true
            end
        end
    end
end

local function getUraniumValue()
    return tonumber(table.concat({ string.match(Player.PlayerGui.PowerPlantRobberyGui.Price.TextLabel.Text, "Uranium Value: $(%d),(%d+)") }, ""))
end

function Instant(cf)
    if not Character:FindFirstChild("InVehicle") then findEnterVehicle() end
    local root = Vehicle().Model.PrimaryPart
    repeat
        root.CFrame = cf
        wait()
    until root.CFrame == cf
end

function SellUranium()
	local powerPlant = Player.PlayerGui:FindFirstChild("PowerPlantRobberyGui")
	local attempts = 0
    repeat
		teleport(CFrame.new(2280, 23, -2064), "vehicle")
        wait(0.5)
		teleport(CFrame.new(2227, 19, -2455), "Sell")
        repeat task.wait() until Player.PlayerGui:FindFirstChild("PowerPlantRobberyGui") == nil or getUraniumValue() <= 6000
		teleport(CFrame.new(2292, 19, -2588), "Sell")
		wait(1)
		teleport(CFrame.new(2227, 19, -2455), "Sell")
		teleport(CFrame.new(2280, 23, -2064), "Sell")
        if isBagFull() or powerPlant then
            attempts = attempts + 1
        end
	until (not Player.PlayerGui:FindFirstChild("PowerPlantRobberyGui")) or (not powerplant and not isBagFull()) or attempts == 3
    if attempts == 3 then
        game.Players.LocalPlayer.Character:BreakJoints()
        wait(8)
        return
    end
end


function isBagFull()
    if not Player.PlayerGui.RobberyMoneyGui.Enabled then
        return false
    end
    local moneys = string.split(Player.PlayerGui.RobberyMoneyGui.Container.Bottom.Progress.Amount.Text, " / ")
    return moneys[1] == moneys[2]
end

local mainlocalscr = game.Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("LocalScript")
local markersystem = game.ReplicatedStorage:WaitForChild("Game"):WaitForChild("RobberyMarkerSystem")
local robconsts = require(game.ReplicatedStorage.Robbery:WaitForChild("RobberyConsts"))

local Value = {
    Museum = false,
    Donut = false,
    PowerPlant = false,
    CargoShip = false,
    Gas = false,
    Jewelry = false,
    TrainPassenger = false,
    TrainCargo = false,
    CargoPlane = false,
    Casino = false,
    Bank = false,
    Drops = false
}

local robstates = {}
local roblabels = {}

local LPH_ENCSTR = function(...) return ... end
local LPH_JIT_ULTRA = function(...) return ... end

local garbage, hasbypassedac = LPH_JIT_ULTRA(function()
    local cache = {}
    local hasbypassedac = false
    for i, v in next, getgc() do
        if type(v) == "function" and islclosure(v) then
            local scr = getfenv(v).script
            if scr == markersystem and getinfo(v).name == "setRobberyMarkerState" then
                cache.markerstates = getupvalue(v, 1)
            end
        end
    end
    return cache, hasbypassedac
end)()

local function updaterobbery(name, pretty, val)
    local isopen = val.Value ~= robconsts.ENUM_STATUS.CLOSED
    robstates[name] = isopen
    Value[name] = isopen and true or false 
end

local function registerrobbery(val)
    local name, pretty = garbage.markerstates[tonumber(val.Name)].Name, robconsts.PRETTY_NAME[tonumber(val.Name)]
    updaterobbery(name, pretty, val)
    val:GetPropertyChangedSignal("Value"):Connect(function()
        updaterobbery(name, pretty, val)
    end)
end

local function console(text, color)
    if color then rconsoleprint('@@'.. color .. '@@') end
    if not color then rconsoleprint('@@WHITE@@') end
    rconsoleprint(("%s\n"):format(text))
end

function connectStep(name, func)
    Stepped[name] = game.RunService.Stepped:Connect(func)
end
function disconnectStep(name)
    if Stepped[name] then
		Stepped[name]:Disconnect()
	end
end

function FindHeli()
    local Region = {
        CFrame.new(-1192.51233, 43.27742, -1583.03906),
        CFrame.new(210.372711, 84.5349655, 1104.79517),
        CFrame.new(837.670166, 21.9434853, -3643.55566)
    }
    local Helis = {
        CFrame.new(-1167.2196, 57.3966217, -1564.61877),
        CFrame.new(186.251709, 62.4349518, 1092.57568),
        CFrame.new(854.998535, 19.3194942, -3681.85767)
    }
    local dd = game:GetService("Workspace").VehicleSpawns:GetChildren()	
    local attempts = 1
    table.sort(dd, 
        function(vq, v2) 
            local v3 = vq:FindFirstChild("Region")
            local v4 = v2:FindFirstChild("Region")
    
            if v3 ~= nil and v4 ~= nil  then
            return (v3.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude < 
            (v4.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude 
        end
    end)
    repeat		
        teleport(Region[attempts], "vehicle")
        attemptJump()
        teleport(Helis[attempts], "above")
        wait(1)
        print(attempts)
        wait(0.1)
        for i,v in pairs(game.Workspace.Vehicles:GetChildren()) do
            if v:FindFirstChild("Seat") then
                if v.Name == "Heli" then
                    for _,d in pairs(require(game:GetService("ReplicatedStorage").Module.UI).CircleAction.Specs) do
                        if d.Part == v.Seat then
                            d:Callback(true)
                        end
                    end
                end
            end
        end
        wait(8)
        if humanoid() == true then return end
        attempts = attempts + 1
        if attempts == 4 then
            repeat
                for i,v in pairs(game.Workspace.Vehicles:GetChildren()) do
                    if v:FindFirstChild("Seat") then
                        if v.Name == "Heli" then
                            for _,d in pairs(require(game:GetService("ReplicatedStorage").Module.UI).CircleAction.Specs) do
                                if d.Part == v.Seat then
                                    d:Callback(true)
                                end
                            end
                        end
                    end
                end
                wait()
            until humanoid()== true
            return
        end
    until humanoid() == true
end

function attemptJump()
    repeat
        game.VirtualInputManager:SendKeyEvent(true, "Space", false, game)
        wait()
        game.VirtualInputManager:SendKeyEvent(false, "Space", false, game)
		wait(0.5)
    until not humanoid()
end

function G_11_()
    wait(0.3)
    local safePlatform = workspace:FindFirstChild("PlatformPart") or Instance.new("Part", workspace)
    safePlatform.Name = "PlatformPart"
    safePlatform.Anchored = true
    safePlatform.Size = Vector3.new(300, 1, 300)
    safePlatform.Position = Vector3.new(Root.Position.X, 300, Root.Position.Z)
    if Vehicle() then
      Vehicle().Model:SetPrimaryPartCFrame(CFrame.new(Root.Position.X, 305, Root.Position.Z))
    else
      game:GetService("Players").LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(Root.Position.X, 310, Root.Position.Z))
    end
end

local function path(target)
    local dpath = PathfindingService:CreatePath({WaypointSpacing = 3})
    local path = dpath;
    path:ComputeAsync(Root.Position, target);

    if path.Status == Enum.PathStatus.Success then -- if path making is successful
        local waypoints = path:GetWaypoints();

        for index = 1, #waypoints do 
            local waypoint = waypoints[index];
            teleport(CFrame.new(waypoint.Position + Vector3.new(0, 4, 0)), 0, "Player"); -- walking movement is less optimal
            --task.wait(0.05);
        end
    end
end

local function pressKey(key)
    game.VirtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait()
    game.VirtualInputManager:SendKeyEvent(false, key, false, game)
end


rconsolename("Jailnoob Group - https://discord.gg/KH6aU7HyBz")
rconsoleprint('@@MAGENTA@@')
console("Thanks for using Jailnoob", "MAGENTA")
rconsoleprint('@@WHITE@@')
console("This project is brought to you by:")
wait(1)
console("Jerry")
wait(1)
console("Mini")

function robTrain()
    if not rayCast(Character.Head.Position + Vector3.new(0, 3, 0), Vector3.new(0, 1000, 0)) then end
    if Character:FindFirstChild("InVehicle") then attemptJump() end
    console("Teleporting To Box Train", "BLUE")
    local BoxCar 
    for i,v in pairs(workspace.Trains:GetChildren()) do
        if v.Name:match("BoxCar") then
            BoxCar = v
        end
    end
    local Vault = BoxCar.Model.Rob.Gold
    Root.CFrame = Root.CFrame + Vector3.new(0, 500, 0)
    wait(1)
    console("Collecting Cash")
    connectStep("Vault", function()
        Root.CFrame = CFrame.new(Vault.Position + Vector3.new(0, 3, 0))
    end)
    if (Vault.Position - Root.Position).Magnitude > 5 then
        repeat
            wait()
        until (Vault.Position - Root.Position).Magnitude < 5
    end
    for i,v in pairs(Specs) do
        if v.Name == "Open Door" and BoxCar:IsAncestorOf(v.Part) then
            v:Callback(true)
            break
        end
    end
    for i,v in pairs(Specs) do
        if v.Name == "Breach Vault" and BoxCar:IsAncestorOf(v.Part) then
            v:Callback(true)
            break
        end
    end
    repeat
        wait()
    until isBagFull() or Player.Team.Name == "Prisoner" or Humanoid().Health == 0 or (Vector3.new(-1662, 42, 267) - Vault.Position).Magnitude < 20
    disconnectStep("Vault")
    if (Vector3.new(2533.67358, 19.6808662, -2876.81226) - Vault.Position).Magnitude < 20 then
        repeat task.wait() until (Vector3.new(2442.15649, 19.2093182, -2124.89478) - Vault.Position).Magnitude < 1
    end
    if rayCast(Character.Head.Position + Vector3.new(0, 3, 0), Vector3.new(0, 1000, 0)) then
        console("Waiting for train to leave tunnel.")
        repeat wait() until not rayCast(Character.Head.Position + Vector3.new(0, 3, 0), Vector3.new(0, 1000, 0))
        wait(0.5)
    end
    findEnterVehicle()
    console("Box Train Done.", "GREEN")
    G_11_()
    Value.TrainCargo = false
end

function robPassenger()
    console("Robbing Steam Train", "BLUE")
    for n = 1, 5 do
        for i, v in next, require(game:GetService("ReplicatedStorage").Module.UI).CircleAction.Specs do
            if v.Name == "Grab briefcase" then
                task.wait(v.Duration)
                v:Callback(true)
                task.wait(1)
                if Value.TrainPassenger == false then return end
                if Player.Team.Name == "Prisoner" then return end
            end
        end
    end
    console("Selling")
    attemptSell()
    console("Steam Train Done.")
    G_11_()
    Value.TrainPassenger = false
end

function robGas()
    console("Teleporting To Gas Station", "BLUE")
    teleport(CFrame.new(-1538.0172119140625, 18.039798736572266, 703.547607421875), "vehicle")
    wait(0.3)
    attemptJump()
    teleport(CFrame.new(-1595.80884, 18.4961395, 710.339294), "Player")
    teleport(CFrame.new(-1599.28296, 18.4961395, 686.888794), "Player")
    console("Robbing Gas")
    wait(2)
    for fd, fe in pairs(require(game:GetService("ReplicatedStorage").Module.UI).CircleAction.Specs) do
        if fe.Name == "Rob" and (fe.Part.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 30 then
        fe:Callback()
        console("Bypassing Time Anti Cheat")
        wait(fe.Duration)
        fe:Callback(true)
        end
    end
    teleport(CFrame.new(-1587.27197, 18.4961395, 689.059143), "Player")
    teleport(CFrame.new(-1584.7467, 18.4961395, 708.507629), "Player")
    teleport(CFrame.new(-1538.0172119140625, 18.039798736572266, 703.547607421875), "Player")
    console("Gas Station Success!", "GREEN")
    findEnterVehicle()
    G_11_()
    Value.Gas = false
end

function robDonut()
    Escape()
    console("Teleporting To Donut Store", "BLUE")
	teleport(CFrame.new(121, 20, -1637), "vehicle")
	wait(0.5)
	attemptJump()
	Root.CFrame = CFrame.new(121, 20, -1632)
	wait(0.5)
	teleport(CFrame.new(109, 22, -1587), "Player")
	teleport(CFrame.new(85, 20, -1596), "Player")
    console("Robbing Donut")
	for i,v in pairs(require(game.ReplicatedStorage.Module.UI).CircleAction.Specs) do
		if v.Name == "Rob" and (v.Part.Position - Root.Position).Magnitude < 20 then
			v:Callback()
            console("Bypassing Time Anti Cheat")
			wait(v.Duration)
			v:Callback(true)
			break
		end
	end
    wait(0.3)
	teleport(CFrame.new(109, 22, -1587), "Player")
	teleport(CFrame.new(121, 20, -1637), "Player")
    console("Donut Done.", "GREEN")
    wait(0.4)
    findEnterVehicle()
    G_11_()
	Value.Donut = false
end

function robPlane()
    if not Value.CargoPlane then return end
    findEnterVehicle()
    console("Robbing Plane.", "BLUE")
	local Q = {}
    local Y = game:GetService("RunService").Stepped
    local Q = Vehicle().Model.PrimaryPart
    local O = Y:Connect(function()
        Q.CFrame = game:GetService("Workspace"):FindFirstChild("Plane").Root.CFrame + Vector3.new(0, 10, 0)
        Q.Velocity, Q.RotVelocity = Vector3.new(), Vector3.new()
    end)
    console("Grabbing Crate.")
    repeat
        for i, v in pairs(require(game:GetService("ReplicatedStorage").Module.UI).CircleAction.Specs) do
            if v.Name == "Inspect Crate" then
                v:Callback(true)
            end
        end
        wait(0.1)
    until isBagFull()
    O:Disconnect()
	if isBagFull() then
		wait(0.1)
		repeat
			teleport(CFrame.new(-342, 26, 2015), "vehicle")
			wait(3)
			teleport(CFrame.new(-342, 26, 2051), "vehicle")
			wait(2)
		until not isBagFull()
	end
    console("Plane Done.")
    G_11_()
	Value.CargoPlane = false
end

function robPower()
    console("Teleporting to PowerPlant", "BLUE")
    teleport(CFrame.new(63, 23, 2344), "vehicle")
    wait(0.5)
	attemptJump()
    wait(0.5)
	teleport(CFrame.new(89, 23, 2326), "Player")
    task.wait(0.5)
	connectStep("openPuzzle", function()
		Root.CFrame = CFrame.new(89, 23, 2326)
	end)
    if Value.PowerPlant == false then return end
    if game.Players.LocalPlayer.Team == "Prisoner" then return end
    repeat wait() until Puzzle.IsOpen or not Value.PowerPlant
    if not Value.PowerPlant or game.Players.LocalPlayer.Team == "Prisoner" then
		disconnectStep("openPuzzle")
        wait(1)
        return
    end
    console("Solving Puzzle 1/2")
    if Puzzle.IsOpen then
        for i,v in pairs(Puzzle.Grid) do
            for i2,v2 in pairs(v) do
                v[i2] = v2 + 1
            end
        end
        local solution = game.HttpService:JSONDecode((syn and syn.request or http_request or request)({
            Url = "https://numberlink-solver.sagesapphire.repl.co",
            Method = "POST",
            Body = game.HttpService:JSONEncode({
                Matrix = Puzzle.Grid
            }),
            Headers = {
                ["Content-Type"] = "application/json"
            }
        }).Body).Solution
        for i,v in pairs(solution) do
            for i2,v2 in pairs(v) do
                v[i2] = v2 - 1
            end
        end
        Puzzle.Grid = solution
        Puzzle.OnConnection()
        repeat wait() until not Puzzle.IsOpen
    end
    disconnectStep("openPuzzle")
    teleport(CFrame.new(95, 26, 2334), "Player")
    teleport(CFrame.new(145, 26, 2290), "Player")
    teleport(CFrame.new(206, 21, 2241) + Vector3.new(0, -2, 0), "Player")
    teleport(CFrame.new(143, -3, 2095) + Vector3.new(0, -2, 0), "Player")
    teleport(CFrame.new(120, -9, 2100) + Vector3.new(0, -2, 0), "Player")
    repeat wait() until Puzzle.IsOpen or Value.PowerPlant == false
    if Value.PowerPlant == false then
        return
    end
    console("Solving Puzzle 2/2")
    if Puzzle.IsOpen then
        for i,v in pairs(Puzzle.Grid) do
            for i2,v2 in pairs(v) do
                v[i2] = v2 + 1
            end
        end
        wait(2.5)
        local solution = game.HttpService:JSONDecode((syn and syn.request or http_request or request)({
            Url = "https://numberlink-solver.sagesapphire.repl.co",
            Method = "POST",
            Body = game.HttpService:JSONEncode({
                Matrix = Puzzle.Grid
            }),
            Headers = {
                ["Content-Type"] = "application/json"
            }
        }).Body).Solution
        for i,v in pairs(solution) do
            for i2,v2 in pairs(v) do
                v[i2] = v2 - 1
            end
        end
        wait(2.5)
        Puzzle.Grid = solution
        Puzzle.OnConnection()
        repeat wait() until not Puzzle.IsOpen
    end
    wait(0.1)
    local keys, network = loadstring(game:HttpGet("https://raw.githubusercontent.com/JerryWasTaken/Minihub/main/Keys.lua"))()
    if Player.Team.Name == "Criminal" then
        network:FireServer(keys.SwitchTeam)
        network:FireServer(keys.JoinTeam, "Prisoner")
        wait(8)
    end
    wait(2.5)
    console("Selling.")
	if Player.PlayerGui:FindFirstChild("PowerPlantRobberyGui") then
		SellUranium()
	end
    findEnterVehicle()
    console("PowerPlant Done.", "GREEN")
    G_11_()
	Value.PowerPlant = false
end

function robJew()
    for i, v in next, Jewelry:GetDescendants() do
        if (v.ClassName == "TouchInterest" or v.ClassName == "TouchTransmitter") and v.Parent.Name ~= "LaserTouch" then
            v.Parent:Destroy()
        end
    end
    console("Teleporting To Jewelry", "BLUE")
    teleport(CFrame.new(84.3588409, 18.2111111, 1311.39929), "vehicle")
    wait(0.5)
    attemptJump()
    Root.CFrame = CFrame.new(91.1881866, 18.5956364, 1311.01477)
    wait(1)
    Root.CFrame = CFrame.new(100.253342, 18.607439, 1310.19824)
    wait(1)
    local Boxes = {
        CFrame.new(104.515007, 19.0133152, 1283.33923, 0.983205616, 1.00652675e-09, 0.182501182, 2.47286858e-10, 1, -6.84741064e-09, -0.182501182, 6.77754297e-09, 0.983205616),
        CFrame.new(115.764389, 18.607439, 1281.91919, 0.979889035, -1.8629601e-08, 0.199543282, 3.73196407e-08, 1, -8.99028265e-08, -0.199543282, 9.55416724e-08, 0.979889035),
        CFrame.new(126.281631, 18.607439, 1280.43823, 0.982408583, -1.07418444e-07, 0.186744079, 1.01500589e-07, 1, 4.12510843e-08, -0.186744079, -2.1570786e-08, 0.982408583),
        CFrame.new(139.309769, 18.607439, 1277.91589, 0.984579325, 1.05420888e-07, 0.174938649, -1.06150068e-07, 1, -5.18881027e-09, -0.174938649, -1.34609541e-08, 0.984579325),
        CFrame.new(150.718018, 18.607439, 1292.91675, 0.149938837, 3.1444356e-09, -0.988695264, -1.14559732e-07, 1, -1.4192965e-08, 0.988695264, 1.15392744e-07, 0.149938837),
        CFrame.new(153.378403, 18.607439, 1308.36462, 0.195775896, -4.58642084e-08, -0.980648637, -4.2113065e-08, 1, -5.51766739e-08, 0.980648637, 5.21003827e-08, 0.195775896)
    }
    local boxes = Jewelry:FindFirstChild("Boxes"):GetChildren()
    local box
    local a = 1
    print("hi")
    console("Punching boxes")
    while not isBagFull() and Value.Jewelry do
        teleport(Boxes[a], "Player")
        table.sort(boxes, function(a, b)
            return (a.Position - Root.Position).Magnitude < (b.Position - Root.Position).Magnitude and a.Position.Y < 20
        end)
        local box
        for i,v in pairs(boxes) do
            if v.Transparency < 0.9 then
                box = v
                break
            end
        end
        wait(0.5)
        for i,v in pairs(boxes) do
            if v.Transparency ~= 1 then
                for i = 1, 5 do
                    pressKey("F")
                    wait(0.5)
                end
                break
            else
                break
            end
        end
        a = a + 1
        if a == 6 and not isBagFull then
            return
        end
    end
    if isBagFull() then
        repeat
            Root.CFrame = CFrame.new(-87.2522202, 108.935295, 991.435364)
            pressKey("A")
            wait(0.2)
        until (Vector3.new(-74.3804703, 18.568058, 1028.31873) - Root.Position).Magnitude < 5
        console("Selling.")
        repeat
            teleport(CFrame.new(-247, 18, 1616), "above")
			wait(1)
        until not isBagFull()
    end
    console("Jewelry Done.", "GREEN")
    G_11_()
    Value.Jewelry = false
end

function robMus()
    console("Teleporting To Museum", "BLUE")
    Instant(CFrame.new(1100.63196, 106.056938, 1283.68518))
	wait(0.5)
	attemptJump()
	teleport(CFrame.new(1127, 110, 1304) + Vector3.new(0, 4, 0), "Player")
    console("Grabbing bones")
    repeat
        for i,v in pairs(Specs) do
            if v.Name:match("Grab Bone") then
                v:Callback(true)
                wait(0.5)
            end
        end
    until isBagFull() or game.Players.LocalPlayer.Team.Name == "Prisoner" or not Value.Museum
	teleport(CFrame.new(1056, 106, 1247), "Player")
    console("Selling.")
	if isBagFull() then
        attemptSell()
	end
    console("Museum Done.", "GREEN")
    findEnterVehicle()
    G_11_()
	Value.Museum = false
end

function robShip()
    local tp2 = loadstring(game:HttpGet("https://raw.githubusercontent.com/JerryWasTaken/Minihub/main/teleport2.lua"))()
    FindHeli()
    pressKey("G")
    local currentVehicle = Vehicle().Model
    local root = currentVehicle.PrimaryPart
    local ShipCrate = game.Workspace.CargoShip.Crates:GetChildren()[1].MeshPart
    if ShipCrate then
        for i = 1, 1 do
            local ShipCrate = game.Workspace.CargoShip.Crates:GetChildren()[math.random(2)].MeshPart
            print("Grabbing Crate ".. i .. "/2")
            local Vehicle = Vehicle().Model
            local PrimaryPart = Vehicle.PrimaryPart
            local Q = {}
            local Y = game:GetService("RunService").Stepped
            local Q = Vehicle
            for _, v in next, game.CollectionService:GetTagged("HeliPickup") do
                if v.Name == "Crate" then
                    ShipPickup = v
                    break
                end
            end
            local balls = game.Workspace.CargoShip.Crates:GetChildren()[1]
            local balls2 = balls.MeshPart
            repeat
                if game.Players.LocalPlayer.Character:FindFirstChild("InVehicle") then
                    local currentVehicle = Vehicle
                    local root = currentVehicle.PrimaryPart
                    local Y = math.random(300, 400)
                    repeat
                        if not game.Players.LocalPlayer.Character:FindFirstChild("InVehicle") then
                            break
                        end
                        local Dir = (Vector3.new(balls2.Position.X, Y, balls2.Position.Z) - Vector3.new(root.Position.X, Y, root.Position.Z))
                        Vehicle:SetPrimaryPartCFrame(CFrame.new(root.Position.X, Y, root.Position.Z) + (Dir.Unit * 11))
                        wait()
                    until rayCast(balls2.Position, Vector3.new(0, Y-10, 0)) and (Vector3.new(balls2.Position.X, Y, balls2.Position.Z) - Vector3.new(root.Position.X, Y, root.Position.Z)).Magnitude < 11
                    Vehicle:SetPrimaryPartCFrame(CFrame.new(balls2.Position + Vector3.new(0, 3, 0)))
                end
            until (balls2.Position - Root.Position).Magnitude < 20
            wait(0.5)
            connectStep("ShipCrate", function()
                Q:SetPrimaryPartCFrame(balls2.CFrame + Vector3.new(0, 39, 0))
            end)
            wait(6)
        --[[ repeat
                wait(0.3)
            until GetLocalVehiclePacket().Model.Preset:FindFirstChild("RopePull").AttachedTo.Value == "Crate"--]]
            disconnectStep("ShipCrate")
            wait()
            print("Not yet pressed")
            pressKey("G")
            print("pressed")
            wait()
            balls:SetPrimaryPartCFrame(
                CFrame.new(-468.714783, 9.1156683, 1905.35339)
            )
        end
        wait(1)
        for i = 1, 1 do
            local ShipCrate = game.Workspace.CargoShip.Crates:GetChildren()[math.random(2)].MeshPart
            print("Grabbing Crate ".. i .. "/2")
            local Vehicle = Vehicle().Model
            local PrimaryPart = Vehicle.PrimaryPart
            local Q = {}
            local Y = game:GetService("RunService").Stepped
            local Q = Vehicle().Model.PrimaryPart
            for _, v in next, game.CollectionService:GetTagged("HeliPickup") do
                if v.Name == "Crate" then
                    ShipPickup = v
                    break
                end
            end
            pressKey("G")
            wait()
            local balls = game.Workspace.CargoShip.Crates:GetChildren()[2]
            local balls2 = balls.MeshPart
            repeat
                if game.Players.LocalPlayer.Character:FindFirstChild("InVehicle") then
                    local currentVehicle = Vehicle().Model
                    local root = currentVehicle.PrimaryPart
                    local Y = math.random(300, 400)
                    repeat
                        if not game.Players.LocalPlayer.Character:FindFirstChild("InVehicle") then
                            break
                        end
                        local Dir = (Vector3.new(balls2.Position.X, Y, balls2.Position.Z) - Vector3.new(root.Position.X, Y, root.Position.Z))
                        root.CFrame = CFrame.new(root.Position.X, Y, root.Position.Z) + (Dir.Unit * 11)
                        wait()
                    until rayCast(balls2.Position, Vector3.new(0, Y-10, 0)) and (Vector3.new(balls2.Position.X, Y, balls2.Position.Z) - Vector3.new(root.Position.X, Y, root.Position.Z)).Magnitude < 11
                    root.CFrame = CFrame.new(balls2.Position + Vector3.new(0, 3, 0))
                end
            until (balls2.Position - Root.Position).Magnitude < 20
            wait(0.5)
            connectStep("ShipCrate", function()
                Q.CFrame = balls2.CFrame + Vector3.new(0, 39, 0)
            end)
            wait(6)
        --[[ repeat
                wait(0.3)
            until GetLocalVehiclePacket().Model.Preset:FindFirstChild("RopePull").AttachedTo.Value == "Crate"--]]
            disconnectStep("ShipCrate")
            wait()
            print("Not yet pressed")
            pressKey("G")
            print("pressed")
            wait()
            balls:SetPrimaryPartCFrame(
                CFrame.new(-468.714783, 9.1156683, 1905.35339)
            )
        end
        tp2(CFrame.new(-307.427521, 18.2636909, 1599.08606))
        attemptJump()
        wait(0.5)
        findEnterVehicle()
    end
end

local BankPaths = {
    ["01UpperManagement"] = {
        CFrame.new(86.6891632, 27.7893982, 919.55304) + Vector3.new(0, 5, 0),
        CFrame.new(85.0449219, 30.3203545, 901.631714) + Vector3.new(0, 5, 0),
        CFrame.new(75.7619019, 37.149868, 889.624817) + Vector3.new(0, 5, 0),
        CFrame.new(78.9199753, 44.9200134, 873.116943) + Vector3.new(0, 5, 0),
        CFrame.new(70.3065491, 51.392189, 861.531677) + Vector3.new(0, 5, 0),
        CFrame.new(74.8635941, 56.245945, 850.862122) + Vector3.new(0, 5, 0),
        CFrame.new(70.0843048, 60.2341843, 832.451355) + Vector3.new(0, 5, 0),
        CFrame.new(27.1561337, 60.2341919, 841.806702) + Vector3.new(0, 5, 0),
        CFrame.new(32.7206306, 60.2341843, 862.579102) + Vector3.new(0, 5, 0),
        CFrame.new(53.7243156, 60.2341843, 863.99054) + Vector3.new(0, 5, 0),
        CFrame.new(57.5389671, 60.2341843, 886.989746) + Vector3.new(0, 5, 0),
        CFrame.new(37.8139915, 60.2341881, 895.217529) + Vector3.new(0, 5, 0),
        CFrame.new(44.8027611, 60.2341843, 925.830383) + Vector3.new(0, 5, 0),
    },
    ["02Basement"] = {
        CFrame.new(50.3702354, 18.736063, 924.43042),
        CFrame.new(85.4746323, 9.23804665, 918.503845),
        CFrame.new(94.6071091, -0.661975741, 965.972412),
        CFrame.new(60.2607765, -8.71194172, 948.01532)
    },
    ["03Corridor"] = {
        CFrame.new(56.2616272, 18.0231895, 923.147156),
        CFrame.new(56.2616272, 18.0231895, 923.147156) + Vector3.new(0, -5, 0),
        CFrame.new(57.0027695, -7.91255093, 926.284119),
    },
    ["05Underwater"] = {
        CFrame.new(56.3401031, 18.7390518, 923.530212),
        CFrame.new(101.456192, 1.4882617, 915.283875),
        CFrame.new(96.2809219, -12.8460102, 880.283936),
        CFrame.new(93.3022919, -12.8507042, 855.341309)
    },
    ["06TheBlueRoom"] = {
        CFrame.new(57.9409981, 18.7315865, 922.500732),
        CFrame.new(57.9409637, 0.450669616, 922.502869),
        CFrame.new(40.438118, -0.0142833591, 925.795349)
    },
    ["09Presidential"] = {
        CFrame.new(57.1129761, 21.0502243, 922.76239),
        CFrame.new(57.1129799, -8.16348171, 922.76239),
        CFrame.new(83.6684494, -7.80367422, 918.210693),
        CFrame.new(97.5028305, -7.6949482, 993.061279),
        CFrame.new(56.8518143, -7.45991707, 998.705505)
    },
    ["07TheMint"] = {
        CFrame.new(58.2891922, 18.6407261, 923.230957),
        CFrame.new(102.727531, 1.28942442, 914.082947),
        CFrame.new(90.1080399, 1.28942418, 845.054993),
        CFrame.new(75.884819, 0.289363265, 846.967346),
        CFrame.new(72.4295807, 0.289363414, 830.607605),
        CFrame.new(53.7737808, 0.289363325, 832.894531)
    },
}

local BankPathsEscape = {
    ["01UpperManagement"] = {
        CFrame.new(44.8027611, 60.2341843, 925.830383) + Vector3.new(0, 5, 0),
        CFrame.new(37.8139915, 60.2341881, 895.217529) + Vector3.new(0, 5, 0),
        CFrame.new(57.5389671, 60.2341843, 886.989746) + Vector3.new(0, 5, 0),
        CFrame.new(53.7243156, 60.2341843, 863.99054) + Vector3.new(0, 5, 0),
        CFrame.new(32.7206306, 60.2341843, 862.579102) + Vector3.new(0, 5, 0),
        CFrame.new(27.1561337, 60.2341919, 841.806702) + Vector3.new(0, 5, 0),
        CFrame.new(70.0843048, 60.2341843, 832.451355) + Vector3.new(0, 5, 0),
        CFrame.new(74.8635941, 56.245945, 850.862122) + Vector3.new(0, 5, 0),
        CFrame.new(70.3065491, 51.392189, 861.531677) + Vector3.new(0, 5, 0),
        CFrame.new(78.9199753, 44.9200134, 873.116943) + Vector3.new(0, 5, 0),
        CFrame.new(75.7619019, 37.149868, 889.624817) + Vector3.new(0, 5, 0),
        CFrame.new(85.0449219, 30.3203545, 901.631714) + Vector3.new(0, 5, 0),
        CFrame.new(86.6891632, 27.7893982, 919.55304) + Vector3.new(0, 5, 0),
    },
    ["02Basement"] = {
        CFrame.new(60.2607765, -8.71194172, 948.01532),
        CFrame.new(94.6071091, -0.661975741, 965.972412),
        CFrame.new(85.4746323, 9.23804665, 918.503845),
        CFrame.new(50.3702354, 18.736063, 924.43042)
    },
    ["03Corridor"] = {
        CFrame.new(57.0027695, -7.91255093, 926.284119),
        CFrame.new(56.2616272, 18.0231895, 923.147156) + Vector3.new(0, -5, 0),
        CFrame.new(56.2616272, 18.0231895, 923.147156),
    },
    ["05Underwater"] = {
        CFrame.new(93.3022919, -12.8507042, 855.341309),
        CFrame.new(96.2809219, -12.8460102, 880.283936),
        CFrame.new(101.456192, 1.4882617, 915.283875),
        CFrame.new(56.3401031, 18.7390518, 923.530212)
    },
    ["06TheBlueRoom"] = {
        CFrame.new(40.438118, -0.0142833591, 925.795349),
        CFrame.new(57.9409637, 0.450669616, 922.502869),
        CFrame.new(57.9409981, 18.7315865, 922.500732)
    },
    ["09Presidential"] = {
        CFrame.new(56.8518143, -7.45991707, 998.705505),
        CFrame.new(97.5028305, -7.6949482, 993.061279),
        CFrame.new(83.6684494, -7.80367422, 918.210693),
        CFrame.new(57.1129799, -8.16348171, 922.76239),
        CFrame.new(57.1129761, 21.0502243, 922.76239),
    },
    ["07TheMint"] = {
        CFrame.new(53.7737808, 0.289363325, 832.894531),
        CFrame.new(72.4295807, 0.289363414, 830.607605),
        CFrame.new(75.884819, 0.289363265, 846.967346),
        CFrame.new(90.1080399, 1.28942418, 845.054993),
        CFrame.new(102.727531, 1.28942442, 914.082947),
        CFrame.new(58.2891922, 18.6407261, 923.230957),
    },
}

function robBank()
    local layout = workspace.Banks:GetChildren()[1].Layout:GetChildren()[1]
    if layout.Name == "04Remastered" then
        return
    end
    if layout.Name == "08Deductions" then return end
    if layout:FindFirstChild("Lasers") then
        layout.Lasers:Destroy()
    end
    Escape()
    console("Teleporting to Bank", "BLUE")
    Instant(CFrame.new(40.7974968, 18.7341385, 926.061035))
    local path = BankPaths[layout.Name]
    local path2 = BankPathsEscape[layout.Name]
    console("Going to Vault")
    for i = 1, #path do
        if layout.Name == "04Remastered" then return end
        teleport(path[i], "Player")
    end
    teleport(layout.Money.CFrame, "Player")
    repeat
        wait()
        if Ub(100) == true then 
            console("Police entered. Escaping.")
            for i = 1, #path2 do
                teleport(path2[i], "Player")
            end
            teleport(CFrame.new(40.7974968, 18.7341385, 926.061035), "Player")
            teleport(CFrame.new(29.9837666, 18.7341156, 859.596375), "Player")
            teleport(CFrame.new(-14.8533173, 18.1434326, 866.278687), "Player")
            console("Bank Done.", "GREEN")
            findEnterVehicle()
            G_11_()
            Value.Bank = false
            return 
        end
        if Player.Team.Name == "Prisoner" then Value.Bank = false return end
        if Character:FindFirstChild("Handcuffs") then Value.Bank = false return end
        if Humanoid().Health == 0 then Value.Bank = false return end
    until isBagFull() or Character:FindFirstChild("Handcuffs")
    console("Escaping")
    if Player.Team.Name == "Prisoner" then return end
    for i = 1, #path2 do
        teleport(path2[i], "Player")
    end
    teleport(CFrame.new(40.7974968, 18.7341385, 926.061035), "Player")
    teleport(CFrame.new(29.9837666, 18.7341156, 859.596375), "Player")
    teleport(CFrame.new(-14.8533173, 18.1434326, 866.278687), "Player")
    console("Bank Done.", "GREEN")
    findEnterVehicle()
    G_11_()
    Value.Bank = false
end

game.ReplicatedStorage.RobberyState.ChildAdded:Connect(function(child)
    registerrobbery(child)
end)

for i, v in next, game.ReplicatedStorage.RobberyState:GetChildren() do
    task.spawn(registerrobbery, v)
end

local Test = true
local Bb = workspace.Museum.Roof.Hole.RoofPart

while wait(0.5) do
    if Test then
        if game.Players.LocalPlayer.Team.Name == "Prisoner" then
            if game.Players.LocalPlayer.PlayerGui.MainGui.CellTime.Visible == true then
                console("You have been arrested. Please wait.")
                repeat
                    wait(0.5)
                until game.Players.LocalPlayer.PlayerGui.MainGui.CellTime.Visible == false
            end
            if game:GetService("Players").LocalPlayer.PlayerGui.TeamGui.Enabled == true then
                repeat
                    wait()
                until game:GetService("Players").LocalPlayer.PlayerGui.TeamGui.Enabled == false
                wait(5)
            end
            if (Root.Position - CFrame.new(-2947.72485, -49.0370331, 2438.69141).p).magnitude < 15 then
                console("Fixing your position, please wait...")
                game.Players.LocalPlayer.Character:BreakJoints()
                wait(8)
            end
            console("Escaping..")
            repeat
                Escape()
            until not rayCast(Character.Head.Position + Vector3.new(0, 3, 0), Vector3.new(0, 1000, 0))
            task.wait(0.1)
            teleport(CFrame.new(-1169.17102, 18.3958454, -1389.85645), "above")
            wait(0.5)
            G_11_()
            wait(0.5)
        elseif Value.TrainCargo then
            robTrain()
        elseif Value.TrainPassenger then
            robPassenger()
        elseif Value.Gas then
            robGas()
        elseif Value.Donut then
            robDonut()
        elseif Value.CargoPlane and workspace:FindFirstChild("Plane").PrimaryPart.Position.Y > 200 and game:GetService("Workspace"):FindFirstChild("Plane").Crates.Crate1["1"].Transparency == 0 then
            robPlane()
        elseif Value.Museum and Bb.CanCollide == false then
            robMus()
        elseif Value.Jewelry then
            robJew()
        elseif Value.Bank then
            robBank()
        elseif Value.PowerPlant then
            robPower()
        else
            console("Waiting For Stores To Open.")
            repeat
                wait()
            until Value.Donut or Value.Gas or Value.TrainCargo or (Value.Museum and Bb.CanCollide == false) or Value.TrainPassenger or Value.Jewelry or Value.Bank or (Value.CargoPlane and workspace:FindFirstChild("Plane").Root.Position.Y > 200 and game:GetService("Workspace"):FindFirstChild("Plane").Crates.Crate1["1"].Transparency == 0) or Character:FindFirstChild("Handcuffs") or Player.Team.Name == "Prisoner"
        end
        if Character:FindFirstChild("Handcuffs") then
            console("You have been arrested.")
            Character.Handcuffs.AncestryChanged:Wait()
        end
    end
end

--rconsoleclear()
