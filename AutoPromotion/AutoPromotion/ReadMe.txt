﻿Auto Promotes troops when they are eligible for promotion. You can set progression you want your troops to follow in the config files.

Go to 
[code]~\steamapps\workshop\content\268500\2893561181[/code]

go to the Config folder, open the XComGameData.ini in whatever text editor of your choice, and follow the instructions at the top of the file.

if you would like to add a custom class you made or a custom class you use, you can open a PR on github.
Simply [url=https://github.com/IslandRhythms/AutoPromoteFeature-XCOM2Mod] Click here[/url] to go the repository, and go to the XComGameData.ini file and add your changes.


[h1]New Features and Fixes with update released on 02/26/2023[/h1]

The following has been added:
[list]
[*] Console Command GetSoldierAbilitisForRank(string SoldierName, int rank) logs the ability name and position for the given rank in the log file
[*] Buy Random Ability => Enable to have your troops select a random ability when they rank up. Enabling causes the mod to ignore presets for classes as well as the rank no buy option.s
[/list]

[hr][/hr]
The following has been implemented upon user request/user aid

[h3]Mod Config Menu Integration[/h3]
Due to demand, the Mod Config Menu has been integrated to enable a more customized auto promoting experience.
[list]
[*] Enable OnlySquaddies => Enable to make it so that it will only auto promote to rank squaddie. disabled by default. Having this and OnlyVets enabled renders the two options useless as now it will autopromote all troops regardless of rank.
[*] Enable OnlyVets => Enable to make it so that it will only auto promote starting at rank squaddie. disabled by default. Having this and OnlySquaddies enabled renders the two options useless as now it will autopromote all troops regardless of rank.
[*] Check Barracks => Enable to check the barracks after every mission for troops eligible for promotion and auto promote them.
[*] Enable Logging => This is helpful for debugging but also figuring out what the class internal name is. If you want to add a custom class and don't know the internal name, enable to find out. Details below. disabled by default
[*] Show Promotion Popup => When a soldier is eligible for promotion, a pop up occurs. You can disable/enable this. This is disabled by default.
[*] Ignore Covert Action => Enable to not autopromte soldiers on covert actions. If you have Show Promotion Popup enabled, it will still execute.
[*] Rank Up But Not Buy Ability => Rank the soldier up to the next available rank (ex: squaddie to corporal) but do not buy the ability. disabled by default.
[*] Enable Buying Random Ability => Enable to have your troops select a random ability when they rank up. Enabling causes the mod to ignore presets for classes as well as the rank no buy option.
[*] Use Soldier Full Name => Enable to allow using the soldier's name as well as the class name. So if John Doe is no found, it will default to the class the trooper is. Enabled by default. Credit to RustyDios.
[/list]

[h2] Code Improvement, Logging Improvement, LWOTC Support, Using The Soldier's Name, as well as the new image can be attributed to Rusty Dios. Thanks Rusty.[/h2]

[h2] Code Refactor done by me[/h2]

If you want to say more than thank you, feel free to [url=https://www.buymeacoffee.com/TheIslandRhythm] Buy me an apple[/url]

[h3] How to find the Soldier's Internal Class Name or Full Name [/h3]
Make sure that you have logging enabled, otherwise you will not see the logs!
Also make sure you have ranked up a soldier to squaddie with the class in question, otherwise you won't see it.
Also make sure that you don't have buying a random ability enabled.
[list]
[*] Go to this file in your computer
[code]..\Documents\my games\XCOM2 War of the Chosen\XComGame\Logs\Launch.log[/code]
[*] Then, search for "Beat_AutoPromote" or "==========". This will take you to the start of the logs.
[*] Scroll down and You should see a line that says "COMPLETED AUTO-PROMOTION", look 1 line above it.
[*] The text in the brackets next to "soldierType" is what you are looking for.
[*] If for some reason the full name isn't working for you, the line above the one from the previous step has the name you need to enter.
[/list]