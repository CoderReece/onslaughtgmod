function EFFECT:Init( data ) 
	self.Ent = data:GetEntity()
	self.Pos = data:GetOrigin()
	self.emitter = ParticleEmitter( self.Pos )
end

local parts = { "sprites/light_glow02_add" }
 
function EFFECT:Think()
	local ply = self.Ent:GetNWEntity("owner")
   	if not IsValid( self.Ent )  then
		self.emitter:Finish( )
		return false
	end
	local p = self.emitter:Add( parts[math.random(1,#parts)], self.Pos)
	for i = 0, 6 do
		local vel = (Vector(math.Rand(-15,15), math.Rand(-15,15),math.Rand(50,120) + i))
		p:SetVelocity( vel )
		p:SetDieTime( math.Rand( .2, .4 ) )
		p:SetGravity( Vector( 0, 0, -1 ) )
		p:SetStartSize( math.Rand( 1, 4 ) )
		p:SetEndSize( 15 )
		p:SetColor(Color(200,200,200))
		p:SetStartAlpha( math.Rand( 200, 255 ) )
		p:SetAirResistance( 5 )
		p:SetEndAlpha( 0 )
	end
	return true
end

function EFFECT:Render()
 
end