if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Pulse Rifle"
	SWEP.DrawCrosshair		= true
	SWEP.DrawAmmo			= false
	SWEP.ViewModelFOV		= 60
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 2
end

--Swep info and other stuff

SWEP.Base = "ose_base"

SWEP.Author	= "Conman420 + Matt"
SWEP.Contact = "FP thread"
SWEP.Purpose = "Killing hunters with one shot."
SWEP.Instructions = "Primary : Fires a pulse round.\nSecondary : Fires a combine ball."
SWEP.AdminSpawnable	= false
SWEP.Spawnable	= false
SWEP.HoldType			= "ar2"
SWEP.ViewModel	= "models/weapons/v_irifle.mdl"
SWEP.WorldModel	= "models/weapons/w_irifle.mdl"
SWEP.Primary.ClipSize = 30
SWEP.Primary.Damage = 13.4
SWEP.Primary.Bullets = 1
SWEP.Primary.Delay = 0.1
SWEP.Primary.Cone = 0.02
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "AR2"
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "AR2AltFire"
SWEP.Secondary.Sound = Sound( "Weapon_CombineGuard.Special1" )
SWEP.Secondary.Sound2 = Sound("Weapon_IRifle.Single")
SWEP.Ball = nil

function SWEP:Holster(wep)

	return true
end

function SWEP:Think()
	/*if self.Owner:KeyPressed( IN_ATTACK ) then
		if ( !self:CanPrimaryAttack() ) then return end
		local speed = CLASSES[self.Owner:GetNetworkedInt("class")].SPEED / 1.5
		GAMEMODE:SetPlayerSpeed(self.Owner, speed, speed)
	end
	if self.Owner:KeyReleased( IN_ATTACK ) then
		local speed = CLASSES[self.Owner:GetNetworkedInt("class")].SPEED
		GAMEMODE:SetPlayerSpeed(self.Owner, speed, speed)
	end*/
end

function SWEP:DoImpactEffect(tr,dmgtype)
	local auto = EffectData()
	auto:SetOrigin(tr.HitPos)
	auto:SetNormal(tr.HitNormal)
	util.Effect("AR2Impact", auto)
end

function SWEP:PrimaryAttack()
 	if ( !self:CanPrimaryAttack() ) then return end
	
	self.Weapon:SetNextPrimaryFire( CurTime( ) + .1 )
	self.Weapon:EmitSound("Weapon_AR2.Single")
	
	local prf = WEP_PREFIXES[self.Prefix] or WEP_PREFIXES[1]
	
	local dmgmod = prf.DMG or 0
	local conemod = prf.CONE or 0
	
	local dmg = self.Primary.Damage - (self.Primary.Damage * dmgmod)
	local cone = self.Primary.Cone - (self.Primary.Cone * conemod)

	self:ShootBullet(dmg, self.Primary.Bullets, cone)

	self:TakePrimaryAmmo( 1 )
		self.Owner:ViewPunch( Angle( math.random(-0.75,0.75), math.random(-1,1), 0 ) )
	if CLIENT then
		self.Weapon:SendWeaponAnim( ACT_VM_RECOIL1 )
	end
	self.Owner:SetAnimation(ACT_RANGE_ATTACK_AR2)

end

function SWEP:Shoot( damage, num_bullets, aimcone )

	local bullet = {}
	bullet.Num = num_bullets
	bullet.Src = self.Owner:GetShootPos() // Source
	bullet.Dir = self.Owner:GetAimVector() // Dir of bullet
	bullet.Spread = Vector( aimcone, aimcone, 0 ) // Aim Cone
	bullet.Tracer = 1 // Show a tracer on every x bullets
	bullet.TracerName = "AR2Tracer"
	bullet.Force = 3 // Amount of force to give to phys objects
	bullet.Damage = damage

	self.Owner:FireBullets( bullet )

	self:ShootEffects()

end

function SWEP:SecondaryAttack( )
	if ( self:Ammo2() < 1 ) then return end
	self:EmitSound(self.Secondary.Sound)
	timer.Simple(0.5,function()
		self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
		//self.Weapon:EmitSound( "weapons/irifle/irifle_fire2.wav" )
		
		self:TakeSecondaryAmmo(1)
		
		self:SetNextPrimaryFire(CurTime()+1)
		self:SetNextSecondaryFire(CurTime() + 3)
			
		local pOwner = self.Owner;
		 
		local vecSrc     = pOwner:GetShootPos();
		local vecAiming = pOwner:GetAimVector();
		 
		 
		local vecVelocity = vecAiming * 1000.0;
	 
		if ( !CLIENT ) then
 
		    local ent = ents.Create("prop_combine_ball")
		    ent:PhysicsInit(SOLID_VPHYSICS)
		    ent:SetSolid(SOLID_VPHYSICS)
		    ent:SetMoveType(MOVETYPE_VPHYSICS)
		    ent:SetCollisionGroup(24)
		    ent:SetPos(self.Owner:GetShootPos())
		    ent:SetOwner(self.Owner)
		    ent:SetAbsVelocity(self.Owner:GetForward() * 1000)
		    ent:SetSaveValue("m_flRadius", 10)
		    ent:SetSaveValue("m_vecAbsVelocity", self.Owner:GetForward() * 1000)
		    ent:Spawn()
		 
		    ent:SetSaveValue("m_bWeaponLaunched", true)
		    ent:SetSaveValue("m_flSpeed", 1000)
		    ent:SetSaveValue("m_bLaunched", true)
		    ent:SetSaveValue("m_nState", 2)
		 
		    local phys = ent:GetPhysicsObject()
		    if IsValid(phys) then
		        phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
		        phys:SetMass(150)
		        phys:SetInertia(Vector(500, 500, 500))
		    end
		    pOwner:EmitSound( self.Secondary.Sound2 );
		end	
	end)
end