package classes.Scenes
{

	import classes.DefaultDict;
	import classes.Scenes.Areas.Bog;
	import classes.Scenes.Areas.Swamp;
	import classes.Scenes.Monsters.ImpScene;
	import classes.Scenes.NPCs.AmilyScene;
	import classes.Scenes.NPCs.pregnancies.PlayerBenoitPregnancy;
	import classes.Scenes.NPCs.pregnancies.PlayerMousePregnancy;
	import classes.helper.DummyOutput;
	import org.flexunit.asserts.*;
	import org.hamcrest.assertThat;
	import org.hamcrest.core.*;
	import org.hamcrest.number.*;
	import org.hamcrest.object.*;
	import org.hamcrest.text.*;
	import org.hamcrest.collection.*;
	
	import classes.helper.StageLocator;
	
	import classes.CoC;
	import classes.Player;
	import classes.GlobalFlags.kGAMECLASS;
	import classes.GlobalFlags.kFLAGS;
	import classes.PregnancyStore;
	import classes.StatusEffects;
	
	public class PregnancyProgressionTest 
	{
		private static const COTTON_225_MESSAGE:String = "You stroke the orb and wonder with a half-grin if you'll have a daughter who takes after her 'daddy'.";
		private static const FROG_ANAL_8_MESSAGE:String = "Your gut churns, and with a squelching noise,";
		private static const HEAT_END:String = "It seems your heat has ended.";
		private static const IMP_BIRTH_MESSAGE:String = "The pain begins to subside as your delivery continues...";
		private static const MOUSE_BIRTH_MESSAGE:String = "Two emerge, then four, eight... you lose track.";
		
		private var cut:PregProgForTest;
		private var scenePregProg:PregProgForTest;
		private var player:Player;
		private var scene:DummyScene;
		private var output:DummyOutput;
		
		
		[BeforeClass]
		public static function setUpClass():void {
			kGAMECLASS = new CoC(StageLocator.stage);
		}
		
		[Before]
		public function setUp():void {
			player = new Player();
			player.createVagina();
			kGAMECLASS.player = player;
			
			output = new DummyOutput();
			
			cut = new PregProgForTest();
			scenePregProg = new PregProgForTest();
			
			kGAMECLASS.flags = new DefaultDict();
			kGAMECLASS.impScene = new ImpScene(scenePregProg, output);
			kGAMECLASS.amilyScene = new AmilyScene(scenePregProg, output);
			kGAMECLASS.swamp = new Swamp(scenePregProg, output);
			
			new PlayerMousePregnancy(scenePregProg, output);
			new PlayerBenoitPregnancy(scenePregProg, output);
			
			scene = new DummyScene();
		}
		
		[Test]
		public function cancelHeatOutput():void {
			player.goIntoHeat(false);
			player.knockUpForce(PregnancyStore.PREGNANCY_COTTON, 225);
			
			cut.updatePregnancy();
			
			assertThat(cut.collectedOutput, hasItem(containsString(HEAT_END)));
		}
		
		[Test]
		public function cancelHeatDisplayChange():void {
			player.goIntoHeat(false);
			player.knockUpForce(PregnancyStore.PREGNANCY_COTTON, 225);
			
			assertThat(cut.updatePregnancy(), equalTo(true));
		}
		
		[Test]
		public function updateFrogAnalPregnancyOutput():void {
			player.buttKnockUpForce(PregnancyStore.PREGNANCY_FROG_GIRL, 8);
			
			cut.updatePregnancy();
			
			assertThat(cut.collectedOutput, hasItem(containsString(FROG_ANAL_8_MESSAGE)));
		}
		
		[Test]
		public function updateFrogAnalPregnancyDisplayChange():void {
			player.buttKnockUpForce(PregnancyStore.PREGNANCY_FROG_GIRL, 8);
			
			assertThat(cut.updatePregnancy(), equalTo(true));
		}
		
		[Test]
		public function updateImpBirthOutput():void {
			player.knockUpForce(PregnancyStore.PREGNANCY_IMP, 1);
			
			scenePregProg.updatePregnancy();
			
			assertThat(output.collectedOutput, hasItem(containsString(IMP_BIRTH_MESSAGE)));
		}
		
		[Test]
		public function updateImpBirthDisplayChange():void {
			player.knockUpForce(PregnancyStore.PREGNANCY_IMP, 1);
			
			assertThat(scenePregProg.updatePregnancy(), equalTo(true));
		}
		
		[Test]
		public function amilyFailsafeCorruption():void {
			player.knockUpForce(PregnancyStore.PREGNANCY_AMILY, 1);
			kGAMECLASS.flags[kFLAGS.AMILY_FOLLOWER] = 2;
			
			scenePregProg.updatePregnancy();
			
			assertThat(output.collectedOutput, hasItem(containsString(MOUSE_BIRTH_MESSAGE)));
		}
		
		[Test]
		public function amilyFailsafeUrtha():void {
			player.knockUpForce(PregnancyStore.PREGNANCY_AMILY, 1);
			kGAMECLASS.flags[kFLAGS.AMILY_VISITING_URTA] = 2;
			
			scenePregProg.updatePregnancy();
			
			assertThat(output.collectedOutput, hasItem(containsString(MOUSE_BIRTH_MESSAGE)));
		}
		
		[Test]
		public function amilyFailsafePrison():void {
			player.knockUpForce(PregnancyStore.PREGNANCY_AMILY, 1);
			kGAMECLASS.flags[kFLAGS.IN_PRISON] = 1;
			
			scenePregProg.updatePregnancy();
			
			assertThat(output.collectedOutput, hasItem(containsString(MOUSE_BIRTH_MESSAGE)));
		}
		
		[Test]
		public function benoitTimeBasedResetIncubation():void {
			player.knockUpForce(PregnancyStore.PREGNANCY_BENOIT, 1);
			
			scenePregProg.updatePregnancy();
			
			assertThat(kGAMECLASS.player.pregnancyIncubation, equalTo(3));
		}
		
		[Test]
		public function benoitTimeBasedResetIncubationTwo():void {
			player.knockUpForce(PregnancyStore.PREGNANCY_BENOIT, 2);
			
			scenePregProg.updatePregnancy();
			
			assertThat(kGAMECLASS.player.pregnancyIncubation, equalTo(3));
		}
		
		[Test]
		public function benoitTimeBasedNoDisplayOutput():void {
			player.knockUpForce(PregnancyStore.PREGNANCY_BENOIT, 1);
			
			assertThat(scenePregProg.updatePregnancy(), equalTo(false));
		}
		
		[Test]
		public function registerPlayerAsMotherVaginalPregnancy():void {
			var replacedPrevious:Boolean = cut.registerVaginalPregnancyScene(PregnancyStore.PREGNANCY_PLAYER, PregnancyStore.PREGNANCY_IMP, scene);
			
			assertThat(replacedPrevious, equalTo(false));
		}
		
		[Test]
		public function registerPlayerAsMotherVaginalPregnancyReplaceExisting():void {
			cut.registerVaginalPregnancyScene(PregnancyStore.PREGNANCY_PLAYER, PregnancyStore.PREGNANCY_IMP, scene);
			var replacedPrevious:Boolean = cut.registerVaginalPregnancyScene(PregnancyStore.PREGNANCY_PLAYER, PregnancyStore.PREGNANCY_IMP, scene);
			
			assertThat(replacedPrevious, equalTo(true));
		}
		
		[Test]
		public function registerMultipleVaginalScenes():void {
			var minoScene:DummyScene = new DummyScene();
			
			cut.registerVaginalPregnancyScene(PregnancyStore.PREGNANCY_PLAYER, PregnancyStore.PREGNANCY_IMP, scene);
			cut.registerVaginalPregnancyScene(PregnancyStore.PREGNANCY_PLAYER, PregnancyStore.PREGNANCY_MINOTAUR, minoScene);
			
			player.knockUpForce(PregnancyStore.PREGNANCY_IMP, 1);
			cut.updatePregnancy();
			
			assertThat(scene.birth, equalTo(true));
			assertThat(minoScene.birth, equalTo(false));
		}
		
		[Test(expected="ArgumentError")]
		public function registerNonPlayerNotSupported():void {
			cut.registerVaginalPregnancyScene(PregnancyStore.PREGNANCY_MARBLE, PregnancyStore.PREGNANCY_PLAYER, scene);
		}
		
		[Test]
		public function callsVaginalPregnancyUpdate():void {
			cut.registerVaginalPregnancyScene(PregnancyStore.PREGNANCY_PLAYER, PregnancyStore.PREGNANCY_IMP, scene);
			
			player.knockUpForce(PregnancyStore.PREGNANCY_IMP, 337);
			cut.updatePregnancy();
			
			assertThat(scene.updated, equalTo(true));
		}
		
		[Test]
		public function callsVaginalPregnancyBirth():void {
			cut.registerVaginalPregnancyScene(PregnancyStore.PREGNANCY_PLAYER, PregnancyStore.PREGNANCY_IMP, scene);
			
			player.knockUpForce(PregnancyStore.PREGNANCY_IMP, 1);
			cut.updatePregnancy();
			
			assertThat(scene.birth, equalTo(true));
		}
		
		[Test]
		public function hasNoRegistreredScene():void {
			assertThat(cut.hasRegisteredVaginalScene(PregnancyStore.PREGNANCY_PLAYER, PregnancyStore.PREGNANCY_IMP), equalTo(false));
		}
		
		[Test]
		public function hasRegistreredScene():void {
			cut.registerVaginalPregnancyScene(PregnancyStore.PREGNANCY_PLAYER, PregnancyStore.PREGNANCY_IMP, scene);
			
			assertThat(cut.hasRegisteredVaginalScene(PregnancyStore.PREGNANCY_PLAYER, PregnancyStore.PREGNANCY_IMP), equalTo(true));
		}
		
		[Test]
		public function spiderPregnancyText():void {
			player.knockUpForce(PregnancyStore.PREGNANCY_SPIDER, 180);
			
			scenePregProg.updatePregnancy();
			
			assertThat(output.collectedOutput, hasItem(containsString("spider-morph")));
			assertThat(output.collectedOutput, not(hasItem(containsString("driders"))));
		}
		
		[Test]
		public function driderPregnancyText():void {
			player.knockUpForce(PregnancyStore.PREGNANCY_DRIDER_EGGS, 180);
			
			scenePregProg.updatePregnancy();
			
			assertThat(output.collectedOutput, hasItem(containsString("driders")));
			assertThat(output.collectedOutput, not(hasItem(containsString("spider-morph"))));
		}
	}
}

import classes.Scenes.PregnancyProgression;

class PregProgForTest extends PregnancyProgression {
	public var collectedOutput:Vector.<String> = new Vector.<String>(); 
	
	override protected function outputText(output:String):void {
		collectedOutput.push(output);
	}
	
	public function pregUpdate():Boolean {
		return updatePregnancy();
	}
}

import classes.Scenes.VaginalPregnancy;

class DummyScene implements VaginalPregnancy {
	public var updated:Boolean = false;
	public var birth:Boolean = false;
	
	public function updateVaginalPregnancy():Boolean 
	{
		this.updated = true;
		return true;
	}
	
	public function vaginalBirth():void 
	{
		this.birth = true;
	}
}
