require "defines"


function notify_error(msg)
    for _,player in pairs(game.players) do
        player.print(msg)
    end
end


local function show_gui_with_player_and_entity(player, entity)
    if not global.gui_data then global.gui_data = {} end

    if not entity or not entity.valid then return end

    global.gui_data[player.index] = {
        entity_name = entity.name,
        position = entity.position,
    }

    local root = player.gui.center.add{type="frame",
        name="assembly_naming_GUI",
        caption={"assembly-naming-title"},
        direction="horizontal"}

    root.add{type="textfield", name="new_name", text=entity.backer_name}
    root.add{type="button", name="assembly_naming_close", caption={"assembly-naming-close"}}

    root.new_name.text = entity.backer_name
end


local function show_gui(player_index, ent_name, position)
    local player = game.get_player(player_index)
    local entity = player.surface.find_entity(ent_name, position)

    show_gui_with_player_and_entity(player, entity)
end


local function show_gui_with_entity(player_index, entity)
    local player = game.get_player(player_index)

    show_gui_with_player_and_entity(player, entity)
end


local function hide_gui(player_index, ent_name, position)
    local player = game.get_player(player_index)

    if player.gui.center.assembly_naming_GUI ~= nil and player.gui.center.assembly_naming_GUI.valid then
        player.gui.center.assembly_naming_GUI.destroy()
    end
end


local function gui_click(event)
    local player = game.get_player(event.player_index)

    if event.element.name == "assembly_naming_close" then
        if global.gui_data and global.gui_data[event.player_index] then
            local gui_data = global.gui_data[event.player_index]
            local ent = player.surface.find_entity(gui_data.entity_name, gui_data.position)

            if ent and ent.valid then
                ent.backer_name = player.gui.center.assembly_naming_GUI.new_name.text
            end
        end

        hide_gui(event.player_index)
    end
end


local function count_items(player, entity)
    if not player or not entity then return end

    player.print({"item-count-line", entity.localised_name, entity.get_item_count()})
end


script.on_event(defines.events.on_gui_click, function(event)
    local status, err = pcall(gui_click, event)
    if err then notify_error({"WrenchFu-Demo-error", err}) end
end)


local interface = {}

function interface.show_naming_gui(player_index, ent_name, position)
    local status, err = pcall(show_gui, player_index, ent_name, position)
    if err then notify_error({"WrenchFu-Demo-error", err}) end
end

function interface.show_naming_gui_with_entity(player_index, entity)
    local status, err = pcall(show_gui_with_entity, player_index, entity)
    if err then notify_error({"WrenchFu-Demo-error", err}) end
end

function interface.hide_naming_gui(player_index, ent_name, position)
    local status, err = pcall(hide_gui, player_index, ent_name, position)
    if err then notify_error({"WrenchFu-Demo-error", err}) end
end

function interface.count_items(player, entity)
    local status, err = pcall(count_items, player, entity)
    if err then notify_error({"WrenchFu-Demo-error", err}) end
end

function interface.no_op()
end

remote.add_interface("WrenchFu-Demo", interface)


-- The default convention: you will be told the entity name and position, and the close_function
-- will be called when the player is more than 6 tiles from the entity's position.
--
-- Note that, in this case, we can completely avoid passing any options, as the defaults are what
-- we wnat.
remote.call("WrenchFu", "register", "assembling-machine-1", "WrenchFu-Demo", "show_naming_gui", "hide_naming_gui")

-- Specifying options lets us gain more control over how WrenchFu will handle us.
--
-- To begin with, we can set a different proximity distance (distance the player must reach before
-- the close_function is called):
remote.call("WrenchFu", "register", "assembling-machine-2", "WrenchFu-Demo", "show_naming_gui", "hide_naming_gui",
    {
        proximity_distance = 30,
    })

-- We can also say that we want the actual entity that got hit by the wrench (instead of its name
-- and position):
remote.call("WrenchFu", "register", "assembling-machine-3", "WrenchFu-Demo", "show_naming_gui_with_entity", "hide_naming_gui",
    {
        proximity_distance = 30,
        wants_entity = true,
    })

-- Further, we can ask for an actual player instead of a player_index (saves us having to do it!):
local options = {
    wants_entity = true,
    wants_player = true,
}
-- Note that in the following we don't actually have a use for a close_function, so here are two
-- ways to handle that case:
--
-- 1. attach a no-op function as the handler. WrenchFu will call it, and it will do nothing.
-- (note: the no-op function must be in your remote interface!)
remote.call("WrenchFu", "register", "basic-transport-belt", "WrenchFu-Demo", "count_items", "no_op", options)
remote.call("WrenchFu", "register", "fast-transport-belt", "WrenchFu-Demo", "count_items", "no_op", options)
remote.call("WrenchFu", "register", "express-transport-belt", "WrenchFu-Demo", "count_items", "no_op", options)

-- 2. send nil as the handler. WrenchFu will notice this, and will not try to call it.
remote.call("WrenchFu", "register", "basic-transport-belt-to-ground", "WrenchFu-Demo", "count_items", nil, options)
remote.call("WrenchFu", "register", "fast-transport-belt-to-ground", "WrenchFu-Demo", "count_items", nil, options)
remote.call("WrenchFu", "register", "express-transport-belt-to-ground", "WrenchFu-Demo", "count_items", nil, options)

