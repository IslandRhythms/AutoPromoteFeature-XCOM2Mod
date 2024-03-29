class X2EventListener_Template extends X2EventListener ;


`include(AutoPromotion/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)
//add the listener
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(AutoPromote_CreateListener_CovertActionCompleted());

	return Templates;
}

//create the listener
static function X2EventListenerTemplate AutoPromote_CreateListener_CovertActionCompleted()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'AutoPromote_CovertActionCompleted');

	Template.RegisterInTactical = false;	//listen during missions
	Template.RegisterInStrategy = true;		//listen during avenger

	//set to listen for event, do a thing, at this time
	Template.AddCHEvent('CovertActionCompleted', CheckForAvailablePromotions, ELD_OnStateSubmitted);

	return Template;
}

//what does the listener do when it hears a call?
static function EventListenerReturn CheckForAvailablePromotions(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
    local XComGameState_CovertAction CovAct;
	local XComGameState_StaffSlot SlotState;
	local int i;
	local XComGameState_Unit Unit;
	local XComGameState UpdateState;
	local XComGameStateContext_ChangeContainer Container;
	local XComGameStateHistory History;
	local bool bEnableLogging;

    CovAct = XComGameState_CovertAction(EventSource);
	`LOG("Value of ini value IGNORECA. This value is flipped with !"$`GETMCMVAR(IGNORECA), bEnableLogging, 'Beat_AutoPromote');
    if (CovAct != none)
    {
		`LOG("======================", bEnableLogging, 'Beat_AutoPromote');
		`LOG("Inside the event listener", bEnableLogging, 'Beat_AutoPromote');
		History = `XCOMHISTORY;
		Container = class 'XComGameStateContext_ChangeContainer'.static.CreateEmptyChangeContainer("Soldier Auto-Promotion");
		UpdateState = History.CreateNewGameState(true, Container);
		bEnableLogging = `GETMCMVAR(ENABLELOGGING);
        //do stuff
		for (i = 0; i < CovAct.StaffSlots.Length; i++)
		{
			SlotState = CovAct.GetStaffSlot(i);
			Unit = SlotState.GetAssignedStaff();
			if(`GETMCMVAR(IGNORECA)) {
				Unit.bNeedsNewClassPopup = `GETMCMVAR(SHOWPROMOTIONPOPUP);
				continue;
			}
			if (Unit.IsAlive() && Unit.IsSoldier() && Unit.CanRankUpSoldier())
			{
					if (`GETMCMVAR(ONLYSQUADDIES) && `GETMCMVAR(ONLYVETS)) {
						// if they have no abilities marked, default to the config files.
						`LOG("This Unit is eligible to Promote, start process", bEnableLogging, 'Beat_AutoPromote');
			
						class'AutoPromote'.static.autoPromote(Unit, UpdateState);
					} else if (`GETMCMVAR(ONLYSQUADDIES) && Unit.GetSoldierRank() == 0) {
						`LOG("ONLYSQUADDIES is enabled and this unit is a rookie, start process.", bEnableLogging, 'Beat_AutoPromote');
			
						class'AutoPromote'.static.autoPromote(Unit, UpdateState);
					} else if (`GETMCMVAR(ONLYVETS) && Unit.GetSoldierRank() != 0) {
							`LOG("ONLYVETS is enabled and the unit is not a rookie, start process", bEnableLogging, 'Beat_AutoPromote');
			
							class'AutoPromote'.static.autoPromote(Unit, UpdateState);
					} else {
							`LOG("ONLYVETS and ONLYSQUADDIES is disabled so business as usual, start process", bEnableLogging, 'Beat_AutoPromote');
			
							class'AutoPromote'.static.autoPromote(Unit, UpdateState);
					}
			}
		}
		`GAMERULES.SubmitGameState(UpdateState);	
    }

	return ELR_NoInterrupt;
}