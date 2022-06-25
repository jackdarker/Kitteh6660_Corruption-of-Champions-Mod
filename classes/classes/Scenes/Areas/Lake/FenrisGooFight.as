/**
 * ...
 * @author jackdarker
 */
package classes.Scenes.Areas.Lake 
{
	import classes.*;
	import classes.Scenes.NPCs.Fenris;
	import classes.GlobalFlags.kFLAGS;
	import classes.Scenes.SceneLib;
	
	public class FenrisGooFight extends GooGirl
	{

		override protected function performCombatAction():void
		{
			//Todo: darn- those functions are private what now?
			//1/3 chance of base attack + bonus if in acid mode
			if ((findPerk(PerkLib.Acid) >= 0 && rand(3) == 0) || rand(3) == 0)
			//	super.gooGalAttack();
			//else if (rand(5) == 0) gooEngulph();
			//else if (rand(3) == 0) gooPlay();
			//else gooThrow();
			gooThrow();
		}
		protected function gooThrow():void
		{
			outputText("The girl reaches into her torso, pulls a large clump of goo out, and chucks it at you like a child throwing mud. The slime splatters on your chest and creeps under your " + player.armorName + ", tickling your skin like fingers dancing across your body. ", false);
			var damage:Number = 1;
			player.takePhysDamage(damage, true);
			player.dynStats("lus", 5 + rand(3) + player.sens / 10);
		}

		override public function defeated(hpVictory:Boolean):void
		{
			defeatGoo(hpVictory);
			
		}

		override public function won(hpVictory:Boolean, pcCameWorms:Boolean):void
		{
			if (pcCameWorms) {
				outputText("\n\nThe goo-girl seems confused but doesn't mind.");
				doNext(SceneLib.combat.endLustLoss);
			} else {
				looseToGoo(hpVictory);
			}
		}

		override public function teased(lustDelta:Number,isNotSilent:Boolean=true):void
		{
			if (lust <= 99) {
				if (lustDelta <= 0) outputText("\nThe goo-girl looks confused by your actions, as if she's trying to understand what you're doing.", false);
				else if (lustDelta < 13) outputText("\nThe curious goo has begun stroking herself openly, trying to understand the meaning of your actions by imitating you.", false);
				else outputText("\nThe girl begins to understand your intent. She opens and closes her mouth, as if panting, while she works slimy fingers between her thighs and across her jiggling nipples.", false);
			}
			else outputText("\nIt appears the goo-girl has gotten lost in her mimicry, squeezing her breasts and jilling her shiny " + skinTone + " clit, her desire to investigate you forgotten.", false);
			applyTease(lustDelta);
			//Todo: also teases Fenris at same time?
		}
		private function looseToGoo(hpVictory:Boolean):void {
			clearOutput();
			var x:Number = player.biggestCockIndex();
			outputText("Todo: get raped\n", false);
			player.slimeFeed();
			player.orgasm();
			player.dynStats("sen", 4);
			player.slimeFeed();
			SceneLib.combat.cleanupAfterCombatImpl();		
		}
		private function defeatGoo(hpVictory:Boolean):void
		{
			var _rapeFunc:Function =rapeFunc;
			var _Leave:Function =null;
			clearOutput();
			//Todo: Fenris-Level&Quest progression
			Fenris.getInstance().addXP(10);
			
			outputText("\n\n<b>What do you do to her, and if anything, which of your body parts do you use?</b>", false);
			EngineCore.simpleChoices( "You Rape", _rapeFunc,
			"Fenris rape", _rapeFunc,
			"Threesome", _rapeFunc,
			"",null,
			"Leave", SceneLib.combat.cleanupAfterCombatImpl);
		}
		private function rapeFunc():void
		{
			clearOutput();
			outputText("Todo: Fenris and you have your way with her.", false);
			player.orgasm();
			player.slimeFeed();
			doNext(SceneLib.combat.cleanupAfterCombatImpl);
		}
		public function FenrisGooFight() 
		{
			super(false);
		}
	}

}