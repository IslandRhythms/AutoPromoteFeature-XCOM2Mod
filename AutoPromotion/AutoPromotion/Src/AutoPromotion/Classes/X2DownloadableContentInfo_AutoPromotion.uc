//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_AutoPromotion.uc                                    
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_AutoPromotion extends X2DownloadableContentInfo;

var config(Game) bool bEnableLogging;
`include(AutoPromotion/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)

static event OnLoadedSavedGame(){}
static event InstallNewCampaign(XComGameState StartState){}

static event onPostMission()
{
	local StateObjectReference UnitRef;
	local XComGameState_Unit Unit;
	local XComGameStateContext_ChangeContainer Container;
	local XComGameState UpdateState;
	local XComGameState_HeadquartersXCom XCOMHQ;
	local XComGameStateHistory History;
	local int i;

	`LOG("=================================", default.bEnableLogging, 'Beat_AutoPromote');
	`LOG("onPostMission in Promotion Screen Mod", default.bEnableLogging, 'Beat_AutoPromote');

	History = `XCOMHISTORY;
	XCOMHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	Container = class 'XComGameStateContext_ChangeContainer'.static.CreateEmptyChangeContainer("Soldier Auto-Promotion");
	UpdateState = History.CreateNewGameState(true, Container);

	`LOG("ObjectIDs of the deployed squad returning from mission", default.bEnableLogging, 'Beat_AutoPromote');

	foreach `XCOMHQ.Squad(UnitRef)
	{
		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitRef.ObjectID));
		`LOG(Unit.GetFullName() @"ID [" @UnitRef.ObjectID @"]", default.bEnableLogging, 'Beat_AutoPromote');
	}

	`LOG("Checking values that could be used to determine eligibility promotion", default.bEnableLogging, 'Beat_AutoPromote');
	`LOG("ObjectIDs of the entire roster", default.bEnableLogging, 'Beat_AutoPromote');
	if (`GETMCMVAR(ONLYSQUADDIES)) {
	for (i = 0; i < XCOMHQ.Crew.Length; i++)
		{
			// Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(XCOMHQ.Crew[i].ObjectID));
			Unit = XComGameState_Unit(UpdateState.ModifyStateObject(class 'XComGameState_Unit', XCOMHQ.Crew[i].ObjectID));
		
			`LOG(Unit.GetFullName() @"ID [" @XCOMHQ.Crew[i].ObjectID @"]", default.bEnableLogging, 'Beat_AutoPromote');
		
			if (Unit.IsAlive() && Unit.IsSoldier() && Unit.CanRankUpSoldier() && Unit.GetSoldierRank() == 0)
			{
				// if they have no abilities marked, default to the config files.
				`LOG("This Unit is eligible to Promote, start process", default.bEnableLogging, 'Beat_AutoPromote');
			
				class'AutoPromote'.static.autoPromote(Unit, UpdateState);
			}
		}
	} else {
		for (i = 0; i < XCOMHQ.Crew.Length; i++)
		{
			// Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(XCOMHQ.Crew[i].ObjectID));
			Unit = XComGameState_Unit(UpdateState.ModifyStateObject(class 'XComGameState_Unit', XCOMHQ.Crew[i].ObjectID));
		
			`LOG(Unit.GetFullName() @"ID [" @XCOMHQ.Crew[i].ObjectID @"]", default.bEnableLogging, 'Beat_AutoPromote');
		
			if (Unit.IsAlive() && Unit.IsSoldier() && Unit.CanRankUpSoldier())
			{
				// if they have no abilities marked, default to the config files.
				`LOG("This Unit is eligible to Promote, start process", default.bEnableLogging, 'Beat_AutoPromote');
			
				class'AutoPromote'.static.autoPromote(Unit, UpdateState);
			}
		}
	}

	`GAMERULES.SubmitGameState(UpdateState);
}
