class 'MazeModShared'

require "__shared/Util/Logger"

local m_vuExtensions = require "__shared/Util/VUExtensions"

function MazeModShared:__init()
	print("Initializing MazeModShared")
	self:RegisterVars()
	self:RegisterEvents()
end


function MazeModShared:RegisterVars()
	--self.m_this = that
end


function MazeModShared:RegisterEvents()
  -- Events:Subscribe('Partition:Loaded', self, self.OnPartitionLoaded)
end

function MazeModShared:OnPartitionLoaded(p_Partition)
	local s_Instances = p_Partition.instances

	for _, s_Instance in ipairs(s_Instances) do
		if s_Instance == nil then
			return
		end

		-- WaterEntityData
		if s_Instance.instanceGuid == Guid("03B86272-9A5E-D87D-9632-101F1BCD0BAE") then
			print("Found WaterEntityData")
			local s_ObjectInstance = m_vuExtensions:MakeWritable(s_Instance)

			s_ObjectInstance.enabled = false
			s_ObjectInstance.asset = nil --This removes the water, but not the mesh+texture, so you can fall through it.

			print("Water removed")
		end
	end
end

g_MazeModShared = MazeModShared()

