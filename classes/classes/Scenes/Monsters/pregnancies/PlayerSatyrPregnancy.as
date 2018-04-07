package classes.Scenes.Monsters.pregnancies 
{
	import classes.GlobalFlags.kGAMECLASS;
	import classes.Player;
	import classes.PregnancyStore;
	import classes.Scenes.PregnancyProgression;
	import classes.Scenes.VaginalPregnancy;
	import classes.internals.GuiOutput;
	
	/**
	 * Contains pregnancy progression and birth scenes for a Player impregnated by Satyr.
	 */
	public class PlayerSatyrPregnancy implements VaginalPregnancy
	{
		private var output:GuiOutput;
		
		/**
		 * Create a new Satyr pregnancy for the player. Registers pregnancy for Satyr.
		 * @param	pregnancyProgression instance used for registering pregnancy scenes
		 * @param	output instance for gui output
		 */
		public function PlayerSatyrPregnancy(pregnancyProgression:PregnancyProgression, output:GuiOutput) 
		{
			this.output = output;
			
			pregnancyProgression.registerVaginalPregnancyScene(PregnancyStore.PREGNANCY_PLAYER, PregnancyStore.PREGNANCY_SATYR, this);
		}
		
		/**
		 * @inheritDoc
		 */
		public function updateVaginalPregnancy():Boolean 
		{
			//TODO remove this once new Player calls have been removed
			var player:Player = kGAMECLASS.player;
			var displayedUpdate:Boolean = false;
			
			//Stage 1: 
			if (player.pregnancyIncubation === 150) {
				output.text("\n<b>You find that you're feeling quite sluggish these days; you just don't have as much energy as you used to.  You're also putting on weight.</b>\n");
				
				displayedUpdate = true;
			}
			
			//Stage 2: 
			if (player.pregnancyIncubation === 125) {
				output.text("\n<b>Your belly is getting bigger and bigger.  Maybe your recent urges are to blame for this development?</b>\n");
				
				displayedUpdate = true;
			}
			
			//Stage 3: 
			if (player.pregnancyIncubation === 100) {
				output.text("\n<b>You can feel the strangest fluttering sensations in your distended belly; it must be a pregnancy.  You should eat more and drink plenty of wine so your baby can grow properly.  Wait, wine...?</b>\n");
				
				displayedUpdate = true;
			}
			
			//Stage 4: 
			if (player.pregnancyIncubation === 75) {
				output.text("\n<b>Sometimes you feel a bump in your pregnant belly.  You wonder if it's your baby complaining about your moving about.</b>\n");
				
				displayedUpdate = true;
			}
			
			//Stage 5: 
			if (player.pregnancyIncubation === 50) {
				output.text("\n<b>With your bloating gut, you are loathe to exert yourself in any meaningful manner; you feel horny and hungry all the time...</b>\n");
				
				displayedUpdate = true;
				//temp min lust up +5
			}
			
			//Stage 6: 
			if (player.pregnancyIncubation === 30) {
				output.text("\n<b>The baby you're carrying constantly kicks your belly in demand for food and wine, and you feel sluggish and horny.  You can't wait to birth this little one so you can finally rest for a while.</b>\n");
				
				displayedUpdate = true;
				//temp min lust up addl +5
			}
			
			return displayedUpdate;
		}
		
		/**
		 * @inheritDoc
		 */
		public function vaginalBirth():void 
		{
			kGAMECLASS.plains.satyrScene.satyrBirth(true);
		}
	}
}
