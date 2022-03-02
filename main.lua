function love.load()
    love.window.setMode(1000, 768)

    anim8 = require 'libraries/anim8/anim8'
    sti = require 'libraries/Simple-Tiled-Implementation-Master/sti'
    cameraFile = require 'libraries/hump/camera'
    
    -- creating cam to make camera file an obj
    cam = cameraFile()

    sounds = {}
    sounds.jump = love.audio.newSource("audio/jump.wav", "static") -- static for sound effects 
    sounds.music = love.audio.newSource("audio/music.mp3", "stream") -- stream for music 
    sounds.music:setLooping(true) -- music will end when track ends so have to allow looping for continues play
    sounds.music:setVolume(0.5) -- allows to set volume 1 is max so .5 is half volume

    sounds.music:play()

    sprites = {}
    sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')
    sprites.enemySheet = love.graphics.newImage('sprites/enemySheet.png')
    sprites.background = love.graphics.newImage('sprites/background.png')

    local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight()) 
    local enemyGrid = anim8.newGrid(100, 79, sprites.enemySheet:getWidth(), sprites.enemySheet:getHeight()) 


    animations = {}
    animations.idle = anim8.newAnimation(grid('1-15',1), 0.5) -- 1-15 that we want the first 15 pictures then 1 to indicate row 1 then how long you want each animation to run for 
    animations.jump = anim8.newAnimation(grid('1-7',2), 0.5)
    animations.run = anim8.newAnimation(grid('1-15',3), 0.5)
    animations.enemy = anim8.newAnimation(enemyGrid('1-2',1), 0.03)

    wf = require 'libraries/windfield/windfield' -- include the windfield folder for physics 
    world = wf.newWorld(0,800, false)  --create a world for the physics world. paramters are for gracity 0 for up 0 for down if set to 100 would have them going down
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('platform')
    world:addCollisionClass('player' --[[ {ignores = {'platform'}} ]])
    world:addCollisionClass('Danger')

    -- adding our new playerlua file

    require('player')
    require('enemy')
    require('libraries/show') -- show used to save data to the save data table



    --creates something for the player object to land on still moves need to change the type.
   -- moved to new function  platform = world:newRectangleCollider(250, 400, 300, 100, {collision_class = "platform"})

    -- three trypes of colliders, dyamic, static and kinematic... dynamics are defualt  it will fall with gravity, static they dont move due to physical interactions,
    -- kinematic only collide with dynamic aren't using

   -- moved to new function  platform:setType('static') -- changes it from the default of dynamic to static to make it stay still 

    dangerZone = world:newRectangleCollider(-500, 800, 5000, 50, {collision_class = "Danger"})
    dangerZone:setType('static')

    platforms = {}

    flagX = 0
    flagY = 0 -- where in the level flag is located 

    saveData = {} --create a new table to save data in this case it will be current level

    --currentLevel = "level1"
    saveData.currentLevel = "level1" -- so we'll make current level a property in save data

    if love.filesystem.getInfo("data.lua") then 
        local data = love.filesystem.load("data.lua")
        data()

    end

    
    loadMap(saveData.currentLevel)

end

function love.update(dt)
    world:update(dt)
    --calling the map that was created with the tiles program in level1.lua
    gameMap:update(dt)
    --calling update file from player
    playerUpdate(dt)
    -- getting enemy update
    updateEnemies(dt)
    -- note 2 need to get players position 
    local px, py = player:getPosition()
    -- note 1  make camera follow player ** makes cam look at a specific point in the game
    cam:lookAt(px, love.graphics.getHeight()/2) -- cam use (px, py) but screen can get off centered so best to use the the game map for center 
                                                -- so when play jumps or goes on a lower platform it doesn't move down    
    
     -- detect when player hits flag to change to the next level collision detection 

     local colliders = world:queryCircleArea(flagX, flagY, 10, {'player'}) -- locations (flagx and flag y, circumfrance of circle = 10 and collider object)
     if #colliders > 0 then
        if saveData.currentLevel == "level1" then -- if your on level one and rach a flag
            loadMap('level2')            -- then it will go to level 2       
        --elseif currentlevel == "level2" then
            --loadMap("level3") *if you have a level 3     
        elseif saveData.currentLevel == "level2" then -- and if you are on level 2 and hit a flag then
            loadMap("level1")                -- you go back t level 1
        end     

     end
end

function love.draw()
    love.graphics.draw(sprites.background, 0, 0)
    -- have to call camera want to do that first so everything else is drawn over the camera 
    cam:attach()    
        --world:draw() -- dont want to keep when game is active but good to have while programing for debugging 
        -- draw the map 
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        --world:draw() -- dont want to keep when game is active but good to have while programing for debugging  move after drawlayer so we can see it better 
        
        --calling draw from player file
        drawPlayer()
        drawEnemies()
    cam:detach() -- everything should be inside the cam attach and detach unless its something you always want on the screen no matter where the cam is looking like a health bar 
   
end 

function love.keypressed(key)
    if key == 'up' then 
        if player.grounded then 
            player:applyLinearImpulse(0, -4000)  --make a player jump by pressing upkey
            sounds.jump:play()
        end
    end
    if key == 'r' then 
        loadMap('level2')
    end
end
--using a program for level, tiled

function love.mousepressed(x, y, button)
    if button == 1 then 
        local colliders = world:queryCircleArea(x, y, 200, {'platform', 'Danger'})
        for i,c in ipairs(colliders) do
            c:destroy() 
        end
    end
end

function spawnPlatform(x, y, width, height)
    if width > 0 and height > 0 then
         --creates something for the player object to land on still moves need to change the type.
        local platform = world:newRectangleCollider(x, y, width, height, {collision_class = "platform"})

        -- three trypes of colliders, dyamic, static and kinematic... dynamics are defualt  it will fall with gravity, static they dont move due to physical interactions,
        -- kinematic only collide with dynamic aren't using
    
        platform:setType('static') -- changes it from the default of dynamic to static to make it stay still 
    
        table.insert(platforms, platform)  
    end
end

function destroyAll() -- when changing platforms (levels) it will remove all obj (platform and enemies)
    local i = #platforms
    while i > -1 do 
        if platforms[i] ~= nil then 
            platforms[i]:destroy()
        end
        table.remove(platforms, i)
        i = i -1
    end

    local i = #enemies
    while i > -1 do 
        if enemies[i] ~= nil then 
            enemies[i]:destroy()
        end
        table.remove(enemies, i) -- remove enemies 
        i = i -1
    end

end

function loadMap(mapName)

    saveData.currentLevel = mapName
    love.filesystem.write("data.lua",table.show(saveData, "saveData")) -- first paramater the file you want to save data to name it whatever you want second parameter
    -- is the data you want to save using the show.lua library in that parameters put the name of the table you want to save and a tag
    
    destroyAll()
    gameMap = sti("maps/" .. mapName .. ".lua")
    for i, obj in pairs(gameMap.layers["Start"].objects) do
        -- set start position objects 
        playerStartX =  obj.x   
        playerStartY = obj.y 
    end 
    player:setPosition(playerStartX, playerStartY)

    for i, obj in pairs(gameMap.layers["Platforms"].objects) do
        -- object = object from tiles and it will take each of their values. 
        spawnPlatform(obj.x, obj.y, obj.width, obj.height) 
    end 
    for i, obj in pairs(gameMap.layers["Enemies"].objects) do
        -- object = object from tiles and it will take each of their values. for the enemies obj 
        spawnEnemy(obj.x, obj.y) 
    end 
    for i, obj in pairs(gameMap.layers["Flag"].objects) do
        -- set flag objects 
        flagX =  obj.x   
        flagY = obj.y 
    end 
end