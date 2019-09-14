package classes.Scenes.Areas.Forest 
{
import classes.*;
import classes.BodyParts.Butt;
import classes.BodyParts.Hips;
import classes.BodyParts.Tail;
import classes.GlobalFlags.kACHIEVEMENTS;
import classes.GlobalFlags.kFLAGS;
import classes.Scenes.Places.HeXinDao;
import classes.Scenes.SceneLib;
import classes.internals.*;
	
public class TentacleBeastRaging extends TentacleBeast
{
	private function tentaclePhysicalAttackWrath():void {
		outputText("The shambling horror throws its tentacles at you with a crazy and uncontroled manner.\n");
		var temp:int = int(((str + weaponAttack) * 2) - Math.random()*(player.tou) - player.armorDef);
		if (temp < 0) temp = 0;
		this.wrath -= 200;
		//Miss
		if(temp == 0 || (player.spe - spe > 0 && int(Math.random()*(((player.spe-spe)/4)+80)) > 80)) {
			outputText("However, you quickly evade the clumsy efforts of the abomination to strike you.");
		}
		//Hit
		else {
			outputText("The tentacles crash upon your body mercilessly. ");
			player.takePhysDamage(temp, true);
		}
	}
	
		override protected function performCombatAction():void
		{
			this.wrath += 100;
			if (this.wrath >= 200) tentaclePhysicalAttackWrath();
			else  super.performCombatAction();
		}
		
		override public function defeated(hpVictory:Boolean):void
		{
			super.defeated(hpVictory);  
			//if there was no action taken by super, we will end up here
			if (this.HP <= 0) SceneLib.forest.tentacleBeastScene.choiceofaction();
			else cleanupAfterCombat();
		}
		
		public function TentacleBeastRaging() 
		{
			super.setupMonster();
			this.short = "raging tentacle beast";
			this.long = "You see the massive, shambling and growling angry form of the tentacle beast before you.  Appearing as a large shrub, it shifts its bulbous mass and reveals a collection of unnaturaly twisted thorny tendrils and deformed cephalopodic limbs.";
			initStrTouSpeInte(31, 25, 10, 20);
			initWisLibSensCor(15, 90, 20, 100);
			this.weaponAttack = 3;
			this.armorDef = 5;
			this.armorMDef = 0;
			this.bonusHP = 40;
			this.bonusWrath = 100;
			this.gems = rand(7)+3;
			this.createPerk(PerkLib.EnemyFeralType, 0, 0, 0, 0);
			checkMonster();
		}
		
	}

}