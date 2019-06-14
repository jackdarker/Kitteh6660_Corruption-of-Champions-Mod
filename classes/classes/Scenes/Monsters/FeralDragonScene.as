/**
 * Created by aimozg on 04.01.14.
 */
package classes.Scenes.Monsters
{
import classes.*;
import classes.BodyParts.LowerBody;
import classes.BodyParts.Tail;
import classes.GlobalFlags.kFLAGS;
import classes.Items.Armors.LustyMaidensArmor;
import classes.Scenes.UniqueSexScenes;

use namespace CoC;

	public class FeralDragonScene extends BaseContent
	{
		public var uniquuuesexscene:UniqueSexScenes = new UniqueSexScenes();
		
		public function FeralDragonScene()
		{
		}
		
		public function playerVictory(hpVictory:Boolean):void {
			clearOutput();
			menu();
			if(!hpVictory) {
				outputText("You smile in satisfaction as " + monster.a + monster.short + " gets distraced by its own arousal.");
			} else {
				outputText("Growling angrily at you " + monster.a + " wounded "+ monster.short + " starts to retreat by unfolding its large, leathery wings and taking of into the air.");
			}
			
			//todo sextime
			addButton(14, "Leave", cleanupAfterCombat);
			
		}
		//monster is not in the mood and will leave
		public function monsterVictory(hpVictory:Boolean, pcCameWorms:Boolean):void {
			if (doSFWloss()) return;
			outputText("The " + monster.short +" takes no further interest in you and leaves the battlefield.");
			menu();
			addButton(4, "Leave", cleanupAfterCombat);
		}
		//monster is in the mood
		public function monsterVictoryRape(hpVictory:Boolean, pcCameWorms:Boolean):void {
			if (doSFWloss()) return;
			outputText("The " + monster.short +" takes no interest in you and leaves the battlefield.");
			//Todo sexytime
			menu();
			addButton(4, "Leave", cleanupAfterCombat);
		}
		
		public function dragonEncounter():void {
			clearOutput();
			outputText("While you are moving through this area, you stumbled right into a large creature.\n");
			startCombat(new FeralDragon());
			return;
		}
	}
}