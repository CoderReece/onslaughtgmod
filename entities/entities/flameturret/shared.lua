//include("entemu.lua")

ENT.Type		= "anim"
//This makes sure this entity inherits everything from gamemodes/sandbox/entities/entities/base_gmodentity
//ENT.Base 		= "base_gmodentity"
ENT.PrintName		= "Turret"
ENT.Author		= "Jeff,Hxrmn, Matt Damon"
ENT.Contact		= "Visit the forums, fool."
ENT.Purpose		= "To destroy everything in sight."
ENT.Instructions	= "Spawn it and put an NPC in front of it, it will shoot said NPC."

ENT.Spawnable			= true
ENT.AdminSpawnable		= true

--Weapon related

--[[
	0,2,0 - Turret Yaw Local Pos, get angle from here to target position to derive Yaw from.
	-60 to 60 - Turret Yaw Parameter Range
	
	Turret Pitch Local Pos, get angle from here to target position to derive Pitch from.
	turretYaw:Forward() * 7 + Vector(0,0,53)
	
	-20 to 20 - Turret Pitch Parameter Range
]]--
function ENT:GetYawPitch(vec)
	--This gets the offset from 0,2,0 on the entity to the vec specified as a vector
	local yawAng=vec-self.Entity:LocalToWorld(Vector(0,0,0)) //0,2,0
	--Then converts it to a vector on the entity and makes it an angle ("local angle")
	local yawAng=self.Entity:WorldToLocal(self.Entity:GetPos()+yawAng):Angle()
	
	--Same thing as above but this gets the pitch angle. Since the turret's pitch axis and the turret's yaw axis are seperate I need to do this seperately.
	local pAng=vec-self.Entity:LocalToWorld((yawAng:Forward()*8)+Vector(0,0,50))
	local pAng=self.Entity:WorldToLocal(self.Entity:GetPos()+pAng):Angle()

	--Y=Yaw. This is a number between 0-360.	
	local y=yawAng.y
	--P=Pitch. This is a number between 0-360.
	local p=pAng.p
	
	--Numbers from 0 to 360 don't work with the pose parameters, so I need to make it a number from -180 to 180
	if y>=180 then y=y-360 end
	if p>=180 then p=p-360 end
	if y<-60 || y>60 then return false end
	if p<-20 || p>20 then return false end
	--Returns yaw and pitch as numbers between -180 and 180	
	return y,p
end

--This grabs yaw and pitch from ENT:GetYawPitch. If the turret "can aim" there, it returns true, and false otherwise.
--If this function returns false the turret will not fire.
--This function sets the facing direction of the turret also.
function ENT:Aim(vec)
	local y,p=self:GetYawPitch(vec)
	if y==false then
		return false
	end
	self.Entity:SetPoseParameter("aim_yaw",y)
	self.Entity:SetPoseParameter("aim_pitch",p)
	return true
end