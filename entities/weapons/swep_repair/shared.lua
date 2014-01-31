
if SERVER then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight	= 1
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom	= false
end

if CLIENT then
	SWEP.PrintName = "Wrench"
	SWEP.DrawCrosshair = true
	SWEP.DrawAmmo = false
	SWEP.ViewModelFOV = 60
	SWEP.ViewModelFlip = false
	SWEP.Slot = 0
end

local Decals = {
	MAT_CONCRETE = "Concrete",
	MAT_METAL 			= "Metal",
	MAT_DIRT 			= "Dirt",
	MAT_VENT 			= "Vent",
	MAT_GRATE 			= "Grate",
	MAT_TILE 			= "Tile",
	MAT_SLOSH 			= "Slosh",
	MAT_WOOD 			= "Wood",
	MAT_COMPUTER 		= "Computer",
	MAT_GLASS 			= "Glass",
	MAT_FLESH 			= "Flesh",
	MAT_BLOODYFLESH 	= "Bloodyflesh",
	MAT_CLIP 			= "Clip",
	MAT_ANTLION 		= "Antlion",
	MAT_ALIENFLESH 		= "Alienflesh",
	MAT_FOLIAGE 		= "Foliage",
	MAT_SAND 			= "Sand",
	MAT_PLASTIC 		= "Plastic",
}

SWEP.ViewModel	= "models/weapons/v_crowbar.mdl"
SWEP.WorldModel	= "models/weapons/w_crowbar.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= ""

function SWEP:Initialize( )
	if SERVER then
		self:SetWeaponHoldType( "melee" )
	end
end

function SWEP:PrimaryAttack( )
	self.Weapon:SetNextPrimaryFire( CurTime( ) + .3 )
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
	self.Owner:SetAnimation(ACT_MELEE_ATTACK_SWING_GESTURE)
	local trace = { }
	trace.start = self.Owner:GetShootPos( )
	trace.endpos = trace.start + ( self.Owner:GetAimVector( ) * 100 )
	trace.filter = self.Owner

	local tr = util.TraceLine( trace )
	if !tr.Entity || !tr.HitNonWorld then
		self.Weapon:EmitSound( "weapons/iceaxe/iceaxe_swing1.wav" )
		return false
	end

	self.Weapon:EmitSound("physics/flesh/flesh_impact_bullet3.wav")

	local ent = tr.Entity
	if ent.Controller then ent = ent.Controller end

	if SERVER then
		if ent:GetClass() == "sent_turretcontroller" then
			if ent.Shealth >= GAMEMODE.Config.TURRET_HEALTH then return end
			ent.Shealth = ent.Shealth + 5
			if ent.Shealth > GAMEMODE.Config.TURRET_HEALTH then ent.Shealth = GAMEMODE.Config.TURRET_HEALTH end
			ent.Turret:SetNWInt("health", ent.Shealth)
		elseif ent:IsProp() && ent.Shealth then
			if ent.Shealth >= ent.Mhealth then return end
			if !ent:IsOnFire() then
				ent.Shealth = ent.Shealth + 25
				if ent.Shealth > ent.Mhealth then ent.Shealth = ent.Mhealth end
			end
			if math.random(1,3) == 1 then
				ent:Extinguish()
			end
			ent:GetPhysicsObject( ):EnableMotion( false )
			ent:UpdateColour( )
		elseif ent:IsNPC() then
			ent:TakeDamage(25, self.Owner, self.Owner)
		end
	end

	if tr.MatType == MAT_FLESH || tr.HitType == MAT_BLOODYFLESH then
		local effectdata = EffectData()
 		effectdata:SetOrigin( tr.HitPos )
		util.Effect( "BloodImpact", effectdata )
	else
		local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos )
		effectdata:SetNormal( tr.HitNormal )
		effectdata:SetMagnitude( 1 )
		effectdata:SetScale( 1 )
		effectdata:SetRadius( 1 )
		util.Effect( "Sparks", effectdata )
	end

	util.Decal( "Impact." .. ( Decals[MatType] or "Concrete" ), tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal )
end

function SWEP:SecondaryAttack( )

end
