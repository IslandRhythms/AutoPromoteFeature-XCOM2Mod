// This is an Unreal Script

class AutoPromote extends X2DownloadableContentInfo config(GameData);

var config(AutoPromotion_DEFAULT) int VERSION_CFG;

struct AutoPromote_SoldierTypes
{
	var name soldierClass;
	var string soldierName;
	var int squaddie;
	var int corporal;
	var int sergeant;
	var int lieutenant;
	var int captain;
	var int major;
	var int colonel;
	var int brigadier;
};

var config array<AutoPromote_SoldierTypes> AutoPromotePresets;

`include(AutoPromotion/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)


static function autoPromote(XComGameState_Unit Unit, XComGameState UpdateState)
{
	local name soldierType;
	local string soldierFullName;
	local int Index, iRank, iBranch;
	local bool bIsLogged, bUseClassIfNoMatchedName, bShowRankedUpPopups, bOnlySquaddies;
	local XComGameState_HeadquartersXCom XHQ;
	
	soldierType = Unit.GetSoldierClassTemplateName();
	soldierFullName = Unit.GetFullName();

	iRank = Unit.GetSoldierRank();
	Index = default.AutoPromotePresets.find('soldierName', soldierFullName );

	bIsLogged = `GETMCMVAR(ENABLELOGGING);
	bUseClassIfNoMatchedName = `GETMCMVAR(USENAME);
	bShowRankedUpPopups = `GETMCMVAR(SHOWPROMOTIONPOPUP);
	bOnlySquaddies = `GETMCMVAR(ONLYSQUADDIES);
	`LOG("what is bIsLogged"@bIsLogged, bIsLogged, 'Beat_AutoPromote');
	`LOG("what is bUseClassIfNoMatchedName"@bUseClassIfNoMatchedName, bIsLogged, 'Beat_AutoPromote');
	`LOG("what is bShowRankedUpPopups"@bShowRankedUpPopups, bIsLogged, 'Beat_AutoPromote');
	`Log("what is bOnlySquaddies"@bOnlySquaddies, bIsLogged, 'Beat_AutoPromote');

	//not a named unit, so go by class
	if (Index == INDEX_NONE && bUseClassIfNoMatchedName)
	{
		Index = default.AutoPromotePresets.find('soldierClass', soldierType);
	}
	else
	{
		`LOG("No Named match for unit [" @soldierFullName @"], AND Use Class auto-match turned off", bIsLogged, 'Beat_AutoPromote');
		`LOG("SKIPPED AUTO-PROMOTION", bIsLogged, 'Beat_AutoPromote');
		return;
	}

	// The soldier's class/name has a preset, continue on to autopromote it

	//INDEX_NONE == -1 , these are the same so removed the &&
	if (Index != INDEX_NONE )
	{
		switch(iRank) 
		{
			case 1: iBranch = default.AutoPromotePresets[Index].corporal;		break;
			case 2:	iBranch = default.AutoPromotePresets[Index].sergeant;		break;
			case 3:	iBranch = default.AutoPromotePresets[Index].lieutenant;		break;
			case 4:	iBranch = default.AutoPromotePresets[Index].captain;		break;
			case 5:	iBranch = default.AutoPromotePresets[Index].major;			break;
			case 6:	iBranch = default.AutoPromotePresets[Index].colonel;		break;
			case 7: iBranch = default.AutoPromotePresets[Index].brigadier;		break;	//adding LWotC compatibility
			
			default:
				//this is essentially iRank 0, but also covers any typo in the config
				iBranch = default.AutoPromotePresets[Index].squaddie;
				break;
		}
		if (!`GETMCMVAR(RANKNOBUY)) {
			Unit.BuySoldierProgressionAbility(UpdateState, iRank, iBranch);
		}
		Unit.RankUpSoldier(UpdateState);
		Unit.bRankedUp = false;									// this needs to be set false after a rankupsoldier so the NEXT CanRankUpSoldier can be valid!
		Unit.bNeedsNewClassPopup = bShowRankedUpPopups;	// makes the rank/class pop-up NOT come up and spam

		//`GAMERULES.SubmitGameState(UpdateState); 				// -NO! submit gamestates at the code you create them in, it's just easier to follow
	} 
	else if (soldierType == 'Rookie')
	{
		Unit.RankUpSoldier(UpdateState);
		XHQ = XComGameState_HeadquartersXCom(UpdateState.ModifyStateObject(class 'XComGameState_HeadquartersXCom', `XCOMHQ.ObjectID));
		Unit.ApplySquaddieLoadout(UpdateState, XHQ);				// solider was promoted to squaddie, but kept rookie loadlout. Must fix with this.
		Unit.bRankedUp = false;									// this needs to be set false after a rankupsoldier so the NEXT CanRankUpSoldier can be valid!
		Unit.bNeedsNewClassPopup = bShowRankedUpPopups;	// makes the rank/class pop-up NOT come up and spam

		//`GAMERULES.SubmitGameState(UpdateState);
	}
	else
	{
		// if it doesn't have a preset, not our problem. -- but we CAN log the details of the class
		`LOG("If you have a custom soliderType, THIS is what you want to write into the game data ini file", bIsLogged, 'Beat_AutoPromote');
		`LOG("soliderType [" @soldierType @"] did not have any presets", bIsLogged, 'Beat_AutoPromote');
	}

	//call events for promotion etc
	`XEVENTMGR.TriggerEvent('PromotionEvent', Unit, Unit, UpdateState);

	//LOG OUR AUTO-PROMOTE
	`LOG("Soldier Name [" @soldierFullName @"]", bIsLogged, 'Beat_AutoPromote');
	`LOG("soldierType [" @soldierType @"] iRank [" @iRank @"] iBranch [" @iBranch @"] Index [" @Index @"]", bIsLogged, 'Beat_AutoPromote');
	`LOG("COMPLETED AUTO-PROMOTION", bIsLogged, 'Beat_AutoPromote');

}

static function autoPromoteConsoleCommand(XComGameState_Unit Unit, XComGameState UpdateState) {
	local name soldierType;
	local string soldierFullName;
	local int Index, iRank, iBranch, i;
	local bool bIsLogged, bUseClassIfNoMatchedName, bShowRankedUpPopups, bOnlySquaddies;
	local XComGameState_HeadquartersXCom XHQ;
	
	soldierType = Unit.GetSoldierClassTemplateName();
	soldierFullName = Unit.GetFullName();

	iRank = Unit.GetSoldierRank();
	Index = default.AutoPromotePresets.find('soldierName', soldierFullName );

	bIsLogged = `GETMCMVAR(ENABLELOGGING);
	bUseClassIfNoMatchedName = `GETMCMVAR(USENAME);
	bShowRankedUpPopups = `GETMCMVAR(SHOWPROMOTIONPOPUP);
	bOnlySquaddies = `GETMCMVAR(ONLYSQUADDIES);

	//not a named unit, so go by class
	if (Index == INDEX_NONE && bUseClassIfNoMatchedName)
	{
		Index = default.AutoPromotePresets.find('soldierClass', soldierType);
	}
	else
	{
		`LOG("No Named match for unit [" @soldierFullName @"], AND Use Class auto-match turned off", bIsLogged, 'Beat_AutoPromote');
		`LOG("SKIPPED AUTO-PROMOTION", bIsLogged, 'Beat_AutoPromote');
		return;
	}
	// check case where it is a rookie that got promoted from the LevelUpBarracks command
	for (i = 0; i < iRank; i++) {
		switch(i) 
			{
				case 1: iBranch = default.AutoPromotePresets[Index].corporal;		break;
				case 2:	iBranch = default.AutoPromotePresets[Index].sergeant;		break;
				case 3:	iBranch = default.AutoPromotePresets[Index].lieutenant;		break;
				case 4:	iBranch = default.AutoPromotePresets[Index].captain;		break;
				case 5:	iBranch = default.AutoPromotePresets[Index].major;			break;
				case 6:	iBranch = default.AutoPromotePresets[Index].colonel;		break;
				case 7: iBranch = default.AutoPromotePresets[Index].brigadier;		break;	//adding LWotC compatibility
			
				default:
					//this is essentially iRank 0, but also covers any typo in the config
					iBranch = default.AutoPromotePresets[Index].squaddie;
					break;
			}
		Unit.BuySoldierProgressionAbility(UpdateState, i, iBranch); // i instead of iRank
		// Unit.bRankedUp = false;									// this needs to be set false after a rankupsoldier so the NEXT CanRankUpSoldier can be valid!
		// Unit.bRankedUp in this case can remain unassigned as the LevelUpBarracks command did everything but run BuySoldierProgression
		// Unit.bNeedsNewClassPopup = bShowRankedUpPopups;	// makes the rank/class pop-up NOT come up and spam
	}

}

