class 'MazeModClient'

--wall shield
-- local wallPartitionGuid = Guid("f085ee56-a4d2-11e1-8f7b-a4270eaee571", "D")
-- local wallInstanceGuid = Guid("29a9e904-2ae7-14cf-43b4-4817e9cb899c", "D")

--objects/concretewall_01/concretewall_01
local wallPartitionGuid = Guid("82daaafa-040d-11de-beed-ff559017a74c","D")
local wallInstanceGuid = Guid("82daaafb-040d-11de-beed-ff559017a74c","D")

function MazeModClient:__init()
	print("Initializing MazeModClient")
	self:RegisterVars()
	self:RegisterEvents()
end


function MazeModClient:RegisterVars()
	self.m_SpawnedWalls = {}
end


function MazeModClient:RegisterEvents()
	self.m_EngineUpdateEvent = Events:Subscribe('Engine:Update', self, self.OnEngineUpdate)
end

function MazeModClient:SpawnWall(p_Transform) --DEBUG
	
	local s_WallBlueprint = ResourceManager:FindInstanceByGUID(wallPartitionGuid, wallInstanceGuid)

	if s_WallBlueprint == nil then
		print("Cound't find wall")
	end

	local s_WallBlueprint = _G[s_WallBlueprint.typeInfo.name](s_WallBlueprint)

	local s_Params = EntityCreationParams()
	s_Params.transform = p_Transform
	s_Params.variationNameHash = 0

	local s_ObjectEntities = EntityManager:CreateEntitiesFromBlueprint(s_WallBlueprint, s_Params)

	table.insert(self.m_SpawnedWalls, s_ObjectEntities)
	for i, entity in ipairs(s_ObjectEntities) do
		entity:Init(Realm.Realm_Client, true)
	end
end

function MazeModClient:OnEngineUpdate(p_Delta, p_SimDelta) --DEBUG
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()
  if s_LocalPlayer == nil then
    	return
    end
	if s_LocalPlayer.soldier == nil then
		return
	end
	if InputManager:WentKeyDown(InputDeviceKeys.IDK_F1) then
		print(s_LocalPlayer.soldier.transform)
		self:SpawnWall(s_LocalPlayer.soldier.transform)
	end

end

g_MazeModClient = MazeModClient()

