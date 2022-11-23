--[[

    Changelog:



]]

--[[ ==========  Macros  ========== ]]

LPH_ENCSTR = function(...) return ... end

--[[ ==========  Settings  ========== ]]

local settings = {
    aimbot = {
        aimbot = {
            enabled = false,
            aimKey = "MouseButton2",
            ignoreAimKey = false,
            wallCheck = false,
            smoothness = 1,
            aimPart = "HumanoidRootPart"
        },
        silentAim = {
            enabled = false,
            hitChance = 100,
            headshotChance = 0
        },
        fov = {
            enabled = false,
            radius = 100
        },
        autoFire = {
            triggerbot = false,
            autoShoot = false,
            autoWall = false
        }
    },
    visuals = {
        misc = {
            minimapShowAll = false
        }
    },
    teleports = {
        locations = {
            eject = false
        }
    },
    vehicleMods = {
        cars = {
            speed = 1,
            brakes = 1,
            height = 1,
            turn = 1,
            driveOnWater = false,
            autoFlip = false,
            antiTirePop = false,
            antiPitManeuver = false
        },
        helis = {
            speed = 1,
            antiFall = false,
            instantPickup = false,
            infHeliHeight = false,
            infDroneHeight = false
        },
        boats = {
            speed = 1,
            boatsOnLand = false,
            jetskiOnLand = false
        },
        offense = {
            popTires = false,
            shootDownHelis = false,
            teamCheck = false
        }
    },
    itemMods = {
        gunMods = {
            wallbang = false,
            noFlintlockKnockback = false
        },
        fireRate = {
            enabled = false,
            rate = 0
        },
        jetPack = {
            infFuel = false,
            premiumFuel = false
        },
        utility = {
            shootWhileDriving = false,
            shootWhileJetpacking = false
        },
        projectiles = {
            disableMilitary = false,
            disableTurrets = false,
            disableDispensers = false
        }
    },
    playerMods = {
        charMods = {
            walkEnabled = false,
            walkSpeed = 16,
            jumpEnabled = false,
            jumpPower = 50,
            flySpeed = 150,
            infJump = false,
            instantSpecs = false,
            noPunchCooldown = false,
            antiRagdoll = false,
            antiFallDamage = false,
            antiTaze = false,
            antiSkydive = false
        },
        cosmetic = {
            orangeJustice = false
        },
        safes = {
            autoSkip = false
        }
    },
    robbery = {
        autoRob = {
            enabled = false
        },
        robMods = {
            autoSolve = false,
            autoJewel = false,
            autoMuseum = false,
            noIconDelay = false,
            notify = false,
        }
    },
    funMods = {
        doors = {
            bypassCheck = false,
            loopOpen = false  
        },
        wall = {
            loopExplode = false
        },
        gate = {
            loopLift = false
        },
        sewers = {
            loopOpen = false
        },
        volcano = {
            loopErupt = false
        }
    }
}

--[[ ==========  Variables  ========== ]]


local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local collectionService = game:GetService("CollectionService")
local httpService = game:GetService("HttpService")
local pathfindingService = game:GetService("PathfindingService")
local virtualInputManager = game:GetService("VirtualInputManager")
local teams = game:GetService("Teams")
local players = game:GetService("Players")

local player = players.LocalPlayer
local mouse = player:GetMouse()
local cam = workspace.CurrentCamera
local moneyValue = player:WaitForChild("leaderstats"):WaitForChild("Money")
local controls = require(player.PlayerScripts.PlayerModule):GetControls()


local museumPuzzle1 = workspace.Museum.Puzzle1
local museumPuzzle2 = workspace.Museum.Puzzle2.Pieces

local localScript = player.PlayerScripts:WaitForChild("LocalScript")
local robberyMarkerSys = replicatedStorage.Game.RobberyMarkerSystem

local robberyMoneyGui = player.PlayerGui:WaitForChild("RobberyMoneyGui")
local bagLabel = robberyMoneyGui.Container.Bottom.Progress.Amount
local minimap = player.PlayerGui.AppUI.Buttons.Minimap.Map.Container.Points

local branch = workspace.Switches.BranchBack
local doors = getupvalue(getconnections(collectionService:GetInstanceRemovedSignal("Door"))[1].Function, 1)

local modules = {
    bulletEmitter = require(replicatedStorage.Game.ItemSystem.BulletEmitter),
    plasmaPistol = require(replicatedStorage.Game.Item.PlasmaPistol),
    basic = require(replicatedStorage.Game.Item.Basic),
    taser = require(replicatedStorage.Game.Item.Taser),
    itemSystem = require(replicatedStorage.Game.ItemSystem.ItemSystem),
    defaultActions = require(replicatedStorage.Game.DefaultActions),
    museum = require(replicatedStorage.Game.Museum),
    falling = require(replicatedStorage.Game.Falling),
    playerUtils = require(replicatedStorage.Game.PlayerUtils),
    puzzleFlow = require(replicatedStorage.Game.Robbery.PuzzleFlow),
    gunShopUtils = require(replicatedStorage.Game.GunShop.GunShopUtils),
    gunShopUI = require(replicatedStorage.Game.GunShop.GunShopUI),
    characterUtil = require(replicatedStorage.Game.CharacterUtil),
    vehicle = require(replicatedStorage.Game.Vehicle),
    boat = require(replicatedStorage.Game.Boat.Boat),
    gun = require(replicatedStorage.Game.Item.Gun),
    jetPack = require(replicatedStorage.Game.JetPack.JetPack),
    jetPackGui = require(replicatedStorage.Game.JetPack.JetPackGui),
    jetPackUtil = require(replicatedStorage.Game.JetPack.JetPackUtil),
    cartSystem = require(replicatedStorage.Game.Cart.CartSystem),
    gamepassSystem = require(replicatedStorage.Game.Gamepass.GamepassSystem),
    gamepassUtils = require(replicatedStorage.Game.Gamepass.GamepassUtils),
    robberyConsts = require(replicatedStorage.Game.Robbery.RobberyConsts),
    tombSystem = require(replicatedStorage.Game.Robbery.TombRobbery.TombRobberySystem),
    turret = require(replicatedStorage.Game.Robbery.CargoShip.Turret),
    dispenser = require(replicatedStorage.Game.DartDispenser.DartDispenser),
    militaryTurret = require(replicatedStorage.Game.MilitaryTurret.MilitaryTurret),
    destructibleSpawn = require(replicatedStorage.Game.Destructible.DestructibleSpawn),
    party = require(replicatedStorage.Game.Party),
    vehicleData = require(replicatedStorage.Game.Garage.VehicleData),
    alexChassis = require(replicatedStorage.Module.AlexChassis),
    ui = require(replicatedStorage.Module.UI),
    rayCast = require(replicatedStorage.Module.RayCast),
    localization = require(replicatedStorage.Module.Localization),
    gameSettings = require(replicatedStorage.Resource.Settings),
    inventoryItemSystem = require(replicatedStorage.Inventory.InventoryItemSystem),
    inventoryItemUtils = require(replicatedStorage.Inventory.InventoryItemUtils)
}

local originals = {
    emit = modules.bulletEmitter.Emit,
    shootOther = modules.plasmaPistol.ShootOther,
    updateMousePosition = modules.basic.UpdateMousePosition,
    tase = modules.taser.Tase,
    setAttr = modules.inventoryItemUtils.setAttr,
    ragdoll = modules.falling.StartRagdolling,
    isPointInTag = modules.playerUtils.isPointInTag,
    getLocalVehiclePacket = modules.vehicle.GetLocalVehiclePacket,
    updatePhysics = modules.boat.UpdatePhysics,
    isJetPackFlying = modules.jetPack.IsFlying,
    doesPlayerOwn = modules.gamepassSystem.DoesPlayerOwn,
    turretShoot = modules.turret.Shoot,
    dispenserFire = modules.dispenser._fire,
    militaryFire = modules.militaryTurret._fire,
    vehicleEnter = modules.alexChassis.VehicleEnter,
    updatePrePhysics = modules.alexChassis.UpdatePrePhysics,
    rayIgnoreNonCollide = modules.rayCast.RayIgnoreNonCollide,
    rayIgnoreNonCollideWithIgnoreList = modules.rayCast.RayIgnoreNonCollideWithIgnoreList,
    launchFireworks = getupvalue(modules.party.Init, 1),
    }

local specs = modules.ui.CircleAction.Specs
local event = getupvalue(modules.alexChassis.SetEvent, 1)
local puzzle = getupvalue(modules.puzzleFlow.Init, 3)
local defaultActions = getupvalue(modules.defaultActions.punchButton.onPressed, 1)
local destructibleFolder = getupvalue(getproto(modules.destructibleSpawn._setup, 3, true)[1], 7)

local attemptPunch = defaultActions.attemptPunch

local jetPackTable = getupvalue(getproto(modules.jetPack.Init, 1, true)[1], 1)
originals.jetPackEquip = jetPackTable.EquipLocal
local jetPackEquipped = nil

local museumDetect = getproto(getproto(modules.museum, 9, true)[1], 1)
local museumDetectIndex = table.find(getconstants(museumDetect), 0.5)
originals.fireServer = getupvalue(event.FireServer, 1)

local orangeJusticeTrack = nil
local timeFunc, timeFuncIndex = nil, nil
local vehicleClasses, isHoldingIndex = nil, nil
local equipCondition = nil

local fovCircle = Drawing.new("Circle")
local gunTables, gunData = {}, {}
local connections, clientHashes = {}, {}
local statusLabels, robberyStates, hasRobbed = {}, {}, {}
local wallbangIgnore = {}
local ownedVehicles = {}
local carNames, heliNames = {}, {}
local char, root, hum = nil, nil, nil
local target = nil
local isAimKeyDown, isFlying, isTeleporting = false, false, false
local baseFlyVec = Vector3.new(0, 1e-10, 0)
local pickUpItem = false
local currentRobbery, doCancelTp, cancelTp = "", false, false
local noFlyAreas, noClipAllowed = {}, {}

local flyKeys = {
	W = false,
	A = false,
	S = false,
	D = false,
	Space = false,
	LeftShift = false
}

local fakeSniper = {
    __ClassName = "Sniper",
    Local = true,
    IgnoreList = {},
    LastImpact = 0,
    LastImpactSound = 0,
}

local pathRotations = {
    ["2"] = Vector3.new(180, -51.94, 0),
    ["3"] = Vector3.new(-180, -51.94, -180),
    ["10"] = Vector3.new(180, -51.94, 0),
    ["11"] = Vector3.new(-180, -51.94, -180),
    ["12"] = Vector3.new(-180, -51.94, -180),
    ["19"] = Vector3.new(180, -51.94, 0),
    ["20"] = Vector3.new(-180, -51.94, 90),
    ["13"] = Vector3.new(180, -51.94, -90),
    ["14"] = Vector3.new(-180, -51.94, -180)
}

local robberyLocations = {
	["Bank"] = CFrame.new(-12, 20, 782),
	["Jewelry Store"] = CFrame.new(126, 20, 1368),
	["Museum"] = CFrame.new(1142, 104, 1247),
	["Power Plant"] = CFrame.new(636, 39, 2357),
    ["Tomb"] = CFrame.new(465, 21, -464),
	["Donut Store"] = CFrame.new(90, 20, -1511),
	["Gas Station"] = CFrame.new(-1526, 19, 699)
}

local placeLocations = {
	["Prison Yard"] = CFrame.new(-1220, 18, -1760),
	["1M Dealership"] = CFrame.new(720, 20, -1572),
	["Volcano Base"] = CFrame.new(1816, 48, -1634),
	["Military Base"] = CFrame.new(685, 19, 485),
    ["Police Headquarters"] = CFrame.new(183, 18, 1084),
	["Secret Agent Base"] = CFrame.new(1527, 86, 1551),
	["City Base"] = CFrame.new(-250, 18, 1616),
	["Boat Docks"] = CFrame.new(-430, 21, 2025),
	["Airport"] = CFrame.new(-1202, 41, 2846),
	["Fire Station"] = CFrame.new(-930, 32, 1349),
	["Gun Store"] = CFrame.new(391, 18, 533),
	["JetPack Mountain"] = CFrame.new(1384, 168, 2596),
	["Pirate Hideout"] = CFrame.new(1955, 14, 2117),
	["Lighthouse"] = CFrame.new(-2044, 45, 1722),
	["Prison Island"] = CFrame.new(-2917, 24, 2312),
    ["Season Leaderboard"] = CFrame.new(-1304, 18, -924),
    ["Hacker Cage"] = CFrame.new(-306, 20, 301),
    ["Events Room"] = CFrame.new(64, 19, 1144),
    ["Train Station"] = CFrame.new(1635, 19, 258),
    ["Glider Store"] = CFrame.new(175, 20, -1720),
    ["Dog Shelter"] = CFrame.new(252, 20, -1620)
}

local bankLayoutPaths = {
    TheMint = {
        CFrame.new(52, 20, 857),
        CFrame.new(94, 3, 858),
        CFrame.new(96, 3, 795),
        CFrame.new(65, 2, 762)
    },
    Corridor = {
        CFrame.new(50, 20, 857),
        CFrame.new(50, -7, 857),
        CFrame.new(52, -7, 861)
    },
    Presidential = {
        CFrame.new(48, 20, 857),
        CFrame.new(47, -6, 857),
        CFrame.new(72, -6, 858),
        CFrame.new(79, -6, 933),
        CFrame.new(47, -6, 933)
    },
    Remastered = {
        CFrame.new(51, 20, 857),
        CFrame.new(93, 3, 858),
        CFrame.new(95, 3, 818)
    },
    Basement = {
        CFrame.new(44, 20, 856),
        CFrame.new(75, 11, 858),
        CFrame.new(75, 1, 884),
        CFrame.new(75, 1, 905),
        CFrame.new(43, -7, 885)
    },
    Underwater = {
        CFrame.new(51, 19, 856),
        CFrame.new(93, 3, 858),
        CFrame.new(96, -12, 801)
    },
    Deductions = {
        CFrame.new(52, 20, 857),
        CFrame.new(93, 3, 858),
        CFrame.new(89, 3, 918),
        CFrame.new(37, 2, 888)
    },
    TheBlueRoom = {
        CFrame.new(48, 21, 856),
        CFrame.new(48, 2, 856)
    }
}

local tombExits = {
    CFrame.new(1283, 18, -1143),
    CFrame.new(206, 21, 234)
}

local playerSpeed = 150
local vehicleSpeed = 350
local tpHeight = 300

--[[ ==========  Garbage Collection  ========== ]]

local hasBypassedAC
local openDoor, registerDoor, clientEvents, vehicleTable, exitVehicle, formatMoney, robberyMarkerStates

for i, v in next, getgc() do
    if hasBypassedAC and openDoor and registerDoor and clientEvents and vehicleTable and exitVehicle and formatMoney and robberyMarkerStates then break end
    if type(v) == "function" and islclosure(v) then
        local scr = getfenv(v).script
        if scr == localScript then
            local name, consts = getinfo(v).name, getconstants(v)
            if name == "DoorSequence" then
                openDoor = v
            elseif name == "RegisterDoor" then
                registerDoor = v
            elseif name == "FormatMoney" then
                formatMoney = v
            elseif name == "StopNitro" then
                clientEvents = getupvalue(getupvalue(v, 1), 2)
            elseif table.find(consts, "FailedPcall") then
				setupvalue(v, 2, true) -- Anticheat
                hasBypassedAC = true
            elseif table.find(consts, "NitroLastMax") and table.find(consts, "NitroForceUIUpdate") then
                vehicleTable = getupvalue(v, 1)
                for i, v in next, vehicleTable.VehiclesOwned do
                    ownedVehicles[i] = true
                end
            elseif table.find(consts, "FireServer") and table.find(consts, "LastVehicleExit") and table.find(consts, "tick") then
                exitVehicle = v
            end
        elseif scr == robberyMarkerSys and getinfo(v).name == "setRobberyMarkerState" then
            robberyMarkerStates = getupvalue(v, 1)
        end
    end
end

local nameToId = {}
for i, v in next, robberyMarkerStates do
    nameToId[v.Name] = v.RobberyId
end

--[[ ==========  Custom Functions  ========== ]]

local function addConnection(name, conn)
    connections[name] = conn
end

local function stopConnection(name)
    if connections[name] then
        connections[name]:Disconnect()
        connections[name] = nil
    end
end

local function orangeJustice()
    if hum then
        local anim = Instance.new("Animation")
        anim.AnimationId = "http://www.roblox.com/asset/?id=3066265539"
        orangeJusticeTrack = hum:LoadAnimation(anim)
        orangeJusticeTrack:Play()
    end
end

local function registerChar(character)
    char, root, hum = character, character:WaitForChild("HumanoidRootPart"), character:WaitForChild("Humanoid")
    if settings.playerMods.cosmetic.orangeJustice then
        orangeJustice()
    end
    if settings.playerMods.charMods.walkEnabled then
        hum.WalkSpeed = settings.playerMods.charMods.walkSpeed
    end
    if settings.playerMods.charMods.jumpEnabled then
        hum.JumpPower = settings.playerMods.charMods.jumpPower
    end
    char.ChildAdded:Connect(function(child)
        if isTeleporting and child.Name == "Handcuffs" then
            cancelTp = true
        end
    end)
    hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if hum and settings.playerMods.charMods.walkEnabled then
            hum.WalkSpeed = settings.playerMods.charMods.walkSpeed
        end
    end)
    hum.Died:Connect(function()
        if isTeleporting then
            cancelTp = true
        end
        isAtAfk = false
        char, root, hum = nil, nil, nil
    end)
end


local function getTarget()
	local retPart, dist = nil, settings.aimbot.fov.enabled and settings.aimbot.fov.radius or math.huge
	for i, v in next, players:GetPlayers() do
        if v.Team ~= player.Team then
            local rootPart = v.Character and v.Character:FindFirstChild(settings.aimbot.aimbot.aimPart)
            if rootPart then
                local pos, vis = cam:WorldToScreenPoint(rootPart.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    if mag < dist then
                        retPart, dist = rootPart, mag
                    end
                end
            end
        end
	end
	return retPart
end

local function openDoors()
    for i, v in next, doors do
        if not v.State.Open then
            openDoor(v)
        end
    end
end

local function explodeWall()
    for i, v in next, specs do
        if v.Name == "Explode Wall" then
            v:Callback(true)
            break
        end
    end
end

local function liftGate()
    for i, v in next, specs do
        if v.Name == "Lift Gate" then
            v:Callback(true)
            break
        end
    end
end

local function openSewers()
    for i, v in next, specs do
        if v.Name == "Pull Open" then
            v:Callback(true)
        end
    end
end

local function pressKey(key)
    virtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait()
    virtualInputManager:SendKeyEvent(false, key, false, game)
end


local function solvePuzzle()
    local grid = {}
    cache.misc:DeepCopy(puzzle.Grid, grid, true)
	for i, v in next, grid do
		for i2, v2 in next, v do
			v[i2] = v2 + 1
		end
	end
	local solution = httpService:JSONDecode(httprequest({
		Url = "https://numberlink-solver.sagesapphire.repl.co",
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = httpService:JSONEncode({
			Matrix = grid
		})
	}).Body).Solution
	for i, v in next, solution do
		for i2, v2 in next, v do
			v[i2] = v2 - 1
		end
	end
	puzzle.Grid = solution
	puzzle.OnConnection()
end


local function tableFind(tab, val)
    for i, v in next, tab do
        if v == val then
            return i
        end
    end
end

local function getXZDir(start, target)
	local xzNow = Vector3.new(start.Position.X, 0, start.Position.Z)
	local xzEnd = Vector3.new(target.Position.X, 0, target.Position.Z)
	return (xzEnd - xzNow).Unit
end

local function getXZMag(start, target)
	local xzNow = Vector3.new(start.Position.X, 0, start.Position.Z)
	local xzEnd = Vector3.new(target.Position.X, 0, target.Position.Z)
	return (xzEnd - xzNow).Magnitude
end

local function tryEnterSeat(seat)
	local success = false
	for i, v in next, specs do
		if v.Part == seat then
			if v.Name == "Hijack" then
				v:Callback(true)
				task.wait(0.5)
				success = tryEnterSeat(seat)
				break
			end
			v:Callback(true)
			task.wait(0.5)
			success = originals.getLocalVehiclePacket() ~= nil
			break
		end
	end
	return success
end


local function getTeleportIgnoreList()
    local ignoreList = { workspace.Vehicles, workspace.Items, workspace.Trains, destructibleFolder, workspace.Terrain.Clouds, char }
    for i, v in next, doors do
        if v.Model then
            ignoreList[#ignoreList + 1] = v.Model
        end
    end
    for i, v in next, noClipAllowed do
        ignoreList[#ignoreList + 1] = i
    end
    if workspace:FindFirstChild("Rain") then
        ignoreList[#ignoreList + 1] = workspace.Rain
    end
    return ignoreList
end

local function randomVector()
    local x, y, z = math.random(-150, 150), math.random(-150, 150), math.random(-150, 150)
    return Vector3.new(x / 1000, y / 1000, z / 1000)
end

local function getNextLocation(start, target, speed, step)
    local dir, mag = getXZDir(start, target), math.min((speed * step) + (math.random(-150, 150) / 1000), getXZMag(start, target))
    return CFrame.new(Vector3.new(start.Position.X, tpHeight, start.Position.Z) + ((dir * mag) + randomVector()), Vector3.new(target.Position.X, start.Position.Y, target.Position.Z) + target.LookVector)
end

local function getNextDirectLocation(start, target, speed, step)
    local dir, mag = (target.Position - start.Position).Unit, math.min((speed * step) + (math.random(-150, 150) / 1000), (target.Position - start.Position).Magnitude)
    return CFrame.new(start.Position + ((dir * mag) + randomVector()), Vector3.new(target.Position.X, start.Position.Y, target.Position.Z) + target.LookVector)
end

local function playerTeleportDirect(target, speed, drop)
	local success, arrived, isInstance = true, false, typeof(target) == "Instance"
	workspace.Gravity = 0
	local conn = runService.Stepped:Connect(function(dur, step)
        if char == nil or root == nil or cancelTp then
            success, arrived, cancelTp = false, true, false
        else
            for i, v in next, char:GetChildren() do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
            root.CFrame = getNextDirectLocation(root, isInstance and target.CFrame or target, speed, step)
            root.Velocity, root.RotVelocity = Vector3.new(), Vector3.new()
            if getXZMag(root, target) < 0.5 then
                arrived = true
            end
        end
	end)
	repeat task.wait() until arrived
	conn:Disconnect()
    if success then
        root.CFrame = drop and (isInstance and target.CFrame or target) or CFrame.new((isInstance and target.CFrame or target).Position, target.Position + root.CFrame.LookVector)
        root.Velocity, root.RotVelocity = Vector3.new(), Vector3.new()
        for i, v in next, char:GetChildren() do
            if v:IsA("BasePart") then
                v.CanCollide = true
            end
        end
    end
	workspace.Gravity = drop and 196.2 or 0
    return success
end

local function playerTeleport(target, options)
    local success, isInstance = true, typeof(target) == "Instance"
	if select(1, workspace:FindPartOnRayWithIgnoreList(Ray.new(root.Position, Vector3.new(0, tpHeight - root.Position.Y, 0)), getTeleportIgnoreList(), false, true)) ~= nil then
		local pathFound, excluded = false, {}
		repeat
            if cancelTp then
                success, cancelTp = false, false
                break
            end
			local destructibles = {}
			for i, v in next, destructibleFolder:GetChildren() do
				if excluded[v.PrimaryPart] == nil then
					destructibles[#destructibles + 1] = v.PrimaryPart
				end
			end
			table.sort(destructibles, function(a, b)
				return (a.Position - root.Position).Magnitude < (b.Position - root.Position).Magnitude
			end)
			local path = pathfindingService:CreatePath({ AgentCanJump = false, WaypointSpacing = 25 })
			path:ComputeAsync(root.Position, destructibles[1].Position)
			if path.Status == Enum.PathStatus.Success then
				local waypoints = path:GetWaypoints()
				for i = 1, #waypoints do
                    local mag = (waypoints[i].Position - root.Position).Magnitude
					if playerTeleportDirect(CFrame.new(waypoints[i].Position + Vector3.new(0, 4, 0)), mag < 24 and 25 or 60, i == #waypoints) then
                        if select(1, workspace:FindPartOnRayWithIgnoreList(Ray.new(root.Position, Vector3.new(0, tpHeight - root.Position.Y, 0)), getTeleportIgnoreList(), false, true)) == nil then
                            break
                        end
                    else
                        success = false
                        break
                    end
				end
				pathFound = true
			else
				excluded[destructibles[1]] = true
			end
			task.wait(0.25)
		until success == false or pathFound == true
        setupPathfinding(false)
		task.wait(0.25)
	end
	local arrived = false
	workspace.Gravity = 0
    task.wait(0.1)
	local conn = runService.Stepped:Connect(function(dur, step)
        if root == nil or cancelTp then
            success, arrived, cancelTp = false, true, false
        else
            root.CFrame = getNextLocation(root, isInstance and target.CFrame or target, playerSpeed, step)
            root.Velocity, root.RotVelocity = Vector3.new(), Vector3.new()
            if getXZMag(root, target) < 0.5 then
                arrived = true
            end
        end
	end)
	repeat task.wait() until arrived
	conn:Disconnect()
	if success then
        if options.stallDrop then
            repeat
                root.CFrame = getNextLocation(root, isInstance and target.CFrame or target, playerSpeed, 1)
                root.Velocity, root.RotVelocity = Vector3.new(), Vector3.new()
                task.wait()
            until options.stallDrop()
        end
        root.CFrame = isInstance and target.CFrame or target
        root.Velocity, root.RotVelocity = Vector3.new(), Vector3.new()
    end
	workspace.Gravity = 196.2
    return success
end

local function carTeleport(target, options)
	local success = true
    local isInstance = typeof(target) == "Instance"
    local vehicle = originals.getLocalVehiclePacket()
    local vehicleModel = vehicle.Model
    local VehiclePart = vehicle.Model.PrimaryPart
    local arrived = false
    local hasLift = vehicle.Lift ~= nil
	if hasLift then
		modules.alexChassis.SetGravity(vehicle, 0)
	end
	local conn = game.RunService.Stepped:Connect(function(dur, step)
        if vehicle.Model.PrimaryPart then
            vehicleModel:SetPrimaryPartCFrame(getNextLocation(VehiclePart, isInstance and target.CFrame or target, vehicleSpeed, step))
            VehiclePart.Velocity, VehiclePart.RotVelocity = Vector3.new(), Vector3.new()
            if getXZMag(VehiclePart, target) < 0.5 then
                arrived = true
            end
        else
            success = false
            arrived = true
        end
	end)
	repeat task.wait() until arrived
	conn:Disconnect()
	if success then
        if options.stallDrop then
            repeat
                vehicleModel:SetPrimaryPartCFrame(getNextLocation(VehiclePart, isInstance and target.CFrame or target, vehicleSpeed, 1))
                VehiclePart.Velocity, VehiclePart.RotVelocity = Vector3.new(), Vector3.new()
                task.wait()
            until options.stallDrop
        end
        vehicleModel:SetPrimaryPartCFrame(isInstance and target.CFrame or target)
        VehiclePart.Velocity, VehiclePart.RotVelocity = Vector3.new(), Vector3.new()
        if hasLift then
            modules.alexChassis.SetGravity(vehicle, 100 or 0)
        end
        if options.exitVehicle then
            task.wait(0.25)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "Space", false, game)
            
            wait()
            
            game:GetService("VirtualInputManager"):SendKeyEvent(false, "Space", false, game)
            task.wait(0.25)
        end
    else
        workspace.Gravity = 196.2
    end
    
return success
end

local function teleport(target, options)
    local success = true

    isTeleporting = true
    tpHeight = math.random(300, 350)
    controls:Disable()
	if options.mode == "Car" then
        if originals.getLocalVehiclePacket() then
            success = carTeleport(target, options)
        else
            success = false
        end
	end
    controls:Enable()
    isTeleporting = false
    return success
end

return teleport
