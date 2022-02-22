function love.load()
    anim8 = require 'libraries/anim8/anim8'

    sprites = {}
    sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')

    local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())

    animations = {}
    animations.idle = anim8.newAnimation(grid('1-15',1), 0.5) -- 1-15 that we want the first 15 pictures then 1 to indicate row 1 then how long you want each animation to run for 
    animations.jump = anim8.newAnimation(grid('1-7',2), 0.5)
    animations.run = anim8.newAnimation(grid('1-15',3), 0.5)

    wf = require 'libraries/windfield/windfield' -- include the windfield folder for physics 
    world = wf.newWorld(0,800, false)  --create a world for the physics world. paramters are for gracity 0 for up 0 for down if set to 100 would have them going down
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('platform')
    world:addCollisionClass('player' --[[ {ignores = {'platform'}} ]])
    world:addCollisionClass('Danger')

    -- creates a collider an object that holds all physsics about something in this case the player
    player = world:newRectangleCollider(360, 100, 80, 80, {collision_class = "player"})
    player:setFixedRotation(true) --so player doesn't rotate while falling
    player.speed = 240
    player.animation = animations.run

    --creates something for the player object to land on still moves need to change the type.
    platform = world:newRectangleCollider(250, 400, 300, 100, {collision_class = "platform"})

    -- three trypes of colliders, dyamic, static and kinematic... dynamics are defualt  it will fall with gravity, static they dont move due to physical interactions,
    -- kinematic only collide with dynamic aren't using

    platform:setType('static') -- changes it from the default of dynamic to static to make it stay still 

    dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Danger"})
    dangerZone:setType('static')
end

function love.update(dt)
    world:update(dt)

    if player.body then 
        local px, py = player:getPosition() -- gets player x and y positions and fills it int he px and py
        if love.keyboard.isDown('right') then 
            player:setX(px + player.speed*dt) --sets players x pos current position plus 5 so moves right -- changed five to vairable playerspeed
        end
        if love.keyboard.isDown('left') then 
            player:setX(px - player.speed*dt) --sets players x pos current position minus 5 so moves left -- changed five to vairable playerspeed
        end

        if player:enter('Danger') then
            player:destroy()
        end
    end

    player.animation:update(dt)
end

function love.draw()
    world:draw() -- dont want to keep when game is active but good to have while programing for debugging 
    player.animation:draw(sprites.playerSheet, 0, 0, nil, 0.25)

end 

function love.keypressed(key)
    if key == 'up' then 
        local colliders = world:queryRectangleArea(player:getX() - 40, player:getY() + 40, 80, 2, {'platform'})
        if #colliders > 0 then 
            player:applyLinearImpulse(0, -7000)  --make a player jump by pressing upkey
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then 
        local colliders = world:queryCircleArea(x, y, 200, {'platform', 'Danger'})
        for i,c in ipairs(colliders) do
            c:destroy() 
        end
    end
end