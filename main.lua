function love.load()
    wf = require 'libraries/windfield/windfield' -- include the windfield folder for physics 
    world = wf.newWorld(0,800)  --create a world for the physics world. paramters are for gracity 0 for up 0 for down if set to 100 would have them going down

    world:addCollisionClass('player')
    world:addCollisionClass('platform')

    -- creates a collider an object that holds all physsics about something in this case the player
    player = world:newRectangleCollider(360, 100, 80, 80, {collision_class = "player"})

    player.speed = 240

    platform = world:newRectangleCollider(250, 400, 300, 100, {collision_class = "platform"}) --creates something for the player object to land on still moves need to change the type.
    -- three trypes of colliders, dyamic, static and kinematic... dynamics are defualt  it will fall with gravity, static they dont move due to physical interactions,
    -- kinematic only collide with dynamic aren't using
    platform:setType('static') -- changes it from the default of dynamic to static to make it stay still 
end

function love.update(dt)
    world:update(dt)

    local px, py = player:getPosition() -- gets player x and y positions and fills it int he px and py
    if love.keyboard.isDown('right') then 
        player:setX(px + player.speed*dt) --sets players x pos current position plus 5 so moves right -- changed five to vairable playerspeed
    end
    if love.keyboard.isDown('left') then 
        player:setX(px - player.speed*dt) --sets players x pos current position minus 5 so moves left -- changed five to vairable playerspeed
    end
end

function love.draw()
    world:draw() -- dont want to keep when game is active but good to have while programing for debugging 

end 

function love.keypressed(key)
    if key == 'up' then 
        player:applyLinearImpulse(0, -7000)  --make a player jump by pressing upkey
    end
end

