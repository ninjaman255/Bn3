--Enable fog for all maps

--[[ local ezweather = require('scripts/ezlibs-scripts/ezweather')
local custom = {}

local areas = Net.list_areas()
for i, area_id in ipairs(areas) do
    ezweather.start_fog_in_area(area_id)
    print('Loaded custom')
end
return custom
--]]