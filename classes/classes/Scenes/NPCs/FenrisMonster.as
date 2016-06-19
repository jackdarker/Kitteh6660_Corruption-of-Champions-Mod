/**
 * ...
 * @author jk
 */

package classes.Scenes.NPCs
{
	import classes.*;
	import classes.GlobalFlags.kFLAGS;
	import classes.internals.*;

	public class FenrisMonster extends Monster
	{
		public function FenrisMonster() {
			//Todo: update stats before combat depending on progress
			var _monster:Monster = this;
			var _fenris:Fenris = Fenris.getInstance();
			_monster.a = "the ";
			_monster.short = "wolf";
			_monster.imageName = "hellhound"; //Todo: add image
			_monster.long = "You are fighting an anthro-wolf";
			if (_fenris.hasVagina()) {
					_monster.createVagina(_fenris.getVaginaVirgin(),VAGINA_WETNESS_NORMAL,_fenris.getVaginaSize());
					//createStatusEffect(StatusEffects.BonusVCapacity, 85, 0, 0, 0);
				}
			/*if (_fenris.getBreastSize() >= 1) {
					//Todo: add multiple
					_monster.createBreastRow(Appearance.breastCupInverse("D"));
			} else {*/
					_monster.createBreastRow(0);
			//}
			if (_fenris.getCockCount() >= 1) {
					//Todo: add multiple
					_monster.createCock(_fenris.getCockSize(), _fenris.getCockSize()/10, CockTypesEnum.DOG);
					_monster.balls = 2;
					_monster.ballSize = 2;
					_monster.cumMultiplier = 1;
			}
				
			_monster.ass.analLooseness = ANAL_LOOSENESS_TIGHT;
			_monster.ass.analWetness = ANAL_WETNESS_DRY;
				//this.createStatusEffect(StatusEffects.BonusACapacity,85,0,0,0);
			_monster.tallness = 70;
			_monster.hipRating = HIP_RATING_SLENDER;
			_monster.buttRating = BUTT_RATING_TIGHT;
			_monster.skinTone = "stone gray";
			_monster.hairColor = "dark gray";
			_monster.hairLength = 5;

			recalcBaseStats();
			recalcWeaponStats();
			recalcArmorStats();
			_monster.drop = new ChainedDrop().
						add(undergarments.C_LOIN,0.05).
						add(consumables.CANINEP,0.95);
			_monster.tailType = TAIL_TYPE_DOG;
			_monster.tailRecharge = 0;
			_monster.checkMonster();		
	}
	private function recalcBaseStats():void {
		level = Fenris.getInstance().level;
		//bonusHP = 75;
		lust = 1;
		lustVuln = .05;
		
		gems = 5 + rand(5);
		initStrTouSpeInte(50, 50, 55, 50);
		initLibSensCor(1, 1, 1);
			
	}
	//depending on equpped weapon of Fenris-NPC
	private function recalcWeaponStats():void {
		var _weapon:int = Fenris.getInstance().getEquippedItem(Fenris.ITEMSLOT_WEAPON);
		weaponName = Fenris.getInstance().getEquippedItemText(Fenris.ITEMSLOT_WEAPON,false);
		switch (_weapon) {
			case Fenris.WEAPON_KNIFE:
					weaponVerb="strike";
					weaponAttack = 10;
					break;
			default:
					weaponVerb="slash";
					weaponAttack = 4;
		}	
	}
	private function recalcArmorStats():void {
		var _underwear:int = Fenris.getInstance().getEquippedItem(Fenris.ITEMSLOT_UNDERWEAR);
		armorName = Fenris.getInstance().getEquippedItemText(Fenris.ITEMSLOT_UNDERWEAR,false);

		switch (_underwear) {
			case Fenris.UNDERWEAR_LOINCLOTH:
				armorDef = 4;
				armorPerk = "";
				armorValue = 10;
				break;
			default:
				armorDef = 4;
				armorPerk = "";
				armorValue = 3;
		}	
	}
	private function fenrisAttack():void {
			var damage:Number;
			var select:int = rand(2);
			var _oldweaponName:String = this.weaponName;
			var _oldweaponVerb:String = this.weaponVerb;
			var _oldweaponAttack:Number = this.weaponAttack;
			//return to combat menu when finished
			doNext(game.playerMenu);
			if (select == 0) {
				this.weaponName = "claws";
				this.weaponVerb = "claw";
				this.weaponAttack = 10;
				eAttack();
				this.weaponAttack = _oldweaponAttack;
				this.weaponName = _oldweaponName;
				this.weaponVerb = _oldweaponVerb;
			} else {
				eAttack();
			}
  
			//we dont need the following stuff ??    ----------------->
			/*
			//Blind dodge change
			if (findStatusEffect(StatusEffects.Blind) >= 0 && rand(3) < 1) {
				outputText(capitalA + short + " completely misses you with a blind attack!\n", false);
			}
			//Determine if dodged!
			else if (player.spe - spe > 0 && int(Math.random() * (((player.spe-spe) / 4) + 80)) > 80) {
				outputText("You nimbly dodge the wolfs attack!", false);
			}
			//Determine if evaded
			else if (player.findPerk(PerkLib.Evade) >= 0 && rand(100) < 10) {
				outputText("Using your skills at evading attacks, you anticipate and sidestep " + a + short + "'s attack.\n", false);
			}
			//("Misdirection"
			else if (player.findPerk(PerkLib.Misdirection) >= 0 && rand(100) < 10 && player.armorName == "red, high-society bodysuit") {
				outputText("Using Raphael's teachings, you anticipate and sidestep " + a + short + "' attacks.\n", false);
			}
			//Determine if cat'ed
			else if (player.findPerk(PerkLib.Flexibility) >= 0 && rand(100) < 6) {
				outputText("With your incredible flexibility, you squeeze out of the way of " + a + short + "", false);
			}
			//Determine damage - str modified by enemy toughness!
			else
			{
				damage = int((str + weaponAttack) - rand(player.tou/2) - player.armorDef/2);
				//No damage
				if (damage <= 0) {
					damage = 0;
					//Due to toughness or amor...
					if (rand(player.armorDef + player.tou) < player.armorDef) outputText("You absorb and deflect every " + weaponVerb + " with your " + player.armorName + ".", false);
					else outputText("You deflect and block every " + weaponVerb + " " + a + short + " throws at you.", false);
				}
				//Take Damage
				//Todo:add decription
				else outputText("You got hit. ", false);
				if (damage > 0) {
					if (lustVuln > 0 && (player.armor.name == "barely-decent bondage straps" || player.armor.name == "nothing")) {
						outputText("\n" + capitalA + short + " brushes against your exposed skin and jerks back in surprise, coloring slightly from seeing so much of you revealed. ", false);
						lust += 5 * lustVuln;
					}
				}
				if (damage > 0) damage = player.takeDamage(damage, true);
			}*/
			
			statScreenRefresh();
			outputText("\n", false);
			combatRoundOver();
		}

		override protected function performCombatAction():void
		{
			trace("Fenris Perform Combat Action Called");
			//Todo: add combat
			var select:Number = rand(1);
			trace("Selected: " + select);
			switch(select) {
				case 0:
					fenrisAttack();
					break;
				default:
					fenrisAttack();
					break;
			}
		}

		override public function defeated(hpVictory:Boolean):void
		{
			//if (findStatusEffect(StatusEffects.Sparring) >= 0) game.helFollower.PCBeatsUpSalamanderSparring();
			//else game.helScene.beatUpHel();
		}

		override public function won(hpVictory:Boolean, pcCameWorms:Boolean):void
		{
			if (pcCameWorms){
				outputText("\n\nFenris waits it out in stoic silence...");
				doNext(game.combat.endLustLoss);
			} else {
				//if (findStatusEffect(StatusEffects.Sparring) >= 0) game.helFollower.loseToSparringHeliaLikeAButtRapedChump();
				game.fenrisScene.loseToFenris();
			}
		}
	}
}