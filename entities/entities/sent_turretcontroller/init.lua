
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.Shealth = GAMEMODE.Config.TURRET_HEALTH
ENT.Turret = nil
ENT.Owner = nil
ENT.LastTouch = CurTime()

function ENT:Initialize()   
	self.Entity:SetModel( "models/props_c17/oildrum001.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self:SetNoDraw( true )
	self:DrawShadow( false )	
	
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake()
		phys:EnableMotion(false)
	end 
	self.Turret = self.Entity:GetParent()
end

function ENT:SpawnFunction( ply, tr)

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "sent_turretcontroller" )
	
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:Think() //Called every frame
end

function ENT:Touch(ent) -- Zombies need all the help they can get :-(
	if table.HasValue(Zombies, ent:GetClass()) && self.LastTouch + 2 < CurTime() then
		ent:SetSchedule(SCHED_MELEE_ATTACK1)
		ent:SetNPCState(3)
		self.Shealth = self.Shealth - 10
		self.LastTouch = CurTime()
		if self.Shealth <= 0 then
			self:DoExplosions()
		end
	end
end

function ENT:OnTakeDamage(dmg)
	if dmg:GetInflictor():IsPlayer() then
	 	dmg:SetDamage(0)
		return dmg 
	elseif IsValid(dmg:GetInflictor():GetOwner()) then
		if dmg:GetInflictor():GetOwner():IsPlayer() then
			dmg:SetDamage(0)
			return dmg
		end
	end
	self.Shealth = self.Shealth - dmg:GetDamage() 
	self.Turret:SetNWInt("health",self.Shealth)
	if self.Shealth <= 0 then
		self:DoExplosions()
	end
end

function ENT:DoExplosions(id)
	local effectdata = EffectData()
	local pos = self.Entity:GetPos()
	effectdata:SetStart( pos )
	effectdata:SetOrigin( pos )
	effectdata:SetScale( 1 )
	util.Effect( "Explosion", effectdata )
	self.Turret:Remove()
	self.Entity:Remove()
	self:GetOwner():Message("One of your turrets has died!",Color(255,100,100,255))
end





