
function EFFECT:Init( data ) 
	self.Ent = data:GetEntity()
	self.Pos = data:GetOrigin()
	self.emitter = ParticleEmitter( self.Pos )
end

local parts = { "models/roller/rollermine_glowred", "models/roller/rollermine_gloworange"}
 
function EFFECT:Think()
   	if not IsValid( self.Ent )  then
		self.emitter:Finish( )
		return false
	end
	self.Pos = self.Ent:GetPos() + Vector(0,0,20)
	for i = 0, 360, 1 do
		local circlepos = Vector(math.sin(i) * 50, math.cos(i) * 50, 0)
		local p = self.emitter:Add( parts[math.random(1,#parts)], self.Pos + circlepos)
		local vel = (self.Pos - (circlepos + self.Pos)) * -20
 		p:SetVelocity( vel )
		p:SetDieTime( 0.2 )
		p:SetGravity( Vector( 0, 0, 0 ) )
		p:SetStartSize( 7 )
		p:SetEndSize( 25 )
		p:SetColor(Color(200,200,200))
		p:SetStartAlpha( math.Rand( 200, 255 ) )
		p:SetAirResistance( 10 )
		p:SetEndAlpha( math.Rand( 10, 50 ) )
	end
	return false
end

function EFFECT:Render()
 
end
