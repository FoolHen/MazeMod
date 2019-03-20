class 'MazeModServer'

local Maze = require "maze"

local wallPartitionGuid = Guid("82daaafa-040d-11de-beed-ff559017a74c","D")
local wallInstanceGuid = Guid("82daaafb-040d-11de-beed-ff559017a74c","D")

local startingpos = {x = 1282, y = 206, z = -947} --244 -60 863

local mazeWidth, mazeHeight = 30, 30

local wallWidth = 10.2
local wallHeight = 2.55
local spawnedWalls = {}

function MazeModServer:__init()
	print("Initializing MazeModServer")
	self:RegisterVars()
	self:RegisterEvents()
end


function MazeModServer:RegisterVars()
	self.m_Maze = Maze:new(mazeWidth, mazeHeight, false)

	recursive_backtracker(self.m_Maze)
end

function MazeModServer:RegisterEvents()
	self.m_PlayerChat = Events:Subscribe('Player:Chat', self, self.PlayerChat)
	Events:Subscribe('Server:LevelLoaded', self, self.OnLevelLoaded)

end

function MazeModServer:OnLevelLoaded(p_Map, p_GameMode, p_Round)
	self:BuildMaze()
end


function MazeModServer:PlayerChat(p_Player, p_RecipientMask, p_Message)
	if message == '' then
		return
	end

	local parts = p_Message:split(' ')

	if parts[1] == "wall" then
		local s_Soldier = p_Player.soldier
		if s_Soldier == nil then
			return 
		end

		local trans = s_Soldier.transform.trans

		local t1 = LinearTransform(
			Vec3(1.0, 0.0, 0.0),
			Vec3(0.0, 1.0, 0.0),
			Vec3(0.0, 0.0, 1.0),
			Vec3(trans.x, trans.y, trans.z + wallWidth/2) -- - (wallWidth/2.0)
		)
		print("spawning wall at "..tostring(trans))
		self:SpawnWallTrans(t1)
	end

	if parts[1] == "w" then
		local s_Soldier = p_Player.soldier
		if s_Soldier == nil then
			return 
		end

		-- local trans = s_Soldier.transform.trans
		print("startingpos = ".. startingpos.x ..", ".. startingpos.y ..", "..startingpos.z..", ")
		local t1 = LinearTransform(
			Vec3(1.0, 0.0, 0.0),
			Vec3(0.0, 1.0, 0.0),
			Vec3(0.0, 0.0, 1.0),
			Vec3(startingpos.x, startingpos.y, startingpos.z + wallWidth/2) -- - (wallWidth/2.0)
		)
		print("enfrente: " ..tostring(t1.trans))
		self:SpawnWall(t1)
	end

	if parts[1] == "tp" then
		local soldier = p_Player.soldier
		if soldier == nil then
			return
		end

		local pos = Vec3(
			startingpos.x - 2,
			startingpos.y,
			startingpos.z - 2
		)

		soldier:SetPosition(pos)

	end

	if parts[1] == "set" then
		local s_Soldier = p_Player.soldier
		if s_Soldier == nil then
			return 
		end

		local trans = s_Soldier.transform.trans
		startingpos.x = trans.x
		startingpos.y = trans.y
		startingpos.z = trans.z

		-- print(tostring(s_Soldier.transform))
	end

	if parts[1] == "pos" then
		local s_Soldier = p_Player.soldier
		if s_Soldier == nil then
			return 
		end

		local trans = s_Soldier.transform.trans

		print(s_Soldier.transform)
	end
end

function MazeModServer:BuildMaze()
	--Upper walls
	for i = 1, #self.m_Maze[1] do
		if self.m_Maze[1][i].north:IsClosed() then

			self:SpawnWall(true, - (i-1)*wallWidth, 0, 0)
			self:SpawnWall(true, - (i-1)*wallWidth, wallHeight, 0)
			self:SpawnWall(true, - (i-1)*wallWidth, 2*wallHeight, 0)
		end
	end


	for j, row in ipairs(self.m_Maze) do
		--Left Walls
		if row[1].west:IsClosed() then
			self:SpawnWall(false, 0, 0, - (j-1)*wallWidth)
			self:SpawnWall(false, 0, wallHeight, - (j-1)*wallWidth)
			self:SpawnWall(false, 0, 2*wallHeight, - (j-1)*wallWidth)
		end

		for i, cell in ipairs(row) do
			if cell.east:IsClosed() then
				self:SpawnWall(false, - (i-1)*wallWidth - wallWidth, 0 , - (j-1)*wallWidth)
				self:SpawnWall(false, - (i-1)*wallWidth - wallWidth, wallHeight , - (j-1)*wallWidth)
				self:SpawnWall(false, - (i-1)*wallWidth - wallWidth, 2*wallHeight , - (j-1)*wallWidth)
			end

			if cell.south:IsClosed() then
				self:SpawnWall(true, - (i-1)*wallWidth, 0,  - (j-1)*wallWidth - wallWidth)
				self:SpawnWall(true, - (i-1)*wallWidth, wallHeight,  - (j-1)*wallWidth - wallWidth)
				self:SpawnWall(true, - (i-1)*wallWidth, 2*wallHeight,  - (j-1)*wallWidth - wallWidth)
			end
		end
	end
end

function MazeModServer:SpawnWallTrans( p_Transform )
	-- Events:Dispatch('BlueprintManager:SpawnBlueprint', nil, wallPartitionGuid, wallInstanceGuid, tostring(p_Transform), nil)
end

function MazeModServer:SpawnWall( p_IsRotated, p_XOffset, p_YOffset, p_ZOffset )

	local s_Transform = LinearTransform(
		Vec3(1.0, 0.0, 0.0),
		Vec3(0.0, 1.0, 0.0),
		Vec3(0.0, 0.0, 1.0),

		Vec3(startingpos.x + p_XOffset, startingpos.y + p_YOffset, startingpos.z + p_ZOffset)
	)

	if p_IsRotated then
		s_Transform.left = Vec3(0.0, 0.0, -1.0)
		s_Transform.forward = Vec3(1.0, 0.0, 0.0)
	end

	Events:Dispatch('BlueprintManager:SpawnBlueprint', nil, wallPartitionGuid, wallInstanceGuid, tostring(s_Transform), nil)


	-- local s_WallBlueprint = ResourceManager:FindInstanceByGUID(wallPartitionGuid, wallInstanceGuid)

	-- if s_WallBlueprint == nil then
	-- 	print("Cound't find wall")
	-- else
	-- 	-- print("Found wall blueprint")
	-- end

	-- local s_WallBlueprint = _G[s_WallBlueprint.typeInfo.name](s_WallBlueprint)

	-- if s_WallBlueprint.needNetworkId == false then
	-- 	NetEvents:BroadcastLocal('MazeModClient:SpawnWall', s_Transform)
	-- end

	-- local s_Params = EntityCreationParams()
	-- s_Params.transform = s_Transform
	-- s_Params.variationNameHash = 0
	-- s_Params.networked = s_WallBlueprint.needNetworkId == true

	-- local s_ObjectEntities = EntityManager:CreateEntitiesFromBlueprint(s_WallBlueprint, s_Params)

	-- table.insert(spawnedWalls, s_ObjectEntities)

	-- for i, entity in ipairs(s_ObjectEntities) do
	-- 	entity:Init(Realm.Realm_ClientAndServer, true)
	-- end
end

function string:split(sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

--https://github.com/shironecko/LuaMaze
function recursive_backtracker(maze, x, y)
	local first_one = nil
	if not x then
		first_one = true
		maze:ResetDoors(true)

		MathUtils:GetRandomInt(from, to)

		x = MathUtils:GetRandomInt(1, #maze[1])
		y = MathUtils:GetRandomInt(1, #maze)
		-- x, y = random(#maze[1]), random(#maze)
	end
	
	maze[y][x].visited = true
	
	local directions = maze:DirectionsFrom(x, y, function (cell) return not cell.visited end)  
	while #directions ~= 0 do
		-- local rand_i = random(#directions)
		local rand_i = MathUtils:GetRandomInt(1, #directions)
		local dirn = directions[rand_i]
		
		directions[rand_i] = directions[#directions]
		directions[#directions] = nil
		
		if not maze[dirn.y][dirn.x].visited then
			maze[y][x][dirn.name]:Open()
			recursive_backtracker(maze, dirn.x, dirn.y)
		end
	end
	
	if first_one then maze:ResetVisited() end
end

g_MazeModServer = MazeModServer()

