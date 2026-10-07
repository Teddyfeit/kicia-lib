# kicia-lib - Used really much ai
================================================================================
  KICIALIB - FULL DOCUMENTATION
  ================================================================================
  A GUI library in the style of LinoriaLib, built on the extracted Kicia menu.
  Use it to build your own menus: tabs, group boxes, toggles, sliders,
  dropdowns, colour pickers, buttons, text boxes, keybinds.

  Folder: ...\Default Project\KiciaLib\

      KiciaLib-Bundle.lua        519,050 bytes   pure library, ends with return Library
      Mein-Script.lua            521,119 bytes   everything in one file, run it directly
      Mein-Script-Url.lua          5,136 bytes   loadstring + your code underneath
      KiciaLib-Complete.lua       12,068 bytes   every widget in one demo script
      Harmlos-Script.lua           2,001 bytes   tiny harmless demo
      KiciaLib.lua                15,752 bytes   library, two-file variant
      KiciaUI.lua                501,738 bytes   GUI engine (two-file variant only)
      KiciaLib-Doku.txt                       this file (English)
      KiciaLib-Tutorial.txt                   step-by-step (German)
      Mein-Script                           example with buttons


================================================================================
  0. THREE WAYS TO USE THE LIBRARY
================================================================================

  WAY A - one file, no hosting, no workspace
  -------------------------------------------
  Open Mein-Script.lua in your executor and run it. The whole engine, the
  whole library and your own code are in that single file. Your code starts
  at line 19,349 (jump there with Ctrl+End).

  WAY B - one loadstring over the internet (the LinoriaLib pattern)
  -----------------------------------------------------------------
  Host KiciaLib-Bundle.lua once, then in your script:

      local Library = loadstring(game:HttpGet('RAW_URL/kicia-lib-v1.lua'))()

      -- your code with the buttons goes underneath

  KiciaLib-Bundle.lua contains nothing of your code. It ends with
  "return Library", which is why loadstring(...)() gives you the Library
  back. Nothing is written to your workspace.

  WAY C - two files in the executor workspace
  -------------------------------------------
      local Library = loadstring(readfile('KiciaLib.lua'))()

  Needs KiciaLib.lua (15,752 bytes) AND KiciaUI.lua (501,738 bytes) in the
  same folder. KiciaUI.lua can then be swapped on its own.

  RULE: always load a file as a file. Never mark a long text and paste it -
  one corrupted line kills the whole script. If the byte count does not
  match, the file was damaged while copying.


================================================================================
  1. YOUR FIRST SCRIPT
================================================================================

  -- 1. load
  local Library = loadstring(game:HttpGet('RAW_URL/kicia-lib-v1.lua'))()

  -- 2. window
  local Window = Library:CreateWindow{
      Title = 'My Script',
      Icon  = 'rbxassetid://127234874352422',
  }

  -- 3. tab and group boxes
  local Main = Window:AddTab('Main')
  local Left = Main:AddLeftGroupbox('General')
  local Right = Main:AddRightGroupbox('Options')

  -- 4. widgets
  Left:AddToggle{
      Text     = 'Enabled',
      Default  = true,
      Callback = function(v) print('toggle =', v) end,
  }

  Left:AddSlider{
      Text = 'Brightness', Min = 0, Max = 100,
      Rounding = 0, Default = 50, Suffix = '%',
      Callback = function(v) print('slider =', v) end,
  }

  Right:AddButton{
      Text     = 'Click me',
      Callback = function() print('clicked') end,
  }

  Menu key: RightShift by default.
  Closing: Window:Unload(), or the X in the menu.


================================================================================
  2. LAYOUT / HIERARCHY
================================================================================

  There are four levels, outermost first:

      Library                the library itself
        +- Window            the window (there is only one per script)
             +- Tab          a tab along the top
                  +- Group   a titled column (left box / right box)

  Every widget function (AddToggle, AddSlider, ...) hangs off a Group.
  A Group is created from a Tab:

      local Tab = Window:AddTab('Visuals')
      local Box = Tab:AddLeftGroupbox('Atmosphere')

  Then:  Box:AddToggle{ ... }

  The order is always:
      CreateWindow  ->  AddTab  ->  AddLeftGroupbox / AddRightGroupbox
      ->  AddToggle / AddSlider / ...

  Skipping a step gives "attempt to call a nil value (field 'AddToggle')".
  Storing the result matters: without "local Main = Window:AddTab(...)"
  you get "attempt to index nil (field 'AddLeftGroupbox')". Objects in Lua
  are invisible unless you assign them to a variable.


================================================================================
  3. Library  (the root)
================================================================================

  Library.Version
      '1.0'

  Library:CreateWindow(opts)  ->  Window
      opts is a table with:
          Title       string        window title (falls back to 'KiciaLib')
          Icon        string        'rbxassetid://...'
          Description string        subtitle
          Directory   string        folder for saved state
          MenuKey     Enum.KeyCode  keyboard shortcut for the menu
          Accent      Color3        accent colour
          OnUnload    function      called when the menu closes

      Create only ONE window per script.

  Library:Unload()
      Close the window, fire OnUnload, destroy everything.

  Library.Menu
      The raw Kicia menu, for advanced use. nil until a window exists.

  Sharing between scripts:
      KiciaLib remembers itself through getgenv().KiciaLib. If a second
      script runs the same loadstring line it gets the SAME Library, so
      no second window appears - exactly like LinoriaLib. To start over,
      call Library:Unload() first.

      Library.Menu is what makes that reuse check work: it is set by
      CreateWindow and cleared again by both Unload paths.


================================================================================
  4. Window
================================================================================

  Window:AddTab(name)                  ->  Tab
  Window:AddTab(name, {                ->  Tab
      Label       = 'Visuals',
      Icon        = 'rbxassetid://...',
      Description = 'Text under the title',
  })
      name may be the visible title directly.

  Window:SetVisible(true|false, force?)
      Show or hide the menu. force = true skips the animation.

  Window:SetAccent(Color3)
      Change the accent colour at runtime.

  Window:Unload()
      Clean shutdown: fire OnUnload, save state, destroy.

  Window.Keybind
      Current key (Enum.KeyCode). Default: RightShift.

  Window.Menu / Window._raw
      The raw Kicia menu.


================================================================================
  5. Tab
================================================================================

  Tab:AddLeftGroupbox(title)     ->  Group
  Tab:AddRightGroupbox(title)    ->  Group
  Tab:AddFullGroupbox(title)     ->  Group

  Order does not matter. left / right are the two columns of the Kicia
  grid, 'full' occupies both columns.

  NOTE: a tab has exactly ONE grid. You may create any number of group
  boxes - they share that grid automatically. (Kicia throws an error if
  you try to build two grids, so the library creates the grid on the
  first call and remembers it.)


================================================================================
  6. Group  -  every widget
================================================================================

  All widgets take a table:

      widget = Group:AddToggle{ ... }

  ---------------------------------------------------------------------------
  AddToggle
  ---------------------------------------------------------------------------
      local t = Box:AddToggle{
          Text     = 'On',          -- label
          Default  = false,         -- starting value (true/false)
          Tooltip  = 'shown on hover',
          Callback = function(v)    -- fired on EVERY change
              print(v)              -- v is true or false
          end,
      }

      t.State     -> true/false
      t:Get()     -> true/false
      t:Set(true) -> write a value (callback does not fire)
      t:Set(true, true) -> write silently, callback does not fire
      t:OnChanged(fn)   -> add another observer (additive)

  ---------------------------------------------------------------------------
  AddSlider
  ---------------------------------------------------------------------------
      local s = Box:AddSlider{
          Text     = 'FOV',
          Min      = 30,
          Max      = 120,
          Rounding = 0,           -- decimal places (0..6)
          Default  = 80,
          Suffix   = '',          -- e.g. '%', 'm', string.char(176)
          Callback = function(v) print(v) end,
      }

      Rounding = 0  ->  integers, step 1
      Rounding = 2  ->  two decimals, step 0.01
      Rounding = 4  ->  step 0.0001

      To control the increment directly, use Step instead:
          Box:AddSlider{ Text='X', Min=0, Max=1, Step=0.001, Default=0.5 }
      Step wins if both are given.

      s.State -> number,  s:Get() -> number,  s:Set(55)

  ---------------------------------------------------------------------------
  AddDropdown
  ---------------------------------------------------------------------------
      local d = Box:AddDropdown{
          Text     = 'Preset',
          Options  = { 'Cinematic', 'Hazy', 'Vibrant', 'Noir' },
          Default  = 'Cinematic',   -- MUST be one of Options
          Tooltip  = 'what it does',
          Callback = function(v) print('chosen:', v) end,
      }

      IMPORTANT: Default must be one of the Options, otherwise the row
      renders empty. If Default is missing the first Option is used.

      d.State -> string,  d:Set('Noir')

  ---------------------------------------------------------------------------
  AddColorPicker
  ---------------------------------------------------------------------------
      local c = Box:AddColorPicker{
          Text     = 'Accent',
          Default  = Color3.fromRGB(255, 100, 0),
          Callback = function(color3)   -- you always get a Color3
              print(color3.R, color3.G, color3.B)
          end,
      }

      c.State -> Color3,  c:Set(Color3.fromRGB(0, 255, 0))

      Kicia stores { Rgb = Color3, Alpha = number } internally. The
      library converts that for you - in and out, always a Color3.

  ---------------------------------------------------------------------------
  AddButton
  ---------------------------------------------------------------------------
      Box:AddButton{
          Text     = 'Apply',
          Callback = function() print('click') end,
      }

      Variant (optional):
          Box:AddButton{ Text='Reset', Variant='ghost',   Callback=fn }
          Box:AddButton{ Text='Main',  Variant='primary', Callback=fn }

      A button has no state and returns nothing you need to keep.

  ---------------------------------------------------------------------------
  AddInput  (text box)
  ---------------------------------------------------------------------------
      local i = Box:AddInput{
          Text        = 'Key',
          Placeholder = 'XXXX-XXXX-XXXX',
          Default     = '',
          Callback    = function(v) print('text:', v) end,
      }

      i.State -> string,  i:Set('new text')

  ---------------------------------------------------------------------------
  AddKeybind
  ---------------------------------------------------------------------------
      local k = Box:AddKeybind{
          Text     = 'Menu key',
          Callback = function(keycode) print(keycode) end,
      }

      Default is optional (Enum.KeyCode.X). If the arguments are not
      supported by this build the library prints a warning and returns
      nil instead of crashing - guard with "if k then ... end".
      The widget arguments for Kicia's keybind row are NOT fully
      verified, which is why this one runs through pcall.

  ---------------------------------------------------------------------------
  AddLabel
  ---------------------------------------------------------------------------
      Box:AddLabel('plain text')
      Box:AddLabel{ Text  = 'table form' }
      Box:AddLabel{ Label = 'Kicia spelling' }

  ---------------------------------------------------------------------------
  AddDivider
  ---------------------------------------------------------------------------
      Box:AddDivider()

  ---------------------------------------------------------------------------
  AddDependencyBox  (contents only visible while a toggle is on)
  ---------------------------------------------------------------------------
      local master = Box:AddToggle{ Text = 'Effects on', Default = true }

      local sub = Box:AddDependencyBox(master)

      sub:AddSlider{ Text='Density', Min=0, Max=1, Step=0.01, Default=0.5 }

      sub has EXACTLY the same methods as Box: AddToggle, AddSlider,
      AddDropdown, AddColorPicker, AddButton, AddInput, AddKeybind,
      AddLabel, AddDivider, AddDependencyBox, AddRaw.

      Pass the toggle OBJECT (the wrapper), not the raw widget. The
      library unwraps it via .Raw, because Kicia's AddGroup listens to
      the raw control's ValueChanged.

  ---------------------------------------------------------------------------
  AddRaw  (escape hatch for every remaining Kicia widget)
  ---------------------------------------------------------------------------
      Kicia ships more widgets than this library maps directly. Reach
      them with AddRaw. The arguments are then Kicia's own spelling
      (Label, OnChanged instead of Text, Callback):

      Box:AddRaw('AddRangeSlider',   { Label='From-To', Min=0, Max=10 })
      Box:AddRaw('AddMultiDropdown', { Label='Tags', Options={'a','b'} })
      Box:AddRaw('AddList',          { Label='Players', Options={...} })
      Box:AddRaw('AddMultiList',     { Label='Team', Options={...} })
      Box:AddRaw('AddOrderedList',   { Label='Order', Options={...} })
      Box:AddRaw('AddIconStrip',     { Label='Icons', Options={...} })
      Box:AddRaw('AddViewport',      { Label='Preview', ... })
      Box:AddRaw('AddGear',          { ... })
      Box:AddRaw('AddMultiSection',  { ... })

      Full list of raw methods found on the container class:
        AddToggle AddSlider AddRangeSlider AddButton AddLabel AddDivider
        AddTextBox AddDropdown AddMultiDropdown AddList AddMultiList
        AddKeybind AddColor AddIconStrip AddViewport AddOrderedList
        AddGear AddGroup AddMultiSection

      Not demoed: AddSkinChanger - it belongs to the original project,
      not to a UI test.

      Unknown name -> error naming that method.
      Failure inside -> error() with the cause, so you can see it.

      Because these props are not verified, always call AddRaw through
      pcall in a demo script (see KiciaLib-Complete.lua, function tryRaw).


================================================================================
  7. The widget object  (returned by AddToggle, AddSlider, ...)
================================================================================

  Every widget except Button, Label and Divider returns an object:

      .Type       string   'Toggle' | 'Slider' | 'Dropdown' |
                           'ColorPicker' | 'TextBox' | 'Keybind'
      .State      any      current value, stays in sync
      .Raw        table    the underlying Kicia widget
                           (needed by AddDependencyBox)

      :Get()             -> current value
      :Set(v)            -> write a value
      :Set(v, true)      -> write WITHOUT firing the callback
      :OnChanged(fn)     -> add another observer
                           (any number of them, never replaces another)

  Watching a value without a callback at build time:

      local t = Box:AddToggle{ Text='Godmode' }
      t:OnChanged(function(v) print('now', v) end)
      t:OnChanged(function(v) log(v) end)   -- second observer

  Why chaining is safe: Kicia's OnChanged does
  "arg._trove:Connect(arg.Changed, arg2)" - it ADDS a connection, it
  never overwrites one.


================================================================================
  8. Callbacks vs. OnChanged
================================================================================

  While building you use Callback (the Linoria spelling):

      Box:AddToggle{ Text='On', Callback = function(v) ... end }

  Under the hood the library does:

      ctrl:OnChanged(function(raw) ... end)

  OnChanged adds observers, so calling it twice keeps both.

  If you want an extra observer later, use the returned object:

      local t = Box:AddToggle{ Text='On' }
      t:OnChanged(function(v) ... end)


================================================================================
  9. Managing state  (reading, writing, restoring)
================================================================================

  -- read
      local v = sliderObj.State
      local v = sliderObj:Get()

  -- write
      sliderObj:Set(75)

  -- write without firing callbacks
      sliderObj:Set(75, true)

  -- collect everything (for your own save system)
      local saved = {}
      for name, obj in pairs(myObjects) do
          saved[name] = obj:Get()
      end

  -- restore everything
      for name, v in pairs(saved) do
          if myObjects[name] then myObjects[name]:Set(v, true) end
      end

  There is NO built-in save/load. Kicia's own config module (bG) was
  deliberately left out of the extraction - it carries the original
  project's config schema. If you want persistence, build it with
  writefile / readfile over the loop above.


================================================================================
  10. Full example  (two tabs, dependency box, colour)
================================================================================

    local Library = loadstring(game:HttpGet('RAW_URL/kicia-lib-v1.lua'))()

    local Window = Library:CreateWindow{
        Title    = 'My Hub',
        Icon     = 'rbxassetid://127234874352422',
        MenuKey  = Enum.KeyCode.RightShift,
        Accent   = Color3.fromRGB(0, 170, 255),
    }

    -- tab 1
    local T1 = Window:AddTab('Visuals', { Description = 'Atmosphere' })
    local VLeft  = T1:AddLeftGroupbox('Master')
    local VRight = T1:AddRightGroupbox('Details')

    local enabled = VLeft:AddToggle{
        Text     = 'Everything on',
        Default  = true,
        Tooltip  = 'Switches the whole effect',
    }

    local box = VLeft:AddDependencyBox(enabled)
    box:AddSlider{
        Text='Density', Min=0, Max=1, Rounding=2, Default=0.5,
        Callback=function(v) print('density', v) end,
    }
    box:AddColorPicker{
        Text='Colour', Default=Color3.fromRGB(255,80,80),
        Callback=function(c) print('colour', c) end,
    }

    VRight:AddDropdown{
        Text='Preset', Options={'A','B','C'}, Default='A',
    }
    VRight:AddButton{
        Text='Reset', Variant='ghost',
        Callback=function() print('reset') end,
    }
    VRight:AddDivider()
    VRight:AddLabel('Done.')

    -- tab 2
    local T2 = Window:AddTab('Config')
    local CL = T2:AddLeftGroupbox('Save')
    CL:AddButton{ Text='Save', Callback=function() print('saved') end }


================================================================================
  11. MENU KEY
================================================================================

  Default: RightShift

  Change it:
      Window = Library:CreateWindow{ Title='...', MenuKey = Enum.KeyCode.F4 }

  Change it later:
      Window.Keybind = Enum.KeyCode.F4

  Keys: Enum.KeyCode.RightShift, Enum.KeyCode.LeftAlt,
        Enum.KeyCode.F4, Enum.KeyCode.End, Enum.KeyCode.Home, ...

  Note: set the key in the CreateWindow options, not afterwards - the
  label shown inside the menu follows the constructor value.


================================================================================
  12. CLOSING / CLEANUP
================================================================================

  Library:Unload()
      Close the window, fire OnUnload, destroy everything, clear the
      getgenv() marker so the next run builds fresh.

  Window:Unload()
      Same thing, through the window.

  OnUnload callback (passed to CreateWindow):
      Library:CreateWindow{
          Title = 'X',
          OnUnload = function()
              -- your own cleanup here:
              -- stop loops, disconnect hooks
              print('menu closed')
          end,
      }

  Re-running a script:
      If a second script loads the same library it reuses the existing
      window - no second one appears. To genuinely start over, call
      Library:Unload() first.


================================================================================
  13. WATCHING FOR ERRORS
================================================================================

  The library prints problems to the console (warn):
      [KiciaLib] could not install the error sink
      [KiciaLib] warm-up problems - XYZ: ...
      [KiciaLib] AddKeybind failed: ...
      [KiciaLib] <name> failed: ...
      [KiciaLib] could not load KiciaUI.lua ...

  warm-up problems means one of Kicia's modules was unreachable while
  building. The menu may still appear; some widgets then do not work.
  Send me that message.

  "could not load KiciaUI.lua" only happens in WAY C - the file is
  missing or outdated. Expected: 501,738 bytes. It cannot happen in
  WAY A or WAY B.

  The raw widget demos print their own results:
      [demo] AddList -> ok
      [demo] AddGear -> <error>
  That is expected: AddRaw properties are not verified, so a failing
  one is reported rather than fatal.


================================================================================
  14. COMMON ERRORS
================================================================================

  "attempt to call a nil value (field 'AddToggle')"
      You attached AddToggle to something that is not a Group.
      Order: CreateWindow -> AddTab -> AddLeftGroupbox -> AddToggle

  "attempt to index nil (field 'AddLeftGroupbox')"
      AddTab was not called, or its result was not saved with
      "local Main = Window:AddTab(...)".

  "table index is nil" on a dropdown
      Your Default value is not in Options.

  "attempt to index nil" on t.State
      The widget was nil. AddKeybind returns nil when unsupported -
      check first:  if obj then ... end

  "attempt to call a nil value (global 'readfile')"
      Your executor has no readfile, or you are in Roblox Studio.
      Use WAY A or WAY B instead.

  "attempt to call a nil value (global 'HttpGet')"
      HttpGet is disabled. Enable "Http Requests" in your executor,
      or use WAY A (single local file).

  "KiciaLib could not load KiciaUI.lua"
      WAY C only: KiciaUI.lua missing or outdated (501,738 bytes).

  Syntax error in the middle of the file
      The file was corrupted while copying or pasting. Never paste
      long files - copy them as files and check the byte count.

  Two windows open
      CreateWindow was called twice, or two separate Library instances
      were built. Call Library:Unload() first.

  Widget has no effect
      A Callback only fires on CHANGE. If the starting value is already
      correct, your code has to apply it once at start-up:
          applySomewhere(obj:Get())


================================================================================
  15. LIMITS  (what this library cannot do)
================================================================================

  - No built-in config storage. Kicia's config module was left out of
    the extraction on purpose - it carries the original project's
    schema. Build it yourself, see section 9.
  - No tabbox / sub-tab building through the library. Kicia has
    Tab:AddTab, but it does not mix with the grid.
  - AddKeybind works through pcall; its exact arguments are not fully
    verified, so it warns instead of crashing.
  - AddRaw widgets are reachable but their property names are taken
    from the source, not from a live test. Wrap them in pcall.
  - The look is Kicia, not LinoriaLib: dark, rounded corners, accent
    197,59,59, fonts rbxassetid://12187365364. The API is Linoria-like,
    the skin stays Kicia.
  - Requires an executor with loadstring / getgenv / readfile (WAY C)
    or HttpGet (WAY B). It does not run in Roblox Studio.


================================================================================
  16. QUICK REFERENCE
================================================================================

  Load (Way A)
      -- open Mein-Script.lua and run it, nothing else to load
  Load (Way B)
      local L = loadstring(game:HttpGet('RAW_URL/kicia-lib-v1.lua'))()
  Load (Way C)
      local L = loadstring(readfile('KiciaLib.lua'))()

  Build
      local W = L:CreateWindow{ Title='X', MenuKey=Enum.KeyCode.RightShift,
                                Accent=Color3, Directory='Dir',
                                OnUnload=fn, Icon='rbxassetid://...' }
      local T = W:AddTab('Main' [, { Label, Icon, Description }])
      local G = T:AddLeftGroupbox('Title')   -- also Right / Full

  Widgets
      G:AddToggle      { Text, Default, Callback, Tooltip }
      G:AddSlider      { Text, Min, Max, Rounding | Step, Default, Suffix, Callback }
      G:AddDropdown    { Text, Options, Default, Tooltip, Callback }
      G:AddColorPicker { Text, Default=Color3, Callback }
      G:AddButton      { Text, Callback, Variant = 'primary'|'ghost' }
      G:AddInput       { Text, Placeholder, Default, Callback }
      G:AddKeybind     { Text, Default=Enum.KeyCode, Callback }
      G:AddLabel       'text'   |  { Text = '...' }
      G:AddDivider     ()
      G:AddDependencyBox(toggleObject)  -> Group
      G:AddRaw('AddXyz', { Kicia props })

  Widget object
      .State  .Type  .Raw
      :Get()  :Set(v[, silent])  :OnChanged(fn)

  Window
      W:AddTab(name[, opts])   W:SetVisible(bool[, force])
      W:SetAccent(Color3)      W:Unload()   W.Keybind   W.Menu

  Library
      L.Version   L:CreateWindow(opts)   L:Unload()   L.Menu
      getgenv().KiciaLib


================================================================================
  END
================================================================================
