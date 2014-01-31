if( SERVER ) then
AddCSLuaFile( "shared.lua" )
end
if( CLIENT ) then
SWEP.BounceWeaponIcon = false
SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_crowbar")
killicon.Add("weapon_crowbar","weapons/weapon_crowbar",Color(255,255,255))
end

SWEP.PrintName 		= "Crowbar"
SWEP.Slot 			= 0
SWEP.SlotPos 		= 3
SWEP.DrawAmmo 		= false
SWEP.DrawCrosshair 	= true
SWEP.Author			= "Baddog"
SWEP.Instructions	= "Leftclick to slash with your crowbar."
SWEP.Category		= ""

SWEP.ViewModelFOV	= 60
SWEP.ViewModelFlip	= false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true


SWEP.ViewModel      = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel   	= "models/weapons/w_crowbar.mdl"

SWEP.Primary.Delay				= 0.36
SWEP.Primary.ClipSize			= -1
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Automatic   		= true
SWEP.Primary.Ammo         		= "none"
SWEP.Primary.Hit                        = Sound( "Weapon_Crowbar.Melee_Hit" )
SWEP.Primary.Sound                      = Sound( "Weapon_Crowbar.Single" )

SWEP.Secondary.Delay			= 0.36
SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Automatic  	 	= true
SWEP.Secondary.Ammo         	= "none"


function SWEP:Initialize()
	self:SetWeaponHoldType("melee")
end

function SWEP:Holster()
	return true
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire(CurTime() + 0.7)
	self:SetNextSecondaryFire(CurTime() + 0.7)
	return true
end

function SWEP:OnRemove()
	return true
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end

function SWEP:PrimaryAttack()

			local pPlayer           = self.Owner;

			if ( !pPlayer ) then
					return;
			end

			//if ( !self:CanPrimaryAttack() ) then return end

			local vecSrc            = pPlayer:GetShootPos();
			local vecDirection      = pPlayer:GetAimVector();

			local trace                     = {}
					trace.start             = vecSrc
					trace.endpos    = vecSrc + ( vecDirection * 75 )
					trace.filter    = pPlayer

			local traceHit          = util.TraceLine( trace )

			pPlayer:SetAnimation( PLAYER_ATTACK1 );
			if ( traceHit.Hit ) then

					self.Weapon:EmitSound( self.Primary.Hit );

					self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER );

					self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
					self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay );
					if CLIENT or not traceHit.Entity:IsNPC() then return end
					local dmg = DamageInfo()
					dmg:SetDamage(25)
					dmg:SetAttacker(self.Owner)
					dmg:SetInflictor(self)
					dmg:SetDamageForce(self.Owner:GetAimVector() * 100)
					dmg:SetDamagePosition(self.Owner:GetPos())
					dmg:SetDamageType(DMG_CLUB)
					traceHit.Entity:TakeDamageInfo(dmg)

					return

			end

			self.Weapon:EmitSound( self.Primary.Sound );

			self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER );

			self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
			self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay );


			return

end

local ActIndex = {}
	ActIndex["pistol"] 		= ACT_HL2MP_IDLE_PISTOL
	ActIndex["smg"] 			= ACT_HL2MP_IDLE_SMG1
	ActIndex["grenade"] 		= ACT_HL2MP_IDLE_GRENADE
	ActIndex["ar2"] 			= ACT_HL2MP_IDLE_AR2
	ActIndex["shotgun"] 		= ACT_HL2MP_IDLE_SHOTGUN
	ActIndex["rpg"]	 		= ACT_HL2MP_IDLE_RPG
	ActIndex["physgun"] 		= ACT_HL2MP_IDLE_PHYSGUN
	ActIndex["crossbow"] 		= ACT_HL2MP_IDLE_CROSSBOW
	ActIndex["melee"] 		= ACT_HL2MP_IDLE_MELEE
	ActIndex["slam"] 			= ACT_HL2MP_IDLE_SLAM
	ActIndex["normal"]		= ACT_HL2MP_IDLE
	ActIndex["knife"]			= ACT_HL2MP_IDLE_KNIFE
	ActIndex["sword"]			= ACT_HL2MP_IDLE_MELEE2
	ActIndex["passive"]		= ACT_HL2MP_IDLE_PASSIVE
	ActIndex["fist"]			= ACT_HL2MP_IDLE_FIST

function SWEP:SetWeaponHoldType(t)

	local index = ActIndex[t]
	
	if (index == nil) then
		Msg("SWEP:SetWeaponHoldType - ActIndex[ \""..t.."\" ] isn't set!\n")
		return
	end

self.ActivityTranslate = {}
self.ActivityTranslate [ ACT_MP_STAND_IDLE ]				= index
self.ActivityTranslate [ ACT_MP_WALK ]						= index+1
self.ActivityTranslate [ ACT_MP_RUN ]						= index+2        
self.ActivityTranslate [ ACT_MP_CROUCH_IDLE ]				= index+3
self.ActivityTranslate [ ACT_MP_CROUCHWALK ]				= index+4
self.ActivityTranslate [ ACT_MP_ATTACK_STAND_PRIMARYFIRE ]	= index+5
self.ActivityTranslate [ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ]	= index+5
self.ActivityTranslate [ ACT_MP_RELOAD_STAND ]				= index+6
self.ActivityTranslate [ ACT_MP_RELOAD_CROUCH ]				= index+6
self.ActivityTranslate [ ACT_MP_JUMP ]						= index+7
self.ActivityTranslate [ ACT_RANGE_ATTACK1 ]				= index+8
	if t == "normal" then
		self.ActivityTranslate [ ACT_MP_JUMP ] = ACT_HL2MP_JUMP_SLAM
	end
	if t == "passive" then
		self.ActivityTranslate [ ACT_MP_CROUCH_IDLE ] = ACT_HL2MP_CROUCH_IDLE
	end	
	self:SetupWeaponHoldTypeForAI(t)
end

function SWEP:TranslateActivity(act)

	if (self.Owner:IsNPC()) then
		if (self.ActivityTranslateAI[act]) then
			return self.ActivityTranslateAI[act]
		end

		return -1
	end

	if (self.ActivityTranslate[act] != nil) then
		return self.ActivityTranslate[act]
	end
	
	return -1
end