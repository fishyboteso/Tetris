TetrisCha =
{
    name            = "TetrisCha",
    currentState    = 0,
    angle           = 0,
    swimming        = false,
    state           = {}
}
TetrisCha.state     = {
    idle      =  0, --Running around, neither looking at an interactable nor fighting
    lookaway  =  1, --Looking at an interactable which is NOT a fishing hole
    looking   =  2, --Looking at a fishing hole
    depleted  =  3, --fishing hole just depleted
    nobait    =  5, --Looking at a fishing hole, with NO bait equipped
    fishing   =  6, --Fishing
    reelin    =  7, --Reel in!
    loot      =  8, --Lootscreen open, only right after Reel in!
    invfull   =  9, --No free inventory slots
    fight     = 14, --Fighting / Enemys taunted
    dead      = 15  --Dead
}

local function _changeState(state, overwrite)
    if TetrisCha.currentState == state then return end

    if TetrisCha.currentState == TetrisCha.state.fight and not overwrite then return end

    if TetrisCha.swimming and state == TetrisCha.state.looking then state = TetrisCha.state.lookaway end

    EVENT_MANAGER:UnregisterForUpdate(TetrisCha.name .. "STATE_REELIN_END")
    EVENT_MANAGER:UnregisterForUpdate(TetrisCha.name .. "STATE_DEPLETED_END")
    EVENT_MANAGER:UnregisterForEvent(TetrisCha.name .. "OnSlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)

    if state == TetrisCha.state.depleted then
        EVENT_MANAGER:RegisterForUpdate(TetrisCha.name .. "STATE_DEPLETED_END", 3000, function()
            if TetrisCha.currentState == TetrisCha.state.depleted then _changeState(TetrisCha.state.idle) end
        end)

    elseif state == TetrisCha.state.fishing then
        TetrisCha.angle = (math.deg(GetPlayerCameraHeading())-180) % 360

        if not GetSetting_Bool(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT) then -- false = auto_loot off
            LOOT_SCENE:RegisterCallback("StateChange", _LootSceneCB)
        end
        EVENT_MANAGER:RegisterForEvent(TetrisCha.name .. "OnSlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function()
            if TetrisCha.currentState == TetrisCha.state.fishing then _changeState(TetrisCha.state.reelin) end
        end)

    elseif state == TetrisCha.state.reelin then
        EVENT_MANAGER:RegisterForUpdate(TetrisCha.name .. "STATE_REELIN_END", 3000, function()
            if TetrisCha.currentState == TetrisCha.state.reelin then _changeState(TetrisCha.state.idle) end
        end)
    end

    TetrisCha.currentState = state
    TetrisCha.CallbackManager:FireCallbacks(TetrisCha.name .. "TetrisCha_STATE_CHANGE", TetrisCha.currentState)
end

local function _lootRelease()
    local action, _, _, _, additionalInfo = GetGameCameraInteractableActionInfo()
    local angleDiv = ((math.deg(GetPlayerCameraHeading())-180) % 360) - TetrisCha.angle

    if action and additionalInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE then
        _changeState(TetrisCha.state.looking)
    elseif action then
        _changeState(TetrisCha.state.lookaway)
    elseif -30 < angleDiv and angleDiv < 30 then
        _changeState(TetrisCha.state.depleted)
    else
        _changeState(TetrisCha.state.idle)
    end
end

local function _lootRelease()
    local action, _, _, _, additionalInfo = GetGameCameraInteractableActionInfo()
    local angleDiv = ((math.deg(GetPlayerCameraHeading())-180) % 360) - TetrisCha.angle

    if action and additionalInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE then
        _changeState(TetrisCha.state.looking)
    elseif action then
        _changeState(TetrisCha.state.lookaway)
    elseif -30 < angleDiv and angleDiv < 30 then
        _changeState(TetrisCha.state.depleted)
    else
        _changeState(TetrisCha.state.idle)
    end
end

function _LootSceneCB(oldState, newState)
    if newState == SCENE_HIDDEN then -- IDLE
        _lootRelease()
        LOOT_SCENE:UnregisterCallback("StateChange", _LootSceneCB)
    elseif TetrisCha.currentState ~= TetrisCha.state.reelin and TetrisCha.currentState ~= TetrisCha.state.loot then -- fishing interrupted
        LOOT_SCENE:UnregisterCallback("StateChange", _LootSceneCB)
    elseif newState == SCENE_SHOWN then -- LOOT, INVFULL
        if (GetBagUseableSize(BAG_BACKPACK) - GetNumBagUsedSlots(BAG_BACKPACK)) <= 0 then
            _changeState(TetrisCha.state.invfull)
        else
            _changeState(TetrisCha.state.loot)
        end
    end
end

local tmpInteractableName = ""
local tmpNotMoving = true
function TetrisCha_OnAction()
    local action, interactableName, _, _, additionalInfo = GetGameCameraInteractableActionInfo()

    if action and (TetrisCha.currentState == TetrisCha.state.fishing or TetrisCha.currentState == TetrisCha.state.reeling) and INTERACTION_FISH ~= GetInteractionType() then -- fishing interrupted
        _changeState(TetrisCha.state.idle)

    elseif action and IsPlayerTryingToMove() and TetrisCha.currentState < TetrisCha.state.fishing then
        _changeState(TetrisCha.state.lookaway)
        tmpInteractableName = ""
        tmpNotMoving = false
        EVENT_MANAGER:RegisterForUpdate(TetrisCha.name .. "MOVING", 400, function()
            if not IsPlayerTryingToMove() then
                EVENT_MANAGER:UnregisterForUpdate(TetrisCha.name .. "MOVING")
                tmpNotMoving = true
            end
        end)

    elseif action and additionalInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE then -- NOBAIT, LOOKING
        if not GetFishingLure() then
            _changeState(TetrisCha.state.nobait)
        elseif TetrisCha.currentState < TetrisCha.state.fishing and tmpNotMoving then
            _changeState(TetrisCha.state.looking)
            tmpInteractableName = interactableName
        end

    elseif action and tmpInteractableName == interactableName and INTERACTION_FISH == GetInteractionType() then -- FISHING, REELIN+
        if TetrisCha.currentState > TetrisCha.state.fishing then return end
        _changeState(TetrisCha.state.fishing)

    elseif action then -- LOOKAWAY
        _changeState(TetrisCha.state.lookaway)
        tmpInteractableName = ""

    elseif TetrisCha.currentState == TetrisCha.state.reelin and GetSetting_Bool(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT) then --DEPLETED
        _lootRelease()

    elseif TetrisCha.currentState ~= TetrisCha.state.depleted then -- IDLE
        _changeState(TetrisCha.state.idle)
        tmpInteractableName = ""
    end
end

function TetrisChaInit()

    TetrisCha.CallbackManager = ZO_CallbackObject:New()

    ZO_PreHookHandler(RETICLE.interact, "OnEffectivelyShown", TetrisCha_OnAction)
    ZO_PreHookHandler(RETICLE.interact, "OnHide", TetrisCha_OnAction)

    EVENT_MANAGER:RegisterForEvent(TetrisCha.name, EVENT_PLAYER_SWIMMING, function(eventCode) TetrisCha.swimming = true end)
    EVENT_MANAGER:RegisterForEvent(TetrisCha.name, EVENT_PLAYER_NOT_SWIMMING, function(eventCode) TetrisCha.swimming = false end)
    EVENT_MANAGER:RegisterForEvent(TetrisCha.name, EVENT_PLAYER_DEAD, function(eventCode) _changeState(TetrisCha.state.dead, true) end)
    EVENT_MANAGER:RegisterForEvent(TetrisCha.name, EVENT_PLAYER_ALIVE, function(eventCode) _changeState(TetrisCha.state.idle) end)
    EVENT_MANAGER:RegisterForEvent(TetrisCha.name, EVENT_PLAYER_COMBAT_STATE, function(eventCode, inCombat)
        if inCombat then
            _changeState(TetrisCha.state.fight)
        elseif TetrisCha.currentState == TetrisCha.state.fight then
            _changeState(TetrisCha.state.idle, true)
        end
    end)

    _changeState(TetrisCha.state.idle)
end
