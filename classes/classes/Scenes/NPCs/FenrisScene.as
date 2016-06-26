package classes.Scenes.NPCs{

	import classes.Scenes.NPCs.Fenris;
	import classes.Scenes.NPCs.FenrisMonster;
	import classes.Scenes.Areas.Lake.FenrisGooFight;
	import classes.GlobalFlags.kFLAGS;
	import classes.GlobalFlags.kGAMECLASS;
	import classes.internals.*;
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
		case Fenris.MAINQUEST_Greetings: 
			if (value==1) {
				stage = Fenris.MAINQUEST_Greetings;
			} else {
				stage = Fenris.MAINQUEST_Steal_Cloth;				
			}
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
	if (!player.hasItem(ItemType.lookupItem("DbgWand"))) player.itemSlot1.setItemAndQty(ItemType.lookupItem("DbgWand"), 1);  //Todo: ??debug
	//Todo: spriteSelect(68);
	var _fenris:Fenris = Fenris.getInstance();
	var stage:uint = _fenris.getMainQuestStage();
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
	case Fenris.MAINQUEST_Greetings:  //
		var _rand:Number = rand(100);
		if (_rand < 10 && !_fenris.testMainQuestFlag(Fenris.MAINFLAG_Stole_Cloth)) { //repeats randomly until Player steals his gear
			outputText("You can see Fenris swimming in the lake again.\n\n");
			menu();
			addButton(0, "Greetings", metAgain, 0, null, null, "Head over for some greetings");
			addButton(1, "Steal cloth", stealCloth, 1, null, null, "Try to sneak up and steal the loin cloth");
			addButton(14, "Leave", camp.returnToCampUseOneHour, null, null, null, "Continue on");
		}else if (_rand < 10 && _fenris.getMainQuestStage() < Fenris.MAINQUEST_CAGED &&
			_fenris.testMainQuestFlag(Fenris.MAINFLAG_Stole_Cloth)) {
			fenrisGotCaged(0);		
		} else if(_rand>90) {
			gooFight();
		} else metAgain(0);
		break;
	case Fenris.MAINQUEST_CAGED:  //
		break;
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
private function fenrisGotCaged(stage:int = -1):void {
	if (stage < 0) stage = _dlgStage;
	_dlgStage = stage;
	if (stage <= 0 ) {
		outputText("You can see Fenris other there. As the wolfman sees you [fenris ey] trys to hide behind a fallen tree. He seems to be anxious again.\n\n");	
		outputText("'<i>Uhh, hi [player short]</i>' [fenris ey] responds '<i> how is it going.</i>' \n\n");
		outputText("You sigh '<i>Some more troubles?</i>'\n");
		outputText("Fenris whines '<i>Mmh...well I run into some crazy guy ...and well he seemed to be easy to overpower at first..</i>'");
		outputText("'<i>but he draw some dirty tricks..and then..</i>'\n\n");
		outputText("'<i>And then he did abuse you right?</i>' you finish the sentence.\n");
		outputText("'<i>Kinda... he locked that damn thing on me ..told me I should not run around naked ..</i>'\n\n");
		outputText("'<i>Thing,what thing? </i>' you question\n");
		menu();
		addButton(0, "Next", fenrisGotCaged, 100, null, null, "");	
	} else if (stage == 100 ) {
		outputText("[fenris Ey] steps out of [fenris eir] cover:\n");
		outputText("[fenris Eir] entire shaft is engulfed by something that seems to some kind of metal tube. You approach him to take a closer look.\n");
		outputText("'<i>I tried to pull it off since some hours now </i>' [fenris ey] whimpers. '<i>but its just to thight fitting</i>'\n");
		outputText("You kneel down to inspect this device. Indeed its a solid tube that appears to be slipped over his sheath.\n");
		outputText("Grabing the tube you try to pull it off in the upward direction.\n");
		outputText("'<i>AAhh... No, wait,... its locked around my testicles.. </i>' [fenris ey] quickly intercepts \n");
		outputText("'<i>and there is something sticking inside my pene.. </i>' \n");
		outputText("Rigth, the tube is locked in place with a sturdy metal ring grasping around the base of [fenris eir] nuts in a tight fit.\n");
		outputText("The tip of [fenris eir] sheath is covered by the tube except of a small hole. \n");
		outputText("Fenris sees you inspecting the hole '<i>I can pee through it but there is something pushed into my pisslit... its going halfway into my pene </i>' \n");
		outputText("A hollow urethrea plug you guess. This makes it even more complicated to remove this chastity device.\n")
		outputText("'<i>please help me ... its stiring all the time...but I cannot get hard with this..  </i>' [fenris ey] whimpers\n");
		outputText("For sure, this device would keep someone from getting hard forcibly and at the same time causes a continues source of stimulation.");
		menu();
		addButton(0, "Next", fenrisGotCaged, 101, null, null, "");	
	} else if (stage == 101 ) {
		outputText("So what do you have in mind:\n");
		outputText("Maybe the goblins and other cockhungry sluts are now much less interested in him since he is incapable to use his 'gear'. \n");
		outputText("Of course it is still troublesome to not being able to get off. It could be much more likely that bad things happen to him if he is running around distracted.");
		outputText("Do you offer your help freely. Because thats what are friends are doing, right.\n");
		outputText("Or maybe get some kind of compensation in return for your effort. But that would let a stale impression on him.\n");
		outputText("Or tell him to stick with it. \n");
		menu();
		addButton(1, "Help him", fenrisGotCaged, 201, null, null, "");	
		addButton(2, "Compensation?", fenrisGotCaged, 202, null, null, "");	
		addButton(3, "Keep it", fenrisGotCaged, 203, null, null, "");
	} else if (stage == 201 ) {
		clearOutput();
		outputText("I will help you. But how?\n"); //-> friendship++ 
		menu();
		addButton(14, "Leave", camp.returnToCampUseOneHour, null, null, null, "Continue on");
	} else if (stage == 202 ) {
		clearOutput();
		outputText("I have other important tasks already. But what could you offer me\n"); //-> get some money or use himother ways
		menu();
		addButton(14, "Leave", camp.returnToCampUseOneHour, null, null, null, "Continue on");
	} else if (stage == 203 ) {
		clearOutput();
		outputText("Maybe its not that bad to stick with it. Think about it.\n");  //-> on longterm he will be a submissive buttslut
		menu();
		addButton(14, "Leave", camp.returnToCampUseOneHour, null, null, null, "Continue on");
	}else trace("missing Fenris-stage " + stage.toString());
}
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
		outputText("'<i>I'am starving - what can I eat?</i>' \n\n");
		menu();
		addButton(0, "Give food", metAgain, 100, null, null, "See if you have some food to spare");
		addButton(1, "Give directions", metAgain, 200, null, null, "what places to go to or avoid");
		addButton(2, "What to eat", metAgain, 300, null, null, "what to eat");
		addButton(3, "Who to mess", metAgain, 400, null, null, "someone to avoid maybe");
		addButton(13, "Appearance", fenrisAppearance, metAgain, null, null, "");
		addButton(14, "Leave", camp.returnToCampUseOneHour, null, null, null, "Continue on");
	} else if (stage == 100) { //giving some food
		outputText("Todo: give him something to eat -with effects perhaps \n\n");	
		menu();
		buildRandomGiveFoodMenu();
		addButton(13, "Appearance", fenrisAppearance, metAgain, null, null, "");
		addButton(14, "Back", metAgain, 0, null, null, "");	
	} else if (stage == 101) { // selected a food
		outputText("Todo: Since his hunger is sated at least a little bit, you bid farwell. \n\n");	
		doNext(camp.returnToCampUseOneHour);
	} else if (stage == 200) { //Todo: check your map and tell him to go or avoid places
		outputText("Todo: where should he go, maybe into deepwoods and meet akabal? \n\n");	
		menu();
		buildLocationToGoMenu();
		addButton(13, "Appearance", fenrisAppearance, metAgain, null, null, "");
		addButton(14, "Back", metAgain, 0, null, null, "");		
	} else if (stage == 300) { //Todo: check your map and tell him what enemydrops he should take
		outputText("Todo: what food should he avoid or search \n\n");	
		menu();
		addButton(13, "Appearance", fenrisAppearance, metAgain, null, null, "");
		addButton(14, "Back", metAgain, 0, null, null, "");		
	} else if (stage == 400) {//Todo: check your map and tell him who to attack/trust
		outputText("Todo: should he fight some enemys for experience? What could go wrong fighting a minotaur? \n\n");	
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
		if (Fenris.getInstance().testMainQuestFlag(Fenris.MAINFLAG_SEARCH_MOUNTAIN)) {
			addButton(0, "search mountain", goThere,Fenris.MAINFLAG_SEARCH_MOUNTAIN, 200, null, "");
		} else {
			addButton(0, "avoid mountain", dontGoThere,Fenris.MAINFLAG_SEARCH_MOUNTAIN, 200, null, "");
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
 * Todo: make several pages instead
 */ 
private function buildRandomGiveFoodMenu():void {
	var _foods:TakeoutDrop = new TakeoutDrop(null);
	if (player.hasItem(consumables.VITAL_T)) _foods.add(consumables.VITAL_T,1);
	if (player.hasItem(consumables.BLACKPP)) _foods.add(consumables.BLACKPP,1);
	if (player.hasItem(consumables.CANINEP)) _foods.add(consumables.CANINEP,1);
	if (player.hasItem(consumables.IMPFOOD)) _foods.add(consumables.IMPFOOD,1);
	if (player.hasItem(consumables.GOB_ALE)) _foods.add(consumables.GOB_ALE,1);
	if (player.hasItem(consumables.SDELITE)) _foods.add(consumables.SDELITE, 1);
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
	
	//Todo: add effect to fenris
	var Result:ReturnResult = new ReturnResult();
	Fenris.getInstance().eatThis(Food, Result);
	outputText("Fenris takes a suspicious look at " + Food.longName +".");
	outputText(Result.Text);
	if (Result.Code == 0) {
		player.consumeItem(ItemType.lookupItem(Food.id));
	}
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
		progressMainQuest(2)
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
	outputText("Right in front of you stands a walking, speaking wolfman. \n");
	outputText("[fenris descrwithclothes] \n");
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
		//Todo: calc win chance of fenris
		menu();
		addButton(14, "Leave", camp.returnToCampUseOneHour, null, null, null, ""); 
	} else trace("missing Fenris-stage " + stage.toString());
}
/* 
 */ 
public function loseToFenris():void {
	outputText("Todo: Loose description ");
	combat.cleanupAfterCombat();
	//dynStats("lust+", 10 + player.lib / 10, "cor+", 5 + rand(10));
 }
}}
