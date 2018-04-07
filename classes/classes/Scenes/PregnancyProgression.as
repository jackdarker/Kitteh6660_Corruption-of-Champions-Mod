package classes.Scenes 
{
	import classes.*;
	import classes.GlobalFlags.*;
	import classes.Items.ArmorLib;
	import classes.internals.PregnancyUtils;
	import flash.utils.Dictionary;
	import classes.internals.LoggerFactory;
	import mx.logging.ILogger;
	
	public class PregnancyProgression extends BaseContent
	{
		private static const LOGGER:ILogger = LoggerFactory.getLogger(PregnancyProgression);
		
		/**
		 * This sensing variable is used by tests to detect if
		 * the vaginal birth code has been called. This is used for pregnancies
		 * that do not provide any other means of detection (e.g. counter variables).
		 */
		public var senseVaginalBirth:Vector.<int>;
		
		/**
		 * Map pregnancy type to the class that contains the matching scenes.
		 * Currently only stores player pregnancies.
		 */
		private var vaginalPregnancyScenes:Dictionary;
		
		public function PregnancyProgression() {
			this.senseVaginalBirth = new Vector.<int>();
			this.vaginalPregnancyScenes = new Dictionary();
		}
		
		/**
		 * Record a call to a vaginal birth function.
		 * This method is used for testing.
		 * @param	pregnancyType to record
		 */
		public function detectVaginalBirth(pregnancyType:int):void {
			senseVaginalBirth.push(pregnancyType);
		}
		
		/**
		 * Register a scene for vaginal pregnancy. The registered scene will be used for pregnancy
		 * progression and birth.
		 * <b>Note:</b> Currently only the player is supported as the mother.
		 * 
		 * @param	pregnancyTypeMother The creature that is the mother
		 * @param	pregnancyTypeFather The creature that is the father
		 * @param	scenes The scene to register for the combination
		 * @return true if an existing scene was overwritten
		 * @throws ArgumentError If the mother is not the player
		 */
		public function registerVaginalPregnancyScene(pregnancyTypeMother:int, pregnancyTypeFather:int, scenes:VaginalPregnancy):Boolean {
			if (pregnancyTypeMother !== PregnancyStore.PREGNANCY_PLAYER) {
				LOGGER.error("Currently only the player is supported as mother");
				throw new ArgumentError("Currently only the player is supported as mother");
			}
			
			var previousReplaced:Boolean = false;
			
			if (hasRegisteredVaginalScene(pregnancyTypeMother, pregnancyTypeFather)) {
				previousReplaced = true;
				LOGGER.warn("Vaginal scene registration for mother {0}, father {1} will be replaced.", pregnancyTypeMother, pregnancyTypeFather);
			}
			
			vaginalPregnancyScenes[pregnancyTypeFather] = scenes;
			LOGGER.debug("Mapped pregancy scene {0} to mother {1}, father {2}", scenes, pregnancyTypeMother, pregnancyTypeFather);
			
			return previousReplaced;
		}
		
		/**
		 * Check if the given vaginal pregnancy combination has a registered scene.
		 * @param	pregnancyTypeMother The creature that is the mother
		 * @param	pregnancyTypeFather The creature that is the father
		 * @return true if a scene is registered for the combination
		 */
		public function hasRegisteredVaginalScene(pregnancyTypeMother:int, pregnancyTypeFather:int):Boolean {
			// currently only player pregnancies are supported
			if (pregnancyTypeMother !== PregnancyStore.PREGNANCY_PLAYER) {
				return false;
			}
			
			return pregnancyTypeFather in vaginalPregnancyScenes;
		}
		
		/**
		 * Update the current vaginal and anal pregnancies (if any). Updates player status and outputs messages related to pregnancy or birth. 
		 * @return true if the output needs to be updated
		 */
		public function updatePregnancy():Boolean
		{
			var displayedUpdate:Boolean = false;
			var pregText:String = "";
			if ((player.pregnancyIncubation <= 0 && player.buttPregnancyIncubation <= 0) ||
				(player.pregnancyType === 0 && player.buttPregnancyType === 0)) {
				return false;
			}

			displayedUpdate = cancelHeat();
			
			if (player.pregnancyIncubation > 0 && player.pregnancyIncubation < 2) player.knockUpForce(player.pregnancyType, 1);
			//IF INCUBATION IS VAGINAL
			if (player.pregnancyIncubation > 1) {
				displayedUpdate = updateVaginalPregnancy(displayedUpdate);
			}
			//IF INCUBATION IS ANAL
			if (player.buttPregnancyIncubation > 1) {
				displayedUpdate = updateAnalPregnancy(displayedUpdate);
			}
			
			amilyPregnancyFailsafe();
			
			if (player.pregnancyIncubation === 1) {
				displayedUpdate = updateVaginalBirth(displayedUpdate);
			}
			
			displayedUpdate = updateAnalBirth(displayedUpdate);

			return displayedUpdate;
		}
		
		private function cancelHeat():Boolean 
		{
			if (player.inHeat) {
				outputText("\nYou calm down a bit and realize you no longer fantasize about getting fucked constantly.  It seems your heat has ended.\n");
				//Remove bonus libido from heat
				dynStats("lib", -player.statusEffectv2(StatusEffects.Heat));
				
				if (player.lib < 10) {
					player.lib = 10;
				}
				
				statScreenRefresh();
				player.removeStatusEffect(StatusEffects.Heat);
				
				return true;
			}
			
			return false;
		}
		
		private function updateVaginalPregnancy(displayedUpdate:Boolean):Boolean
		{
			if (hasRegisteredVaginalScene(PregnancyStore.PREGNANCY_PLAYER, player.pregnancyType)) {
				var scene:VaginalPregnancy = vaginalPregnancyScenes[player.pregnancyType] as VaginalPregnancy;
				LOGGER.debug("Updating pregnancy for mother {0}, father {1} by using class {2}", PregnancyStore.PREGNANCY_PLAYER, player.pregnancyType, scene);
				return scene.updateVaginalPregnancy();
			} else {
				LOGGER.debug("Could not find a mapped vaginal pregnancy for mother {0}, father {1} - using legacy pregnancy progression", PregnancyStore.PREGNANCY_PLAYER, player.pregnancyType);;
			}
			
			return displayedUpdate;
		}
		
		private function updateAnalPregnancy(displayedUpdate:Boolean):Boolean 
		{
			if (player.buttPregnancyType === PregnancyStore.PREGNANCY_FROG_GIRL) {
				if (player.buttPregnancyIncubation === 8) {
					//Egg Maturing
					outputText("\nYour gut churns, and with a squelching noise, a torrent of transparent slime gushes from your ass.  You immediately fall to your knees, landing wetly amidst the slime.  The world around briefly flashes with unbelievable colors, and you hear someone giggling.\n\nAfter a moment, you realize that it’s you.");
					//pussy:
					if (player.hasVagina()) outputText("  Against your [vagina], the slime feels warm and cold at the same time, coaxing delightful tremors from your [clit].");
					//[balls:
					else if (player.balls > 0) outputText("  Slathered in hallucinogenic frog slime, your balls tingle, sending warm pulses of pleasure all the way up into your brain.");
					//[cock:
					else if (player.hasCock()) outputText("  Splashing against the underside of your " + player.multiCockDescriptLight() + ", the slime leaves a warm, oozy sensation that makes you just want to rub [eachCock] over and over and over again.");
					//genderless: 
					else outputText("  Your asshole begins twitching, aching for something to push through it over and over again.");
					outputText("  Seated in your own slime, you moan softly, unable to keep your hands off yourself.");
					dynStats("lus=", player.maxLust(), "scale", false);
					displayedUpdate = true;
				}
			}
			//Pregnancy 4 Satyrs
			if (player.buttPregnancyType === PregnancyStore.PREGNANCY_SATYR) {
				//Stage 1: 
				if (player.buttPregnancyIncubation === 150) {
					outputText("\n<b>You find that you're feeling quite sluggish these days; you just don't have as much energy as you used to.  You're also putting on weight.</b>\n");
					displayedUpdate = true;
				}
				//Stage 2: 
				if (player.buttPregnancyIncubation === 125) {
					outputText("\n<b>Your belly is getting bigger and bigger.  Maybe your recent urges are to blame for this development?</b>\n");
					displayedUpdate = true;
				}
				//Stage 3: 
				if (player.buttPregnancyIncubation === 100) {
					outputText("\n<b>You can feel the strangest fluttering sensations in your distended belly; it must be a pregnancy.  You should eat more and drink plenty of wine so your baby can grow properly.  Wait, wine...?</b>\n");
					displayedUpdate = true;
				}
				//Stage 4: 
				if (player.buttPregnancyIncubation === 75) {
					outputText("\n<b>Sometimes you feel a bump in your pregnant belly.  You wonder if it's your baby complaining about your moving about.</b>\n");
					displayedUpdate = true;
				}
				//Stage 5: 
				if (player.buttPregnancyIncubation === 50) {
					outputText("\n<b>With your bloating gut, you are loathe to exert yourself in any meaningful manner; you feel horny and hungry all the time...</b>\n");
					displayedUpdate = true;
					//temp min lust up +5
				}
				//Stage 6: 
				if (player.buttPregnancyIncubation === 30) {
					outputText("\n<b>The baby you're carrying constantly kicks your belly in demand for food and wine, and you feel sluggish and horny.  You can't wait to birth this little one so you can finally rest for a while.</b>\n");
					displayedUpdate = true;
					//temp min lust up addl +5
				}
			}
			//DRIDAH BUTT Pregnancy!
			if (player.buttPregnancyType === PregnancyStore.PREGNANCY_DRIDER_EGGS) {	
				if (player.buttPregnancyIncubation === 199) {
					outputText("\n<b>After your session with the drider, you feel so nice and... full.  There is no outward change on your body, aside from the egg-packed bulge of your belly, but your " + player.assholeDescript() + " tingles slightly and leaks green goop from time to time. Hopefully it's nothing to be alarmed about.</b>\n");
					displayedUpdate = true;
				}
				if (player.buttPregnancyIncubation === 180) {
					outputText(images.showImage("cDrider-loss-butt"));
					outputText("\n<b>A hot flush works its way through you, and visions of aroused driders quickly come to dominate your thoughts.  You start playing with a nipple while you lose yourself in the fantasy, imagining being tied up in webs and packed completely full of eggs, stuffing your belly completely with burgeoning spheres of love.  You shake free of the fantasy and notice your hands rubbing over your slightly bloated belly.  Perhaps it wouldn't be so bad?</b>\n");
					dynStats("lib", 1, "sen", 1, "lus", 20);
					displayedUpdate = true;				
				}
				if (player.buttPregnancyIncubation === 120) {
					outputText("\n<b>Your belly is bulging from the size of the eggs growing inside you and gurgling just about any time you walk.  Green goo runs down your " + player.legs() + " frequently, drooling out of your pregnant asshole.</b>\n");
					displayedUpdate = true;
				}
				if (player.buttPregnancyIncubation === 72) {
					outputText("\n<b>The huge size of your pregnant belly constantly impedes your movement, but the constant squirming and shaking of your unborn offspring makes you pretty sure you won't have to carry them much longer.");
					outputText("</b>\n");
					displayedUpdate = true;
				}
			}
			//Bee Egg's in butt pregnancy
			if (player.buttPregnancyType === PregnancyStore.PREGNANCY_BEE_EGGS) {
				if (player.buttPregnancyIncubation === 36) {
					outputText("<b>\nYou feel bloated, your bowels shifting uncomfortably from time to time.</b>\n");
					displayedUpdate = true;
				}
				if (player.buttPregnancyIncubation === 20) {
					outputText("<b>\nA honey-scented fluid drips from your rectum.</b>  At first it worries you, but as the smell fills the air around you, you realize anything with such a beautiful scent must be good.  ");
					if (player.cockTotal() > 0) outputText("The aroma seems to permeate your very being, slowly congregating in your ");
					if (player.cockTotal() === 1) {
						outputText(player.cockDescript(0));
						if (player.countCocksOfType(CockTypesEnum.HORSE) === 1) outputText(", each inhalation making it bigger, harder, and firmer.  You suck in huge lungfuls of air, until your " + player.cockDescript(0) + " is twitching and dripping, the flare swollen and purple.  ");
						if (player.dogCocks() === 1) outputText(", each inhalation making it thicker, harder, and firmer.  You suck in huge lungfuls of air, desperate for more, until your " + player.cockDescript(0) + " is twitching and dripping, its knot swollen to the max.  ");
						if (player.countCocksOfType(CockTypesEnum.HUMAN) === 1) outputText(", each inhalation making it bigger, harder, and firmer.  You suck in huge lungfuls of air, until your " + player.cockDescript(0) + " is twitching and dripping, the head swollen and purple.  ");
						//FAILSAFE FOR NEW COCKS
						if (player.countCocksOfType(CockTypesEnum.HUMAN) === 0 && player.dogCocks() === 0 && player.countCocksOfType(CockTypesEnum.HORSE) === 0) outputText(", each inhalation making it bigger, harder, and firmer.  You suck in huge lungfuls of air until your " + player.cockDescript(0) + " is twitching and dripping.  ");
					}
					if (player.cockTotal() > 1) outputText("groin.  Your " + player.multiCockDescriptLight() + " fill and grow with every lungful of the stuff you breathe in.  You suck in great lungfuls of the tainted air, desperate for more, your cocks twitching and dripping with need.  ");
					outputText("You smile knowing you couldn't stop from masturbating if you wanted to.\n");
					dynStats("int", -.5, "lus", 500);
					displayedUpdate = true;
				}
			}
			//Sand Traps in butt pregnancy
			if (player.buttPregnancyType === PregnancyStore.PREGNANCY_SANDTRAP || player.buttPregnancyType === PregnancyStore.PREGNANCY_SANDTRAP_FERTILE) {
				if (player.buttPregnancyIncubation === 36) {
					//(Eggs take 2-3 days to lay)
					outputText("<b>\nYour bowels make a strange gurgling noise and shift uneasily.  You feel ");
					if (player.buttPregnancyType === PregnancyStore.PREGNANCY_SANDTRAP_FERTILE) outputText(" bloated and full; the sensation isn't entirely unpleasant.");
					else {
						outputText("increasingly empty, as though some obstructions inside you were being broken down.");
						player.buttKnockUpForce(); //Clear Butt Pregnancy
					}
					outputText("</b>\n");
					displayedUpdate = true;
				}
				if (player.buttPregnancyIncubation === 20) {
					//end eggpreg here if unfertilized
					outputText("\nSomething oily drips from your sphincter, staining the ground.  You suppose you should feel worried about this, but the overriding emotion which simmers in your gut is one of sensual, yielding calm.  The pressure in your bowels which has been building over the last few days feels right somehow, and the fact that your back passage is dribbling lubricant makes you incredibly, perversely hot.  As you stand there and savor the wet, soothing sensation a fantasy pushes itself into your mind, one of being on your hands and knees and letting any number of beings use your ass, of being bred over and over by beautiful, irrepressible insect creatures.  With some effort you suppress these alien emotions and carry on, trying to ignore the oil which occasionally beads out of your " + player.assholeDescript() + " and stains your [armor].\n");
					dynStats("int", -.5, "lus", 500);
					displayedUpdate = true;
				}
			}
			//Bunny TF buttpreggoz
			if (player.buttPregnancyType === PregnancyStore.PREGNANCY_BUNNY) {
				if (player.buttPregnancyIncubation === 800) {
					outputText("\nYour gut gurgles strangely.\n");
					displayedUpdate = true;
				}
				if (player.buttPregnancyIncubation === 785) {
					getGame().mutations.neonPinkEgg(true,player);
					outputText("\n");
					displayedUpdate = true;
				}
				if (player.buttPregnancyIncubation === 776) {
					outputText("\nYour gut feels full and bloated.\n");
					displayedUpdate = true;
				}
				if (player.buttPregnancyIncubation === 765) {
					getGame().mutations.neonPinkEgg(true,player);
					outputText("\n");
					displayedUpdate = true;
				}
				if (player.buttPregnancyIncubation === 745) {
					outputText("\n<b>After dealing with the discomfort and bodily changes for the past day or so, you finally get the feeling that the eggs in your ass have dissolved.</b>\n");
					displayedUpdate = true;
					player.buttKnockUpForce(); //Clear Butt Pregnancy
				}
			}
			
			return displayedUpdate;
		}

		/**
		 * Changes pregnancy type to Mouse if Amily is in a invalid state.
		 */
		private function amilyPregnancyFailsafe():void 
		{
			//Amily failsafe - converts PC with pure babies to mouse babies if Amily is corrupted
			if (player.pregnancyIncubation === 1 && player.pregnancyType === PregnancyStore.PREGNANCY_AMILY) 
			{
				if (flags[kFLAGS.AMILY_FOLLOWER] === 2 || flags[kFLAGS.AMILY_CORRUPTION] > 0) {
					player.knockUpForce(PregnancyStore.PREGNANCY_MOUSE, player.pregnancyIncubation);
				}
			}
			
			//Amily failsafe - converts PC with pure babies to mouse babies if Amily is with Urta
			if (player.pregnancyIncubation === 1 && player.pregnancyType === PregnancyStore.PREGNANCY_AMILY) 
			{
				if (flags[kFLAGS.AMILY_VISITING_URTA] === 1 || flags[kFLAGS.AMILY_VISITING_URTA] === 2) {
					player.knockUpForce(PregnancyStore.PREGNANCY_MOUSE, player.pregnancyIncubation);
				}
			}
			
			//Amily failsafe - converts PC with pure babies to mouse babies if PC is in prison.
			if (player.pregnancyIncubation === 1 && player.pregnancyType === PregnancyStore.PREGNANCY_AMILY) 
			{
				if (prison.inPrison) {
					player.knockUpForce(PregnancyStore.PREGNANCY_MOUSE, player.pregnancyIncubation);
				}
			}
		}
		
		/**
		 * Check is the player has a vagina and create one if missing.
		 */
		private function createVaginaIfMissing(): void {
			PregnancyUtils.createVaginaIfMissing(output, player);
		}
		
		private function updateVaginalBirth(displayedUpdate:Boolean):Boolean 
		{
			if (hasRegisteredVaginalScene(PregnancyStore.PREGNANCY_PLAYER, player.pregnancyType)) {
				var scene:VaginalPregnancy = vaginalPregnancyScenes[player.pregnancyType] as VaginalPregnancy;
				LOGGER.debug("Updating vaginal birth for mother {0}, father {1} by using class {2}", PregnancyStore.PREGNANCY_PLAYER, player.pregnancyType, scene);
				scene.vaginalBirth();
				
				// TODO find a cleaner way to solve this
				// ignores Benoit pregnancy because that is a special case
				if (player.pregnancyType !== PregnancyStore.PREGNANCY_BENOIT) {
					giveBirth();
				}
			} else {
				LOGGER.debug("Could not find a mapped vaginal pregnancy scene for mother {0}, father {1} - using legacy pregnancy progression", PregnancyStore.PREGNANCY_PLAYER, player.pregnancyType);;
			}
			
			// TODO find a better way to do this
			// due to non-conforming pregancy code
			if (player.pregnancyType === PregnancyStore.PREGNANCY_BENOIT && player.pregnancyIncubation === 3) {
				return displayedUpdate;
			}
			
			player.knockUpForce();
			
			return true;
		}
		
		/**
		 * Updates fertility and tracks number of births. If the player has birthed
		 * enough children, gain the broodmother perk.
		 */
		public function giveBirth():void
		{
			//TODO remove this once new Player calls have been removed
			var player:Player = kGAMECLASS.player;
			
			if (player.fertility < 15) {
				player.fertility++;
			}
			
			if (player.fertility < 25) {
				player.fertility++;
			}
			
			if (player.fertility < 40) {
				player.fertility++;
			}
			
			if (!player.hasStatusEffect(StatusEffects.Birthed)) {
				player.createStatusEffect(StatusEffects.Birthed,1,0,0,0);
			} else {
				player.addStatusValue(StatusEffects.Birthed,1,1);
				
				if (player.findPerk(PerkLib.BroodMother) < 0 && player.statusEffectv1(StatusEffects.Birthed) >= 10) {
					output.text("\n<b>You have gained the Brood Mother perk</b> (Pregnancies progress twice as fast as a normal woman's).\n");
					player.createPerk(PerkLib.BroodMother,0,0,0,0);
				}
			}
		}

		private function updateAnalBirth(displayedUpdate:Boolean):Boolean 
		{
			//Give birf if its time... to ANAL EGGS
			if (player.buttPregnancyIncubation === 1 && player.buttPregnancyType === PregnancyStore.PREGNANCY_FROG_GIRL) {
				getGame().bog.frogGirlScene.birthFrogEggsAnal();
				displayedUpdate = true;
				player.buttKnockUpForce(); //Clear Butt Pregnancy
			}
			//Give birf if its time... to ANAL EGGS
			if (player.buttPregnancyIncubation === 1 && player.buttPregnancyType === PregnancyStore.PREGNANCY_DRIDER_EGGS) {
				getGame().swamp.corruptedDriderScene.birthSpiderEggsFromAnusITSBLEEDINGYAYYYYY();
				displayedUpdate = true;
				player.buttKnockUpForce(); //Clear Butt Pregnancy
			}
			//GIVE BIRF TO TRAPS
			if (player.buttPregnancyIncubation === 1 && player.buttPregnancyType === PregnancyStore.PREGNANCY_SANDTRAP_FERTILE) {
				getGame().desert.sandTrapScene.birfSandTarps();
				player.buttKnockUpForce(); //Clear Butt Pregnancy
				if (player.butt.rating < 17) {
					//Guaranteed increase up to level 10
					if (player.butt.rating < 13) {
						player.butt.rating++;
						outputText("\nYou notice your " + player.buttDescript() + " feeling larger and plumper after the ordeal.\n");
					}
					//Big butts only increase 50% of the time.
					else if (rand(2) === 0){
						player.butt.rating++;
						outputText("\nYou notice your " + player.buttDescript() + " feeling larger and plumper after the ordeal.\n");				
					}
				}
				displayedUpdate = true;
			}	
			//Give birth (if it's time) to beeeeeeez
			if (player.buttPregnancyIncubation === 1 && player.buttPregnancyType === PregnancyStore.PREGNANCY_BEE_EGGS) {
				outputText("\n");
				outputText(images.showImage("birth-beegirl"));
				outputText("There is a sudden gush of honey-colored fluids from your ass.  Before panic can set in, a wonderful scent overtakes you, making everything ok.  ");
				if (player.cockTotal() > 0) outputText("The muzzy feeling that fills your head seems to seep downwards, making your equipment hard and tight.  ");
				if (player.vaginas.length > 0) outputText("Your " + player.vaginaDescript(0) + " becomes engorged and sensitive.  ");
				outputText("Your hand darts down to the amber, scooping up a handful of the sticky stuff.  You wonder what your hand is doing as it brings it up to your mouth, which instinctively opens.  You shudder in revulsion as you swallow the sweet-tasting stuff, your mind briefly wondering why it would do that.  The stuff seems to radiate warmth, quickly pushing those nagging thoughts away as you scoop up more.\n\n");
				outputText("A sudden slip from below surprises you; a white sphere escapes from your anus along with another squirt of honey.  Your drugged brain tries to understand what's happening, but it gives up, your hands idly slathering honey over your loins.  The next orb pops out moments later, forcing a startled moan from your mouth.  That felt GOOD.  You begin masturbating to the thought of laying more eggs... yes, that's what those are.  You nearly cum as egg number three squeezes out.  ");
				if (player.averageLactation() >= 1 && player.biggestTitSize() > 2) outputText("Seeking even greater sensation, your hands gather the honey and massage it into your " + player.breastDescript(0) + ", slowly working up to your nipples.  Milk immediately begins pouring out from the attention, flooding your chest with warmth.  ");
				outputText("Each egg seems to come out closer on the heels of the one before, and each time your conscious mind loses more of its ability to do anything but masturbate and wallow in honey.\n\n");
				outputText("Some time later, your mind begins to return, brought to wakefulness by an incredibly loud buzzing...  You sit up and see a pile of dozens of eggs resting in a puddle of sticky honey.  Most are empty, but a few have hundreds of honey-bees emptying from them, joining the massive swarms above you.  ");
				if (player.cor < 35) outputText("You are disgusted, but glad you were not stung during the ordeal.  You stagger away and find a brook to wash out your mouth with.");
				if (player.cor >= 35 && player.cor < 65) outputText("You are amazed you could lay so many eggs, and while the act was strange there was something definitely arousing about it.");
				if (player.cor >= 65 && player.cor < 90) outputText("You stretch languidly, noting that most of the drugged honey is gone.  Maybe you can find the Bee again and remember to bottle it next time.");
				if (player.cor >= 90) outputText("You lick your lips, savoring the honeyed residue on them as you admire your thousands of children.  If only every night could be like this...\n");
				player.buttKnockUpForce(); //Clear Butt Pregnancy
				player.orgasm('Anal');
				dynStats("int", 1, "lib", 4, "sen", 3);
				if (player.buttChange(20, true)) outputText("\n");
				if (player.butt.rating < 17) {
					//Guaranteed increase up to level 10
					if (player.butt.rating < 13) {
						player.butt.rating++;
						outputText("\nYou notice your " + player.buttDescript() + " feeling larger and plumper after the ordeal.");
					}
					//Big butts only increase 50% of the time.
					else if (rand(2) === 0){
						player.butt.rating++;
						outputText("\nYou notice your " + player.buttDescript() + " feeling larger and plumper after the ordeal.");				
					}
				}
				outputText("\n");
				displayedUpdate = true;
			}

			//Satyr butt preg
			if (player.buttPregnancyType === PregnancyStore.PREGNANCY_SATYR && player.buttPregnancyIncubation === 1) {
				player.buttKnockUpForce(); //Clear Butt Pregnancy
				displayedUpdate = true;
				getGame().plains.satyrScene.satyrBirth(false);
			}
			
			return displayedUpdate;
		}
	}
}
