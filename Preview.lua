-- Preview Struct
TetrisPV = {
    name = "TetrisPV",
    array = {},
    Block = {},
    width = 4,
    height = 4,
    enabled = true
}

local logger = LibDebugLogger(TetrisPV.name)

-- Clear and set Block in Preview array
local function _setBlocktoArray()
    for i=0,TetrisPV.width-1 do
        for j=0,TetrisPV.height-1 do
            TetrisPV.array[i][j] = Tetris.blocks.none
        end
    end

    if TetrisPV.Block.typus ~= Tetris.blocks.i then
        y = 1
    else
        y = 0
    end

    TetrisPV.array[TetrisPV.Block.a.x - 3][TetrisPV.Block.a.y + y] = TetrisPV.Block.typus
    TetrisPV.array[TetrisPV.Block.b.x - 3][TetrisPV.Block.b.y + y] = TetrisPV.Block.typus
    TetrisPV.array[TetrisPV.Block.c.x - 3][TetrisPV.Block.c.y + y] = TetrisPV.Block.typus
    TetrisPV.array[TetrisPV.Block.d.x - 3][TetrisPV.Block.d.y + y] = TetrisPV.Block.typus
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
    if TetrisPV.enabled then
        TetrisPV.UI:SetHidden(false)
        HUD_SCENE:AddFragment(TetrisPV.fragment)
        LOOT_SCENE:AddFragment(TetrisPV.fragment)
    else
        TetrisPV:hide()
    end
end


function TetrisPV:hide()
    TetrisPV.UI:SetHidden(true)
    HUD_SCENE:RemoveFragment(TetrisPV.fragment)
    LOOT_SCENE:RemoveFragment(TetrisPV.fragment)
end


-- Create UI for Preview
function TetrisPV:createUI(params)

    TetrisPV.enabled = params.preview

    dimXPV = Tetris.brdr + TetrisPV.width*params.pixelsize + Tetris.brdr
    dimYPV = Tetris.brdr + TetrisPV.height*params.pixelsize + Tetris.brdr
    dimX,dimY = Tetris.UI.background:GetDimensions()

    -- PV Toplevel
    TetrisPV.UI = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_TOPLEVELCONTROL)
    TetrisPV.UI:SetMouseEnabled(true)
    TetrisPV.UI:SetClampedToScreen(true)
    TetrisPV.UI:SetMovable(true)
    TetrisPV.UI:SetDimensions(dimXPV, dimYPV)
    TetrisPV.UI:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, params.posx - ((dimX - dimXPV)/2), params.posy - dimYPV)
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
    for i=0,TetrisPV.width-1 do
        TetrisPV.UI.pixel[i] = {}
        TetrisPV.array[i] = {}
        for j=0,TetrisPV.height-1 do
            TetrisPV.UI.pixel[i][j] = WINDOW_MANAGER:CreateControl(nil, TetrisPV.UI, CT_TEXTURE)
            TetrisPV.UI.pixel[i][j]:SetDimensions(params.pixelsize-2, params.pixelsize-2)
            TetrisPV.UI.pixel[i][j]:SetColor(1, 1, 1, 1)
            TetrisPV.UI.pixel[i][j]:SetAnchor(TOPLEFT, TetrisPV.UI.background, TOPLEFT, Tetris.brdr+1+(i*params.pixelsize), Tetris.brdr+1+(j*params.pixelsize))
            TetrisPV.UI.pixel[i][j]:SetHidden(false)
            TetrisPV.UI.pixel[i][j]:SetDrawLevel(1)
        end
    end
    
    TetrisPV.fragment = ZO_FadeSceneFragment:New(TetrisPV.UI, 100, 200)
    TetrisPV.UI:SetHidden(true)

    TetrisPV.fragment:RegisterCallback("StateChange", function()
        TetrisPV.UI:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, params.posx - ((dimX - dimXPV)/2), params.posy - dimYPV)
    end)
end