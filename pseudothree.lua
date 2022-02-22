--
--[ PseudoThree.lua by DigitDorian ]
--[ A Library for Rendering and Moving a camera around]
--

PseudoThree = {
	Camera = {
		Position = {x=0,y=0,z=0},
		Rotation = {x=0,y=0,z=0},
		FOV = 60
	},
	World = love.physics.newWorld(),
	ViewDimensions = {x=love.graphics.getWidth(), y=love.graphics.getHeight()}
}

-- 3D TO 2D SPACE --
function PseudoThree.Transform3DTo2D(objx, objy, objz)
	local posx = (PseudoThree.ViewDimensions.x/2) + objx - PseudoThree.Camera.Position.x - (math.sin(PseudoThree.Camera.Rotation.x) * PseudoThree.ViewDimensions.x/1.9)
	local posy = (PseudoThree.ViewDimensions.y/2) + objy - PseudoThree.Camera.Position.y

	--local viewscale = nil
	local viewscale = 1 / (objz - PseudoThree.Camera.Position.z)

	return {x = posx, y = posy, scale = viewscale}
end

-- This is for Occlusion Culling or similar things
function PseudoThree.IsInRange(objpos)
	result = false
	if objpos.scale > 0 then
		if objpos.x > 0 and objpos.x < PseudoThree.ViewDimensions.x then
			if objpos.y > 0 and objpos.y < PseudoThree.ViewDimensions.y then
				result = true
			end
		end
	end

	return result
end

function PseudoThree.RaycastMap(reference)
	--love.graphics.print(PseudoThree.Camera.Rotation.x - 30)

	for i=0, PseudoThree.ViewDimensions.x do
		-- Get the ray direction. This is used in more than one spot
		local RayDirection = PseudoThree.Camera.Rotation.x+(i/PseudoThree.ViewDimensions.x*PseudoThree.Camera.FOV-(PseudoThree.Camera.FOV/2))
		local closeness = 2
		nx, ny = 0

		-- This is the callback when the ray touches an object in the environment.
		-- This is called in the for loop and function so that I can integrate variables that I need like closest (and originally the i value )
		function RaycastCallback(fixture, x, y, xn, yn, fraction)
			-- We need to check if the object is static to consider it a wall
			bodytype = fixture:getBody():getType()
		
			if bodytype == "static" then
				-- Just to get rid of that fisheye effect
				if fraction < closeness then
					closeness = fraction
					nx = xn
					ny = yn
				end
				return 1
			elseif fixture == null then
				return -1
			end
			
		end

		-- Get the ray end
		local raydir = PseudoThree.Rotate2DVector({0, -500}, RayDirection)

		-- Annnnd... Open Fire!
		PseudoThree.World:rayCast(reference:getX(), reference:getY(), reference:getX()+raydir.x, reference:getY()+raydir.y, RaycastCallback)

		if closeness <= 1 then
			Distance = closeness * 2 * math.cos(math.rad(RayDirection) - math.rad(PseudoThree.Camera.Rotation.x))

			drawy = PseudoThree.ViewDimensions.y * 0.2 / Distance

			love.graphics.setColor(1-closeness, 1-closeness, 1-closeness)
				
			love.graphics.rectangle("fill", i, (PseudoThree.ViewDimensions.y - drawy)/2, 1, drawy)
			love.graphics.setColor(1,1,1)
		end
	end
end

-- CALCULATION FUNCTIONS --

function PseudoThree.Rotate2DVector(vec, rot)
	local outy = (math.sin(math.rad(rot)) * vec[1]) + (math.cos(math.rad(rot)) * vec[2])
	local outx = (math.cos(math.rad(rot)) * vec[1]) - (math.sin(math.rad(rot)) * vec[2])
	return {x = outx, y = outy}
end