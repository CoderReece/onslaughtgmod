
ENT.Base = "base_entity"
ENT.Type = "brush"

function ENT:Initialize()
end

function ENT:Touch(ent)
	if ent:IsPlayer() then
		ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	end
end

function ENT:StartTouch(ent)
	if PHASE == "BUILD" then
		if ent:IsProp() then ent:PropRemove(true) end
		if ent:GetClass() == "sent_spawnpoint" then ent:Remove() end
	end
	if ent:IsPlayer() then
		ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	end
end

function ENT:EndTouch(ent)
	if ent:IsPlayer() then
		ent:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	end
end

function ENT:Think()

end
