/**
 * Hell-Hound-Companion
 * @author Foxxling (idea & writing) & JD (coding)
 */
package classes.Scenes.NPCs {
	
	import classes.*;
	import classes.GlobalFlags.*;
	import classes.Scenes.API.Encounter;
	import classes.Scenes.Camp;
	import classes.Scenes.Monsters.Goblin;
	import classes.Scenes.NPCs.HHCFollower;
		
	public class HHCScene extends NPCAwareContent implements Encounter {
		//override the following encounter-functions when creating new encounters and call encounterTracking on execution	
		public function encounterChance():Number {
			if (flags[kFLAGS.CODEX_ENTRY_HELLHOUNDS] < 1 || HHCFollower.getInstance().getMainQuestStage()==HHCFollower.MAINQUEST_Disabled) return 0;
			if (player.cor < 25) return 0;	//need to be at least little corrupt ?
			return 1;
		}
		public function execEncounter():void {
			var state:uint = HHCFollower.getInstance().getMainQuestStage();
			switch(state) {
				case HHCFollower.MAINQUEST_Not_Met:
					firstEnc();
					break;
				case HHCFollower.MAINQUEST_Fed_Him:
					secondEnc();
					break;
				case HHCFollower.MAINQUEST_Hunt_With_Him:
					//TodothirdEnc();
					break;
			default:
				trace("unhandled state:", state);
			}
		}
		public function encounterName():String {
			return "Hell-Hound Companion";
		}
		
		public function firstEnc():void {
			//spriteSelect(SpriteDb.s_hhc_sick);
			clearOutput();
			outputText("After wandering through the mountains for some time, you hear the high pitched keen of an animal. It appears to be coming from a large crag in some nearby rocks. When you peek around the corner to investigate, you find a sickly looking hellhound. \n\n");
			outputText("The two headed demonic dog man lies in the fetal position, his bony arms  wrapped around skinny legs. His fur is patchy, exposed skin peeking through in spots. His ribs are visible and you see several bloody sores across his body. The fire in his eyes is very weak. His pair of black shafts hang limply above a shriveled sac.\n\n");
			outputText("One of his heads rises and his dim, almost black eyes gaze into yours. He sniffs at you before lying back down with a grimace, as if even just lifting his head is hard work. You hear the loud growl of a rumbling stomach as the starving hound lies there. He clearly hasn't eaten in a long time, and his body is as weak as a baby’s. He will soon expire if he doesn't get something to eat. Will you feed him?\n\n");
			doYesNo(feedHim, dontFeedHim);
		}
		public function feedHim():void {
			clearOutput();
			HHCFollower.getInstance().setMainQuestStage(HHCFollower.MAINQUEST_Fed_Him);
			outputText("You drop your pack to pull out some of the food you brought with you from camp. You offer it to the starving hellhound, before dropping it into his outstretched hand. The two heads are obviously wary of your help. He examines the food for a few moments before one head reaches forward and snaps it up.\n\n");
			outputText("You sit there and watch as the hellhound slowly consumes the food and wonder what brought him to such a poor state. You feel an odd tingle at the back of your skull, and you can almost see the face of something but then it's gone. It seems the hellhound has finished his small meal, his two heads are now staring at you with perplexed expressions.\n\n");
			outputText("Judging by the brighter fire in the creature's eyes, it will last for a while longer now. You realize that you've wasted a lot of time dealing with what is ultimately just another dumb beast, so you collect your things and begin to move on. Perhaps you might see this creature again sometime. \n\n");
			if (HHCFollower.getInstance().getMainQuestFlag() > 3) { //patched him up enough
				HHCFollower.getInstance().setMainQuestStage(HHCFollower.MAINQUEST_Hunt_With_Him);
			}
			doNext(camp.returnToCampUseOneHour);
		}
		public function dontFeedHim():void {
			clearOutput();
			HHCFollower.getInstance().setMainQuestStage(HHCFollower.MAINQUEST_Disabled);
			if (player.cor < 40) {
				outputText("This creature isn't really your problem, and giving out charity to corrupted creatures is probably just asking for trouble. You leave the hellhound to his troubles, and continue your explorations.\n\n");
			} else {
				outputText("This creature isn't really your problem. Maybe if it was a little more pleasing to look upon or play with you'd help it but no such luck. You silently wonder if there's anything to fuck on the mountains but are disappointed when nothing else worthy of note happens on your trip through the mountains. \n\n");
			}
			outputText("You’re pretty sure that the hellhound won’t be bothering you again.");
			doNext(camp.returnToCampUseOneHour);
		}
		public function secondEnc():void {
			clearOutput();
			outputText("As you explore the mountains you become aware of an odd presence at the back of your mind. You look around and find the weak hellhound you fed padding up behind you. His midnight black hair once again covers his skin but you can still see his ribs. \n\n");
			outputText("He looks at you nervously, and you get the impression he is asking you to help him find more food. You shrug, wondering what it is that hellhounds eat anyway; it then occurs to you that he might hunt lesser creatures like imps and goblins. \n\n");
			outputText("When you say as much his skinny faces spread into twin grins, his eagerness apparent in his suddenly twitching tail.");
			menu();
			addButton(1, "Shoo", shoo);// , 0, 0, 0, "Piss of hell hound");
			addButton(2, "Hunt Goblin", huntGoblin);// , 0, 0, 0, "hunt down some goblin to play with")
			addButton(14, "Leave", curry(doNext, camp.returnToCampUseOneHour));
		}
		public function shoo():void {
			clearOutput();
			HHCFollower.getInstance().setMainQuestStage(HHCFollower.MAINQUEST_Disabled);
			outputText("You’re quite certain the hellhound is more than capable of finding his own food. When you say as much his ears go flat and his tail tucks between his legs. Both heads avoid your gaze as you leave. \n\n");
			outputText("You’re pretty sure that the hellhound won’t be bothering you again.");
			doNext(camp.returnToCampUseOneHour);
		}
		public function huntGoblin():void {
			clearOutput();
			outputText("You decide to help him find a goblin. Shouldn’t be too hard. As you and your hellhound companion continue down the mountain you keep your eyes peeled. After a while you find her, sitting and playing with her pussy while singing a song about popping out kids. \n\n");
			outputText("The hellhound barks and the goblin jumps up, fingers dripping as she sees the dual cocked beast and runs head first toward him. You step between her and her dual dicked target and she puts up her fists.\n\n");
			outputText("You’re now fighting a goblin.");
			doNext(camp.returnToCampUseOneHour);
			doNext(curry(startCombat,new Goblin(),false)); //TODO: override postVictoryScene with hellhoundPetConsumesGoblin
		}
		public function hellhoundPetConsumesGoblin():void   {
			HHCFollower.getInstance().setMainQuestStage(HHCFollower.MAINQUEST_Hunt_With_Him);
			outputText("You grin with pride as the hound howls triumphantly and springs forward. The demonic dog sinks its claws into the defeated creature's chest, slamming its prey to the ground, and both heads snarl in turn. Panicking, the goblin tries to struggle, and the snarl turns into a murderous roar, quieting the little whore. The hellhound's muzzles bob closer to the goblin's face, thick oily smoke leaking from its nostrils.");
			outputText("It is at this moment that the horny goblin realizes that things might not end well. She twists to one side and scrambles to her feet. Concerned, you ready your "+this.player.weaponName+", but it is wildly unnecessary; the goblin makes it about two steps before your new friend tackles his prey, barking happily. You see the twin shafts bobbing below its belly, engorged at the prospect of a helpless victim. The hound keeps the little horny bitch crushed against the ground beneath its muscular forearms, adding an additional incentive to stay still as its bared teeth snap menacingly alongside the goblin’s head, nipping at her ears.");
			outputText("Precum drips from the tips of the dog's dual members and spatters against the goblin's skin. You shudder, recalling your own encounters with adult hounds, knowing what must come next. Your new friend crouches down, makes a few exploratory nudges, then impatiently begins pistoning its hips, thrusting both its fleshy cocks into the vicinity of the goblin's holes, intending to double penetrate her. They miss their mark only once before the goblin reaches down and pulls the dual demon dog dongs into her holes, apparently having made peace with her inescapable fate. The horny little slut screams in delight as the hellhound shoves his hips forward.");

		   if(this.player.hasVagina()){   
			  outputText("You find yourself unable to resist reaching down and swishing a finger around your "+this.allVaginaDescript+", flicking your "+this.clitDescript()+" and taking in a deep breath as you contemplate what it'd be like to have the hound's twin doggy-dicks plowing <i>your</i> holes.");
		   }
			if(this.player.cocks.length == 1){
				outputText("Your "+this.cockDescript(0)+" presses purposefully against your "+this.player.armorName+", and you absentmindedly give it a firm squeeze as you watch the beast slake its lust.");
			}else if(this.player.dogCocks() == 2 && this.player.cocks.length == 2){
				outputText("Almost subconsciously, your fingers slide to tweak your own "+this.multiCockDescriptLight()+" bulging beneath your "+this.player.armorName+". You can almost imagine exactly what your friend is feeling.");
			}else if(this.player.cocks.length > 1){
				outputText("Your "+this.multiCockDescriptLight()+" stir beneath your "+this.player.armorName+", and you rub them absentmindedly as you watch the beast satisfy itself.");
			}

		   if(this.player.vaginas.length == 0 && this.player.cocks.length == 0){
			  this.outputText("You squirm as you watch, enjoying the heat building in your smooth groin, your fingers absentmindedly fiddling with your "+this.allBreastsDescript()+", lingering on your "+this.nippleDescript(0)+"s.");
		   }

			outputText("Despite your arousal, you remind yourself that it wouldn't be right to join in, that this is the hellhound's chance to learn for itself what victory feels like.");
			outputText("Content with keeping your hands occupied for the time being, you watch raptly as the canine demon continues to thoroughly plow both of the goblin's holes, now popping its heavy shafts up to the hilt with each thrust, while the smaller creature begins to moan softly, feminine fluid dripping into the dust.");
			outputText("Giving a surprised yelp that turns into a howl, the hellhound finally reaches its apex and lurches forward, falling flat onto its prey and sinking both of its cocks deep into the goblin's insides. Thick demon seed leaking out around the Hellhound's twin doggy-dicks.");
			outputText("The goblin's features betray an elaborate mixture of panic and pleasure as the steaming cum soaks its innards, and as though suddenly awakening from a trance, it resumes its efforts to escape and scrabbles at the ground. Lazily, the hound snatches the little creature's ankle in one hand, then slowly pulls it back and holds it tightly as more oily smoke boils out from between its teeth. Its softening penises drool leftover spunk into the dust as it rises to its feet, easily pulling the struggling Goblin up by the neck.");
			outputText("You realize you've begun salivating - a portion of your new friend's hunger is obviously spilling over into your own mind. "+((this.player.cor < 50)?"Aroused and more than somewhat unsettled,":"Aroused but reluctant to watch what comes next,")+" you decide that you can only play voyeur for so long, and leave the hellhound to its meal. So you turn away and head home. ");
			if (HHCFollower.getInstance().getMainQuestFlag() > 3) { 
				HHCFollower.getInstance().setMainQuestStage(HHCFollower.MAINQUEST_ReadyToBond);
				//Todo doNext(readyToBond);
			} else {
				doNext(camp.returnToCampUseOneHour);
			}
		}
	}
}
