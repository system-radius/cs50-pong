--[[
  
  -- Main Program --
  Author: Darius Orias
]]

-- Require libraries
push = require 'push'
Class = require 'class'

-- Require class objects.
require 'Ball'
require 'Paddle'

-- Global constants
WORLD_WIDTH = 1280
WORLD_HEIGHT = 720

V_WIDTH = 432
V_HEIGHT = 243

PADDLE_SPEED = 200
PADDLE_HEIGHT = 20

START_BALL_SPEED = 100

VICTORY_SCORE = 10

-- Load the window and assets
function love.load()

  love.graphics.setDefaultFilter('nearest', 'nearest')
  
  love.window.setTitle('Pong!')

  -- Set a seed for the RNG
  math.randomseed(os.time())

  -- Loads a smaller font
  smallFont = love.graphics.newFont('font.ttf', 8)
  largeFont = love.graphics.newFont('font.ttf', 16)
  scoreFont = love.graphics.newFont('font.ttf', 32)

  sounds = {
    ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
    ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
    ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
  }

  -- Sets the loaded small font as the active font
  love.graphics.setFont(smallFont)
  -- Actual window loading. Using push allows for development in a static dimension (virtual)
  -- while still being flexible to be rendered to the actual dimensions.
  push:setupScreen(V_WIDTH, V_HEIGHT, WORLD_WIDTH, WORLD_HEIGHT, {
    fullscreen = false,
    resizable = true,
    vsync = true
  })

  servingPlayer = 1
  winningPlayer = 0

  player1Score = 0
  player2Score = 0

  player1 = Paddle(10, 30, 5, PADDLE_HEIGHT)
  player2 = Paddle(V_WIDTH - 10, V_HEIGHT - 30, 5, PADDLE_HEIGHT)

  ball = Ball(V_WIDTH / 2 - 2,V_HEIGHT / 2 - 2, 4, 4)
  ball:reset()

  gameState = 'start'

end

-- Called when the window gets resized.
function love.resize(width, height)
  push:resize(width, height)
end

function love.update(dt)
  
  -- Clamp the values for both up and down movements of the paddle
  if love.keyboard.isDown('w') then
    player1.dy = -PADDLE_SPEED
  elseif love.keyboard.isDown('s') then
    player1.dy = PADDLE_SPEED
  else
    player1.dy = 0
  end

  if love.keyboard.isDown('up') then
    player2.dy = -PADDLE_SPEED
  elseif love.keyboard.isDown('down') then
    player2.dy = PADDLE_SPEED
  else
    player2.dy = 0
  end

  player1:update(dt)
  player2:update(dt)

  if gameState == 'play' then

    ballBounced = false
    if ball:collides(player1) then
      -- Reverse the X velocity
      ball.dx = -ball.dx * 1.03
      ball.x = player1.x + 5

      ballBounced = true
    end

    if ball:collides(player2) then
      ball.dx = -ball.dx * 1.03
      ball.x = player2.x - 4

      ballBounced = true
    end

    if ballBounced then
      sounds['paddle_hit']:play()
      if ball.dy < 0 then
        ball.dy = -math.random(10, 100)
      else
        ball.dy = math.random(10, 100)
      end
    end

    -- Update the ball state
    ball:update(dt)

    -- Check if somebody scored
    ballReset = false
    if ball.x < 0 then
      player2Score = player2Score + 1
      ballReset = true

      if player2Score == VICTORY_SCORE then
        gameState = 'done'
        winningPlayer = 2
      else
        gameState = 'serve'
        servingPlayer = 1
      end
    elseif ball.x > V_WIDTH - ball.width then
      player1Score = player1Score + 1
      ballReset = true

      if player1Score == VICTORY_SCORE then
        gameState = 'done'
        winningPlayer = 1
      else 
        gameState = 'serve'
        servingPlayer = 2
      end
    end 

    if (ballReset) then
      sounds['score']:play()
      ball:reset()
    end

  end

end

-- Render stuff onto the screen
function love.draw()
  push:apply('start')

  -- Using the version 11 of Love2D, RGB values are fractions.
  love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255)

  love.graphics.setFont(smallFont)

  if gameState == 'start' then
    love.graphics.printf ('Welcome to Pong!', 0, 10, V_WIDTH, 'center')
	  love.graphics.printf ('Press Enter to begin!', 0, 20, V_WIDTH, 'center')
  elseif gameState == 'serve' then
    love.graphics.printf ('Player ' .. tostring(servingPlayer) .. '\'s serve!', 0, 10, V_WIDTH, 'center')
    love.graphics.printf ('Press Enter to serve!', 0, 20, V_WIDTH, 'center')
  elseif gameState == 'done' then
    love.graphics.printf ('Player ' .. tostring(winningPlayer) .. '\'s has won!', 0, 10, V_WIDTH, 'center')
    love.graphics.printf ('Press Enter to start over!', 0, 20, V_WIDTH, 'center')
  end

  love.graphics.setFont(scoreFont)
  love.graphics.print(tostring(player1Score), V_WIDTH / 2 - 50, V_HEIGHT / 3)
  love.graphics.print(tostring(player2Score), V_WIDTH / 2 + 50, V_HEIGHT / 3)

  player1:draw()
  player2:draw()

  ball:draw()

  displayFPS()

  push:apply('end')
end

function displayFPS()
  love.graphics.setFont(smallFont)
  love.graphics.setColor(0, 1, 0, 255)
  love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function love.keypressed(key)
  -- keys can be accessed by their string name
  if key == 'escape' then
    -- Quit the application if the Escape key is pressed.
    love.event.quit()
  elseif key == 'enter' or key == 'return' then
    if gameState == 'start' then
      gameState = 'serve'
    elseif gameState == 'serve' then
      gameState = 'play'
      ball.dx = servingPlayer == 1 and START_BALL_SPEED or -START_BALL_SPEED
    elseif gameState == 'done' then
      gameState = 'serve'
      servingPlayer = winningPlayer == 1 and 2 or 1

      player1Score = 0
      player2Score = 0
      ball:reset()

    else
      gameState = 'start' 

      player1Score = 0
      player2Score = 0
      ball:reset()

    end
  end
end