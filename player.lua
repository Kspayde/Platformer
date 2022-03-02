playerStartX = 360
playerStartY = 100  
  
  
  -- creates a collider an object that holds all physsics about something in this case the player
   -- player = world:newRectangleCollider(360, 100, 40, 100, {collision_class = "player"}) -- changing x, y values to our new variables
    player = world:newRectangleCollider(playerStartX, playerStartY, 40, 100, {collision_class = "player"})
    player:setFixedRotation(true) --so player doesn't rotate while falling
    player.speed = 240
    player.animation = animations.idle
    player.isMoving = false
    player.direction = 1
    player.grounded = true

function playerUpdate(dt)
    if player.body then 
        local colliders = world:queryRectangleArea(player:getX() - 20, player:getY() + 50, 40, 2, {'platform'})
        if #colliders > 0 then 
            player.grounded = true
        else
            player.grounded = false 
        end

        player.isMoving = false
        local px, py = player:getPosition() -- gets player x and y positions and fills it int he px and py
        if love.keyboard.isDown('right') then 
            player:setX(px + player.speed*dt) --sets players x pos current position plus 5 so moves right -- changed five to vairable playerspeed
            player.isMoving = true
            player.direction = 1
        end
        if love.keyboard.isDown('left') then 
            player:setX(px - player.speed*dt) --sets players x pos current position minus 5 so moves left -- changed five to vairable playerspeed
            player.isMoving = true
            player.direction = -1
        end

        if player:enter('Danger') then
            player:setPosition(playerStartX, playerStartY)
        end
    end
    
    if player.grounded then 
        if player.isMoving then 
            player.animation = animations.run
        else
            player.animation = animations.idle
        end
    else
        player.animation = animations.jump
    end

    player.animation:update(dt)
end


function drawPlayer()
    local px, py = player:getPosition()          -- multipluing .25 by negative will flip image making it face left leaving it pos will keep it right
    player.animation:draw(sprites.playerSheet, px, py, nil, 0.25 * player.direction, 0.25, 130, 300)

end
