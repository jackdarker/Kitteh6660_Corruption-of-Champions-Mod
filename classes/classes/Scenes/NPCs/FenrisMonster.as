/**
 * ...
 * @author jackdarker
 */

package classes.Scenes.NPCs
{
	import classes.*;
	import classes.Scenes.SceneLib;
	import classes.VaginaClass;
	import classes.AssClass;
	import classes.BodyParts.Butt;
	import classes.BodyParts.Hips;
	import classes.BodyParts.LowerBody;
	import classes.BodyParts.Tail;
	import classes.GlobalFlags.kFLAGS;
	import classes.internals.*;

	public class FenrisMonster extends Monster
	{
		private var _fenris:Fenris;
	public function FenrisMonster() {
			//Todo: update stats before combat depending on progress
			var _monster:Monster = this;
			_fenris = Fenris.getInstance();
			_monster.a = "the ";
			_monster.short = "wolf";
			//_monster.imageName = "hellhound"; //Todo: add image
			_monster.long = _fenris.descrwithclothes; // "You are fighting an anthro-wolf";
			if (_fenris.hasVagina()) {
					_monster.createVagina(_fenris.getVaginaVirgin(),classes.VaginaClass.WETNESS_NORMAL,_fenris.getVaginaSize());
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
				_monster.balls = _fenris.getBallCount();
				_monster.ballSize = _fenris.getBallSize();
				_monster.cumMultiplier = 1;
		}
			
		this.createBreastRow();
		this.createBreastRow();
		this.createBreastRow();
		this.ass.analLooseness = AssClass.LOOSENESS_NORMAL;
		this.ass.analWetness = AssClass.WETNESS_NORMAL;
		this.tallness = 70;
		this.hips.type = Hips.RATING_AVERAGE;
		this.butt.type = Butt.RATING_AVERAGE + 1;
		this.lowerBody = LowerBody.DOG;
		this.skin.growFur({color:"black"});
		_monster.hairColor = "dark gray";
		_monster.hairLength = 5;

		recalcBaseStats();
		recalcWeaponStats();
		recalcArmorStats();
		_monster.drop = new ChainedDrop().
					add(undergarments.C_LOIN,0.05).
					add(consumables.CANINEP,0.95);
		this.tailType = Tail.DOG;
		_monster.tailRecharge = 0;
		_monster.checkMonster();		
		
	}
	//adjust the Enemy-Level
	private function recalcBaseStats():void {
		var _fenris:Fenris = Fenris.getInstance();
		level = Math.round( (player.level +  (_fenris.getLevel() -player.level)/4)* 10)/10; //autolevel??
		initStrTouSpeInte(_fenris.getStrength(), _fenris.getThoughness(), _fenris.getSpeed(), _fenris.getIntelligence());
		initWisLibSensCor(10/*TODO*/,_fenris.getLibido(), _fenris.getLibido(), _fenris.getCorruption());
		bonusHP = level*10;
		lust = Math.min(70,Fenris.getInstance().getLust());
		lustVuln = 0.01*_fenris.getLibido();		
		gems = 5 + rand(level*5);	
			
	}
	//depending on equpped weapon of Fenris-NPC
	private function recalcWeaponStats():void {
		var _weapon:int = Fenris.getInstance().getEquippedItem(Fenris.ITEMSLOT_WEAPON);
		weaponName = Fenris.getInstance().getEquippedItemText(Fenris.ITEMSLOT_WEAPON,false);
		switch (_weapon) {
			case Fenris.WEAPON_KNIFE:
					weaponVerb="cut";
					weaponAttack = 4;
					break;
			case Fenris.WEAPON_PIPE:
					weaponVerb="smash";
					weaponAttack = 5;
					break;
			default:
					weaponVerb="slash";
					weaponAttack = 3;
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
	//Todo howls to make himself stronger, regenerate fatigue, maybe call supportife hellhounds
	private function fenrisHowlOfDominance():void
	{
		HowlCooldown = 5;
		outputText("Annoyed by your attempts to defeat him, he raises his wolfen head and calls a terrifiying howl.\n", false);
		addHP(this.maxHP()*0.33);
		fatigue += 10;
	}
	//
	private var PentacleState:Number = 0;	//shows the state of the pentacles:
	//0 retracted
	//1 try to grab the player
	//2 pc got grabbed
	//4 molested by 3 pentacles
	//6 molested by 4 pentacles
	//8 molested by 5 pentacles
	//100 pc escaped
	//99..80 cooldown before grabbing again 
	
	//returns true pentacles were used and should skip further attacks
	private function fenrisPentacleGrapple():Boolean { 
		//fenris only has pentacles if corrupted
		var _pentacles:int = _fenris.getPentacleCockCount();
		
		//cooldown for 5 rounds or less
		if (PentacleState >= 80 && PentacleState <= 100) {
			PentacleState = PentacleState-4; 
			return false;
		}
		
		if (_pentacles > 0 && lust > 50) {}
		else { return false; } //no pantacles or lust to low - skip
		//Todo if fenris is aroused he will unleash his pentacles, try to grab  and pleasure player
		
		if (PentacleState >= 3 && PentacleState <=5 ) {
			outputText("You are molested by the pentacles.\n", false);
			player.dynStats("lus", 5 + player.sens / 10); // Lust++
		}
		//just grabbed the player
		if (PentacleState == 2) {
			if(false) {
			//TODO if (player.hasStatusEffect(StatusEffects.bound)) {
				outputText("The pentacles increase their effort to entwine you.\n", false);
				if (_pentacles >= 6) {
					outputText("Two of them slip around your waist and upper body while another set trys to constrict your arms.\n", false);
					PentacleState = PentacleState+3;
				}else if (_pentacles >= 4) {
					outputText("Two of them slip around your waist and upper body while the others try to choke you.\n", false);
					PentacleState = PentacleState+2;
				}else if (_pentacles >= 2) {
					outputText("Both of them slip around your waist and upper body.\n", false);
					PentacleState = PentacleState+1;
				}
				player.dynStats("lus", 5 + player.sens / 10);
			} else {
				PentacleState = 1;
			}
			
		}
		//try to grab player
		if (PentacleState == 1) {
			if(false) {
			//TODO if (player.hasStatusEffect(StatusEffects.bound)) {
				//Success Todo
				if (false) {
					outputText("In an impressive display of gymnastics, you dodge, duck, dip, dive, and roll away from the shower of grab-happy arms trying to hold you. Your instincts tell you that this was a GOOD thing.\n", false);
				}
				//Fail
				else {
					outputText("While you attempt to avoid the onslaught of pseudopods, one catches you around your " + player.foot() + " and drags you to the ground. You attempt to reach for it to pull it off only to have all of the other tentacles grab you in various places and immobilize you in the air. You are trapped and helpless!!!\n\n", false);
					player.dynStats("lus", (8+player.sens/20));
					player.createStatusEffect(StatusEffects.bound, 0, 0, 0, 0);
					PentacleState = 2;
				}
			}
		}
		//unleash tentacles
		if (PentacleState < 1) {
			outputText("The werewolf-beast twists in agony. You think you made a hit but with terror you see " + _pentacles + " tentacles bursting from his back. With ridiciolous speed, they try to entwine you.\n", false);
			PentacleState = 1;
		}
		return true;
	}

	private var HowlCooldown:Number=3;
	
	override protected function performCombatAction():void
	{
		var damage:Number;
		
		if (_fenris.getPentacleCockCount() >= 2 && lust > 50 ) {
			fenrisPentacleGrapple(); //corrupted fenris will try to grab you if horny
		} else if (this.HPRatio() < 0.3 && HowlCooldown<=0 && rand(100) > 70) {
			fenrisHowlOfDominance(); 
		} else {			
			var select:int = rand(2);
			var _oldweaponName:String = this.weaponName;
			var _oldweaponVerb:String = this.weaponVerb;
			var _oldweaponAttack:Number = this.weaponAttack;
			//return to combat menu when finished
			//TODO? doNext(game.playerMenu);
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
			//Set flags for rounds
			if (hasStatusEffect(StatusEffects.Round)) {
				createStatusEffect(StatusEffects.Round,2,0,0,0);
			} else addStatusValue(StatusEffects.Round, 1, 1);
			if (HowlCooldown > 0 ) HowlCooldown = HowlCooldown - 1;
			//statScreenRefresh();
			outputText("\n", false);
			//TODO ?combatRoundOver();
	}
	//TODO override public function handleStruggling(Struggling:Boolean):Boolean
	//{
		//var _Result:Boolean  = Struggling;
		//clearOutput();
		//Todo better description
		//Struggle:
		//if (Struggling) {
			//outputText("You struggle against thight bindings of the tentacles.");
			//Success
			//if (rand(20) + player.str / 20  >= 12) {
				//outputText("  Summoning up reserves of strength you didn't know you had, you wrench yourself free of the pentacles, pushing them away.\n\n");
				//player.removeStatusEffect(StatusEffects.bound);
				//PentacleState = 100; //Start cooldown
				//doAI();
			//} else {//Failure  ++LUST
				//outputText("  Despite your valiant efforts, the pentacles didnt loose their grip on you.\n");
				//game.dynStats("lus", 5 + player.sens / 10);
				//combatRoundOver();
			//}
		//} else {
			//clearOutput();
			//outputText("You just wait to see where this leads too.");
			//outputText("\n\nThe bindings intensifys.");		
			//game.dynStats("lus", 5 + player.sens / 10);
			//combatRoundOver();		
		//}
//
		//return _Result;
	//}
	override public function defeated(hpVictory:Boolean):void
	{
		if (hasStatusEffect(StatusEffects.Sparring)) { }  //Todo
		else {}
		SceneLib.fenrisScene.winAgainstFenris();
		
	}

	override public function won(hpVictory:Boolean, pcCameWorms:Boolean):void
	{
		if (hasStatusEffect(StatusEffects.Sparring)) { }  //Todo
		else {}
		SceneLib.fenrisScene.loseToFenris();
	}
}}