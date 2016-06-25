package classes.Scenes.NPCs{

	import classes.Scenes.NPCs.Fenris;
	import classes.Scenes.NPCs.FenrisMonster;
	import classes.Scenes.Areas.Lake.FenrisGooFight;
	import classes.GlobalFlags.kFLAGS;
	import classes.GlobalFlags.kGAMECLASS;
	import classes.internals.TakeoutDrop;
	import classes.Items.Consumables.SimpleConsumable;
	import classes.ItemType;

	public class FenrisScene extends NPCAwareContent  {

		public var FenrisNPC:classes.Scenes.NPCs.Fenris;

		public function FenrisScene()
		{
			
		}

	/**this will switch to the next stage; see Fenris.as for stages & flags
	 * value defines the quest branch to go on
	 */
	public function progressMainQuest( value:uint):void {
		var stage:uint = Fenris.getInstance().getMainQuestStage();
		switch (stage ) {
		case Fenris.MAINQUEST_Not_Met: 
				stage = Fenris.MAINQUEST_Spotted;
				break;
		case Fenris.MAINQUEST_Spotted: 
			if (value==1) {
				stage = Fenris.MAINQUEST_Greetings;
			} else {
				stage = Fenris.MAINQUEST_Steal_Cloth;				
			}
			break;
		case Fenris.MAINQUEST_Greetings: 
			break;
		case Fenris.MAINQUEST_Steal_Cloth:
			stage = Fenris.MAINQUEST_Greetings;
			break;
		default:
			trace("missing Fenris-stage " + stage.toString());
		}
		Fenris.getInstance().setMainQuestStage(stage);
	}

/* this creates output and options for display depending on quest stage
 * */
public function encounterTracking():void {
	if (!player.hasItem(ItemType.lookupItem("DbgWand"))) player.itemSlot1.setItemAndQty(ItemType.lookupItem("DbgWand"), 1);  //??debug
	//Todo: spriteSelect(68);
	var stage:uint = Fenris.getInstance().getMainQuestStage();
	//First time greeting
	switch (stage ) {
	case Fenris.MAINQUEST_Not_Met:
		clearOutput();
		outputText("You can feel someone hiding in the underbushes. \n'<i>Hey, come out</i>' you call. But there is only silence.\n\n");	
		progressMainQuest(1);
		menu();
		addButton(0, "Next", camp.returnToCampUseOneHour, null, null, null, "Continue on");
		break;
	case Fenris.MAINQUEST_Spotted:
		outputText("You see someone in the water. Maybe you should go over for greeting.\n\n");
		menu();
		addButton(0, "Greetings", greetingsFirstTime, null, null, null, "Head over for some greetings");
		addButton(1, "Steal cloth", stealCloth, 1, null, null, "Try to sneak up and steal the loin cloth");
		addButton(14, "Leave", camp.returnToCampUseOneHour, null, null, null, "Continue on");
		break;
	case Fenris.MAINQUEST_Steal_Cloth:
		clearOutput();
		outputText("You see a wolfman approach you. [fenris Ey] seems to be trying to shyly cover [fenris eir] crotch\n'<i>Hmm.., excuse me</i>' [fenris ey] say's '<i> ...you didn't see a loin cloth lying around, no? </i>' \n\n", false);	
		menu();
		addButton(0, "Nope", afterLoinClothStealDlg, 0, null, null, "Just pretend you didnt steal it");
		addButton(2, "Attack", afterLoinClothStealDlg, 2, null, null, "Ready for some beating?");
		break;
	case Fenris.MAINQUEST_Greetings: 
		var _rand:Number = rand(10);
		if(_rand>5) {
			gooFight();
		} else metAgain(0);
	default:
		trace("missing Fenris-stage " + stage.toString());
	}
}
//some explanation about this:
//	usualy I have a function for every Quest-Stage. This function has an additional stage which has nothing to do with Quest-Stage
// It is used to switch through different substates/dialogs by repeatedly calling the function
// addButton(0, "Nope", afterLoinClothStealDlg, 0, null, null) will start the function afterLoinClothStealDlg at stage 0.
// at some point I want to call a different function and then switch back f.e. with doNext(afterLoinClothStealDlg). But no option to call with argument
// so there is an additional variable _dlgStage to track the actual stage and use it if afterLoinClothStealDlg is called without argument
private var _dlgStage:int; 
private function greetingsFirstTime ():void {
	clearOutput();
	outputText("'<i>Hi there , have some bathing fun?</i>' you call. \n\n TODO:", false);	
	progressMainQuest(1);
	menu();
	addButton(14, "Leave", camp.returnToCampUseOneHour, null, null, null, "Continue on");	
}
private function metAgain(stage:int = -1):void {
	if (stage < 0) stage = _dlgStage;
	_dlgStage = stage;
	if (stage <= 0 ) {
		clearOutput();
		outputText("Todo: How is it going - blabla \n\n");
		outputText("I'am starving - what can I eat? \n\n");
		menu();
		addButton(0, "Give food", metAgain, 100, null, null, "See if you have some food to spare");
		addButton(1, "Give directions", metAgain, 200, null, null, "what places to go to or avoid");
		addButton(2, "What to eat", metAgain, 300, null, null, "what to eat");
		addButton(3, "Who to mess", metAgain, 400, null, null, "someone to avoid maybe");
		addButton(13, "Appearance", fenrisAppearance, metAgain, null, null, "");
		addButton(14, "Leave", camp.returnToCampUseOneHour, null, null, null, "Continue on");
	} else if (stage == 100) {
		outputText("Todo: give him something to eat -with effects perhaps \n\n");	
		//Todo: check your invent for possible food
		//  give and see mutation
		menu();
		buildRandomGiveFoodMenu();
		addButton(13, "Appearance", fenrisAppearance, metAgain, null, null, "");
		addButton(14, "Back", metAgain, 0, null, null, "");	
	} else if (stage == 101) { // selected a food
		outputText("Todo: Since his hunger is sated at least a little bit, you bid farwell. \n\n");	
		doNext(camp.returnToCampUseOneHour);
	} else if (stage == 200) {
		outputText("Todo: where should he go, maybe into deepwoods and meet akabal? \n\n");	
		//Todo: check your map and tell him to go or avoid places
		menu();
		buildLocationToGoMenu();
		addButton(13, "Appearance", fenrisAppearance, metAgain, null, null, "");
		addButton(14, "Back", metAgain, 0, null, null, "");		
	} else if (stage == 300) {
		outputText("Todo: what food should he avoid or search \n\n");	
		//Todo: check your map and tell him what enemydrops he should take
		//  
		menu();
		addButton(13, "Appearance", fenrisAppearance, metAgain, null, null, "");
		addButton(14, "Back", metAgain, 0, null, null, "");		
	} else if (stage == 400) {
		outputText("Todo: should he fight some enemys for experience? What could go wrong fighting a minotaur? \n\n");	
		//Todo: check your map and tell him who to attack/trust
		//  
		menu();
		addButton(13, "Appearance", fenrisAppearance, metAgain, null, null, "");
		addButton(14, "Back", metAgain, 0, null, null, "");		
	} else trace("missing Fenris-stage " + stage.toString());
}

/*build list of places you know
 */ 
private function buildLocationToGoMenu():void {
	if (player.exploredForest > 0) {
		if (Fenris.getInstance().testMainQuestFlag(Fenris.MAINFLAG_SEARCH_FOREST)) {
			addButton(0, "search forest", goThere,Fenris.MAINFLAG_SEARCH_FOREST, 200, null, "");
		} else {
			addButton(0, "avoid forest", dontGoThere,Fenris.MAINFLAG_SEARCH_FOREST, 200, null, "");
		}	
	}
	if (player.exploredMountain > 0) {
		if (Fenris.getInstance().testMainQuestFlag(Fenris.MAINQUEST_SEARCH_MOUNTAIN)) {
			addButton(0, "search mountain", goThere,Fenris.MAINQUEST_SEARCH_MOUNTAIN, 200, null, "");
		} else {
			addButton(0, "avoid mountain", dontGoThere,Fenris.MAINQUEST_SEARCH_MOUNTAIN, 200, null, "");
		}	
	}
	if (player.exploredDesert > 0) {}
	if (player.exploredMountain > 0) {}
}
private function goThere(Flag:uint, stage:int = -1):void {
	if (stage < 0) stage = _dlgStage;
	_dlgStage = stage;
	clearOutput();
	switch (Flag) {
	case Fenris.MAINFLAG_SEARCH_FOREST:
			outputText("You tell him that he should checkout the forest.\n");
			Fenris.getInstance().setMainQuestFlag(Fenris.MAINFLAG_SEARCH_FOREST,true)
		break;
	case Fenris.MAINFLAG_SEARCH_MOUNTAIN:
			outputText("You tell him that he should hike the mountains.\n");
			Fenris.getInstance().setMainQuestFlag(Fenris.MAINFLAG_SEARCH_MOUNTAIN,true)
		break;
	default:
		trace("missing Flocation " + Flag.toString());
	}
	menu();
	doNext(metAgain);
}
private function dontGoThere(Flag:uint, stage:int = -1):void {
	if (stage < 0) stage = _dlgStage;
	_dlgStage = stage;
	clearOutput();
	switch (Flag) {
	case Fenris.MAINFLAG_SEARCH_FOREST:
			outputText("You tell him to avoid the forest.\n");
			Fenris.getInstance().setMainQuestFlag(Fenris.MAINFLAG_SEARCH_FOREST,false)
		break;
	case Fenris.MAINFLAG_SEARCH_MOUNTAIN:
			outputText("You tell him that he should avoid the mountains.\n");
			Fenris.getInstance().setMainQuestFlag(Fenris.MAINFLAG_SEARCH_MOUNTAIN,false)
		break;
	default:
		trace("missing Flocation " + Flag.toString());
	}
	menu();
	doNext(metAgain);
}
/*build random list of foods you could give away
 * random because we could have 20 foods but only 5 buttons and dont want to stick with first 5 foods !
 * 
 */ 
private function buildRandomGiveFoodMenu():void {
	var _foods:TakeoutDrop = new TakeoutDrop(null);
	if (player.hasItem(consumables.VITAL_T)) _foods.add(consumables.VITAL_T,1);
	if (player.hasItem(consumables.BLACKPP)) _foods.add(consumables.BLACKPP,1);
	if (player.hasItem(consumables.CANINEP)) _foods.add(consumables.CANINEP,1);
	if (player.hasItem(consumables.BLUEEGG)) _foods.add(consumables.BLUEEGG,1);
	if (player.hasItem(consumables.PINKEGG)) _foods.add(consumables.PINKEGG,1);
	if (player.hasItem(consumables.KANGAFT)) _foods.add(consumables.KANGAFT, 1);
	var _item:SimpleConsumable;
	_item = _foods.roll();
	if (_item != null) addButton(0, _item.shortName, giveFood,_item, 101, null, "");
	_item = _foods.roll();
	if (_item != null) addButton(1, _item.shortName, giveFood,_item, 101, null, "");
	_item = _foods.roll();
	if (_item != null) addButton(2, _item.shortName, giveFood,_item, 101, null, "");
	_item = _foods.roll();
	if (_item != null) addButton(3, _item.shortName, giveFood,_item, 101, null, "");
	_item = _foods.roll();
	if (_item != null) addButton(4, _item.shortName,giveFood,_item, 101, null, "");
}
private function giveFood(Food:SimpleConsumable, stage:int = -1):void {
	if (stage < 0) stage = _dlgStage;
	_dlgStage = stage;
	clearOutput();
	outputText("Fenris takes a suspicious look at " + Food.longName +". But he is hungry so he wolfyli munches it down.");
	//Todo: add effect to fenris
	player.consumeItem(ItemType.lookupItem(Food.id));
	menu();
	doNext(metAgain);
}

private function stealCloth (stage:int = -1):void {
	if (stage < 0) stage = _dlgStage;
	_dlgStage = stage;
	clearOutput();
	if (stage <=1 ) {
		outputText("You try to sneak over and grab what you can get. \n\n");	
		menu();
		addButton(10, "Next", stealCloth, 2, null, null, "Continue on");
	} else if (stage == 2) {
		//Todo: add sucesss calculation
		outputText("You pull the loin cloth form the stone and make your way silently back to your camp. \n\n");	
		progressMainQuest(1)
		menu();
		addButton(10, "Next", camp.returnToCampUseOneHour, null, null, null, "Continue on");
		//Todo: add item and remove it from fenris
	}	
}
private function afterLoinClothStealDlg(stage:int = -1):void {
	if (stage < 0) stage = _dlgStage;
	_dlgStage = stage;
	//clearOutput();
	if (stage <= 0 ) {
		outputText("'<i>No sorry</i>' you lie. But why do you need an loin cloth after all since you are already furred from tip to toe?\n\n");	
		menu();
		addButton(10, "Next", afterLoinClothStealDlg, 10, null, null, "");
	}else if (stage == 2) {
		startCombat(new FenrisMonster() )
	}else if (stage == 10) {
		outputText("'<i>Sure,but ... I'm used to weare it. I feel kinda vulnerable without it ...and at home they say that wearing clothes separates our kind from animals</i>' [fenris ey] responds. \n <Todo>\n\n");	
		menu();
		//Todo: offer cloth if you have one
		addButton(0, "Get used to it", afterLoinClothStealDlg, 100, null, null, "");
		addButton(14, "Appearance", fenrisAppearance, afterLoinClothStealDlg, null, null, "");
	}else if (stage == 100) {
		outputText("'<i>Not the clothe are making the differences. Just try to keep your wits up. </i>' you answer. \n <Todo>\n\n");	
		progressMainQuest(1);
		menu();
		addButton(14, "Appearance", fenrisAppearance, afterLoinClothStealDlg, null, null, "");
		addButton(14, "Leave", camp.returnToCampUseOneHour, null, null, null, "Continue on");
	}  
	
}
private function fenrisAppearance(back:Function):void {
	clearOutput();
	outputText("Right in front of you stands a walking, speaking wolfman.");
	outputText("[fenris status]"); //for debug only
	menu();
	doNext(back);
}

private function gooFight(stage:int = -1):void {
	if (stage < 0) stage = _dlgStage;
	_dlgStage = stage;
	if (stage <= 0 ) {
		clearOutput();
		outputText("Todo: You see Fenris struggling with a goo-girl. What do you do?\n");
		menu();
		addButton(0, "Fight Goo", gooFight, 100, null, null, "Help Fenris defeating the enemy");
		addButton(14, "Back out", gooFight, 200, null, null, "");
	} else if (stage==100) {
		startCombat(new FenrisGooFight());
	} else if (stage==200) {
		outputText("You silently make your way back, leaving him to his fate.\n");
		menu();
		addButton(14, "Leave", camp.returnToCampUseOneHour, null, null, null, ""); 
	} else trace("missing Fenris-stage " + stage.toString());
}
/* 
 */ 
public function loseToFenris():void {
	outputText("Todo: Loose description ");
	//dynStats("lust+", 10 + player.lib / 10, "cor+", 5 + rand(10));
 }
}}
