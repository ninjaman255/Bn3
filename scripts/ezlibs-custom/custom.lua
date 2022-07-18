local CustPlugin = {}

local playerNaviCache = require('scripts/ezlibs-custom/player_navi_cache')
local nebulibs = require('scripts/ezlibs-custom/nebulous-liberations/main')
local helpers = require('scripts/ezlibs-scripts/helpers')
local ezcheckpoints = helpers.safe_require('scripts/ezlibs-custom/ezcheckpoints')
local ezshortcuts = helpers.safe_require('scripts/ezlibs-custom/ezshortcuts')
local compression = helpers.safe_require('scripts/ezlibs-custom/compression')
local simplebbsmenus = require('scripts/ezlibs-custom/simplebbsmenus')
return CustPlugin