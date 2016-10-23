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
		case Fenris.MAINQUEST_Greetings:
			stage = Fenris.MAINQUEST_CAGED_Init;
			break;
		case Fenris.MAINQUEST_CAGED_Init:
			stage = Fenris.MAINQUEST_CAGED;
			break;
		case Fenris.MAINQUEST_CAGED:
			if (value==1 || value ==2) {
				stage = Fenris.MAINQUEST_CAGED;
			} else if (value==3) { //spoke with blacksmith
				stage = Fenris.MAINQUEST_FORGEKEY1;
			}
			break;
		case Fenris.MAINQUEST_FORGEKEY1:
			stage = Fenris.MAINQUEST_SHRINKCOCK1;
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
		outputText("\nYou can feel someone hiding in the underbushes. \n'<i>Hey, come out</i>' you call. But there is only silence.\n\n");	
		progressMainQuest(1);
		menu();
		addButton(0, "Next", camp.returnToCampUseOneHour, null, null, null, "Continue on");
		break;
	case Fenris.MAINQUEST_Spotted:
		outputText("\nYou see someone in the water. Maybe you should go over for greeting.\n\n");
		menu();
		addButton(0, "Greetings", greetingsFirstTime, null, null, null, "Head over for some greetings");
		addButton(1, "Steal cloth", stealCloth, 1, null, null, "Try to sneak up and steal the loin cloth");
		addButton(14, "Leave", camp.returnToCampUseOneHour, null, null, null, "Continue on");
		break;
	case Fenris.MAINQUEST_Steal_Cloth:
		clearOutput();
		outputText("\nYou see a wolfman approach you. [fenris Ey] seems to be trying to shyly cover [fenris eir] crotch\n'<i>Hmm.., excuse me</i>' [fenris ey] say's '<i> ...you didn't see a loin cloth lying around, no? </i>' \n\n", false);	
		menu();
		addButton(0, "Nope", afterLoinClothStealDlg, 0, null, null, "Just pretend you didnt steal it");
		addButton(2, "Attack", afterLoinClothStealDlg, 2, null, null, "Ready for some beating?");
		break;
	case Fenris.MAINQUEST_Greetings:  //
	case Fenris.MAINQUEST_CAGED_Init:  //
	case Fenris.MAINQUEST_CAGED:  //
		var _rand:Number = rand(100);
		if (_fenris.getPlayerRelation() < -10) {  // he is our enemy now
			startCombat(new FenrisMonster());
		}else if (_fenris.getMainQuestStage() == Fenris.MAINQUEST_FORGEKEY1) {
			fenrisGotCaged(500);
		}else if (_rand < 10 && !_fenris.testMainQuestFlag(Fenris.MAINFLAG_STOLE_CLOTH)) { //repeats randomly until Player steals his gear
			outputText("\nYou can see Fenris swimming in the lake again.\n\n");
			menu();
			addButton(0, "Greetings", metAgain, 0, null, null, "Head over for some greetings");
			addButton(1, "Steal cloth", stealCloth, 1, null, null, "Try to sneak up and steal the loin cloth");
			addButton(14, "Leave", camp.returnToCampUseOneHour, null, null, null, "Continue on");
		}else if (_rand < 10 && _fenris.getMainQuestStage() < Fenris.MAINQUEST_CAGED_Init &&
			_fenris.testMainQuestFlag(Fenris.MAINFLAG_STOLE_CLOTH)) {
			fenrisGotCaged(0);	
		}else if (_fenris.getMainQuestStage() == Fenris.MAINQUEST_CAGED &&
			_fenris.testMainQuestFlag(Fenris.MAINFLAG_CAGED_HELPHIM)) {
			fenrisGotCaged(400);
		} else if (_rand > 90 && _fenris.getPlayerRelation()>-10) {
			gooFight();
		} else metAgain(0);
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
private function fenrisGotCaged(dlgstage:int = -1):void {
	if (dlgstage < 0) dlgstage = _dlgStage;
	_dlgStage = dlgstage;
	if (dlgstage <= 0 ) {
		clearOutput();
		outputText("\nYou can see Fenris other there. As the wolfman sees you [fenris ey] trys to hide behind a fallen tree. He seems to be anxious again.\n\n");	
		outputText("'<i>Uhh, hi [player short]</i>' [fenris ey] responds '<i> how is it going.</i>' \n\n");
		outputText("You sigh '<i>Some more troubles?</i>'\n");
		outputText("Fenris whines '<i>Mmh...well I run into some crazy guy ...and well he seemed to be easy to overpower at first..</i>'");
		outputText("'<i>but he draw some dirty tricks..and then..</i>'\n\n");
		outputText("'<i>And then he did abuse you right?</i>' you finish the sentence.\n");
		outputText("'<i>Kinda... he locked that damn thing on me ..told me I should not run around naked ..</i>'\n\n");
		outputText("'<i>Thing,what thing? </i>' you question\n");
		menu();
		addButton(0, "Next", fenrisGotCaged, 100, null, null, "");	
	} else if (dlgstage == 100 ) {
		clearOutput();
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
	} else if (dlgstage == 101 ) {
		clearOutput();
		outputText("\nSo what do you have in mind:\n");
		outputText("Maybe the goblins and other cockhungry sluts are now much less interested in him since he is incapable to use his 'gear'. \n");
		outputText("Of course it is still troublesome to not being able to get off. It could be much more likely that bad things happen to him if he is running around distracted.");
		outputText("Do you offer your help freely. Because thats what are friends are doing, right.\n");
		outputText("Or maybe get some kind of compensation in return for your effort. But that would let a stale impression on him.\n");
		outputText("Or tell him to stick with it. \n");
		progressMainQuest(0); // MAINQUEST_CAGED_Init done
		menu();
		addButton(1, "Help him", fenrisGotCaged, 201, null, null, "Offer him your help");	
		addButton(2, "Compensation?", fenrisGotCaged, 202, null, null, "Nothing for Nothing");	
		addButton(3, "Keep it", fenrisGotCaged, 203, null, null, "Why not stick with this 'protection'");
	} else if (dlgstage == 201 ) {
		clearOutput();
		outputText("\n'<i>I will help you. But how?'</i>\nFenris cheers up on your offer. You could simply try to search around to find the key. Or maybe you should talk to people who might know more about such chastity devices."); //-> friendship++ 
		Fenris.getInstance().increasePlayerRelation(10, 30);
		Fenris.getInstance().increaseSelfEsteem(10, 30);
		Fenris.getInstance().setMainQuestFlag(Fenris.MAINFLAG_CAGED_HELPHIM, true);
		progressMainQuest(1);
		menu();
		addButton(14, "Leave", camp.returnToCampUseOneHour, null, null, null, "Continue on");
	} else if (dlgstage == 202 ) {
		clearOutput();
		outputText("\n'<i>I have other important tasks already. But maybe you could offer me something?'</i>\n"); //-> get some money or use himother ways
		Fenris.getInstance().increasePlayerRelation( -5, -30);
		Fenris.getInstance().increaseSelfEsteem( -10, 30);
		Fenris.getInstance().setMainQuestFlag(Fenris.MAINFLAG_CAGED_HELPHIM, true);
		progressMainQuest(2);
		menu();
		addButton(14, "Leave", camp.returnToCampUseOneHour, null, null, null, "Continue on");
	} else if (dlgstage == 203 ) {
		clearOutput();
		outputText("\n'<i>Maybe its not that bad to stick with it. Think about it.'</i>\n");  //-> on longterm he will be a submissive buttslut
		progressMainQuest(0);
		menu();
		addButton(14, "Leave", camp.returnToCampUseOneHour, null, null, null, "Continue on");
	} else if (dlgstage == 400) {
		clearOutput();
		outputText("You meet Fenris again and [fenris ey] asks if you have come up with a idea how to help [fenris em].\n'<i>Well, either we find the key or can somehow lockpick it, which seems rather difficult since there isn't a normal lock on it, or... </i> you trail off.\n");  
		outputText("'<i>Or what ?</i>' [fenris ey] responds... \n");  
		menu();
		addButton(1, "Next", fenrisGotCaged, 401, null, null, "Next");	
	} else if (dlgstage == 401) {
		clearOutput();
		outputText("'<i>I was just thinking that there are some, umm ... substances that could make your cock shrink a little bit. ' </i> \n"); 
		outputText("\n[fenris Es] eyes widen in shock \n");
		outputText("'<i>... then you could possibly squirm out of it. ' </i> \n");
		menu();
		addButton(1, "Next", fenrisGotCaged, 402, null, null, "Next");
	} else if (dlgstage == 402) {
		outputText("[fenris Ey] nervously rubs [fenris es] paws together '<i> Na, Im not sure I would like to try this </i>' obviously in doubt. \n"); 
		outputText("'<i>If we might shrink it, we could size it up again. <i>'  you try to convince him \n");
		outputText("'<i>I will try to find someone in Teladre how could help you first. Maybe someone how knows how to lockpick or build a lock. In the meantime you should try to track down however did this to you. Just don't get into more trouble.<i>'\n");
		Fenris.getInstance().increasePlayerRelation(10, 30);
		menu();
		addButton(2, "Talk", metAgain, 0, null, null, "Talk some more");
		addButton(14, "Leave", camp.returnToCampUseOneHour, null, null, null, "Continue on");
		progressMainQuest(3) //Todo move this to Teladre
	}else trace("missing Fenris-dlgstage " + dlgstage.toString());
}
private function greetingsFirstTime ():void {
	clearOutput();
	outputText("'<i>Hi there , have some bathing fun?</i>' you call. \n\n TODO:", false);	
	progressMainQuest(1);
	menu();
	addButton(14, "Leave", camp.returnToCampUseOneHour, null, null, null, "Continue on");	
}
private function debugScr(dlgstage:int = -1):void {
	if (dlgstage < 0) dlgstage = _dlgStage;
	_dlgStage = dlgstage;

	outputText("debug stuff \n\n");	
	menu();
	addButton(4, "DemonLord", debugFct, 400, null, null, "Mutate to corrupt overlord");
	addButton(13, "Appearance", fenrisAppearance, debugScr, null, null, "");
	addButton(14, "Back", metAgain, 0, null, null, "");	
}
private function debugFct(dlgstage:int = -1):void {
	//if (dlgstage < 0) dlgstage = _dlgStage;
	//_dlgStage = dlgstage;
	var _fenris:Fenris = Fenris.getInstance();
	if (dlgstage == 400 ) {
		outputText("Fenris mutates to a corrupted werewulf overlord\n");	
		_fenris.increasePlayerRelation( -100, -80);
		_fenris.increaseSelfEsteem(100, 80);
		_fenris.increaseLibido(100, 70);
		_fenris.increaseLust(100, 70);
		_fenris.increaseLibido(100, 70);
		_fenris.increaseBodyStrength(100, 91);
		_fenris.increaseCorruption(100, 91);
		
	} else trace("missing Fenris-dlgstage " + dlgstage.toString());
	debugScr();
}
private function metAgain(dlgstage:int = -1):void {
	if (dlgstage < 0) dlgstage = _dlgStage;
	_dlgStage = dlgstage;
	var _fenris:Fenris = Fenris.getInstance();
	var stage:uint = _fenris.getMainQuestStage();
	if (dlgstage <= 0 ) {
		clearOutput();
		outputText("There is Fenris: '<i>Hi there, everthing ok? </i>'\nTODO\n");
		outputText("'<i>I'am starving - do you have something to eat?</i>' the wolf growls.\n\n");
		menu();
		addButton(0, "Give food", metAgain, 100, null, null, "See if you have some food to spare");
		addButton(1, "Give directions", metAgain, 200, null, null, "what places to go to or avoid");
		addButton(2, "What to eat", metAgain, 300, null, null, "what to eat");
		addButton(10, "debug", debugScr, 0, null, null, "");
		/*if (stage == Fenris.MAINQUEST_CAGED) {
			addButton(6, "Quest", metAgain, 600, null, null, "");
		}*/
		addButton(13, "Appearance", fenrisAppearance, metAgain, null, null, "");
		addButton(14, "Leave", camp.returnToCampUseOneHour, null, null, null, "Continue on");
	} else if (dlgstage == 100) { //giving some food
		outputText("Todo: give him something to eat -with effects perhaps \n\n");	
		menu();
		buildRandomGiveFoodMenu();
		addButton(13, "Appearance", fenrisAppearance, metAgain, null, null, "");
		addButton(14, "Back", metAgain, 0, null, null, "");	
	} else if (dlgstage == 101) { // selected a food
		outputText("\n Since his hunger is sated at least a little bit, you bid farwell. \n\n");	
		doNext(camp.returnToCampUseOneHour);
	} else if (dlgstage == 200) { //Todo: check your map and tell him to go or avoid places
		outputText("Todo: where should he go, maybe into deepwoods and meet akabal? \n\n");	
		menu();
		buildLocationToGoMenu();
		addButton(13, "Appearance", fenrisAppearance, metAgain, null, null, "");
		addButton(14, "Back", metAgain, 0, null, null, "");		
	} else if (dlgstage == 300) { //Todo: check your map and tell him what enemydrops he should take
		outputText("\nWhat food should he avoid or search \n\n");	
		menu();
		addButton(13, "Appearance", fenrisAppearance, metAgain, null, null, "");
		addButton(14, "Back", metAgain, 0, null, null, "");		
	} else if (dlgstage == 400) {//Todo: check your map and tell him who to attack/trust
		outputText("Todo: should he fight some enemys for experience? What could go wrong fighting a minotaur? \n\n");	
		menu();
		addButton(13, "Appearance", fenrisAppearance, metAgain, null, null, "");
		addButton(14, "Back", metAgain, 0, null, null, "");		
	} else if (dlgstage == 600) {//Todo: Talk about Questprogress
		outputText("Todo:state of Quest; ask him where to look, give him the key or... \n\n");	
		menu();
		addButton(6, "Clues", questCagedDlg, 601, null, null, "Ask about some hints");
		addButton(7, "Rewards", metAgain, 602, null, null, "Ask about some rewards - greedy bitch");
		addButton(13, "Appearance", fenrisAppearance, metAgain, null, null, "");
		addButton(14, "Back", metAgain, 0, null, null, "");	
	} else trace("missing Fenris-dlgstage " + dlgstage.toString());
}

/*build list of places you know
 */ 
private function buildLocationToGoMenu():void {
	if (flags[kFLAGS.TIMES_EXPLORED_FOREST]  > 0) {
		if (Fenris.getInstance().testMainQuestFlag(Fenris.MAINFLAG_SEARCH_FOREST)) {
			addButton(0, "search forest", goThere,Fenris.MAINFLAG_SEARCH_FOREST, 200, null, "");
		} else {
			addButton(0, "avoid forest", dontGoThere,Fenris.MAINFLAG_SEARCH_FOREST, 200, null, "");
		}	
	}
	if (flags[kFLAGS.TIMES_EXPLORED_MOUNTAIN]  > 0) {
		if (Fenris.getInstance().testMainQuestFlag(Fenris.MAINFLAG_SEARCH_MOUNTAIN)) {
			addButton(0, "search mountain", goThere,Fenris.MAINFLAG_SEARCH_MOUNTAIN, 200, null, "");
		} else {
			addButton(0, "avoid mountain", dontGoThere,Fenris.MAINFLAG_SEARCH_MOUNTAIN, 200, null, "");
		}	
	}

}
private function goThere(Flag:uint, dlgstage:int = -1):void {
	if (dlgstage < 0) dlgstage = _dlgStage;
	_dlgStage = dlgstage;
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
		trace("missing location " + Flag.toString());
	}
	menu();
	doNext(metAgain);
}
private function dontGoThere(Flag:uint, dlgstage:int = -1):void {
	if (dlgstage < 0) dlgstage = _dlgStage;
	_dlgStage = dlgstage;
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
		trace("missing location " + Flag.toString());
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
private function giveFood(Food:SimpleConsumable, dlgstage:int = -1):void {
	if (dlgstage < 0) dlgstage = _dlgStage;
	_dlgStage = dlgstage;
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
private function questCagedDlg (dlgstage:int = -1):void {
	if (dlgstage < 0) dlgstage = _dlgStage;
	_dlgStage = dlgstage;
	var _fenris:Fenris = Fenris.getInstance();
	clearOutput();
	if (dlgstage <= 1 ) {
		outputText("If you dont have the key you might try something different. For example shrink his genitals to be able to slip the device off\n\n");
		menu();
		if (player.hasItem(consumables.L_PNKEG, 1) && _fenris.getMainQuestStage()>Fenris.MAINQUEST_HUNTKEY1) {
			addButton(6, "Large Ping Egg", questCagedDlg, 10, null, null, "No pene - no problem");
		}
		if (player.hasItem(consumables.PINKEGG, 1) && _fenris.getMainQuestStage()<=Fenris.MAINQUEST_SHRINKCOCK1) {
			addButton(6, "Ping Egg", questCagedDlg, 20, null, null, "shrinking his pene just a little should help");
		}	
		addButton(14, "Back", metAgain, 0, null, null, "");	
	} else if (dlgstage == 10) {
		outputText("\n'<i>Here eat this. '</i> you present him the large, pink egg.'<i>But it didnt work the last time, why should it work now ?!'</i> \n");	
		outputText("\n'<i>Well, this should remove your cock completely and thn the cage should just drop off'</i> \n'<i>Remove it ? Thats horrible !'</i> he yells at you \n");
		outputText("\nTODO\n\n");
		menu();
		addButton(7, "Try it",questCagedDlg, 11, null, null, "");
		addButton(14, "Back", questCagedDlg, null, null, null, "");	
	} else if (dlgstage == 11) {
		outputText("\nHesitantly he swallows down the egg.\n");
		outputText("\nHe looks down in fear. His maleness shrinks as do his balls. He grabs the cage as he want to make sure to get rid of it this time.");
		outputText("\nHis male flesh quickly vanishs but also the magic of the cage fires up faster. He clenches his legs together making as it seems in arousal and pain at the same time.");
		outputText("\nHe cowers down until the process finishs, still trying to get hold of the metal and obscuring your view.");
		outputText("\n'<i>Damn... '</i> he pulls his hand away <i>is it gone? where is it? '</i>");
		progressMainQuest(1);
		menu();
		addButton(1, "Next",questCagedDlg, 12, null, null, "");	
	}	else if (dlgstage == 12) {
		outputText("\nNo its not gone/n. How stupid can you be just calling this thing 'cockcage' and thinking it would go away if there is no cock anymore.");
		outputText("\nFenris now has a vagina. A small one, but netherless its plain visible that he is now female.");
		outputText("\nThe metal is still there. It just transformed into something that someone could call a 'clit-cage'. A metall bump bulges out of the top of his vulva.")
		outputText("\n'<i>Uhh...is it.. oh no its still there '</i> he trys to twist it off with his thumb and index finger but is immeadiatly stopped by overwhelming sensations.");
		outputText("\nYou check out Fenris. While the egg transformed his maleness, the rest of his body is still male. Well, he might look a little bit more feminine, but his breast are still manly. Someone would call him a cuntboy now.");
		outputText("\nIs this making his life easier? At least the goblins and harpies wouldnt be after him anymore...maybe.");
		outputText("\n\nSo whats the plan now. You need that freaking key if there is any.");
		progressMainQuest(1);
		menu();
		addButton(14, "Back", metAgain, 0, null, null, "");	
	}	else if (dlgstage == 20) {
		outputText("\n'<i>Here eat this. '</i> you present [fenris em] a pink egg.'<i>Will it help... I mean how does it work?'</i> \n");	
		outputText("\n'<i>It will shrink your maleness and then we can pull the cage off'</i> \n'<i>Shrink my pene? ...no thats bad.. I dont wana shrink it..'</i> \n");
		outputText("\n'<i>Dont worry, I'm sure we can make it big again in the same way<i>' you simle.\n '<i>Ohh.. if you think its not lasting...I could try this.");
		menu();
		addButton(7, "Try it",questCagedDlg, 21, null, null, "");
		addButton(14, "Back", questCagedDlg, null, null, null, "");	
	} else if (dlgstage == 21) {
		outputText("\nHesitantly he swallows down the egg.");
		outputText("\nYou watch intently as his maleness starts shrinking slowly. He grabs the cockcage trying to pull it off. Its still tight around the base of his gonads and while his shaft is already reduced by at least one inch its not that easy to escape it.");
		outputText("\n'<i>It's still stuck in my pee slit... '</i> he wines pained. Shit, his cock might shrink but the urethrea plug keeps it's size, stretching the sensitive pipe tremondously .");	
		outputText("\nYou kneel down and try to help him. But as you do so you notice a increasing blue glint on the steel. You think there is some magic starting to build up and indeed you an feel it when grabing the steel.");
		outputText("\nOh no - the contraption starts to shrink, magic working to adapt itself to the reduced size of its content.");	
		outputText("\nYou look up to meet Fenris gaze. He has now tears in his eyes.'<i>I..I'm sorry ...I didnt expect it to be enchanted with magic and ...I'm sorry'</i> you mutter.")
		outputText("\nWell that didn't workout as planned.")
		progressMainQuest(1);
		menu();
		addButton(14, "Back", metAgain, 0, null, null, "");	
	}
}
private function stealCloth (dlgstage:int = -1):void {
	if (dlgstage < 0) dlgstage = _dlgStage;
	_dlgStage = dlgstage;
	clearOutput();
	if (dlgstage <=1 ) {
		outputText("You try to sneak over and grab what you can get. \n\n");	
		menu();
		addButton(10, "Next", stealCloth, 2, null, null, "Continue on");
	} else if (dlgstage == 2) {
		//Todo: add sucesss calculation
		outputText("You pull the loin cloth form the stone and make your way silently back to your camp. \n\n");	
		progressMainQuest(2)
		menu();
		addButton(10, "Next", camp.returnToCampUseOneHour, null, null, null, "Continue on");
		//Todo: add item and remove it from fenris
	}	
}
private function afterLoinClothStealDlg(dlgstage:int = -1):void {
	if (dlgstage < 0) dlgstage = _dlgStage;
	_dlgStage = dlgstage;
	//clearOutput();
	if (dlgstage <= 0 ) {
		outputText("'<i>No sorry</i>' you lie. But why do you need an loin cloth after all since you are already furred from tip to toe?\n\n");	
		menu();
		addButton(10, "Next", afterLoinClothStealDlg, 10, null, null, "");
	}else if (dlgstage == 2) {
		startCombat(new FenrisMonster() )
	}else if (dlgstage == 10) {
		outputText("'<i>Sure,but ... I'm used to weare it. I feel kinda vulnerable without it ...and at home they say that wearing clothes separates our kind from animals</i>' [fenris ey] responds. \n <Todo>\n\n");	
		menu();
		//Todo: offer cloth if you have one
		addButton(0, "Get used to it", afterLoinClothStealDlg, 100, null, null, "");
		addButton(14, "Appearance", fenrisAppearance, afterLoinClothStealDlg, null, null, "");
	}else if (dlgstage == 100) {
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
private function gooFight(dlgstage:int = -1):void {
	if (dlgstage < 0) dlgstage = _dlgStage;
	_dlgStage = dlgstage;
	if (dlgstage <= 0 ) {
		clearOutput();
		outputText("Todo: You see Fenris struggling with a goo-girl. What do you do?\n");
		menu();
		addButton(0, "Fight Goo", gooFight, 100, null, null, "Help Fenris defeating the enemy");
		addButton(14, "Back out", gooFight, 200, null, null, "");
	} else if (dlgstage==100) {
		startCombat(new FenrisGooFight());
	} else if (dlgstage==200) {
		outputText("You silently make your way back, leaving him to his fate.\n");
		//Todo: calc win chance of fenris
		menu();
		addButton(14, "Leave", camp.returnToCampUseOneHour, null, null, null, ""); 
	} else trace("missing Fenris-dlgstage " + dlgstage.toString());
}
/* 
 */ 
public function loseToFenris():void {
	outputText("Todo: Loose description ");
	//Todo: wining against you will boost his selfesteem
	combat.cleanupAfterCombat();
	//dynStats("lust+", 10 + player.lib / 10, "cor+", 5 + rand(10));
 }
}}
