function table.reverse(t)
  local m = {}
  for i = #t, 1, -1 do table.insert(m, t[i]) end
  return m
end

function math.lerp(a,b,t)
  return (1-t)*a + t*b
end

function math.clamp(low, up, v)
  return math.max(low, math.min(up, v))
end

function math.sign(k)
  if k > 0 then
    return 1
  elseif k < 0 then
    return -1
  else
    return 0
  end
end

function rectDir(x, y, w, h, dir)
  if dir == "t" then
    return x, y + h, w, h
  elseif dir == "b" then
    return x, y - h, w, h
  elseif dir == "r" then
    return x + w, y, w, h
  elseif dir == "l" then
    return x - w, y, w, h
  end
  return x, y ,w, h
end
