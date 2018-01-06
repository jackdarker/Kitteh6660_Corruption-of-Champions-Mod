package classes.Scenes.Places.Ingnam 
{
	import classes.*;
	import classes.BodyParts.Butt;
	import classes.BodyParts.Hips;
	import classes.internals.*;
	import classes.GlobalFlags.*;
	
	public class Thief extends Monster
	{
		
				
		override public function defeated(hpVictory:Boolean):void
		{
			game.ingnam.thiefScene.winAgainstThief();
		}
		
		public function Thief() 
		{
			this.a = "the ";
			this.short = "thief";
			this.imageName = "thief";
			this.long = "The thief standing before you is a human.  His skin is fairly pale and his hair is brown.  He's wearing a set of leather armor and wielding a dagger in his right hand.  He's intent on knocking you out so he can take your gems.";
			// this.plural = false;
			this.createCock();
			createBreastRow(Appearance.breastCupInverse("flat"));
			this.ass.analLooseness = AssClass.LOOSENESS_NORMAL;
			this.ass.analWetness = AssClass.WETNESS_NORMAL;
			this.tallness = 5*12 + 5 + rand(4);
			this.hips.rating = Hips.RATING_BOYISH;
			this.butt.rating = Butt.RATING_TIGHT;
			this.skin.tone = "light";
			this.hair.color = "brown";
			this.hair.length = 4;
			initStrTouSpeInte(17, 16, 16, 17);
			initLibSensCor(20, 15, 20);
			this.weaponName = "knife";
			this.weaponVerb = "slash";
			this.weaponAttack = 4;
			this.armorName = "leather armor";
			this.lust = 25;
			this.temperment = TEMPERMENT_LOVE_GRAPPLES;
			this.level = 1;
			this.gems = 5+rand(10);
			this.drop = new WeightedDrop().add(weapons.DAGGER,1)
					.add(armors.LEATHRA,1)
					.add(null,8);
			checkMonster();
		}
		
	}

}