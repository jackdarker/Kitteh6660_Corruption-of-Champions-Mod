package classes.Scenes.Monsters
{
import classes.*;
import classes.BodyParts.Butt;
import classes.BodyParts.Hips;
import classes.BodyParts.Wings;
import classes.BodyParts.Hair;
import classes.BodyParts.Arms;
import classes.BodyParts.Eyes;
import classes.BodyParts.UnderBody;
import classes.BodyParts.Face;
import classes.BodyParts.Tongue;
import classes.BodyParts.Tail;
import classes.BodyParts.Skin;
import classes.GlobalFlags.kFLAGS;
import classes.Scenes.SceneLib;
import classes.internals.*;

	/**
	 * a western (non-anthro) dragon with wings, 2 hindlegs, 2 arms
	 * idea: the dragon wont rape you except certain conditions
	 * - you have dragon or reptilian features and have a minimum sized vag
	 * - you have a centaur body and are in heat
	 * - possible vore if you are a small critter?
	 * 
	 * player rape option:
	 * - female dom if you have big vag
	 * - centaure male doggystyle buttrape
	 * - dragon slit docking for males
	 * 
	 * @author jk
	 */
	public class FeralDragon extends Monster
	{
		public function FeralDragon(noInit:Boolean=false)
		{
			if (noInit) return;
			this.a = "the ";
			this.short = "dragon";
			this.imageName = "feraldragon";	//Todo male-female-herm
			this.long = "It's obvious that this beast is a 4-legged reptile with large leathery wings and a long pointed tail. There is a spark of intelligence in its glooming eyes but there are also sharp teeths and curved claws that mark this mystical beeing as predator.\n";
			// this.plural = false;
			this.level = Math.max(20, 15 + rand(this.player.level / 2));	//scales with player

			this.createCock(rand(2) + 11, rand(1)+2.5, CockTypesEnum.DRAGON);
			this.balls = 0;	//internal
			//this.ballSize = 5;
			createBreastRow(0);
			this.ass.analLooseness = AssClass.LOOSENESS_VIRGIN;
			this.ass.analWetness = AssClass.WETNESS_NORMAL;
			this.tallness = rand(100) + 125;
			this.hips.type = Hips.RATING_BOYISH;
			this.butt.type = Butt.RATING_TIGHT;
			this.skinTone = "purple";
			this.hairColor = "black";
			this.hairLength = 5;	//Todo No hair
			initStrTouSpeInte(120, 90, 100, 90);
			initWisLibSensCor(90, 50, 35, 30);
			this.weaponAttack = 36;
			this.armorDef = 54;
			this.armorMDef = 54;
			this.bonusHP = 1500;
			this.weaponName = "claws";
			this.weaponVerb = "claw-slash";
			this.armorName = "leathery scales";
			this.lust = 0;
			this.temperment = TEMPERMENT_AVOID_GRAPPLES;
			this.gems = rand(this.level*1) + 5;
			this.drop = new WeightedDrop().
					add(consumables.REPTLUM,3).
					add(consumables.SNAKOIL,3);
			this.wings.type = Wings.DRACONIC_LARGE;
			this.lustVuln = 0;
			this.createPerk(PerkLib.Resolute, 0, 0, 0, 0);
			this.createPerk(PerkLib.EnemyFeralType, 0, 0, 0, 0);
			this.createPerk(PerkLib.RefinedBodyI, 0, 0, 0, 0);
			this.createPerk(PerkLib.TankI, 0, 0, 0, 0);
			checkMonster();
		}
		override protected function performCombatAction():void
		{
			if (hasStatusEffect(StatusEffects.StunCooldown)) {
				addStatusValue(StatusEffects.StunCooldown, 1, -1);
				if (statusEffectv1(StatusEffects.StunCooldown) <= 0) removeStatusEffect(StatusEffects.StunCooldown);
			}
			var choice:Number = rand(5);
			if ((choice >= 4 || (choice>=1 && this.hp100<50))&& !hasStatusEffect(StatusEffects.StunCooldown)) heavyAttack();
			else Attack();
			
		}
		//Todo attacks are copied over from ember - make own
		private function heavyAttack():void {
			outputText("The " + short + " bares his teeth and releases a deafening roar; a concussive blast of force heads straight for you!  ");
			if (player.getEvasionRoll()) {
				outputText("You quickly manage to jump out of the way and watch in awe as the blast gouges into the ground you were standing on mere moments ago.");
			}
			outputText("Try as you might, you can't seem to protect yourself; and the blast hits you like a stone, throwing you to the ground. ");
				if(player.findPerk(PerkLib.Resolute) < 0) {
					outputText("Your head swims - it'll take a moment before you can regain your balance. ");
					player.createStatusEffect(StatusEffects.Stunned,0,0,0,0);
				}
				createStatusEffect(StatusEffects.StunCooldown,2,0,0,0);
		}
		
		//Basic attack, average damage, average accuracy
		private function Attack():void {
			outputText("With a growl, the dragon lashes out in a ferocious splay-fingered slash, "+ "his"+ " claws poised to rip into your flesh.  ");
			//Blind dodge change
			if(hasStatusEffect(StatusEffects.Blind) && rand(2) == 0) {
				outputText(capitalA + short + " completely misses you with a blind attack!");
			}
			//Miss/dodge
			else if(player.getEvasionRoll()) outputText("You dodge aside at the last second and Ember's claws whistle past you.");
			else {
				var damage:Number = 0;
				if (wrath >= 100) {
					wrath -= 100;
					damage += (((str + weaponAttack) * 2) - rand(player.tou) - player.armorDef);
				}
				else damage += ((str + weaponAttack) - rand(player.tou) - player.armorDef);
				if (this.level >= 1) damage += (1 + (this.level * 0.1));
				if(damage <= 0) outputText("The dragons claws scrape noisily but harmlessly off your [armor].");
				else {
					outputText("The dragons claws rip into you, leaving stinging wounds. ");
					damage = player.takePhysDamage(damage, true);
				}
			}
		}
		override public function defeated(hpVictory:Boolean):void
		{
			SceneLib.feralDragonScene.playerVictory(hpVictory);
		}

		override public function won(hpVictory:Boolean, pcCameWorms:Boolean):void
		{
			if(this.lustPercent()<50) {
				SceneLib.feralDragonScene.monsterVictory(hpVictory, pcCameWorms);
			} else {
				SceneLib.feralDragonScene.monsterVictoryRape(hpVictory, pcCameWorms);
			}
		}
		
	}

}