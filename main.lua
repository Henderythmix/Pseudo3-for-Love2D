function love.load()
	--love.window.setVSync(0)
	love.mouse.setRelativeMode(true)

	require "pseudothree"

	-- Graphics
	skybox = love.graphics.newImage("skybox.jpeg")
	wall = love.graphics.newImage("wall.png")


	-- Player
	player = {
		Body = love.physics.newBody(PseudoThree.World, 20, 20, "dynamic"),
		Shape = love.physics.newCircleShape(10),
		Rotation = 90
	}

	player.Fixture = love.physics.newFixture(player.Body, player.Shape)

	-- Map
	mapBodies = {}
	mapCollisions = {}
	mapFixtures = {}

	mapBodies[1] = love.physics.newBody(PseudoThree.World, 40, 40)
	mapFixtures[1] = love.physics.newFixture(mapBodies[1], love.physics.newCircleShape(10))

	mapBodies[2] = love.physics.newBody(PseudoThree.World, 100, 100)
	mapFixtures[2] = love.physics.newFixture(mapBodies[2], love.physics.newRectangleShape(100, 20))

	mapBodies[3] = love.physics.newBody(PseudoThree.World, 100, 0)
	mapFixtures[3] = love.physics.newFixture(mapBodies[3], love.physics.newRectangleShape(20, 100))
end

function love.update(dt)
	vely = 0
	velx = 0

	if love.keyboard.isDown("w") then
		vely = -1
	end
	if love.keyboard.isDown("s") then
		vely = 1
	end
	if love.keyboard.isDown("d") then
		velx = 1
	end
	if love.keyboard.isDown("a") then
		velx = -1
	end

	currentvelocity = PseudoThree.Rotate2DVector({velx*40, vely*40}, player.Rotation)
	player.Body:setLinearVelocity(currentvelocity.x, currentvelocity.y)
	PseudoThree.World:update(dt)
	PseudoThree.Camera.Position.x = player.Body:getX()
	PseudoThree.Camera.Position.z = player.Body:getY()
	PseudoThree.Camera.Rotation.x = player.Rotation
end

function love.mousemoved(x, y, dx, dy)
	player.Rotation = player.Rotation + dx
end

function love.draw()
	love.graphics.print(love.timer.getFPS(), 0, 0)
	love.graphics.print(player.Body:getY(), 0, 12)
	love.graphics.print(PseudoThree.Camera.Rotation.x, 0, 24)

	--[[for y=1, 8 do
		for x=1, 8 do
			if map[(y-1)*8+x] == 1 then
				love.graphics.rectangle("fill", love.graphics.getWidth()/2+(x-1)*16, love.graphics.getHeight()/2+(y-1)*16, 16, 16)
			end
		end
	end]]

	-- Draw World
	love.graphics.draw(skybox, 0, 0, 0, 3.1)
	PseudoThree.RaycastMap(player.Body)

end