Tetris = {
    name = "Tetris",
    author = "Sem",
    manipulations = {},
    array = {},
    blocks = {},
    Block = {}
}
Tetris.manipulations = {
    nothing = 0,
    left = 1,
    right = 2,
    rotate = 3,
    slam = 4,
    down = 5
}
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

--local Tetrisparams = {}
--local Tetrisdefaults = {}
local _tick

local logger = LibDebugLogger(Tetris.name)

-- maximum manipulations per tick
local maxManipulations = { left = 5, right = 5, rotate = 4 }

local pixelsize = 16
local brdr = 8
local width = 10
local height = 20
local timeout = 500



--http://lua-users.org/wiki/CopyTable
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


local function _setBlockToArray(typus)
    Tetris.array[Tetris.Block.a.x][Tetris.Block.a.y] = typus
    Tetris.array[Tetris.Block.b.x][Tetris.Block.b.y] = typus
    Tetris.array[Tetris.Block.c.x][Tetris.Block.c.y] = typus
    Tetris.array[Tetris.Block.d.x][Tetris.Block.d.y] = typus
end


-- executes Manipulation on pixel array if possible
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


-- drawUI
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
        end
    end
end


--returns TRUE if any more TetrisMoves are possible for Block
--else FALSE
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


local function _createBlock()
    typus = math.random(Tetris.blocks.j, Tetris.blocks.o)
    Tetris.Block = TetrisMoves.start(typus)

    if not _checkMoves() then
        EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "tick")
        for i=0,width-1 do
            for j=0,height-1 do
                Tetris.array[i][j] = Tetris.blocks.none
            end
        end
        EVENT_MANAGER:RegisterForUpdate(Tetris.name .. "tick", timeout, Tetris.tick)
    else
        _setBlockToArray(typus)
    end

    _drawUI()
end


local function _manipulate(manipulation)
    result = true
    -- rule: allow only max Manipulations
    if manipulation == Tetris.manipulations.slam then

        while _checkMoves() and result do
            EVENT_MANAGER:UnregisterForUpdate(Tetris.name .. "tick")
            result = _execManipulation(Tetris.manipulations.down)
        end

        Tetris.tick()
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
    EVENT_MANAGER:RegisterForUpdate(Tetris.name .. "tick", timeout, Tetris.tick)
end



--Keybinding Actions
function Tetris.keyLeft()
    _manipulate(Tetris.manipulations.left)
end
function Tetris.keyRight()
    _manipulate(Tetris.manipulations.right)
end
function Tetris.keyRotate()
    _manipulate(Tetris.manipulations.rotate)
end
function Tetris.keySlam()
    _manipulate(Tetris.manipulations.slam)
end


local function _createUI()
    dimX = brdr + width*pixelsize + brdr
    dimY = brdr + height*pixelsize + brdr

    Tetris.UI = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_TOPLEVELCONTROL)
    Tetris.UI:SetMouseEnabled(true)
    Tetris.UI:SetClampedToScreen(true)
    Tetris.UI:SetMovable(true)
    Tetris.UI:SetDimensions(dimX, dimY)
    Tetris.UI:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, 300, 100)
    Tetris.UI:SetDrawLevel(0)
    Tetris.UI:SetDrawLayer(DL_MAX_VALUE-1)
    Tetris.UI:SetDrawTier(DT_MAX_VALUE-1)

    Tetris.UI.background = WINDOW_MANAGER:CreateControl(nil, Tetris.UI, CT_TEXTURE)
    Tetris.UI.background:SetDimensions(dimX, dimY)
    Tetris.UI.background:SetColor(0, 0, 0, 1)
    Tetris.UI.background:SetAnchor(TOPLEFT, Tetris.UI, TOPLEFT, 0, 0)
    Tetris.UI.background:SetHidden(false)
    Tetris.UI.background:SetDrawLevel(0)

    Tetris.UI.pixel = {}

    for i=0,width-1 do
        Tetris.UI.pixel[i] = {}
        Tetris.array[i] = {}
        for j=0,height-1 do
            Tetris.array[i][j] = 0
            Tetris.UI.pixel[i][j] = WINDOW_MANAGER:CreateControl(nil, Tetris.UI, CT_TEXTURE)
            Tetris.UI.pixel[i][j]:SetDimensions(pixelsize-2, pixelsize-2)
            Tetris.UI.pixel[i][j]:SetColor(1, 1, 1, 1)
            Tetris.UI.pixel[i][j]:SetAnchor(TOPLEFT, Tetris.UI.background, TOPLEFT, brdr+1+(i*pixelsize), brdr+1+(j*pixelsize))
            Tetris.UI.pixel[i][j]:SetHidden(false)
            Tetris.UI.pixel[i][j]:SetDrawLevel(0)
        end
    end
end


function Tetris.OnAddOnLoaded(event, addonName)
    if addonName == Tetris.name then
        -- init once and never come here again
        EVENT_MANAGER:UnregisterForEvent(Tetris.name, EVENT_ADD_ON_LOADED)

        -- save/load last game
        --Tetrisparams = ZO_SavedVars:NewAccountWide("FishyQRparamsvar", 2, nil, Tetrisdefaults)

        ZO_CreateStringId("SI_BINDING_NAME_TETRISLEFT", "Move Left")
        ZO_CreateStringId("SI_BINDING_NAME_TETRISRIGHT", "Move Right")
        ZO_CreateStringId("SI_BINDING_NAME_TETRISROTATE", "Rotate")
        ZO_CreateStringId("SI_BINDING_NAME_TETRISSLAM", "Slam")


        _createUI()
        _createBlock()
        _drawUI()

        EVENT_MANAGER:RegisterForUpdate(Tetris.name .. "tick", timeout, Tetris.tick)
    end
end

EVENT_MANAGER:RegisterForEvent(Tetris.name, EVENT_ADD_ON_LOADED, Tetris.OnAddOnLoaded)
