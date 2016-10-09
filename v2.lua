local v2 = {}
v2.__index = v2

function v2.__add(u, v)
  return v2.new(u.x + v.x, u.y + v.y)
end

function v2.__sub(u, v)
  return v2.new(u.x - v.x, u.y - v.y)
end

function v2.__mul(k, v)
  return v2.new(k * v.x, k * v.y)
end

function v2.__div(v, k)
  return v2.new(v.x / k, v.y / k)
end

function v2.__eq(u, v)
  return u.x == v.x and u.y == v.y
end

function v2.__tostring(u)
  return "(" .. u.x .. " " .. u.y .. ")"
end

function v2.new(x, y)
  if not y then
    y = x
  end
  return setmetatable({x = x or 0, y = y or 0}, v2)
end

function v2.dist(u, v)
  return (u - v):len()
end

function v2:clone()
  return v2.new(self.x, self.y)
end

function v2:unpack()
  return self.x, self.y
end

function v2:list()
  return {self.x, self.y}
end

function v2:lenSq()
  return self.x * self.x + self.y * self.y
end

function v2:len()
  return math.sqrt(self:lenSq())
end

function v2:norm()
  local len = self:len()
  self.x = self.x / len
  self.y = self.y / len
  return self
end

function v2:normed()
  local v = self:clone()
  return v:norm()
end

function v2:rotate(rad)
  return v2(self.x * math.cos(rad) - self.y * math.sin(rad),
            self.x * math.sin(rad) - self.y * math.cos(rad))
end

function v2:perp()
  return v2.new(-self.y, self.x)
end

function v2:dot(u)
  return (self * u) * u / u:lenSq()
end

function v2:cross(u)
  return self.x * u.y - self.y * u.x
end

function v2:clampToLen(k)
  local l = self:len()
  if l > k then
    local vs = k / l
    self.x = self.x * vs
    self.y = self.y * vs
  end
  return self
end

setmetatable(v2, {__call = function(_, ...) return v2.new(...) end})
return v2
