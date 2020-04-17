Paddle = Class{}

function Paddle:init(x, y, width, height, ai)
  self.x = x
  self.y = y
  self.width = width
  self.height = height

  self.ai = ai

  self.dy = 0
end

-- Retrieve the center portion of the paddle.
function Paddle:getCenterHeight()
    return self.y + (self.height / 2)
end

function Paddle:update(dt)

  -- The paddle is moving upwards
  if self.dy < 0 then
    -- check for the larger
    self.y = math.max(0, self.y + self.dy * dt)
  elseif self.dy > 0 then
    -- check for the lesser
    self.y = math.min(V_HEIGHT - self.height, self.y + self.dy * dt)
  end
end

function Paddle:draw()
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end