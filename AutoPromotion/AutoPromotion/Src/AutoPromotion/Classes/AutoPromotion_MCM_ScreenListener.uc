// This is an Unreal Script

class AutoPromotion_MCM_ScreenListener extends UIScreenListener;

event OnInit (UIScreen Screen)
{
	local AutoPromote_Screen MCMScreen;

	if (ScreenClass == none)
	{
		if (MCM_API(Screen) != none)
		{
			ScreenClass = Screen.Class;
		}
		else
		{
			return;
		}
	}

	MCMScreen = new class'AutoPromote_Screen';
	MCMScreen.OnInit(Screen);
}

defaultproperties
{
    ScreenClass = none;
}

