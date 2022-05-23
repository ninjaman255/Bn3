local Direction = require("scripts/libs/direction")

-- private functions

local function generate_selection_object(self)
  return {
    x = self.position.x + self.indicator.offset_x / 32,
    y = self.position.y + self.indicator.offset_y / 32,
    z = self.position.z,
    width = self.indicator.width / 32,
    height = self.indicator.height / 32,
    data = {
      type = "tile",
      gid = self.indicator.gid,
    }
  }
end

-- public
local Selection = {}

function Selection:new(instance)
  local attack_collider = {
    instance = instance,
    position = { x = 0, y = 0, z = 0 },
    shape = {},
    shape_offset_x = 0,
    shape_offset_y = 0,
    direction = nil,
    filter = nil,
    objects = {},
    indicator = nil
  }

  setmetatable(attack_collider, self)
  self.__index = self

  return attack_collider
end

function Selection:set_filter(filter)
  self.filter = filter
end

--[[
  indicator = {
    gid,
    width,
    height,
    offset_x,
    offset_y,
  }
]]
function Selection:set_indicator(indicator)
  self.indicator = indicator
end

-- shape = [m][n] bool array, n being odd, just below bottom center is actor position
function Selection:set_shape(shape, shape_offset_x, shape_offset_y)
  self.shape = shape
  self.shape_offset_x = shape_offset_x or 0
  self.shape_offset_y = shape_offset_y or 0
end

function Selection:move(position, direction)
  self.position.x = math.floor(position.x)
  self.position.y = math.floor(position.y)
  self.position.z = math.floor(position.z)
  self.direction = direction
end

function Selection:is_within(x, y, z)
  x = math.floor(x)
  y = math.floor(y)
  z = math.floor(z)

  if z ~= self.position.z then
    return false
  end

  local offset_x = self.position.x - x
  local offset_y = self.position.y - y

  -- transform the player position to fit into the shape
  -- default direction is UP RIGHT

  if self.direction == Direction.DOWN_LEFT then
    offset_x = -offset_x -- flipped
    offset_y = -offset_y -- flipped
  elseif self.direction == Direction.UP_LEFT then
    local old_offset_y = offset_y
    offset_y = -offset_x -- 🤷
    offset_x = old_offset_y -- negative for going left
  elseif self.direction == Direction.DOWN_RIGHT then
    local old_offset_y = offset_y
    offset_y = offset_x -- 🤷
    offset_x = -old_offset_y -- positive for going right
  end

  offset_x = offset_x - self.shape_offset_x
  offset_y = offset_y - self.shape_offset_y

  if offset_y < 1 or offset_y > #self.shape then
    return false
  end

  local row = self.shape[offset_y]
  local center_x = (#row - 1) / 2
  offset_x = offset_x + center_x + 1

  if offset_x < 1 or offset_x > #row then
    return false
  end

  local is_selected = row[offset_x]

  if is_selected == 0 or not is_selected then
    return false
  end

  return self.filter(x, y, z)
end

function Selection:indicate()
  -- generating objects
  for m, row in ipairs(self.shape) do
    local center_x = (#row - 1) / 2

    for n, is_selected in ipairs(row) do
      if is_selected == 0 or not is_selected then
        goto continue
      end

      -- facing up right by default
      local offset_x = n + self.shape_offset_x - center_x - 1
      local offset_y = -(m + self.shape_offset_y)

      -- adjusting the offset to the direction
      if self.direction == Direction.DOWN_LEFT then
        offset_x = -offset_x -- flipped
        offset_y = -offset_y -- flipped
      elseif self.direction == Direction.UP_LEFT then
        local old_offset_y = offset_y
        offset_y = -offset_x -- 🤷
        offset_x = old_offset_y -- negative for going left
      elseif self.direction == Direction.DOWN_RIGHT then
        local old_offset_y = offset_y
        offset_y = offset_x -- 🤷
        offset_x = -old_offset_y -- positive for going right
      end

      local x = self.position.x + offset_x
      local y = self.position.y + offset_y
      local z = self.position.z

      if not self.filter(x, y, z) then
        -- can't attack here
        goto continue
      end

      -- actually generating the object
      local object = generate_selection_object(self)
      object.x = object.x + offset_x
      object.y = object.y + offset_y
      object.layer = z
      object.z = z

      object.id = Net.create_object(self.instance.area_id, object)
      self.objects[#self.objects+1] = object

      ::continue::
    end
  end
end

function Selection:remove_indicators()
  -- delete objects
  for _, object in pairs(self.objects) do
    Net.remove_object(self.instance.area_id, object.id)
  end

  self.objects = {}
end

return Selection
