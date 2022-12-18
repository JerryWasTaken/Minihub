local Workspace = game:GetService("Workspace")
local Services = setmetatable({}, {
    __index = function(_, service)
        if ypcall(function()game:GetService(service)end) then
            return game:GetService(service)
        end
        return nil
    end
})

local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local PathfindingService = Services.PathfindingService
local Character, Root, Humanoid = nil,nil,nil

local FreeVehicles = {"Camaro" ,"Jeep"}
local BlacklistVehicles = {}
local Specs = require(Services.ReplicatedStorage.Module.UI).CircleAction.Specs
local GetLocalVehiclePacket = require(Services.ReplicatedStorage.Game.Vehicle).GetLocalVehiclePacket
local RobberyConsts = require(Services.ReplicatedStorage.Game.Robbery.RobberyConsts)
local Puzzle = getupvalue(require(Services.ReplicatedStorage.Game.Robbery.PuzzleFlow).Init, 3)
local RobberyState = Services.ReplicatedStorage.RobberyState
local Jewelry = workspace.Jewelrys:GetChildren()[1]
local Bank = workspace.Banks:GetChildren()[1]
local Banklayout = workspace.Banks:GetChildren()[1].Layout:GetChildren()[1]
local attemptPunch = getupvalue(require(Services.ReplicatedStorage.Game.DefaultActions).punchButton.onPressed, 1).attemptPunch
local Stepped = {}
local speed = 15.5
local Hours = 0
local Minutes = 0
local Seconds = 0

function RegisterCharacter(Char)
    Character, Root, Humanoid = Char, Char:WaitForChild("HumanoidRootPart", 2873), Char:WaitForChild("Humanoid", 2873)
    Humanoid.Died:Connect(function()
        Character, Root, Humanoid = nil,nil,nil
    end)
end

gunshopui = require(game.ReplicatedStorage.Game.GunShop:WaitForChild("GunShopUI"))

gunshoputils = require(game.ReplicatedStorage.Game:WaitForChild("GunShop"):WaitForChild("GunShopUtils"))


local function grabfromshop(category, name)
    setthreadidentity(2)
    local isopen = not select(1, pcall(gunshopui.open))
    gunshopui.displayList(gunshoputils.getCategoryData(category))
    setthreadidentity(7)
    for i, v in next, gunshopui.gui.Container.Container.Main.Container.Slider:GetChildren() do
        if v:IsA("ImageLabel") and (name == "All" or v.Name == name) and (category ~= "Held" or v.Bottom.Action.Text == "FREE" or v.Bottom.Action.Text == "EQUIP") then
			firesignal(v.Bottom.Action.MouseButton1Down)
		end
    end
    if isopen == false then
        gunshopui.close()
    end
end

RegisterCharacter(LocalPlayer.Character)
LocalPlayer.CharacterAdded:Connect(RegisterCharacter)

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

function Create(Inst, Parent, Config)
    local Inst = Instance.new(Inst, Parent)
    for property, val in pairs(Config) do
        Inst[property] = val
    end
    return Inst
end

function rayCast(Pos, Dir)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {workspace:FindFirstChild("Rain"), workspace:FindFirstChild("RainSnow"), workspace.Vehicles, workspace.VehicleSpawns, workspace.Trains, workspace:FindFirstChild("MinWasTaken#2873")}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	return workspace:Raycast(Pos, Dir, raycastParams)
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

function isVehicle(v)
    return v and v:FindFirstChild("Engine") and v:FindFirstChild("Seat") and v.Seat:FindFirstChild("PlayerName") and v.Seat:FindFirstChild("Player")
end

function getNearestVehicle(minDistance)
    local nearest,minDistance = nil, minDistance or 9e9
    for i, v in pairs(workspace.Vehicles:GetChildren()) do
        if table.find(FreeVehicles, v.Name) and not table.find(BlacklistVehicles, v) and isVehicle(v) and v.Seat.Player.Value == false then
            local distance = (v.Engine.Position - Root.Position).Magnitude
            if distance < minDistance then
                nearest,minDistance = v,distance
            end
        end
    end
    return nearest
end

function getNearestSpawn()
    local nearest,minDistance = nil, 9e9
    for i, v in pairs(workspace.VehicleSpawns:GetChildren()) do
        local distance = (v.Region.Position - Root.Position).Magnitude
        if table.find(FreeVehicles, v.Name) and distance < minDistance then
            nearest,minDistance = v,distance
        end
    end
    return nearest
end

local W = {
	enabled = false,
    IncludeBank = false,
    Notifystatus = false,
    Chatstatus = false,
    IncludeJewelry = false,
    IncludeMuseum = false,
    IncludePlane = false,
    IncludeTrain = false,
    IncludeShip = false,
    IncludePTrain = false,
    IncludePower = false,
    IncludeCasino = false,
    IncludeDrops = false,
    IncludeSmall = false,
    AutoPull = false,
    Premium = false,
    Killaura = false,
    WasEnabled = false,
    VSpeed = 17,
}

function teleport(Destination, Mode, Speed)
	if (Mode == "linear" or Mode == "above") and (Destination - Root.Position).Magnitude < 1 then return end
    if Mode == "linear" then
        local BV = Create("BodyVelocity", Root, {
            Velocity = Vector3.new(),
            MaxForce = Vector3.new(1,1,1) * 9e9
        })
        Humanoid:SetStateEnabled("FallingDown", false)
        local StartPos = Root.Position
        local Dir = (Destination - StartPos)
        for Lerp = 0, Dir.Magnitude, (Speed or 4) do
            if Humanoid.Sit then
                attemptJump()
            end
            Root.CFrame = CFrame.new(StartPos) + (Dir.Unit * Lerp)
            wait()
        end
        Root.CFrame = CFrame.new(Destination)
        BV:Destroy()
    elseif Mode == "above" then
        Escape()
        wait()
        local BV = Create("BodyVelocity", Root, {
            Velocity = Vector3.new(),
            MaxForce = Vector3.new(1,1,1) * 9e9
        })
        local Y = math.random(300, 400)
        local StartPos = Vector3.new(Root.Position.X, Y, Root.Position.Z)
        local Dir = (Vector3.new(Destination.X, Y, Destination.Z) - StartPos)
        for Lerp = 0, Dir.Magnitude, (Speed or 4) do
            if Humanoid.Sit then
                attemptJump()
            end
            Root.CFrame = CFrame.new(StartPos) + (Dir.Unit * Lerp)
            wait()
            if W.enabled == false then BV:Destroy() return end
        end
        Root.CFrame = CFrame.new(Destination)
        BV:Destroy()
    elseif Mode == "vehicle" then
        --loadstring(game:HttpGet("https://raw.githubusercontent.com/JerryWasTaken/Minihub/main/e.lua"))()
        Escape()
        wait()
        repeat
            if Character:FindFirstChild("InVehicle") then
                local currentVehicle = GetLocalVehiclePacket().Model
				local root = currentVehicle.PrimaryPart
                local BV = Create("BodyVelocity", root, {
                    Velocity = Vector3.new(),
                    MaxForce = Vector3.new(1,1,1) * 9e9
                })
                if speed == math.huge then
                    repeat
                        root.CFrame = CFrame.new(Destination)
                        wait()
                    until not Character:FindFirstChild("InVehicle")
                else
                    local Y = math.random(300, 400)
                    local StartPos = Vector3.new(root.Position.X, Y, root.Position.Z)
                    local Dir = (Vector3.new(Destination.X, Y, Destination.Z) - StartPos)
                    for Lerp = 0, Dir.Magnitude, (Speed or 11) do
                        if not Character:FindFirstChild("InVehicle") then
                            break
                        end
                        root.CFrame = CFrame.new(StartPos) + (Dir.Unit * Lerp)
                        wait()
                    end
                    root.CFrame = CFrame.new(Destination)
                end
				BV:Destroy()
            else
                findEnterVehicle()
            end
            if W.enabled == false then break end
            if game.Players.LocalPlayer.Team.Name == "Prisoner" then break end
        until (Destination - Root.Position).Magnitude < 5
    elseif Mode == "path" then
        for i,v in pairs(Destination) do
            teleport((type(v) == "userdata" and v.Position or v) + Vector3.new(0, 3, 0), "linear", Speed or 2)
        end
    end
end

function Escape()
	if not rayCast(Character.Head.Position + Vector3.new(0, 3, 0), Vector3.new(0, 1000, 0)) then return end
    local escapePath = FindEscape()
    if escapePath then
        teleport(escapePath, "path")
        return true
    else
        return false
    end
end

function findEnterVehicle()
    repeat
        Escape()
    until not rayCast(Character.Head.Position + Vector3.new(0, 3, 0), Vector3.new(0, 1000, 0))
if Character:FindFirstChild("InVehicle") then return end
	local nearestSpawn = getNearestSpawn()
    local nearestVehicle = getNearestVehicle()
	local distanceToSpawn = (nearestSpawn.Region.Position - Root.Position).Magnitude
    local distanceToVehicle do
        if nearestVehicle ~= nil then
            distanceToVehicle = (nearestVehicle.Engine.Position - Root.Position).Magnitude
        end
    end
    if nearestVehicle == nil or (distanceToVehicle - 300 > distanceToSpawn) then
        repeat
            if (nearestSpawn.Region.Position - Root.Position).Magnitude > 10 then
                Escape()
                teleport(nearestSpawn.Region.Position, "above")
            end
            wait(0.5)
            if W.enabled == false then break end
            if game.Players.LocalPlayer.Team.Name == "Prisoner" then break end
        until getNearestVehicle(20)
        nearestVehicle = getNearestVehicle(20)
    else
        teleport(nearestVehicle.Engine.Position, "above")
    end
    if nearestVehicle then
        local skipThisCar = false
        repeat
            if (nearestVehicle.PrimaryPart.Position - Root.Position).Magnitude > 10 then
                Escape()
                teleport(nearestVehicle.Engine.Position, "above")
            end
            for i,v in pairs(Specs) do
                if (v.Name == "Enter Driver" or v.Name == "Hijack") and v.Part == nearestVehicle.Seat then
                    v:Callback(true)
					break
                end
            end
            wait()
            if LocalPlayer.PlayerGui.NotificationGui.ContainerNotification.Message.Text:match("Cannot use vehicle here") and game:GetService("Players").LocalPlayer.PlayerGui.NotificationGui.Enabled then
                LocalPlayer.PlayerGui.NotificationGui.Enabled = false
                table.insert(BlacklistVehicles, nearestVehicle)
            end
            for i,v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if v:IsA("TextLabel") then
                    if v.Text:match("That vehicle is locked") and v.Visible then
                        v.Visible = false
                        table.insert(BlacklistVehicles, nearestVehicle)
                        break
                    end
                end
            end
            if W.enabled == false then break end
            if game.Players.LocalPlayer.Team.Name == "Prisoner" then break end
        until table.find(BlacklistVehicles, v) or not isVehicle(nearestVehicle) or nearestVehicle.Seat.Player.Value
	end
end

function attemptJump()
    repeat
        Services.VirtualInputManager:SendKeyEvent(true, "Space", false, game)
        wait()
        Services.VirtualInputManager:SendKeyEvent(false, "Space", false, game)
		wait(0.5)
    until not Humanoid.Sit
end

require(Services.ReplicatedStorage.Game.Paraglide).IsFlying = function()
    return tostring(getfenv(2).script) == "Falling"
end
local safePlatform = workspace:FindFirstChild("MinWasTaken#2873") or Instance.new("Part", workspace)
safePlatform.Name = "MinWasTaken#2873"
safePlatform.Anchored = true
safePlatform.Size = Vector3.new(300, 1, 300)

function isBagFull()
    if not LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled then
        return false
    end
    local moneys = string.split(LocalPlayer.PlayerGui.RobberyMoneyGui.Container.Bottom.Progress.Amount.Text, " / ")
    return moneys[1] == moneys[2]
end

function connectStep(name, func)
    Stepped[name] = Services.RunService.Stepped:Connect(func)
end
function disconnectStep(name)
    if Stepped[name] then
		Stepped[name]:Disconnect()
	end
end

function attemptSell()
	local powerPlant = LocalPlayer.PlayerGui:FindFirstChild("PowerPlantRobberyGui")
	repeat
		teleport(Vector3.new(2280, 23, -2064), "vehicle")
		wait(0.5)
		attemptJump()
		teleport(Vector3.new(2227, 19, -2455), "linear")
		teleport(Vector3.new(2292, 19, -2588), "linear")
		wait(1)
		teleport(Vector3.new(2227, 19, -2455), "linear")
		teleport(Vector3.new(2280, 23, -2064), "linear")
	until (powerplant and not LocalPlayer.PlayerGui:FindFirstChild("PowerPlantRobberyGui")) or (not powerplant and not isBagFull())
end

function FindCamaro()
    if Character:FindFirstChild("InVehicle") then return end
    --	local dist = (v.Region.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude

    local dd = game:GetService("Workspace").VehicleSpawns:GetChildren()	

    table.sort(dd, function(vq, v2) 
        local v3 = vq.Region
        local v4 = v2.Region
        if v3 ~= nil and v4 ~= nil  then
            return (v3.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude < 
            (v4.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude 
        end
    end)
    for _,v in pairs(dd) do
        if v.Name == "Camaro" then
            teleport(Vector3.new(v.Region.Position.x,v.Region.Position.Y,v.Region.Position.z), "above")
            repeat
                wait(0.1)
                    for i,v in pairs(game.Workspace.Vehicles:GetChildren()) do
                        if v:FindFirstChild("Seat") then
                            if v.Name == "Camaro" then
                                for _,d in pairs(require(game:GetService("ReplicatedStorage").Module.UI).CircleAction.Specs) do
                                    if d.Part == v.Seat then
                                        d:Callback(true)
                                    end
                                end
                            end
                        end
                    end
            until game.Players.LocalPlayer.Character.Humanoid.Sit == true		  
            return 
        end				
    end
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/JerryWasTaken/arui/main/waodhsladwadsa"))()

local robstates = {}
local roblabels = {}

local balls = library:AddWindow("Mini-Hub Autorob - V1")

--Main
local ball = balls:AddTab("Auto rob")
local status = ball:AddLabel("h")
ball:AddSwitch("Auto Rob", function(a)
    W.enabled = a
end)
ball:AddSwitch("Kill Aura", function(a)
    W.Killaura = a
    grabfromshop("Held", "Pistol")
end)
ball:AddSwitch("Collect Airdrops", function(a)
    W.IncludeDrops = a
end)
ball:AddSwitch("Rob Small Stores", function(a)
    W.IncludeSmall = a
end)

local old = require(game:GetService("ReplicatedStorage").Module.RayCast).RayIgnoreNonCollideWithIgnoreList

local function getNearestEnemy()
    local nearestDistance, nearestEnemy = 600, nil
    local myTeam = tostring(game:GetService("Players").LocalPlayer.Team)
    for i,v in pairs(game:GetService("Players"):GetPlayers()) do
        local theirTeam = tostring(v.Team)
	    if ((myTeam == "Police" and theirTeam == "Criminal") or theirTeam == "Police") and theirTeam ~= myTeam and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
	    	if (v.Character.HumanoidRootPart.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < nearestDistance then
	    	    nearestDistance, nearestEnemy = (v.Character.HumanoidRootPart.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).Magnitude, v
	    	end
	    end
	end
    return nearestEnemy
end

local function shoot()
    local x,y = workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(x, y, 0, true, game, 1)
    wait()
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(x, y, 0, false, game, 1)
end

local MoneyEarned = ball:AddLabel("Money Earned: $0")
local Time = ball:AddLabel("Elapsed Time: 0h/0m/0s")

--Statuses
local balls2 = balls:AddTab("Store Status")

roblabels.Donut = balls2:AddLabel("Donut store")
roblabels.Gas = balls2:AddLabel("Gas Station")
roblabels.TrainPassenger = balls2:AddLabel("Passenger Train")
roblabels.PowerPlant = balls2:AddLabel("Power Plant")
roblabels.CargoPlane = balls2:AddLabel("Cargo Plane")
roblabels.TrainCargo = balls2:AddLabel("Cargo Train")
roblabels.CargoShip = balls2:AddLabel("Cargo Ship")
roblabels.Museum = balls2:AddLabel("Museum")
roblabels.Tomb = balls2:AddLabel("Tomb")
roblabels.Casino = balls2:AddLabel("Casino")
roblabels.Jewelry = balls2:AddLabel("Jewelry")
roblabels.Bank = balls2:AddLabel("Bank")

roblabels.Donut.TextColor3 = Color3.fromRGB(255, 0, 0)
roblabels.Gas.TextColor3 = Color3.fromRGB(255, 0, 0)
roblabels.TrainPassenger.TextColor3 = Color3.fromRGB(255, 0, 0)
roblabels.PowerPlant.TextColor3 = Color3.fromRGB(255, 0, 0)
roblabels.CargoPlane.TextColor3 = Color3.fromRGB(255, 0, 0)
roblabels.TrainCargo.TextColor3 = Color3.fromRGB(255, 0, 0)
roblabels.CargoShip.TextColor3 = Color3.fromRGB(255, 0, 0)
roblabels.Museum.TextColor3 = Color3.fromRGB(255, 0, 0)
roblabels.Tomb.TextColor3 = Color3.fromRGB(255, 0, 0)
roblabels.Casino.TextColor3 = Color3.fromRGB(255, 0, 0)
roblabels.Jewelry.TextColor3 = Color3.fromRGB(255, 0, 0)
roblabels.Bank.TextColor3 = Color3.fromRGB(255, 0, 0)

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


local mainlocalscr = game.Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("LocalScript")
local markersystem = game.ReplicatedStorage:WaitForChild("Game"):WaitForChild("RobberyMarkerSystem")
local robconsts = require(game.ReplicatedStorage.Game.Robbery:WaitForChild("RobberyConsts"))

local setup = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V3/modules/setup.lua", true))()
local changelog = setup:getloginfo()
setup:startchecks(changelog)

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
    local isopen = val.Value ~= robconsts.ENUM_STATE.CLOSED
    robstates[name] = isopen
    if roblabels[name] then
        roblabels[name].TextColor3 = isopen and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36)
        Value[name] = isopen and true or false 
    end
end

local function registerrobbery(val)
    local name, pretty = garbage.markerstates[tonumber(val.Name)].Name, robconsts.PRETTY_NAME[tonumber(val.Name)]
    updaterobbery(name, pretty, val)
    val:GetPropertyChangedSignal("Value"):Connect(function()
        updaterobbery(name, pretty, val)
    end)
end


local nameToId = {}
for i, v in next, garbage.markerstates do
    nameToId[v.Name] = v.RobberyId
end

robberyConsts = require(game.ReplicatedStorage.Game.Robbery.RobberyConsts)


tomb = function()
	return game.ReplicatedStorage.RobberyState[tostring(nameToId.Tomb)].Value == robberyConsts.ENUM_STATE.STARTED
end

--Misc

local TombStarted = false

local Misc = balls:AddTab("Misc")
Misc:AddSwitch("Auto Pull Museum Lever", function(a)
    W.AutoPull = a
end)
Misc:AddSlider("Teleport Speed", function(v)
	D.Teleport = v
end, {min = 2, max = 7})
Misc:AddSlider("Car Speed", function(v)
	speed = v
end, {min = 8, max = 17})

local function checkShouldAbort(CurrentRobbery, checkRobberyState)
    local shouldAbort = Character == nil or Character.HumanoidRootPart == nil or LocalPlayer.Team ~= game.Teams.Criminal or W.enabled == false or false
    if Character:FindFirstChild("Handcuffs") then
        shouldAbort = true
        Character.Handcuffs.AncestryChanged:Wait()
    end
    if checkRobberyState and Value[CurrentRobbery] == false then
        shouldAbort = true
    end
    return shouldAbort
end

function Door(toggle)
    for _,v in ipairs(Workspace.Jewelrys:FindFirstChildWhichIsA("Model"):GetChildren()) do
        if v.Name == "SwingDoor" then
            v.Model.TheDoor.CanCollide = toggle
            v.Model.TheGlass.CanCollide = toggle
        end
    end
end

function G_19_()
    if LocalPlayer.Team.Name == "Prisoner" or not LocalPlayer.Character then
      status.Text = "Escaping"
      if not LocalPlayer.Character and not LocalPlayer.PlayerGui.MainGui.CellTime.Visible then
        status.Text = "You're arrested please wait"
        repeat
          wait(1)
        until LocalPlayer.PlayerGui.MainGui.CellTime.Visible
        wait(1)
      end
      if not 1 then
        status.Text = "Please wait until you're released"
        repeat
          wait(1)
        until not LocalPlayer.PlayerGui.MainGui.CellTime.Visible
      end
      if (G_8_.Position - Vector3.new(-2946, -48, 2440)).Magnitude <= 200 then
        if (G_8_.Position - Vector3.new(-2947, -48, 2438)).Magnitude <= 8 then
        teleport(Vector3.new(-2946, -48, 2435), "linear", 2)
          wait(0.1)
          teleport(Vector3.new(-2948, -48, 2416), "linear", 2)
        else
          teleport(Vector3.new(-2971, -48, 2434), "linear", 2)
          wait(0.1)
          teleport(Vector3.new(-2959, -48, 2407), "linear", 2)
        end
        teleport(Vector3.new(-2953.2153320313, -47.307273864746, 2361.3508300781), "linear", 2)
        teleport(Vector3.new(-2952.8754882813, -68.178031921387, 2358.1032714844), "linear", 2)
        teleport(Vector3.new(-2949.9711914063, -69.130920410156, 2332.3645019531), "linear", 2)
        teleport(Vector3.new(-2949.7209472656, -79.229385375977, 2331.3273925781), "linear", 2)
        teleport(Vector3.new(-2946.205078125, -78.784355163574, 2303.5622558594), "linear", 2)
        teleport(Vector3.new(-2946.1218261719, -71.083656311035, 2302.5871582031), "linear", 2)
        teleport(Vector3.new(-2941.3134765625, -70.038185119629, 2268.9138183594), "linear", 2)
        teleport(Vector3.new(-2942.3959960938, -69.952743530273, 2266.490234375), "linear", 2)
        game:GetService("Players").LocalPlayer.Character:SetPrimaryPartCFrame(G_8_.CFrame + Vector3.new(0, 500, 0))
        teleport(Vector3.new(-2259, 18, 2254), "above", 2)
        repeat
          wait()
        until LocalPlayer.Team.Name == "Criminal"
        wait(1)
        teleport(Vector3.new(-317, 18, 1601), "above", 2)
        findEnterVehicle()
    end
  end
end

function robMsm()
    G_19_()
    Escape()
    status.Text = "Teleporting to Museum"
	teleport(Vector3.new(1056, 106, 1247), "vehicle")
	wait(0.5)
	attemptJump()
	teleport(Vector3.new(1080, 109, 1266), "linear")
	teleport(Vector3.new(1127, 110, 1304), "linear")
    status.Text = "Grabbing Bones"
	repeat
        for i,v in pairs(Specs) do
            if v.Name:match("Grab Bone") then
                v:Callback(true)
                wait(0.5)
            end
        end
    until isBagFull() or game.Players.LocalPlayer.Team.Name == "Prisoner"
    status.Text = "Escaping"
	teleport(Vector3.new(1127, 110, 1304), "linear")
	teleport(Vector3.new(1056, 106, 1247), "linear")
	if isBagFull() then
        status.Text = "Selling..."
		attemptSell()
	end
    status.Text = "Success."
	Value.Museum = false
end

function robPassenger()
    G_19_()
    Escape()
	--[[if tostring(LocalPlayer.Team) == "Prisoner" then
		teleport(Vector3.new(-1151, 19, -1392), "above")
		wait(0.5)
	end--]]
	for i,v in pairs(Specs) do
        if v.Name == "Grab briefcase" and workspace.Trains.SteamEngine:IsAncestorOf(v.Part) then
			if isBagFull() then break end
            v:Callback(true)
			wait(0.5)
        end
    end
	if isBagFull() then
		attemptSell()
	end
	Value.TrainPassenger = false
end

function robJewelry()
    G_19_()
    findEnterVehicle()
    for i, v in next, Jewelry:GetDescendants() do
        if (v.ClassName == "TouchInterest" or v.ClassName == "TouchTransmitter") and v.Parent.Name ~= "LaserTouch" then
            v.Parent:Destroy()
        end
    end
    Escape()
    status.Text = "Teleporting to Jewelry Store"
    teleport(Vector3.new(118, 19, 1373), "vehicle", speed)
    wait(0.5)
    attemptJump()
    teleport(Vector3.new(137, 19, 1347), "linear", 4)
    teleport(Vector3.new(135, 18, 1336), "linear", 2)
    status.Text = "Punching Cases"
    local boxes = Jewelry.Boxes:GetChildren()
	while not isBagFull() and Value.Jewelry do
        table.sort(boxes, function(a, b)
		    return (a.Position - Root.Position).Magnitude < (b.Position - Root.Position).Magnitude and a.Position.Y < 45 and a.Transparency < 0.9
	    end)
		local box
		for i,v in pairs(boxes) do
			if v.Transparency < 0.9 then
				box = v
				break
			end
		end
        local PathToBox = PathFind(Root.Position, box.Position + box.CFrame.LookVector * 2.5)
        if PathToBox then
            teleport(PathToBox, "path")
            Root.CFrame = CFrame.new(Root.Position, box.Position)
        end
        for i = 1, 8 do
            attemptPunch()
            wait(0.5)
            if box.Transparency > 0.9 then
                break
            end
        end
		Root.Anchored = false
        checkShouldAbort("Jewelry", true)
    end
    status.Text = "Escaping"
    if isBagFull() then
        Door(false)
        local PathToExit = PathFind(Root.Position, Vector3.new(126, 118, 1285))
        if PathToExit then
            repeat
                teleport(PathToExit, "path", 2)
                teleport(Vector3.new(128, 118, 1331), "linear")
                wait(0.3)
                if not isBagFull() then return end
            until (Vector3.new(126, 118, 1285) - Character.HumanoidRootPart.Position).Magnitude >= 5
            Door(true)
        end
        status.Text = "Selling.."
        repeat
            teleport(Vector3.new(-247, 18, 1616), "above")
			wait(1)
        until not isBagFull()
    end
    status.Text = "Success."
    findEnterVehicle()
	Value.Jewelry = false
end

function robPlane()
    G_19_()
	Escape()
    findEnterVehicle()
	local Q = {}
    local Y = game:GetService("RunService").Stepped
    local Q = GetLocalVehiclePacket().Model.PrimaryPart
    O = Y:Connect(function()
        Q.CFrame = game:GetService("Workspace").Plane.Root.CFrame + Vector3.new(0, 10, 0)
        Q.Velocity, Q.RotVelocity = Vector3.new(), Vector3.new()
    end)
    status.Text = "Grabbing Crate."
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
			teleport(Vector3.new(-342, 26, 2015), "vehicle")
			wait(2.5)
			teleport(Vector3.new(-342, 26, 2051), "vehicle")
			wait(2)
		until not isBagFull()
	end
    status.Text = "Success."
	Value.CargoPlane = false
end

function robCargo()
    Escape()
	local BoxCar = workspace.Trains:WaitForChild("BoxCar", 2873)
	if BoxCar then
		local Vault = BoxCar.Model.Rob.Gold
		repeat
			if Character:FindFirstChild("InVehicle") then
                local currentVehicle = GetLocalVehiclePacket().Model
				local root = currentVehicle.PrimaryPart
                local BV = Create("BodyVelocity", root, {
                    Velocity = Vector3.new(),
                    MaxForce = Vector3.new(1,1,1) * 9e9
                })
				local Y = math.random(300, 400)
                repeat
                    if not Character:FindFirstChild("InVehicle") then
                        break
                    end
                	local Dir = (Vector3.new(Vault.Position.X, Y, Vault.Position.Z) - Vector3.new(root.Position.X, Y, root.Position.Z))
                    root.CFrame = CFrame.new(root.Position.X, Y, root.Position.Z) + (Dir.Unit * 11)
                    wait()
                until not rayCast(Vault.Position, Vector3.new(0, Y-10, 0)) and (Vector3.new(Vault.Position.X, Y, Vault.Position.Z) - Vector3.new(root.Position.X, Y, root.Position.Z)).Magnitude < 11
                root.CFrame = CFrame.new(Vault.Position + Vector3.new(0, 3, 0))
				BV:Destroy()
            else
                findEnterVehicle()
            end
		until (Vault.Position - Root.Position).Magnitude < 20
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
		connectStep("vaulttp", function()
			if Character:FindFirstChild("InVehicle") then
				GetLocalVehiclePacket().Model:SetPrimaryPartCFrame(CFrame.new(Vault.Position + Vector3.new(0, 3, 0)))
			else
				Root.CFrame = CFrame.new(Vault.Position + Vector3.new(0, 3, 0))
			end
		end)
		attemptJump()
		repeat wait() until isBagFull() or Character:FindFirstChild("Handcuffs") or (Vector3.new(-1662, 42, 267) - Vault.Position).Magnitude < 20
		disconnectStep("vaulttp")
	end
    findEnterVehicle()
	Value.TrainCargo = false
end

function robDonut()
	Escape()
    status.Text = "Teleporting to Donut Store"
	teleport(Vector3.new(121, 20, -1637), "vehicle", speed)
	wait(0.5)
	attemptJump()
	Root.CFrame = CFrame.new(121, 20, -1632)
	wait(0.5)
	teleport(Vector3.new(109, 22, -1587), "linear")
	teleport(Vector3.new(85, 20, -1596), "linear", 2)
    status.Text = "Robbing.."
	for i,v in pairs(require(game.ReplicatedStorage.Module.UI).CircleAction.Specs) do
		if v.Name == "Rob" and (v.Part.Position - Root.Position).Magnitude < 20 then
			v:Callback(false)
			wait(10)
			v:Callback(true)
			break
		end
	end
	teleport(Vector3.new(109, 22, -1587), "linear", 2)
	teleport(Vector3.new(121, 20, -1637), "linear")
    status.Text = "Success."
    findEnterVehicle()
	Value.Donut = false
end

function robPower()
    Escape()
    status.Text = "Teleporting to PowerPlant"
	teleport(Vector3.new(63, 23, 2344), "vehicle", speed)
	wait(0.5)
	attemptJump()
	teleport(Vector3.new(89, 23, 2326), "linear")
    task.wait(0.5)
    if Puzzle.IsOpen then
    else
        repeat
            if Puzzle.IsOpen then break end
            task.wait(0.5) 
            teleport(Vector3.new(63, 23, 2344), "linear") 
            task.wait(0.5) 
            teleport(Vector3.new(89, 23, 2326), "linear") 
            repeat wait(0.5) until game:GetService("Players").LocalPlayer.PlayerGui.NotificationGui.Enabled == false
            if Puzzle.IsOpen then break end
        until Puzzle.IsOpen or Value.PowerPlant == false
    end
    if Value.PowerPlant == false then
        return
    end
    if game.Players.LocalPlayer.Team == "Prisoner" then
        return
    end
    if W.enabled == false then
        return
    end
    status.Text = "Solving Puzzle 1/2"
    wait(0.5)
    if Puzzle.IsOpen then
        for i,v in pairs(Puzzle.Grid) do
            for i2,v2 in pairs(v) do
                v[i2] = v2 + 1
            end
        end
        local solution = Services.HttpService:JSONDecode((syn and syn.request or http_request or request)({
            Url = "https://numberlink-solver.sagesapphire.repl.co",
            Method = "POST",
            Body = Services.HttpService:JSONEncode({
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
    teleport(Vector3.new(95, 26, 2334), "linear", 2)
    teleport(Vector3.new(145, 26, 2290), "linear")
    teleport(Vector3.new(206, 21, 2241), "linear")
    teleport(Vector3.new(143, -3, 2095), "linear")
    teleport(Vector3.new(120, -9, 2100), "linear")
    repeat wait() until Puzzle.IsOpen or Value.PowerPlant == false
    if Value.PowerPlant == false then
        return
    end
    status.Text = "Solving Puzzle 2/2"
    if Puzzle.IsOpen then
        for i,v in pairs(Puzzle.Grid) do
            for i2,v2 in pairs(v) do
                v[i2] = v2 + 1
            end
        end
        local solution = Services.HttpService:JSONDecode((syn and syn.request or http_request or request)({
            Url = "https://numberlink-solver.sagesapphire.repl.co",
            Method = "POST",
            Body = Services.HttpService:JSONEncode({
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
    wait(0.1)
    teleport(Vector3.new(109, -9, 2106), "linear", 2)
    teleport(Vector3.new(65, -5, 2099), "linear", 3)
    teleport(Vector3.new(33, -12, 2110), "linear", 3)
    teleport(Vector3.new(35, -15, 2142), "linear", 3)
    teleport(Vector3.new(50, -9, 2176), "linear", 3)
    teleport(Vector3.new(74, 5, 2226), "linear", 3)
    teleport(Vector3.new(97, 17, 2265), "linear", 3)
    teleport(Vector3.new(97, 22, 2265), "linear", 3)
    teleport(Vector3.new(60, 24, 2300), "linear", 4)
    status.Text = "Selling.."
	if LocalPlayer.PlayerGui:FindFirstChild("PowerPlantRobberyGui") then
		attemptSell()
	end
	Value.PowerPlant = false
end

function robMansion()
    
end

local Bb = workspace.Museum.Roof.Hole.RoofPart

spawn(function()
    while wait(0.5) do
        if Bb.CanCollide == false or Value.TrainCargo or (Value.CargoPlane and workspace.Plane.PrimaryPart.Position.Y > 200 and workspace.Plane:FindFirstChild("Crates").Crate1['1'].Transparency == 0) or Value.Donut or Value.PowerPlant or Value.Jewelry or Value.TrainPassenger or not W.enabled then
            return
        else
            status.Text = "Waiting for stores to open.."
        end
    end
end)

G_8_ = LocalPlayer.Character.HumanoidRootPart

function vc(text)
    status.Text = text
end

local BankPaths = {
    ["01UpperManagement"] = {
        Vector3.new(86.6891632, 27.7893982, 919.55304) + Vector3.new(0, 5, 0),
        Vector3.new(85.0449219, 30.3203545, 901.631714) + Vector3.new(0, 5, 0),
        Vector3.new(75.7619019, 37.149868, 889.624817) + Vector3.new(0, 5, 0),
        Vector3.new(78.9199753, 44.9200134, 873.116943) + Vector3.new(0, 5, 0),
        Vector3.new(70.3065491, 51.392189, 861.531677) + Vector3.new(0, 5, 0),
        Vector3.new(74.8635941, 56.245945, 850.862122) + Vector3.new(0, 5, 0),
        Vector3.new(70.0843048, 60.2341843, 832.451355) + Vector3.new(0, 5, 0),
        Vector3.new(27.1561337, 60.2341919, 841.806702) + Vector3.new(0, 5, 0),
        Vector3.new(32.7206306, 60.2341843, 862.579102) + Vector3.new(0, 5, 0),
        Vector3.new(53.7243156, 60.2341843, 863.99054) + Vector3.new(0, 5, 0),
        Vector3.new(57.5389671, 60.2341843, 886.989746) + Vector3.new(0, 5, 0),
        Vector3.new(37.8139915, 60.2341881, 895.217529) + Vector3.new(0, 5, 0),
        Vector3.new(44.8027611, 60.2341843, 925.830383) + Vector3.new(0, 5, 0),
    },
    ["02Basement"] = {
        Vector3.new(50.3702354, 18.736063, 924.43042),
        Vector3.new(85.4746323, 9.23804665, 918.503845),
        Vector3.new(94.6071091, -0.661975741, 965.972412),
        Vector3.new(60.2607765, -8.71194172, 948.01532)
    },
    ["03Corridor"] = {
        Vector3.new(56.2616272, 18.0231895, 923.147156),
        Vector3.new(56.2616272, 18.0231895, 923.147156) + Vector3.new(0, -5, 0),
        Vector3.new(57.0027695, -7.91255093, 926.284119),
    },
    ["05Underwater"] = {
        Vector3.new(56.3401031, 18.7390518, 923.530212),
        Vector3.new(101.456192, 1.4882617, 915.283875),
        Vector3.new(96.2809219, -12.8460102, 880.283936),
        Vector3.new(93.3022919, -12.8507042, 855.341309)
    },
    ["06TheBlueRoom"] = {
        Vector3.new(57.9409981, 18.7315865, 922.500732),
        Vector3.new(57.9409637, 0.450669616, 922.502869),
        Vector3.new(40.438118, -0.0142833591, 925.795349)
    },
    ["09Presidential"] = {
        Vector3.new(57.1129761, 21.0502243, 922.76239),
        Vector3.new(57.1129799, -8.16348171, 922.76239),
        Vector3.new(83.6684494, -7.80367422, 918.210693),
        Vector3.new(97.5028305, -7.6949482, 993.061279),
        Vector3.new(56.8518143, -7.45991707, 998.705505)
    },
    ["07TheMint"] = {
        Vector3.new(58.2891922, 18.6407261, 923.230957),
        Vector3.new(102.727531, 1.28942442, 914.082947),
        Vector3.new(90.1080399, 1.28942418, 845.054993),
        Vector3.new(75.884819, 0.289363265, 846.967346),
        Vector3.new(72.4295807, 0.289363414, 830.607605),
        Vector3.new(53.7737808, 0.289363325, 832.894531)
    },
}

local BankPathsEscape = {
    ["01UpperManagement"] = {
        Vector3.new(44.8027611, 60.2341843, 925.830383) + Vector3.new(0, 5, 0),
        Vector3.new(37.8139915, 60.2341881, 895.217529) + Vector3.new(0, 5, 0),
        Vector3.new(57.5389671, 60.2341843, 886.989746) + Vector3.new(0, 5, 0),
        Vector3.new(53.7243156, 60.2341843, 863.99054) + Vector3.new(0, 5, 0),
        Vector3.new(32.7206306, 60.2341843, 862.579102) + Vector3.new(0, 5, 0),
        Vector3.new(27.1561337, 60.2341919, 841.806702) + Vector3.new(0, 5, 0),
        Vector3.new(70.0843048, 60.2341843, 832.451355) + Vector3.new(0, 5, 0),
        Vector3.new(74.8635941, 56.245945, 850.862122) + Vector3.new(0, 5, 0),
        Vector3.new(70.3065491, 51.392189, 861.531677) + Vector3.new(0, 5, 0),
        Vector3.new(78.9199753, 44.9200134, 873.116943) + Vector3.new(0, 5, 0),
        Vector3.new(75.7619019, 37.149868, 889.624817) + Vector3.new(0, 5, 0),
        Vector3.new(85.0449219, 30.3203545, 901.631714) + Vector3.new(0, 5, 0),
        Vector3.new(86.6891632, 27.7893982, 919.55304) + Vector3.new(0, 5, 0),
    },
    ["02Basement"] = {
        Vector3.new(60.2607765, -8.71194172, 948.01532),
        Vector3.new(94.6071091, -0.661975741, 965.972412),
        Vector3.new(85.4746323, 9.23804665, 918.503845),
        Vector3.new(50.3702354, 18.736063, 924.43042)
    },
    ["03Corridor"] = {
        Vector3.new(57.0027695, -7.91255093, 926.284119),
        Vector3.new(56.2616272, 18.0231895, 923.147156) + Vector3.new(0, -5, 0),
        Vector3.new(56.2616272, 18.0231895, 923.147156),
    },
    ["05Underwater"] = {
        Vector3.new(93.3022919, -12.8507042, 855.341309),
        Vector3.new(96.2809219, -12.8460102, 880.283936),
        Vector3.new(101.456192, 1.4882617, 915.283875),
        Vector3.new(56.3401031, 18.7390518, 923.530212)
    },
    ["06TheBlueRoom"] = {
        Vector3.new(40.438118, -0.0142833591, 925.795349),
        Vector3.new(57.9409637, 0.450669616, 922.502869),
        Vector3.new(57.9409981, 18.7315865, 922.500732)
    },
    ["09Presidential"] = {
        Vector3.new(56.8518143, -7.45991707, 998.705505),
        Vector3.new(97.5028305, -7.6949482, 993.061279),
        Vector3.new(83.6684494, -7.80367422, 918.210693),
        Vector3.new(57.1129799, -8.16348171, 922.76239),
        Vector3.new(57.1129761, 21.0502243, 922.76239),
    },
    ["07TheMint"] = {
        Vector3.new(53.7737808, 0.289363325, 832.894531),
        Vector3.new(72.4295807, 0.289363414, 830.607605),
        Vector3.new(75.884819, 0.289363265, 846.967346),
        Vector3.new(90.1080399, 1.28942418, 845.054993),
        Vector3.new(102.727531, 1.28942442, 914.082947),
        Vector3.new(58.2891922, 18.6407261, 923.230957),
    },
}

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

function robBank()
    G_19_()
    local layout = workspace.Banks:GetChildren()[1].Layout:GetChildren()[1]
    if layout.Name == "04Remastered" then
        return
    end
    if layout.Name == "08Deductions" then return end
    if layout:FindFirstChild("Lasers") then
        layout.Lasers:Destroy()
    end
    Escape()
    status.Text = "Teleporting to Bank"
    teleport(Vector3.new(-14.8533173, 18.1434326, 866.278687), "vehicle", speed)
    wait(0.3)
    teleport(Vector3.new(29.9837666, 18.7341156, 859.596375), "linear", 2)
    teleport(Vector3.new(40.7974968, 18.7341385, 926.061035), "linear", 2)
    local path = BankPaths[layout.Name]
    local path2 = BankPathsEscape[layout.Name]
    status.Text = "Going to Vault"
    for i = 1, #path do
        teleport(path[i], "linear", 3)
    end
    teleport(layout.Money.Position, "linear", 3)
    repeat
        wait()
        if Ub(80) == true then 
            status.Text = "[Police Entered] Escaping.."
            for i = 1, #path2 do 
                teleport(path2[i], "linear", 3) 
            end 
            teleport(Vector3.new(40.7974968, 18.7341385, 926.061035), "linear", 2)
            teleport(Vector3.new(29.9837666, 18.7341156, 859.596375), "linear", 2)
            teleport(Vector3.new(-14.8533173, 18.1434326, 866.278687), "linear", 2)
            wait(0.3)
            FindCamaro()
            Value.Bank = false
            return 
        end
        if LocalPlayer.Team.Name == "Prisoner" then Value.Bank = false return end
        if Character:FindFirstChild("Handcuffs") then Value.Bank = false return end
        if Character.Humanoid.Health == 0 then Value.Bank = false return end
    until isBagFull() or Character:FindFirstChild("Handcuffs")
    status.Text = "Escaping"
    if LocalPlayer.Team.Name == "Prisoner" then return end
    for i = 1, #path2 do
        teleport(path2[i], "linear", 3)
    end
    teleport(Vector3.new(40.7974968, 18.7341385, 926.061035), "linear", 2)
    teleport(Vector3.new(29.9837666, 18.7341156, 859.596375), "linear", 2)
    teleport(Vector3.new(-14.8533173, 18.1434326, 866.278687), "linear", 2)
    status.Text = "Success!"
    Value.Bank = false
end

--[[function robBank()
    Escape()
    teleport(Vector3.new(-14.8533173, 18.1434326, 866.278687), "vehicle", 17)
    teleport(Vector3.new(29.9837666, 18.7341156, 859.596375), "linear", 2)
    teleport(Vector3.new(40.7974968, 18.7341385, 926.061035), "linear", 2)
end--]]

function FindHeli()
    --	local dist = (v.Region.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude

    local dd = game:GetService("Workspace").VehicleSpawns:GetChildren()	

    table.sort(dd, 
                    function(vq, v2) 
                        local v3 = vq.Region
                        local v4 = v2.Region
    
                        if v3 ~= nil and v4 ~= nil  then
                            return (v3.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude < 
                            (v4.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude 
                        end
    end)		
         
                 
                    for _,v in pairs(dd) do
                    
            if v.Name == "Heli" then
            teleport(Vector3.new(v.Region.Position.x,v.Region.Position.Y,v.Region.Position.z), "above")
            repeat
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
            until game.Players.LocalPlayer.Character.Humanoid.Sit == true		  
            return 
        end				
    end
end

function robShip()
    FindHeli()
    local ShipCrate = game.Workspace.CargoShip.Crates.Crate.Part
    if ShipCrate then
        repeat
            if Character:FindFirstChild("InVehicle") then
                local currentVehicle = GetLocalVehiclePacket().Model
                local root = currentVehicle.PrimaryPart
                local BV = Create("BodyVelocity", root, {
                    Velocity = Vector3.new(),
                    MaxForce = Vector3.new(1,1,1) * 9e9
                })
                local Y = math.random(300, 400)
                repeat
                    if not Character:FindFirstChild("InVehicle") then
                        break
                    end
                    local Dir = (Vector3.new(ShipCrate.Position.X, Y, ShipCrate.Position.Z) - Vector3.new(root.Position.X, Y, root.Position.Z))
                    root.CFrame = CFrame.new(root.Position.X, Y, root.Position.Z) + (Dir.Unit * 11)
                    wait()
                until not rayCast(ShipCrate.Position, Vector3.new(0, Y-10, 0)) and (Vector3.new(ShipCrate.Position.X, Y, ShipCrate.Position.Z) - Vector3.new(root.Position.X, Y, root.Position.Z)).Magnitude < 11
                root.CFrame = CFrame.new(ShipCrate.Position + Vector3.new(0, 3, 0))
                BV:Destroy()
            else
                FindHeli()
            end
        until (ShipCrate.Position - Root.Position).Magnitude < 20
        local Vehicle = GetLocalVehiclePacket().Model
        local PrimaryPart = Vehicle.PrimaryPart
        local Q = {}
        local Y = game:GetService("RunService").Stepped
        local Q = GetLocalVehiclePacket().Model.PrimaryPart
        O = Y:Connect(function()
            Q.CFrame = game:GetService("Workspace").CargoShip.Crates.Crate.Part.CFrame + Vector3.new(0, 10, 0)
            Q.Velocity, Q.RotVelocity = Vector3.new(), Vector3.new()
        end)

    end
end

function robGas()
    G_19_()
	Escape()
    vc("Teleporting to Gas Station")
	teleport(Vector3.new(-1538.0172119140625, 18.039798736572266, 703.547607421875), "vehicle", speed)
    wait(0.3)
    teleport(Vector3.new(-1595.056640625, 18.49614143371582, 710.1774291992188) + Vector3.new(0, -2.5, 0), "linear", 2)
    teleport(Vector3.new(-1599.45068359375, 18.496139526367188, 685.6439819335938) + Vector3.new(0, -2.5, 0), "linear", 2)
    vc("Robbing")
    if game.Players.LocalPlayer.Team == "Prisoner" then
        return
    end
    if W.enabled == false then
        return
    end
    for fd, fe in pairs(require(game:GetService("ReplicatedStorage").Module.UI).CircleAction.Specs) do
        if fe.Name == "Rob" and (fe.Part.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 30 then
        fe:Callback()
        wait(fe.Duration)
        fe:Callback(true)
        checkShouldAbort("Gas", true)
        end
    end
    teleport(Vector3.new(-1595.056640625, 18.49614143371582, 710.1774291992188) + Vector3.new(0, -1.5, 0), "linear", 2)
    teleport(Vector3.new(-1538.0172119140625, 18.039798736572266, 703.547607421875) + Vector3.new(0, -1.5, 0), "linear", 2)
    findEnterVehicle()
    vc("Success!")
	Value.Gas = false
end

local function chainTeleportDirect(positions)
    local success = true
    for i = 1, #positions do
        teleport(positions[i], "linear", 3)
    end
    return success
end

function robTomb()
    Escape()
    findEnterVehicle()
    teleport(Vector3.new(452, 26, -454), "vehicle", speed)
    task.wait()
    chainTeleportDirect({
        Vector3.new(541, 28, -502),
        Vector3.new(546, 28, -545),
        Vector3.new(546, -58, -545),
        Vector3.new(524, -57, -359),
        Vector3.new(532, -58, -322),
        Vector3.new(544, -58, -303),
        Vector3.new(578, -71, -251),
        Vector3.new(612, -71, -231),
        Vector3.new(648, -72, -226)
    })
    local pillars = workspace.RobberyTomb.DartRoom.Pillars:GetChildren()
    table.sort(pillars, function(a, b)
        return tonumber(a.Name) < tonumber(b.Name)
    end)
    for i, v in next, pillars do
        teleport(Vector3.new(v.InnerModel.Platform.Position + Vector3.new(0, 2.5, 0)), "linear", 2)
    end
    chainTeleportDirect({
        Vector3.new(795, -89, -209),
        Vector3.new(828, -83, -204),
        Vector3.new(938, -84, -191)
    })
    task.wait(4)
    teleport(Vector3.new(965, -84, -188), "linear", 2)
    task.wait(4)
    teleport(Vector3.new(974, -84, -186), "linear", 2)
    repeat
        for i, v in next, require(game.ReplicatedStorage.Module.UI).CircleAction.Specs do
            if v.Name == "Collect" and v.Part.Transparency < 1 then
                v:Callback(true)
                task.wait(1)
                if isBagFull() then break end
            end
        end
        task.wait()
    until isBagFull()
    teleport(Vector3.new(1008, -85, -182), "linear", 2)
    local cartSystem = require(game.ReplicatedStorage.Game.Cart.CartSystem)
    local tombSystem = require(game.ReplicatedStorage.Game.Robbery.TombRobbery.TombRobberySystem)
    repeat
        for i, v in next, require(game.ReplicatedStorage.Module.UI).CircleAction.Specs do
            if v.Name == "Sit" then
                v:Callback(true)
                task.wait(1)
                if cartSystem.getCartForCharacter(game.Players.LocalPlayer.Character) ~= nil then break end
            end
        end
        task.wait()
    until cartSystem.getCartForCharacter(game.Players.LocalPlayer.Character) ~= nil
    repeat task.wait()
        if tombSystem._duckTrack and not tombSystem._duckPromise then
            tombSystem.duck()
        end
    until game.Players.LocalPlayer.PlayerGui.RobberyMoneyGui.Enabled == false
    local tombExits = {
        CFrame.new(1283, 18, -1143),
        CFrame.new(206, 21, 234)
    }
    pressKey(Enum.KeyCode.Space)
    task.wait(0.5)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(-3, 0, 0)
    local exit, dist = nil, math.huge
    for i, v in next, tombExits do
        local mag = (v.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        if mag < dist then
            exit, dist = v, mag
        end
    end
    local path = game:GetService("PathfindingService"):CreatePath({ AgentCanJump = false, WaypointSpacing = 25 })
    path:ComputeAsync(game.Players.LocalPlayer.Character.HumanoidRootPart.Position, exit.Position)
    local waypoints = path:GetWaypoints()
    for i = 1, #waypoints do
        teleport(Vector3.new(waypoints[i].Position + Vector3.new(0, 4, 0)), "linear", 2)
    end
    Value.Tomb = false
end

game.ReplicatedStorage.RobberyState.ChildAdded:Connect(function(child)
    registerrobbery(child)
end)

for i, v in next, game.ReplicatedStorage.RobberyState:GetChildren() do
    task.spawn(registerrobbery, v)
end


local gc = 0
local hc = 0

spawn(function()
    while wait(0.5) do
      if W.Killaura then
        if not game:GetService("Players").LocalPlayer.Character then continue end
        if not game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then continue end
        
        local nearestEnemy = getNearestEnemy()
        if nearestEnemy then
            require(game:GetService("ReplicatedStorage").Module.RayCast).RayIgnoreNonCollideWithIgnoreList = function(...)
                local arg = {old(...)}
                if (tostring(getfenv(2).script) == "BulletEmitter" or tostring(getfenv(2).script) == "Taser") then
                    arg[1] = nearestEnemy.Character.HumanoidRootPart
                    arg[2] = nearestEnemy.Character.HumanoidRootPart.Position
                end
                return unpack(arg)
            end
            if not game:GetService("Players").LocalPlayer.Folder:FindFirstChild("Pistol") then
                fireclickdetector(workspace.Givers:GetChildren()[17].ClickDetector)
            end
            if game:GetService("Players").LocalPlayer.Folder:FindFirstChild("Pistol") then
                while nearestEnemy and nearestEnemy.Character and nearestEnemy.Character:FindFirstChild("HumanoidRootPart") and (nearestEnemy.Character.HumanoidRootPart.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 600 and nearestEnemy.Character.Humanoid.Health > 0 do
                    game:GetService("Players").LocalPlayer.Folder.Pistol.InventoryEquipRemote:FireServer(true)
                    wait()
                    shoot()
                end
                game:GetService("Players").LocalPlayer.Folder.Pistol.InventoryEquipRemote:FireServer(false)
            end
        end
    else
        require(game:GetService("ReplicatedStorage").Module.RayCast).RayIgnoreNonCollideWithIgnoreList = old
      end
      if game then
        game:GetService("UserInputService").MouseIconEnabled = true
      end
    end
end)

spawn(function()
    while wait(0.5) do
        if W.enabled then
            task.wait(1)
            Seconds = Seconds + 1
            if Seconds == 59 then
                Minutes = Minutes + 1
                Seconds = 0
            elseif Minutes == 59 then
                Minutes = 0
                Seconds = 0
                Hours = Hours + 1
            end
            Time.Text = "Elapsed Time: " .. Hours.."h" .. "/".. Minutes .. "m" .. "/" .. Seconds .. "s"
            --Earned.Text = "Money Earned: $" .. MoneyEarned
        else
            Hours = 0
            Minutes = 0
            Seconds = 0
            Time.Text = "Elapsed Time: 0h/0m/0s"
            --Earned.Text = "Money Earned: $0"
        end
    end
end)

while wait(0.5) do
    if W.enabled then
        if game.Players.LocalPlayer.Team.Name == "Prisoner" then
            if game.Players.LocalPlayer.PlayerGui.MainGui.CellTime.Visible == true then
                repeat
                    wait()
                until game.Players.LocalPlayer.PlayerGui.MainGui.CellTime.Visible == false
            end
            if game:GetService("Players").LocalPlayer.PlayerGui.TeamGui.Enabled == true then
                repeat
                    wait()
                until game:GetService("Players").LocalPlayer.PlayerGui.TeamGui.Enabled == false
            end
            if Character:FindFirstChild("Handcuffs") then
                vc("You have been arrested. Please wait.")
                Character.Handcuffs.AncestryChanged:Wait()
            end
            if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - CFrame.new(-2947.72485, -49.0370331, 2438.69141).p).magnitude < 15 then
                repeat
                    G_19_()
                until game.Players.LocalPlayer.Team.Name == "Criminal"
            else
                repeat
                    wait(0.5)
                    status.Text = "Escaping"
                    --loadstring(game:HttpGet("https://raw.githubusercontent.com/JerryWasTaken/Minihub/main/e.lua"))()
                    repeat
                        Escape()
                    until not rayCast(Character.Head.Position + Vector3.new(0, 3, 0), Vector3.new(0, 1000, 0))
                    task.wait(0.1)
                    findEnterVehicle()
                until game.Players.LocalPlayer.Team.Name == "Criminal"
            end
        elseif Value.Museum and Bb.CanCollide == false then
            robMsm()
        elseif Value.TrainPassenger then
            robPassenger()
        elseif Value.Jewelry then
            robJewelry()
        elseif Value.CargoPlane and workspace.Plane.PrimaryPart.Position.Y > 200 and game:GetService("Workspace").Plane.Crates.Crate1["1"].Transparency == 0 then
            robPlane()
       -- elseif Value.TrainCargo and game:GetService("Workspace").Trains.LocomotiveFront.Base.Position.X < 1912 and game:GetService("Workspace").Trains.LocomotiveFront.Base.Position.Z < -1524 then
           -- robCargo()
        elseif Value.Donut then
            robDonut()
        elseif Value.PowerPlant then
            robPower()
        elseif Value.Gas then
            robGas()
        elseif Value.Bank and not Banklayout.Name == "08Deductions" and not Banklayout.Name == "04Remastered" then
            robBank()
        elseif game.ReplicatedStorage.RobberyState[tostring(nameToId.Tomb)].Value == robberyConsts.ENUM_STATE.STARTED then
            robTomb()
        else
            Escape()
		    findEnterVehicle()
		    safePlatform.Position = Vector3.new(Root.Position.X, 300, Root.Position.Z)
		    GetLocalVehiclePacket().Model:SetPrimaryPartCFrame(CFrame.new(Root.Position.X, 305, Root.Position.Z))
		    repeat 
                wait(0.5) 
                vc("Waiting for stores to open"..string.rep('.', gc % 3 + 1))
                gc = gc + 1
            until Bb.CanCollide == false or (Value.Bank and not Banklayout.Name == "08Deductions" and not Banklayout.Name == "04Remastered") or Value.Gas or Value.TrainCargo or (Value.CargoPlane and workspace.Plane.PrimaryPart.Position.Y > 200 and workspace.Plane:FindFirstChild("Crates").Crate1['1'].Transparency == 0) or Value.Donut or Value.PowerPlant or Value.Jewelry or Value.TrainPassenger or not W.enabled
        end
    else
        status.Text = "Autorob disabled"
    end
end
