/**
 * Created by aimozg on 06.01.14.
 */
package classes.Scenes.Areas
{
	import classes.*;
	import classes.GlobalFlags.kFLAGS;
	import classes.GlobalFlags.kGAMECLASS;
	import classes.Scenes.API.Encounter;
	import classes.Scenes.API.Encounters;
	import classes.Scenes.API.FnHelpers;
	import classes.Scenes.Areas.Plains.*;

	use namespace kGAMECLASS;

	public class Plains extends BaseContent
	{
		public var bunnyGirl:BunnyGirl = new BunnyGirl();
		public var gnollScene:GnollScene = new GnollScene();
		public var gnollSpearThrowerScene:GnollSpearThrowerScene = new GnollSpearThrowerScene();
		public var satyrScene:SatyrScene = new SatyrScene();

		public function Plains()
		{
		}
		public function isDiscovered():Boolean {
			return flags[kFLAGS.TIMES_EXPLORED_PLAINS] > 0;
		}
		public function discover():void {
			flags[kFLAGS.TIMES_EXPLORED_PLAINS] = 1;
			outputText("You find yourself standing in knee-high grass, surrounded by flat plains on all sides.  Though the mountain, forest, and lake are all visible from here, they seem quite distant.\n\n<b>You've discovered the plains!</b>");
			doNext(camp.returnToCampUseOneHour);
		}

		private var _explorationEncounter:Encounter = null;
		public function get explorationEncounter():Encounter {
			const game:CoC     = kGAMECLASS;
			const fn:FnHelpers = Encounters.fn;
			return _explorationEncounter ||= Encounters.group(game.commonEncounters, {
				name  : "sheila_xp3",
				chance: Encounters.ALWAYS,
				when  : function ():Boolean {
					return flags[kFLAGS.SHEILA_DEMON] == 0
						   && flags[kFLAGS.SHEILA_XP] == 3
						   && model.time.hours == 20
						   && flags[kFLAGS.SHEILA_CLOCK] >= 0;
				},
				call  : game.sheilaScene.sheilaXPThreeSexyTime
			}, {
				name: "candy_cane",
				when: function ():Boolean {
					return isHolidays() && date.fullYear > flags[kFLAGS.CANDY_CANE_YEAR_MET];
				},
				call: game.xmas.xmasMisc.candyCaneTrapDiscovery
			}, {
				name: "polar_pete",
				when: function ():Boolean {
					return isHolidays() && date.fullYear > flags[kFLAGS.POLAR_PETE_YEAR_MET];
				},
				call: game.xmas.xmasMisc.polarPete
			}, {
				name: "niamh",
				when: function ():Boolean {
					return flags[kFLAGS.NIAMH_MOVED_OUT_COUNTER] == 1
				},
				call: game.telAdre.niamh.niamhPostTelAdreMoveOut
			}, {
				name  : "owca",
				chance: 0.3,
				when  : function ():Boolean {
					return flags[kFLAGS.OWCA_UNLOCKED] == 0;
				},
				mods  : [fn.ifLevelMin(8)],
				call  : game.owca.gangbangVillageStuff
			}, {
				name: "bazaar",
				when: function ():Boolean {
					return flags[kFLAGS.BAZAAR_ENTERED] == 0;
				},
				call: game.bazaar.findBazaar
			}, {
				name  : "helXizzy",
				chance: 0.2,
				when  : function ():Boolean {
					return flags[kFLAGS.ISABELLA_CAMP_APPROACHED] != 0
						   && flags[kFLAGS.ISABELLA_MET] != 0
						   && flags[kFLAGS.HEL_FUCKBUDDY] == 1
						   && flags[kFLAGS.ISABELLA_ANGRY_AT_PC_COUNTER] == 0
						   && !kGAMECLASS.isabellaFollowerScene.isabellaFollower()
						   && (player.tallness <= 78 || flags[kFLAGS.ISABELLA_OKAY_WITH_TALL_FOLKS])
				},
				call  : helXIzzy
			}, {
				name  : "ovielix",
				call  : findOviElix,
				chance: 0.5
			}, {
				name  : "kangaft",
				call  : findKangaFruit,
				chance: 0.5
			}, {
				name  : "gnoll",
				chance: 0.5,
				call  : gnollSpearThrowerScene.gnoll2Encounter
			}, {
				name  : "gnoll2",
				chance: 0.5,
				call  : gnollScene.gnollEncounter
			}, {
				name: "bunny",
				call: bunnyGirl.bunnbunbunMeet
			}, {
				name: "isabella",
				when: function ():Boolean {
					return flags[kFLAGS.ISABELLA_PLAINS_DISABLED] == 0
				},
				call: game.isabellaScene.isabellaGreeting
			}, {
				name  : "helia",
				chance: function ():Number {
					return flags[kFLAGS.HEL_REDUCED_ENCOUNTER_RATE] ? 0.75 : 1.5;
				},
				when  : function ():Boolean {
					return !kGAMECLASS.helScene.followerHel();
				},
				call  : game.helScene.encounterAJerkInThePlains
			}, {
				name: "satyr",
				call: satyrScene.satyrEncounter
			}, {
				name: "sheila",
				when: function ():Boolean {
					return flags[kFLAGS.SHEILA_DISABLED] == 0 && flags[kFLAGS.SHEILA_CLOCK] >= 0
				},
				call: game.sheilaScene.sheilaEncounterRouter
			});
		}
		public function explorePlains():void
		{
			clearOutput();
			flags[kFLAGS.TIMES_EXPLORED_PLAINS]++;
			explorationEncounter.execEncounter();
		}

		private function helXIzzy():void {
			if (flags[kFLAGS.HEL_ISABELLA_THREESOME_ENABLED] == 0) {
				//Hell/Izzy threesome intro
				kGAMECLASS.helScene.salamanderXIsabellaPlainsIntro();
			} else if (flags[kFLAGS.HEL_ISABELLA_THREESOME_ENABLED] == 1) {
				//Propah threesomes here!
				kGAMECLASS.helScene.isabellaXHelThreeSomePlainsStart();
			}
		}

		private function findKangaFruit():void {
			outputText("While exploring the plains you come across a strange-looking plant.  As you peer at it, you realize it has some fruit you can get at.  ");
			inventory.takeItem(consumables.KANGAFT, camp.returnToCampUseOneHour);
		}

		private function findOviElix():void {
			outputText("While exploring the plains you nearly trip over a discarded, hexagonal bottle.  ");
			inventory.takeItem(consumables.OVIELIX, camp.returnToCampUseOneHour);
		}
	}
}
