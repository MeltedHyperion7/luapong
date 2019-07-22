--[[
    The classic game Pong
]]

require "constants"

local explosionSound = love.audio.newSource("explosion.wav", "static")
local hitSound = love.audio.newSource("hit.wav", "static")

local grid = {}

local scoreP1 = 0
local scoreP2 = 0

local directionP1 = NONE
local directionP2 = NONE

local paddlePosP1
local paddlePosP2

local paddlesCanMove

local ballPosX
local ballPosY
local ballDirectionX
local ballDirectionY

local ballTimer = 0
local paddleTimer = 0

function initGrid()
    --[[
        Initialize the game grid.
    ]]

    local yMid = math.floor(MAX_TILES_Y / 2)
    local xMid = math.floor(MAX_TILES_X / 2)
    
    paddlePosP1 = yMid
    paddlePosP2 = yMid
    
    local halfPaddleSize = math.floor(PADDLE_SIZE / 2)
    
    for y = 1, MAX_TILES_Y do
        table.insert(grid, {})
        for x = 1, MAX_TILES_X do
            if (x == 1 or x == MAX_TILES_X) and y >= yMid - halfPaddleSize and y <= yMid + halfPaddleSize then
                table.insert(grid[y], PADDLE)
            elseif x == xMid and y == yMid then
                table.insert(grid[y], BALL)
            else
                table.insert(grid[y], EMPTY)
            end
        end
    end
    
    resetBall()
end

function resetBall()
    --[[
        Center the ball on the board.
    ]]

    local yMid = math.floor(MAX_TILES_Y / 2)
    local xMid = math.floor(MAX_TILES_X / 2)

    for y = 1, MAX_TILES_Y do
        for x = 1, MAX_TILES_X do
            if grid[y][x] == BALL then
                grid[y][x] = EMPTY
            end
        end
    end
    
    ballPosX = xMid
    ballPosY = yMid
    
    local dirX = math.random(1, 2)
    if dirX == 2 then
        dirX = -1
    end

    local dirY = math.random(1, 2)
    if dirY == 2 then
        dirY = -1
    end

    ballDirectionX = dirX
    ballDirectionY = dirY

    grid[yMid][xMid] = BALL

    -- allow paddles to move now
    paddlesCanMove = true
end

function drawGrid()
    --[[
        draw the game grid.
    ]]

    for y = 1, MAX_TILES_Y do
        for x = 1, MAX_TILES_X do
            if grid[y][x] == PADDLE then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.rectangle("fill", (x-1)*TILE_SIZE, (y-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
            elseif grid[y][x] == BALL then

                -- TODO different colour for ball?
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.rectangle("fill", (x-1)*TILE_SIZE, (y-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
            end
        end
    end
end

function drawScore()
    --[[
        Print the players' scores.
    ]]

    -- TODO calculate text width?
    love.graphics.print("Player 1: "..scoreP1, 0, 0)
    love.graphics.print("Player 2: "..scoreP2, WINDOW_WIDTH - 76, 0)
end

function love.load()
    initGrid()
    love.window.setTitle("Pong")
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false
    })
end

function love.keypressed(key)
    -- TODO change to key down?

    if key == "escape" then
        love.event.quit()
    end
end

function love.update(dt)
    --[[
        update game state.
    ]]

    ballTimer = ballTimer + dt
    paddleTimer = paddleTimer + dt

    if paddleTimer >= PADDLE_TICK and paddlesCanMove then
        paddleTimer = 0

        if love.keyboard.isDown(P1_KEY_UP) then
            directionP1 = UP
        elseif love.keyboard.isDown(P1_KEY_DOWN) then
            directionP1 = DOWN
        end

        if love.keyboard.isDown(P2_KEY_UP) then
            directionP2 = UP
        elseif love.keyboard.isDown(P2_KEY_DOWN) then
            directionP2 = DOWN
        end

        local halfPaddleSize = math.floor(PADDLE_SIZE / 2)

        -- update paddle positions
        if directionP1 == UP and paddlePosP1 - halfPaddleSize > 1 then
            
            paddlePosP1 = paddlePosP1 - 1

            for y = 1, MAX_TILES_Y do
                if grid[y][1] == PADDLE then
                    grid[y-1][1] = PADDLE
                    grid[y][1] = EMPTY
                end
            end
        elseif directionP1 == DOWN and paddlePosP1 + halfPaddleSize < MAX_TILES_Y then
            
            paddlePosP1 = paddlePosP1 + 1
            
            for y = MAX_TILES_Y-1, 1, -1 do
                if grid[y][1] == PADDLE then
                    grid[y+1][1] = PADDLE
                    grid[y][1] = EMPTY
                end
            end
        end
        
        if directionP2 == UP and paddlePosP2 - halfPaddleSize > 1 then
            
            paddlePosP2 = paddlePosP2 - 1
            
            for y = 1, MAX_TILES_Y do
                if grid[y][MAX_TILES_X] == PADDLE then
                    grid[y-1][MAX_TILES_X] = PADDLE
                    grid[y][MAX_TILES_X] = EMPTY
                end
            end
        elseif directionP2 == DOWN and paddlePosP2 + halfPaddleSize < MAX_TILES_Y then
            
            paddlePosP2 = paddlePosP2 + 1
            
            for y = MAX_TILES_Y-1, 1, -1 do
                if grid[y][MAX_TILES_X] == PADDLE then
                    grid[y+1][MAX_TILES_X] = PADDLE
                    grid[y][MAX_TILES_X] = EMPTY
                end
            end
        end
    end

    if ballTimer >= BALL_TICK then

        ballTimer = 0
        -- update ball position
        -- TODO change so that ball passes through last columns
        local newBallPosX = ballPosX + ballDirectionX
        local newBallPosY = ballPosY + ballDirectionY

        if newBallPosX == 1 and grid[newBallPosY][newBallPosX] == PADDLE then
            ballDirectionX = ballDirectionX * -1
            hitSound:play()
        elseif newBallPosX == 0 then
            paddlesCanMove = false
            scoreP2 = scoreP2 + 1
            explosionSound:play()
            resetBall()
        elseif newBallPosX == MAX_TILES_X and grid[newBallPosY][newBallPosX] == PADDLE then
            ballDirectionX = ballDirectionX * -1
            hitSound:play()
        elseif newBallPosX == MAX_TILES_X + 1 then
            paddlesCanMove = false
            scoreP1 = scoreP1 + 1
            explosionSound:play()
            resetBall()
        elseif newBallPosY == 1 or newBallPosY == MAX_TILES_Y then
            ballDirectionY = ballDirectionY * -1
            grid[ballPosY][ballPosX] = EMPTY
            grid[newBallPosY][newBallPosX] = BALL
            ballPosX = newBallPosX
            ballPosY = newBallPosY
        else
            grid[ballPosY][ballPosX] = EMPTY
            grid[newBallPosY][newBallPosX] = BALL
            ballPosX = newBallPosX
            ballPosY = newBallPosY
        end

        directionP1 = NONE
        directionP2 = NONE
    end
end

function love.draw()
    drawGrid()
    drawScore()
end
