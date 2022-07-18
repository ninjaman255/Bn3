-- lib by TheMaverickProgrammer aka James King
-- 7/13/2022
-- create stacked menus to emulate submenu options easier


local simplebbsmenus = { _player_menu_states = {}}
local LIBNAME = "simplebbsmenus"

local function printd(msg)
    print("["..LIBNAME.."] "..msg)
end

local function generate_posts(menu)
    local posts = {}

    -- menus show up first as >title
    for _,v in pairs(menu._submenus) do
        posts[#posts+1] = {id = v._title, read = true, title = ">"..v._title, author = ""}
    end

    -- items show up afterwards by their name
    for _,v in pairs(menu._items) do
        posts[#posts+1] = {id = v._name, read = true, title = v._name, author = ""}
    end

    return posts
end

function simplebbsmenus.create_menu(parent, title)
    local new = { _title = title, _items = {}, _submenus = {}, _color = {r=100,g=100,b=100} }
    new._parent = parent

    if parent ~= nil then
        new._color = parent._color
    end

    function new:add_item(name, select_callback)
        local item = {_name=name, _select_callback=select_callback}
        self._items[name] = item
    end

    function new:create_submenu(title)
        local menu = simplebbsmenus.create_menu(self, title)
        self._submenus[title] = menu
        return menu
    end

    function new:remove_submenu_by_title(title)
        self._submenus[title] = nil
    end

    function new:get_item_by_name(name)
        return self._items[name]
    end

    function new:remove_item_by_name(name)
        self._items[name] = nil
    end

    function new:set_color(r,g,b)
        self._color = {r=r,g=g,b=b}
    end

    function new:get_title() return self._title end

    function new:open_for_player(player_id)
        -- TODO: Net.close_bbs(player_id) -- needed?
        local posts = generate_posts(self)
        warn("size of posts is "..#posts)
        Net.open_board(player_id, self._title, self._color, posts)
        --warn(self._title)
        --warn(self._color)
        --warn(posts)
        local entry = simplebbsmenus._player_menu_states[player_id]

        if entry == nil then
            simplebbsmenus._player_menu_states[player_id] = { _curr = nil }
            entry = simplebbsmenus._player_menu_states[player_id]
        end
        entry._curr = self
    end

    return new
end

function simplebbsmenus.handle_selection(player_id, post_id)
    local entry = simplebbsmenus._player_menu_states[player_id]

    if entry == nil then
        return
    end

    local menu = entry._curr._submenus[post_id]
    local item = entry._curr._items[post_id]

    if menu then
        menu:open_for_player(player_id)
        return
    end

    if item then
        if item._select_callback then
            item._select_callback(player_id, item._name, entry._curr, function()
                entry._curr = nil
            end)
        end
    end
end

printd("Loaded")
return simplebbsmenus