Ball = Class{}

function Ball:init(x, y, width, height)
	self.x = x
  self.y = y
  self.width = width
  self.height = height

  self.dx = 0
  self.dy = math.random(-50, 50)
end

function Ball:reset()
  self.x = V_WIDTH / 2 - 2
  self.y = V_HEIGHT / 2 - 2

  self.dx = 0
  self.dy = math.random(-50, 50)
end

function Ball:update(dt)
  
  if self.dy < 0 then
    self.y = math.max(0, self.y + self.dy * dt)
  elseif self.dy > 0 then
    self.y = math.min(V_HEIGHT - self.height, self.y + self.dy * dt)
   end 
  
  if self.y == 0 or self.y == V_HEIGHT - self.height then
    sounds['wall_hit']:play()
    self.dy = -self.dy
  end

  -- Just update X coordinate everytime.
  self.x = self.x + self.dx * dt

end

function Ball:draw()
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function Ball:collides(paddle)
  
  if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
    return false
  end

  if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
    return false
  end

  return true
end