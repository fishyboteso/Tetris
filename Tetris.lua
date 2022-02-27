-- Addon Struct, holds everything of importance
Tetris = {
    name = "Tetris",
    author = "Sem",
    manipulations = {},
    array = {},
    blocks = {},
    Block = {}
}
-- Struct for Block Manipulations
Tetris.manipulations = {
    nothing = 0,
    left = 1,
    right = 2,
    rotate = 3,
    slam = 4,
    down = 5
}
--Struct for Block types
Tetris.blocks = {
    none = 0,
    j = 1,
    l = 2,
    t = 3,
    i = 4,
    z = 5,
    s = 6,
    o = 7
}

-- SavedVar
local Tetrisparams = {}
local Tetrisdefaults = {
    pixelsize   = 16,
    timeout     = 500,
    posx        = 0,
    posy        = 0
}

-- Imports
local logger = LibDebugLogger(Tetris.name)

-- Maximum manipulations per tick
local maxManipulations = { left = 5, right = 5, rotate = 4 }

-- Constants
local brdr = 8
local width = 10
local height = 20

-- Temporary variables
local gameover = false
local typusList = {0,0,0,0,0,0,0}
local greyline = height-1


-- Copy a nested table
-- http://lua-users.org/wiki/CopyTable
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


-- Set Block in Tetris array
local function _setBlockToArray(typus)
    Tetris.array[Tetris.Block.a.x][Tetris.Block.a.y] = typus
    Tetris.array[Tetris.Block.b.x][Tetris.Block.b.y] = typus
    Tetris.array[Tetris.Block.c.x][Tetris.Block.c.y] = typus
    Tetris.array[Tetris.Block.d.x][Tetris.Block.d.y] = typus
end


-- Executes Manipulation on pixel array if possible
local function _execManipulation(manipulation)
    tempBlock = deepcopy(Tetris.Block)

    -- unset old position
    _setBlockToArray(Tetris.blocks.none)

    if manipulation == Tetris.manipulations.left then
        Tetris.Block = TetrisMoves.left(Tetris.Block)
    elseif manipulation == Tetris.manipulations.right then
        Tetris.Block = TetrisMoves.right(Tetris.Block)
    elseif manipulation == Tetris.manipulations.rotate then
        Tetris.Block = TetrisMoves.rotate(Tetris.Block)
    elseif manipulation == Tetris.manipulations.down then
        Tetris.Block = TetrisMoves.down(Tetris.Block)
    end

    --check if it is outside of the grid
    --bottom
    if Tetris.Block.a.y >= height or Tetris.Block.b.y >= height or
       Tetris.Block.c.y >= height or Tetris.Block.d.y >= height then
        Tetris.Block = deepcopy(tempBlock)

        _setBlockToArray(Tetris.Block.typus)
        return false
    end
    --left border
    if Tetris.Block.a.x < 0 or Tetris.Block.b.x < 0 or
       Tetris.Block.c.x < 0 or Tetris.Block.d.x < 0 then
        Tetris.Block = deepcopy(tempBlock)

        _setBlockToArray(Tetris.Block.typus)
        return false
    end
    --right border
    if Tetris.Block.a.x >= width or Tetris.Block.b.x >= width or
       Tetris.Block.c.x >= width or Tetris.Block.d.x >= width then
        Tetris.Block = deepcopy(tempBlock)

        _setBlockToArray(Tetris.Block.typus)
        return false
    end

     --check if pixels are free
    if Tetris.array[Tetris.Block.a.x][Tetris.Block.a.y] ~= Tetris.blocks.none or Tetris.array[Tetris.Block.b.x][Tetris.Block.b.y] ~= Tetris.blocks.none or
       Tetris.array[Tetris.Block.c.x][Tetris.Block.c.y] ~= Tetris.blocks.none or Tetris.array[Tetris.Block.d.x][Tetris.Block.d.y] ~= Tetris.blocks.none then
        Tetris.Block = deepcopy(tempBlock)

        _setBlockToArray(Tetris.Block.typus)
        return false
    end

    -- set new position
    _setBlockToArray(Tetris.Block.typus)

    return true
end


-- Redraws the User Interface of Tetris
local function _drawUI()
    for i=0,width-1 do
        for j=0,height-1 do
            if Tetris.array[i][j] == Tetris.blocks.j then
                Tetris.UI.pixel[i][j]:SetColor(0.06, 0.12, 0.90, 1) --blue
            elseif Tetris.array[i][j] == Tetris.blocks.l then
                Tetris.UI.pixel[i][j]:SetColor(0.87, 0.60, 0.15, 1) --orange
            elseif Tetris.array[i][j] == Tetris.blocks.t then
                Tetris.UI.pixel[i][j]:SetColor(0.53, 0.17, 0.90, 1) --purple
            elseif Tetris.array[i][j] == Tetris.blocks.i then
                Tetris.UI.pixel[i][j]:SetColor(0.41, 0.91, 0.93, 1) --turquoise
            elseif Tetris.array[i][j] == Tetris.blocks.z then
                Tetris.UI.pixel[i][j]:SetColor(0.83, 0.18, 0.07, 1) --red
            elseif Tetris.array[i][j] == Tetris.blocks.s then
                Tetris.UI.pixel[i][j]:SetColor(0.41, 0.90, 0.21, 1) --green
            elseif Tetris.array[i][j] == Tetris.blocks.o then
                Tetris.UI.pixel[i][j]:SetColor(0.93, 0.92, 0.22, 1) --yellow
            elseif Tetris.array[i][j] == Tetris.blocks.none then
                Tetris.UI.pixel[i][j]:SetColor(1, 1, 1, 1) --white
            end
            Tetris.UI.background:SetColor(0,0,0,1)
        end
    end
end


-- Checks if any more downwards moves are possible for active Block
-- returns TRUE if down move is possible for Block
-- else FALSE
local function _checkMoves()
    if Tetris.Block.a.y >= Tetris.Block.b.y and Tetris.Block.a.y >= Tetris.Block.c.y and Tetris.Block.a.y >= Tetris.Block.d.y then
        if Tetris.array[Tetris.Block.a.x][Tetris.Block.a.y+1] ~= Tetris.blocks.none then
            return false
        end

    elseif Tetris.Block.b.y >= Tetris.Block.a.y and Tetris.Block.b.y >= Tetris.Block.c.y and Tetris.Block.b.y >= Tetris.Block.d.y then
        if Tetris.array[Tetris.Block.b.x][Tetris.Block.b.y+1] ~= Tetris.blocks.none then
            return false
        end

    elseif Tetris.Block.c.y >= Tetris.Block.a.y and Tetris.Block.c.y >= Tetris.Block.b.y and Tetris.Block.c.y >= Tetris.Block.d.y then
        if Tetris.array[Tetris.Block.c.x][Tetris.Block.c.y+1] ~= Tetris.blocks.none then
            return false
        end

    elseif Tetris.Block.d.y >= Tetris.Block.a.y and Tetris.Block.d.y >= Tetris.Block.b.y and Tetris.Block.d.y >= Tetris.Block.c.y then
        if Tetris.array[Tetris.Block.d.x][Tetris.Block.d.y+1] ~= Tetris.blocks.none then
            return false
        end
    end

    return true
end


-- Checks if the new Block fits into the field
-- returns TRUE if a new Block can be spawned
-- else FALSE
local function _checkBlock()
    if Tetris.array[Tetris.Block.a.x][Tetris.Block.a.y] ~= Tetris.blocks.none or Tetris.array[Tetris.Block.b.x][Tetris.Block.b.y] ~= Tetris.blocks.none or
       Tetris.array[Tetris.Block.c.x][Tetris.Block.c.y] ~= Tetris.blocks.none or Tetris.array[Tetris.Block.d.x][Tetris.Block.d.y] ~= Tetris.blocks.none then
        return false
    end
    return true
end


-- Creates a new Block if possible, else it triggers "game over" state
local function _createBlock()

    -- complicated way to make sure that every Block type comes at least every 13th turn
    -- typuslist holds a counter for each block type
    j = 1
    for i=1,#typusList do
        if typusList[j] <= typusList[i] then
            j = i
        end
    end

    -- if any Block type was not played for 13 turns, it will be played now
    if typusList[j] > 12 then
        typus = j
        typusList[typus] = 0
    -- else a random block will be played
    else
        -- math.random does not feel random in a pleasant way
        math.randomseed(GetGameTimeMilliseconds())
        typus = math.random(Tetris.blocks.j, Tetris.blocks.o)
        for i=1,#typusList do
            typusList[i] = typusList[i] + 1
        end
        typusList[typus] = 0
    end


    -- get the Block start layout from  Moves.lua
    Tetris.Block = TetrisMoves.start(typus)

    -- check for "game over"
    if not _checkMoves() or not _checkBlock() then
        EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "tick")
        gameover = true
        EVENT_MANAGER:RegisterForUpdate(Tetris.name .. "gameover", 150, Tetris.gameOver)
    else
        _setBlockToArray(typus)
    end

    _drawUI()
end


-- "Game over" state control and animation
function Tetris.gameOver()
    EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "gameover")
    EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "tick")

    -- exit condition, for when all lines are removed
    if greyline == -1 then
        if Tetris.running == true then
            greyline = height-1
            gameover = false
            _createBlock()
            EVENT_MANAGER:RegisterForUpdate(Tetris.name .. "tick", Tetrisparams.timeout, Tetris.tick)
            return
        end
    end

    -- remove next line and timeout
    for i=0,width-1 do
        Tetris.array[i][greyline] = Tetris.blocks.none
    end
    _drawUI()

    greyline = greyline - 1

    EVENT_MANAGER:RegisterForUpdate(Tetris.name .. "gameover", 150, Tetris.gameOver)
end


-- Slam timeout to allow one more manipulation after slam
local function _slam()
    EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "slam")
    Tetris.tick()
end


-- Manipulate active Block (left,right,rotate,slam)
local function _manipulate(manipulation)
    if Tetris.running == false then
        return false
    end

    result = true
    if manipulation == Tetris.manipulations.slam then
        EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "tick")

        while _checkMoves() and result do
            result = _execManipulation(Tetris.manipulations.down)
        end

        -- slam timeout to allow one more manipulation after slam
        EVENT_MANAGER:RegisterForUpdate(Tetris.name .. "slam", 250, _slam)

    elseif manipulation == Tetris.manipulations.down then
        result = _execManipulation(manipulation)

    elseif manipulation == Tetris.manipulations.left and maxManipulations.left > 0 then
        maxManipulations.left = maxManipulations.left - 1
        result = _execManipulation(manipulation)

    elseif manipulation == Tetris.manipulations.right and maxManipulations.right > 0 then
        maxManipulations.right = maxManipulations.right - 1
        result = _execManipulation(manipulation)

    elseif manipulation == Tetris.manipulations.rotate and maxManipulations.rotate > 0 then
        maxManipulations.rotate = maxManipulations.rotate - 1
        result = _execManipulation(manipulation)
    end

    _drawUI()

    return result
end


-- Remove lines that are completed
local function _removeLines()
    rm = 0

    --bottom up
    for j=height-1,0,-1 do
        line = 0
        for i=0,width-1 do
            --add up line
            if Tetris.array[i][j] ~= Tetris.blocks.none then
                line = line + 1
            end

            -- move line down rm steps
            for r=0,rm-1 do
                --line under j becomes line j+1
                Tetris.array[i][j+1+r] = Tetris.array[i][j+r]
                --line j is deleted
                Tetris.array[i][j+r] = Tetris.blocks.none
            end
        end

        if line == width then
            for i=0,width-1 do
                Tetris.array[i][j] = Tetris.blocks.none
            end
            rm = rm + 1
        end
    end
    _drawUI()
end


-- execute move on key or after timeout
function Tetris.tick()
    --unset timer
    EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "tick")

    if not _manipulate(Tetris.manipulations.down) then
        _removeLines()
        _createBlock()
    end

    --reset maxManipulations
    maxManipulations = { left = 5, right = 5, rotate = 4 }

    --set timer
    if Tetris.running == true then
        EVENT_MANAGER:RegisterForUpdate(Tetris.name .. "tick", Tetrisparams.timeout, Tetris.tick)
    end
end


--Keybinding Actions
function Tetris.keyLeft()
    if gameover == false and Tetris.running == true then
        _manipulate(Tetris.manipulations.left)
    end
end
function Tetris.keyRight()
    if gameover == false and Tetris.running == true then
        _manipulate(Tetris.manipulations.right)
    end
end
function Tetris.keyRotate()
    if gameover == false and Tetris.running == true then
        _manipulate(Tetris.manipulations.rotate)
    end
end
function Tetris.keySlam()
    if gameover == false and Tetris.running == true then
        _manipulate(Tetris.manipulations.slam)
    end
end


local blink = 1
local function _backgroundBlink()
    EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "reelinBlink")
    Tetris.UI.background:SetColor(blink, blink, blink, 1)
    blink = (blink + 1) % 2
    EVENT_MANAGER:RegisterForUpdate(Tetris.name .. "reelinBlink", 200, _backgroundBlink)
end


local tmpFishingState = 0
local tmpInteractableName = ""

local function _simpleEngine()
    local action, interactableName, _, _, additionalInfo = GetGameCameraInteractableActionInfo()
    logger:Warn("Tetris Toggle without engine: ", tmpFishingState)
    if additionalInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE and
       tmpFishingState == 0 then
        tmpFishingState = 1
        tmpInteractableName = interactableName
        HUD_SCENE:AddFragment(Tetris.fragment)
        LOOT_SCENE:AddFragment(Tetris.fragment)
        Tetris.running = true
        EVENT_MANAGER:RegisterForUpdate(Tetris.name .. "tick", Tetrisparams.timeout, Tetris.tick)
    elseif action and tmpInteractableName == interactableName then
        logger:Warn("Reelin")
    elseif additionalInfo ~= ADDITIONAL_INTERACT_INFO_FISHING_NODE and
           tmpFishingState == 1 then
        tmpFishingState = 0
        tmpInteractableName = ""
        EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "tick")
        Tetris.running = false
        HUD_SCENE:RemoveFragment(Tetris.fragment)
        LOOT_SCENE:RemoveFragment(Tetris.fragment)
    end
end

-- Toggle Tetris running state and visibility
function Tetris.toggle(fishingState)

    --simple engine if no Chalutier engine is available
    if not Tetris.engine then
        _simpleEngine()
        return
    end

    if fishingState == Tetris.engine.state.reelin then
        _backgroundBlink()
    else
        EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "reelinBlink")
        Tetris.UI.background:SetColor(0, 0, 0, 1)
    end

    -- Tetris.engine states that start Tetris
    if fishingState == Tetris.engine.state.looking or fishingState == Tetris.engine.state.fishing or fishingState == Tetris.engine.state.reelin then
        if Tetris.running == false then
            HUD_SCENE:AddFragment(Tetris.fragment)
            LOOT_SCENE:AddFragment(Tetris.fragment)
            Tetris.running = true
            EVENT_MANAGER:RegisterForUpdate(Tetris.name .. "tick", Tetrisparams.timeout, Tetris.tick)
        end

    -- Tetris.engine states that pause Tetris
    elseif fishingState == Tetris.engine.state.loot then
        if Tetris.running == true then
            EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "tick")
            Tetris.running = false
        end

    --All other Tetris.engine states stop and hide Tetris
    else
        if Tetris.running == true then
            EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "tick")
            Tetris.running = false
            HUD_SCENE:RemoveFragment(Tetris.fragment)
            LOOT_SCENE:RemoveFragment(Tetris.fragment)
        end
    end
end


-- Create UI elements and Fragment
local function _createUI()
    dimX = brdr + width*Tetrisparams.pixelsize + brdr
    dimY = brdr + height*Tetrisparams.pixelsize + brdr

    -- UI Toplevel
    Tetris.UI = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_TOPLEVELCONTROL)
    Tetris.UI:SetMouseEnabled(true)
    Tetris.UI:SetClampedToScreen(true)
    Tetris.UI:SetMovable(true)
    Tetris.UI:SetDimensions(dimX, dimY)
    Tetris.UI:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, Tetrisparams.posx, Tetrisparams.posy)
    Tetris.UI:SetDrawLevel(0)
    Tetris.UI:SetDrawLayer(DL_MAX_VALUE-1)
    Tetris.UI:SetDrawTier(DT_MAX_VALUE-1)


    EVENT_MANAGER:RegisterForUpdate(Tetris.name .. "savePos", 10000, function()
        Tetrisparams.posy = Tetris.UI:GetTop()
        Tetrisparams.posx = Tetris.UI:GetRight() - GuiRoot:GetRight()
    end)

    -- Black Background
    Tetris.UI.background = WINDOW_MANAGER:CreateControl(nil, Tetris.UI, CT_TEXTURE)
    Tetris.UI.background:SetDimensions(dimX, dimY)
    Tetris.UI.background:SetColor(0, 0, 0, 1)
    Tetris.UI.background:SetAnchor(TOPLEFT, Tetris.UI, TOPLEFT, 0, 0)
    Tetris.UI.background:SetHidden(false)
    Tetris.UI.background:SetDrawLevel(0)

    -- Setup Pixel matrix
    Tetris.UI.pixel = {}
    for i=0,width-1 do
        Tetris.UI.pixel[i] = {}
        Tetris.array[i] = {}
        for j=0,height-1 do
            Tetris.array[i][j] = 0
            Tetris.UI.pixel[i][j] = WINDOW_MANAGER:CreateControl(nil, Tetris.UI, CT_TEXTURE)
            Tetris.UI.pixel[i][j]:SetDimensions(Tetrisparams.pixelsize-2, Tetrisparams.pixelsize-2)
            Tetris.UI.pixel[i][j]:SetColor(1, 1, 1, 1)
            Tetris.UI.pixel[i][j]:SetAnchor(TOPLEFT, Tetris.UI.background, TOPLEFT, brdr+1+(i*Tetrisparams.pixelsize), brdr+1+(j*Tetrisparams.pixelsize))
            Tetris.UI.pixel[i][j]:SetHidden(false)
            Tetris.UI.pixel[i][j]:SetDrawLevel(0)
        end
    end

    -- Setup fragment for Scene management
    Tetris.fragment = ZO_FadeSceneFragment:New(Tetris.UI, 100, 500)
    Tetris.UI:SetHidden(true)
end


local function _createMenu()
    --#region addon menu
    --addon menu
    local LAM = LibAddonMenu2

    local pressedShow = false

    local panelName = Tetris.name .. "Settings"

    local panelData = {
        type = "panel",
        name = Tetris.name .. " Settings",
        author = Tetris.author,
    }
    local panel = LAM:RegisterAddonPanel(panelName, panelData)

    panel:SetHandler("OnEffectivelyHidden", function()
        Tetrisparams.posy = Tetris.UI:GetTop()
        Tetrisparams.posx = Tetris.UI:GetRight() - GuiRoot:GetRight()
        if pressedShow == true then
            HUD_UI_SCENE:RemoveFragment(Tetris.fragment)
            Tetris.UI:SetHidden(true)
        end
    end)

    local optionsData = {
        {
            type = "slider",
            name = "Pixel Size",
            min = 1,
            max = 30,
            default = Tetrisparams.pixelsize,
            getFunc = function() return Tetrisparams.pixelsize end,
            setFunc = function(value)
                Tetrisparams.pixelsize = value
            end,
            tooltip = "Set the size of each pixel of the Tetris field.",
            requiresReload = true
        },
        {
            type = "slider",
            name = "Timeout",
            min = 100,
            max = 2000,
            step = 100,
            default = Tetrisparams.timeout,
            getFunc = function() return Tetrisparams.timeout end,
            setFunc = function(value) Tetrisparams.timeout = value end,
            tooltip = "Set the wait time between each Block Down-move.",
        },
        {
            type = "divider",
            reference = "TetrisDevider"
        },
        {
            type = "description",
            text = "Show or hide Tetris field so you can choose a position:"
        },
        {
            type = "button",
            name = "Show",
            func = function()
                if pressedShow == false then
                    pressedShow = true
                    HUD_UI_SCENE:AddFragment(Tetris.fragment)
                    Tetris.UI:SetHidden(false)
                elseif pressedShow == true then
                    pressedShow = false
                    Tetrisparams.posy = Tetris.UI:GetTop()
                    Tetrisparams.posx = Tetris.UI:GetRight() - GuiRoot:GetRight()
                    HUD_UI_SCENE:RemoveFragment(Tetris.fragment)
                    Tetris.UI:SetHidden(true)
                end
            end,
            width = "half",
            requiresReload = false
        }
    }
    LAM:RegisterOptionControls(panelName, optionsData)

end


-- Main function
function Tetris.OnAddOnLoaded(event, addonName)
    if addonName == Tetris.name then
        -- init once and never come here again
        EVENT_MANAGER:UnregisterForEvent(Tetris.name, EVENT_ADD_ON_LOADED)

        -- save/load last game
        Tetrisparams = ZO_SavedVars:NewAccountWide("Tetrisparamsvar", 1, nil, Tetrisdefaults)

        -- strings for keybindings
        ZO_CreateStringId("SI_BINDING_NAME_TETRISLEFT", "Move Left")
        ZO_CreateStringId("SI_BINDING_NAME_TETRISRIGHT", "Move Right")
        ZO_CreateStringId("SI_BINDING_NAME_TETRISROTATE", "Rotate")
        ZO_CreateStringId("SI_BINDING_NAME_TETRISSLAM", "Slam")

        -- create UI
        _createUI()
        _createMenu()
        _createBlock()
        _drawUI()

        -- init state
        Tetris.running = false


        -- connect to Tetris.engine
        if Chalutier then
            Tetris.engine = Chalutier
            Tetris.statechange = "CHALUTIER_STATE_CHANGE"
        elseif FishyCha then
            Tetris.engine = FishyCha
            Tetris.statechange = "FishyCha_STATE_CHANGE"
        else
            Tetris.engine = nil
        end

        if Tetris.engine then
            logger:Warn("Engine: " .. Tetris.engine.name)
            Tetris.engine.CallbackManager:RegisterCallback(Tetris.engine.name .. Tetris.statechange, Tetris.toggle)
        else
            logger:Warn("Engine: " .. "None")
            ZO_PreHookHandler(RETICLE.interact, "OnEffectivelyShown", Tetris.toggle)
            ZO_PreHookHandler(RETICLE.interact, "OnHide", Tetris.toggle)
        end

    end
end

-- Hook into game load system
EVENT_MANAGER:RegisterForEvent(Tetris.name, EVENT_ADD_ON_LOADED, Tetris.OnAddOnLoaded)
