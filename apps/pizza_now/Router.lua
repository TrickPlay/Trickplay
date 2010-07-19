Router = class(function(router)
end)

function Router:route(currentState)
    if(not stateMachine) then
        stateMachine = StateMachine()
        stateMachine[states.init]()

    --Main routing
    elseif(not stateVariables.TRICKPLAY) then
        stateMachine[states.enterAddress]()
    elseif(not stateVariables.PROVIDER) then
        stateMachine[states.selectProvider]()
    elseif(not stateVariables.MENU_DATA) then
        stateMachine[states.collectMenuData]()
    elseif(not stateVariables.DISPLAY_MENU) then
        stateMachine[states.displayMenu]()
    elseif(stateVariables.DONE) then
        stateMachine[states.checkout]()
    elseif(stateVariables.CHECKOUT) then
        stateMachine[states.showDelivery] then

    --Customize particular items    
    elseif not stateVariables.ITEM then
        stateMachine[states.pickItem]()
    elseif not stateVariables.CUSTOM then
        stateMachine[states.customizeItem]()
    else
        stateMachine[states.addItem]()
    end
end
