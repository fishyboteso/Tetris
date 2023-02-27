-- Preview Struct
TetrisPV = {
    name = "TetrisPV",
    array = {},
    Block = {},
    width = 2,
    height = 4
}

--TODO copy paste
local Tetrisdefaults = {
    pixelsize    = 16,
    timeout      = 500,
    posx         = 0,
    posy         = 0,
    blink        = true,
    lookingPause = false,
    bscore = 0,
    lscore = 0,
    showStats = true
}
--Struct for Block types
TetrisPV.blocks = {
    none = 0,
    j = 1,
    l = 2,
    t = 3,
    i = 4,
    z = 5,
    s = 6,
    o = 7
}
--TODO copy paste

-- Constants
local brdr = 8
local width = 2
local height = 4


--local logger = LibDebugLogger(TetrisPV.name)


-- Clear and set Block in Preview array
local function _setBlocktoArray()
    for i=0,width-1 do
        for j=0,height-1 do
            TetrisPV.array[i][j] = TetrisPV.blocks.none
        end
    end

    if TetrisPV.Block.typus ~= TetrisPV.blocks.i then
        y = 1
    else
        y = 0
    end

    TetrisPV.array[TetrisPV.Block.a.x - 4][TetrisPV.Block.a.y + y] = TetrisPV.Block.typus
    TetrisPV.array[TetrisPV.Block.b.x - 4][TetrisPV.Block.b.y + y] = TetrisPV.Block.typus
    TetrisPV.array[TetrisPV.Block.c.x - 4][TetrisPV.Block.c.y + y] = TetrisPV.Block.typus
    TetrisPV.array[TetrisPV.Block.d.x - 4][TetrisPV.Block.d.y + y] = TetrisPV.Block.typus
end


-- Return the new typus and generate the next
function TetrisPV:getNextTypus()
    typus = TetrisPV.nextTypus
    math.randomseed(GetGameTimeMilliseconds())
    TetrisPV.nextTypus = math.random(Tetris.blocks.j, Tetris.blocks.o)
    TetrisPV.Block = TetrisMoves.start(TetrisPV.nextTypus)
    _setBlocktoArray()
    return typus
end


function TetrisPV:show()
    TetrisPV.UI:SetHidden(false)
    HUD_SCENE:AddFragment(TetrisPV.fragment)
    LOOT_SCENE:AddFragment(TetrisPV.fragment)
end


function TetrisPV:hide()
    TetrisPV.UI:SetHidden(true)
    HUD_SCENE:RemoveFragment(TetrisPV.fragment)
    LOOT_SCENE:RemoveFragment(TetrisPV.fragment)
end


-- Create UI for Preview
function TetrisPV:createUI()
    Tetrisparams = ZO_SavedVars:NewAccountWide("Tetrisparamsvar", 1, nil, Tetrisdefaults)

    dimXPV = brdr + width*Tetrisparams.pixelsize + brdr
    dimYPV = brdr + height*Tetrisparams.pixelsize + brdr

    -- PV Toplevel
    TetrisPV.UI = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_TOPLEVELCONTROL)
    TetrisPV.UI:SetMouseEnabled(true)
    TetrisPV.UI:SetClampedToScreen(true)
    TetrisPV.UI:SetMovable(true)
    TetrisPV.UI:SetDimensions(dimXPV, dimYPV)
    TetrisPV.UI:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, Tetrisparams.posx, Tetrisparams.posy - dimYPV)
    TetrisPV.UI:SetDrawLevel(0)
    TetrisPV.UI:SetDrawLayer(DL_MAX_VALUE-1)
    TetrisPV.UI:SetDrawTier(DT_MAX_VALUE-1)

    -- Black Background
    TetrisPV.UI.background = WINDOW_MANAGER:CreateControl(nil, TetrisPV.UI, CT_TEXTURE)
    TetrisPV.UI.background:SetDimensions(dimXPV, dimYPV)
    TetrisPV.UI.background:SetColor(0, 0, 0, 1)
    TetrisPV.UI.background:SetAnchor(TOPLEFT, TetrisPV.UI, TOPLEFT, 0, 0)
    TetrisPV.UI.background:SetHidden(false)
    TetrisPV.UI.background:SetDrawLevel(0)

    -- Setup Preview matrix
    TetrisPV.UI.pixel = {}
    for i=0,width-1 do
        TetrisPV.UI.pixel[i] = {}
        TetrisPV.array[i] = {}
        for j=0,height-1 do
            --if Tetrisparams.PV.array then TetrisPV.array[i][j] = Tetrisparams.PV.array[i][j] else TetrisPV.array[i][j] = 0 end
            TetrisPV.UI.pixel[i][j] = WINDOW_MANAGER:CreateControl(nil, TetrisPV.UI, CT_TEXTURE)
            TetrisPV.UI.pixel[i][j]:SetDimensions(Tetrisparams.pixelsize-2, Tetrisparams.pixelsize-2)
            TetrisPV.UI.pixel[i][j]:SetColor(1, 1, 1, 1)
            TetrisPV.UI.pixel[i][j]:SetAnchor(TOPLEFT, TetrisPV.UI.background, TOPLEFT, brdr+1+(i*Tetrisparams.pixelsize), brdr+1+(j*Tetrisparams.pixelsize))
            TetrisPV.UI.pixel[i][j]:SetHidden(false)
            TetrisPV.UI.pixel[i][j]:SetDrawLevel(1)
        end
    end
    
    TetrisPV.fragment = ZO_FadeSceneFragment:New(TetrisPV.UI, 100, 200)
    TetrisPV.UI:SetHidden(true)
end