AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize( )   
	self.Entity:SetModel( "models/props_c17/oildrum001.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetNoDraw( true )
	self:DrawShadow( false )	

	local phys = self.Entity:GetPhysicsObject( )  	
	if phys:IsValid( ) then  		
		phys:Wake( )
		phys:EnableMotion( false )
	end
	local ED = EffectData( )
	ED:SetEntity(self)
	ED:SetOrigin(self:GetPos())
	util.Effect( "spawnpoint", ED )
	self.snd = CreateSound( self, "k_lab.teleport_rings_high")
	self.snd:Play()
end

function ENT:Touch(ent)
end

function ENT:Think( )
end

function ENT:Remove()
	self.snd:Stop()
end
