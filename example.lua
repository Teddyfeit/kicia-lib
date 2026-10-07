--[[
    KiciaLib-Complete.lua  -  every feature of the library in one script
    Shows every widget and every method KiciaLib exposes:
      - all core widgets (toggle, slider, dropdown, color, button,
        input, keybind, label, divider, dependency box)
      - every advanced widget that is reachable through AddRaw
      - the element API (State / Get / Set / OnChanged / Raw)
      - the window API (tabs, accent, visibility, unload)
      - the library API (Version / Menu / Unload)

    Nothing here changes the game. Every callback only prints.

    Menu key: RightShift
    Offline variant: replace the loadstring line with
        local Library = loadstring(readfile('KiciaLib-Bundle.lua'))()
]]


--  1. LOAD

local URL = 'https://raw.githubusercontent.com/Teddyfeit/kicia-lib/refs/heads/main/library.lua'

-- this must read kicia-2026-10-07 in the console, otherwise you are
-- running an old copy of this file
local BUILD = 'kicia-2026-10-07'
if URL:find('sry%-bro%-idk') then
    warn('[demo] OLD LINK - this copy is outdated, reload the file from disk')
end
print('[demo] build ' .. BUILD .. '  |  ' .. URL)

local Library = loadstring(game:HttpGet(URL))()

print('[demo] Library.Version = ' .. tostring(Library.Version))


--  2. WINDOW

local Window = Library:CreateWindow{
    Title     = 'Complete Demo',
    MenuKey   = Enum.KeyCode.RightShift,
    Accent    = Color3.fromRGB(197, 59, 59),
    Directory = 'CompleteDemo',
    OnUnload  = function() print('[demo] OnUnload callback fired') end,
}

print('[demo] menu key = ' .. tostring(Window.Keybind))


--  3. HELPER - advanced widgets can fail if Kicia expects other props,
--     so every one of them runs through pcall and reports instead of
--     killing the whole script.

local function tryRaw(group, name, props)
    local ok, res = pcall(function() return group:AddRaw(name, props) end)
    if ok then
        print('[demo] ' .. name .. ' -> ok')
        return res
    end
    warn('[demo] ' .. name .. ' -> ' .. tostring(res))
    return nil
end


--  TAB 1  -  BASIC WIDGETS

local tab1 = Window:AddTab('Basics', { Description = 'Every core widget' })
local L1 = tab1:AddLeftGroupbox('Left column')
local R1 = tab1:AddRightGroupbox('Right column')
local F1 = tab1:AddFullGroupbox('Full width')

-- Label
L1:AddLabel('Text label (string form)')
L1:AddLabel{ Text = 'Text label (table form)' }

-- Toggle
local master = L1:AddToggle{
    Text     = 'Master switch',
    Default  = true,
    Tooltip  = 'Tooltips show on hover',
    Callback = function(v) print('[demo] master = ' .. tostring(v)) end,
}

-- Slider
L1:AddSlider{
    Text = 'Whole numbers', Min = 0, Max = 100,
    Rounding = 0, Default = 50, Suffix = '%',
    Callback = function(v) print('[demo] whole = ' .. v) end,
}

L1:AddSlider{
    Text = 'Two decimals', Min = 0, Max = 1,
    Rounding = 2, Default = 0.35,
    Callback = function(v) print('[demo] precise = ' .. v) end,
}

-- raw Step instead of Rounding
L1:AddSlider{
    Text = 'Raw step 0.001', Min = 0, Max = 1,
    Step = 0.001, Default = 0.5,
    Callback = function(v) print('[demo] step = ' .. v) end,
}

L1:AddDivider()

-- Buttons, all three variants
L1:AddButton{
    Text = 'Default variant',
    Callback = function() print('[demo] default button') end,
}
L1:AddButton{
    Text = 'Primary variant', Variant = 'primary',
    Callback = function() print('[demo] primary button') end,
}
L1:AddButton{
    Text = 'Ghost variant', Variant = 'ghost',
    Callback = function() print('[demo] ghost button') end,
}

L1:AddDivider()

-- Input (text box)
local inputObj = L1:AddInput{
    Text        = 'Text box',
    Placeholder = 'type here',
    Default     = '',
    Callback    = function(v) print('[demo] text = ' .. tostring(v)) end,
}

-- Keybind (best effort - pcall'd inside the library)
local keyObj = L1:AddKeybind{
    Text     = 'Keybind row',
    Callback = function(k) print('[demo] key = ' .. tostring(k)) end,
}
if keyObj == nil then
    L1:AddLabel('Keybind not available in this build')
end


-- Dropdown
local dropObj = R1:AddDropdown{
    Text     = 'Dropdown',
    Options  = { 'First', 'Second', 'Third', 'Fourth' },
    Default  = 'Second',
    Tooltip  = 'Default must be one of the Options',
    Callback = function(v) print('[demo] dropdown = ' .. v) end,
}

-- Color picker
local colorObj = R1:AddColorPicker{
    Text     = 'Color picker',
    Default  = Color3.fromRGB(255, 80, 80),
    Callback = function(c)
        print(string.format('[demo] color = %d, %d, %d', c.R * 255, c.G * 255, c.B * 255))
    end,
}

R1:AddDivider()
R1:AddLabel('Labels and dividers work in every group.')

R1:AddButton{
    Text     = 'Set dropdown to "Fourth"',
    Callback = function() dropObj:Set('Fourth') end,
}
R1:AddButton{
    Text     = 'Reset color to green',
    Callback = function() colorObj:Set(Color3.fromRGB(0, 255, 120)) end,
}

-- Dependency box - only visible while the master toggle is on
local dep = R1:AddDependencyBox(master)
dep:AddLabel('Hidden until the master switch is on')
dep:AddSlider{
    Text = 'Dependent slider', Min = 1, Max = 10,
    Rounding = 0, Default = 3,
    Callback = function(v) print('[demo] dependent = ' .. v) end,
}
dep:AddToggle{
    Text = 'Nested toggle',
    Callback = function(v) print('[demo] nested = ' .. tostring(v)) end,
}

-- Full-width group
F1:AddLabel('This section spans both columns.')
F1:AddButton{
    Text = 'Print every current value',
    Callback = function()
        print('[demo] master   = ' .. tostring(master:Get()))
        print('[demo] dropdown = ' .. tostring(dropObj.State))
        print('[demo] input    = ' .. tostring(inputObj:Get()))
        print('[demo] color    = ' .. tostring(colorObj.State))
    end,
}


--  TAB 2  -  ADVANCED WIDGETS (via AddRaw, Kicia's own argument names)

local tab2 = Window:AddTab('Advanced', { Description = 'AddRaw widgets' })
local A1 = tab2:AddLeftGroupbox('Selection widgets')
local A2 = tab2:AddRightGroupbox('Display widgets')

tryRaw(A1, 'AddRangeSlider', {
    Label = 'Range', Min = 0, Max = 100, Default = { 20, 70 },
})

tryRaw(A1, 'AddMultiDropdown', {
    Label = 'Multi dropdown',
    Options = { 'Alpha', 'Beta', 'Gamma' },
    Default = { 'Alpha' },
})

tryRaw(A1, 'AddList', {
    Label = 'List', Options = { 'Player 1', 'Player 2', 'Player 3' },
    Default = 'Player 1',
})

tryRaw(A1, 'AddMultiList', {
    Label = 'Multi list', Options = { 'Red', 'Green', 'Blue' },
    Default = { 'Red' },
})

tryRaw(A1, 'AddOrderedList', {
    Label = 'Ordered list', Options = { 'One', 'Two', 'Three' },
})

tryRaw(A2, 'AddIconStrip', {
    Label = 'Icon strip',
    Options = {
        { Name = 'A', Icon = 'rbxassetid://118838006164746' },
        { Name = 'B', Icon = 'rbxassetid://106205298246017' },
    },
})

tryRaw(A2, 'AddViewport', {
    Label = 'Viewport',
    Model = nil,
})

tryRaw(A2, 'AddGear', {
    Label = 'Gear',
})

tryRaw(A2, 'AddMultiSection', {
    Label = 'Multi section',
})

A2:AddDivider()
A2:AddLabel('AddSkinChanger is deliberately not demoed - it belongs to the original project, not to a UI test.')


--  TAB 3  -  ELEMENT API AND WINDOW API

local tab3 = Window:AddTab('API', { Description = 'Get / Set / OnChanged / window' })
local E1 = tab3:AddLeftGroupbox('Element API')
local E2 = tab3:AddRightGroupbox('Window API')

local probe = E1:AddToggle{
    Text = 'Probe object',
    Callback = function(v) print('[demo] probe callback = ' .. tostring(v)) end,
}

-- a second observer; OnChanged adds, never replaces
probe:OnChanged(function(v) print('[demo] probe observer 2 = ' .. tostring(v)) end)

E1:AddButton{
    Text = 'probe:Set(true)',
    Callback = function()
        probe:Set(true)
        print('[demo] after Set: State=' .. tostring(probe.State) .. ' Get()=' .. tostring(probe:Get()))
    end,
}
E1:AddButton{
    Text = 'probe:Set(false, true) silent',
    Callback = function()
        probe:Set(false, true)
        print('[demo] silent Set done, State=' .. tostring(probe.State))
    end,
}
E1:AddButton{
    Text = 'Print raw widget type',
    Callback = function()
        print('[demo] probe.Type = ' .. tostring(probe.Type))
        print('[demo] probe.Raw  = ' .. tostring(probe.Raw))
    end,
}

E1:AddDivider()
E1:AddLabel('Type / State / Raw are fields. Get / Set / OnChanged are methods.')

-- Window API
E2:AddButton{
    Text = 'Accent: red', Variant = 'primary',
    Callback = function() Window:SetAccent(Color3.fromRGB(197, 59, 59)) end,
}
E2:AddButton{
    Text = 'Accent: blue',
    Callback = function() Window:SetAccent(Color3.fromRGB(0, 85, 255)) end,
}
E2:AddButton{
    Text = 'Accent: green',
    Callback = function() Window:SetAccent(Color3.fromRGB(0, 200, 120)) end,
}

E2:AddDivider()

E2:AddButton{
    Text = 'Hide the menu (2 s)',
    Variant = 'ghost',
    Callback = function()
        Window:SetVisible(false)
        task.delay(2, function() Window:SetVisible(true) end)
    end,
}

E2:AddButton{
    Text = 'Print menu keybind',
    Callback = function() print('[demo] Window.Keybind = ' .. tostring(Window.Keybind)) end,
}

E2:AddButton{
    Text = 'Print Library.Menu',
    Callback = function() print('[demo] Library.Menu = ' .. tostring(Library.Menu)) end,
}

E2:AddDivider()

E2:AddButton{
    Text = 'Unload the whole menu',
    Variant = 'ghost',
    Callback = function()
        print('[demo] unloading...')
        Window:Unload()
    end,
}


--  DONE

print('[demo] ready - press RightShift to open/close the menu')
print('[demo] tabs: Basics | Advanced | API')
