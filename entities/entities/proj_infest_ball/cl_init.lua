include("shared.lua")

function ENT:Initialize()
	self.ParticleTime = 0
	self:DrawShadow(false)
end

function ENT:Draw()
	--self:DrawModel()
end

function ENT:Think()		
	local dlight = DynamicLight(self:EntIndex())
		
	if dlight then
		dlight.Pos = self:GetPos()
		dlight.r = 255
		dlight.g = 100
		dlight.b = 0
		dlight.Brightness = 2
		dlight.Size = 128
		dlight.Decay = 128 * 3
		dlight.DieTime = CurTime() + 0.1
	end
	self:Smoke()
end 

//
// Safe ParticleEmitter Josh 'Acecool' Moser
//
// This should be placed in a CLIENT run directory - such as addons/acecool_particleemitter_override/lua/autorun/client/_particleemitter.lua
// -- http://facepunch.com/showthread.php?t=1309609&p=42275212#post42275212
//
if ( !PARTICLE_EMITTER ) then PARTICLE_EMITTER = ParticleEmitter; end
function ParticleEmitter( _pos, _use3D )
	if ( !_GLOBAL_PARTICLE_EMITTER ) then 
		_GLOBAL_PARTICLE_EMITTER = { };
	end

	if ( _use3D ) then
		if ( !_GLOBAL_PARTICLE_EMITTER.use3D ) then
			_GLOBAL_PARTICLE_EMITTER.use3D = PARTICLE_EMITTER( _pos, true );
		else
			_GLOBAL_PARTICLE_EMITTER.use3D:SetPos( _pos );
		end

		return _GLOBAL_PARTICLE_EMITTER.use3D;
	else
		if ( !_GLOBAL_PARTICLE_EMITTER.use2D ) then
			_GLOBAL_PARTICLE_EMITTER.use2D = PARTICLE_EMITTER( _pos, false );
		else
			_GLOBAL_PARTICLE_EMITTER.use2D:SetPos( _pos );
		end

		return _GLOBAL_PARTICLE_EMITTER.use2D;
	end
end

function ENT:Smoke()
	local vOffset = self:GetPos()
	local vPos = VectorRand()*5
	local emitter = ParticleEmitter(vOffset)
			
	local smoke = emitter:Add("particles/smokey", vOffset + vPos)
			smoke:SetVelocity(self:GetVelocity()+(self:GetVelocity()*-0.25))
			smoke:SetDieTime(math.random(0.05,0.1))
			smoke:SetStartAlpha(50)
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(10)
			smoke:SetEndSize(math.Rand(40, 60))
			smoke:SetRoll(math.Rand(-180, 180))
			smoke:SetRollDelta(math.Rand(-0.2,0.2))
			smoke:SetColor(math.random(0,50), math.random(200,255), math.random(0,150),math.random(50,100))
			smoke:SetAirResistance(math.Rand(25, 100))
			smoke:SetBounce(0.5)
			smoke:SetCollide(true)

	emitter:Finish()
end
