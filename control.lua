require "defines"


local function show_gui(player_index, ent_name, position)
    if not global.gui_data then global.gui_data = {} end

    local player = game.get_player(player_index)
    local ent = player.surface.find_entity(ent_name, position)

    if not ent or not ent.valid then return end

    global.gui_data[player_index] = {
        entity_name = ent_name,
        position = position,
    }

    local root = player.gui.center.add{type="frame",
        name="assembly_naming_GUI",
        caption={"assembly-naming-title"},
        direction="horizontal"}

    root.add{type="textfield", name="new_name", text=ent.backer_name}
    root.add{type="button", name="assembly_naming_close", caption={"assembly-naming-close"}}

    root.new_name.text = ent.backer_name
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


game.on_event(defines.events.on_gui_click, function(event)
    local status, err = pcall(gui_click, event)
    if err then notify_error({"WrenchFu-Demo-error", err}) end
end)


local interface = {}

function interface.show_naming_gui(player_index, ent_name, position)
    local status, err = pcall(show_gui, player_index, ent_name, position)
    if err then notify_error({"WrenchFu-Demo-error", err}) end
end

function interface.hide_naming_gui(player_index, ent_name, position)
    local status, err = pcall(hide_gui, player_index, ent_name, position)
    if err then notify_error({"WrenchFu-Demo-error", err}) end
end

remote.add_interface("WrenchFu-Demo", interface)


game.on_init(function()
    remote.call("WrenchFu", "register", "assembling-machine-1", "WrenchFu-Demo", "show_naming_gui", "hide_naming_gui")
    remote.call("WrenchFu", "register", "assembling-machine-2", "WrenchFu-Demo", "show_naming_gui", "hide_naming_gui")
    remote.call("WrenchFu", "register", "assembling-machine-3", "WrenchFu-Demo", "show_naming_gui", "hide_naming_gui")
end)

game.on_load(function()
    remote.call("WrenchFu", "register", "assembling-machine-1", "WrenchFu-Demo", "show_naming_gui", "hide_naming_gui")
    remote.call("WrenchFu", "register", "assembling-machine-2", "WrenchFu-Demo", "show_naming_gui", "hide_naming_gui")
    remote.call("WrenchFu", "register", "assembling-machine-3", "WrenchFu-Demo", "show_naming_gui", "hide_naming_gui")
end)
