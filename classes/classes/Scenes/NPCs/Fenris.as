/**
 * ...
 * @author jackdarker
 */

package classes.Scenes.NPCs{

	import classes.BreastRowClass;
	import classes.BreastStore;
	import classes.Items.Useable;
	import classes.Items.Weapon;
	import classes.Items.WeaponLib;
	import classes.PregnancyStore;
	import classes.GlobalFlags.kGAMECLASS;
	import classes.GlobalFlags.kFLAGS;
	import classes.TimeAwareInterface;
	import classes.Monster;
	import classes.Player;
	import classes.PerkLib;
	import classes.StatusEffects;
	import classes.Appearance;
	import classes.internals.*;
	import classes.CoC;
	import classes.BaseContent;
	import classes.CockTypesEnum;
	import classes.Items.Consumables.SimpleConsumable;
	import classes.ItemType;
	import classes.SaveAwareInterface;

	//dont extends Monster because we need to change stats and features
	public class Fenris implements SaveAwareInterface, TimeAwareInterface 
	{
		
		//those are the main quest stages
		public static const MAINQUEST_Not_Met:uint = 		0;		//initial value
		public static const MAINQUEST_Spotted:uint = 		5;		//PC heard him in the bushes
		public static const MAINQUEST_Spotted2:uint = 		10;	//PC saw him at the lake
		public static const MAINQUEST_Greetings:uint = 		20;	//PC talked to him first time
		public static const MAINQUEST_Greetings2:uint = 		25;	//PC talked where he cam from
		public static const MAINQUEST_Greetings3:uint = 		30;	//PC talked how sex normally works since fenris is a virgin
		public static const MAINQUEST_Steal_Cloth:uint = 	100; //PC decided to steal his loin cloth
		public static const MAINQUEST_CAGED_Init:uint = 	110; //Fenris got COCKCAGE from Fetish guys because running around naked
		public static const MAINQUEST_CAGED:uint = 			120; //Fenris got COCKCAGE from Fetish guys; you talked with him already
		public static const MAINQUEST_FORGEKEY1:uint =		130; //asked blacksmith for help, cannot forge, decides that its easier to shrink cock
		public static const MAINQUEST_SHRINKCOCK1:uint = 	140; //tryd to shrink his cock a little bit but cage shrinks also !
		public static const MAINQUEST_HUNTKEY1:uint =		150; //defeat fetish zealot, but key lost
		public static const MAINQUEST_HUNTKEY1_SUCCESS:uint =		155; //bought key from fetish zealot,  --> this is the quick end 
		public static const MAINQUEST_Greetings4:uint = 		160;	//PC talked about alternative sex anal,oral;
		
		public static const MAINQUEST_HUNTKEY2:uint =		85; // defend fenris against ?; if you dont help him or fail he might get captured
		public static const MAINQUEST_IMPRISSONED:uint =		300; //someone tells you fenris got captured, player has to free him from prison; how to get to prison if no access to bazaar?
		public static const MAINQUEST_IMPRISSONED2:uint =		310; //you are ready to flee, do you take fenris with you; maybe some obedience training would be of use for him?
		public static const MAINQUEST_IMPRISSONED3:uint =		320; //you fled with him
		//this might repeat several times, the more often he get captured, the more submissive and corrupted he gets
		//f.e. plaything for hellhounds, akabals bitch,...		
		public static const MAINQUEST_HUNTKEY3:uint =		400; //fenris is plaything for hellhound, still no key, gets collared?
		public static const MAINQUEST_SHRINKCOCK2:uint =	500; //he has no cock anymore; still has clitcage
		public static const MAINQUEST_SHRINKCOCK2_NO:uint =	505; //you decided to not remove cock but you still can decide otherwise
		
		public static const MAINQUEST_FORGEKEY2:uint =		550; //spok to smith again; tells you that the key is attracted to the chastity-device; just continue helping fenris to search for it
		
		public static const MAINQUEST_HUNTKEY4:uint =		600; //				
		public static const MAINQUEST_HUNTKEY5:uint =		700; //fight in Zetaz Lair again?? 
		public static const MAINQUEST_FOUNDKEY:uint =		800; //you get the key but it is damaged
		public static const MAINQUEST_DEFER_UNCAGE:uint =		850; //you spoke with fenris but didnt uncage him
		public static const MAINQUEST_UNCAGE:uint =		900; //you released fenris -> quest done; but maybe you can keep the cock cage?
		
		// alternative questline - you got the key but decided to keep the cuntboy  in chastity
		// you discover that you can release the chastity-rings temporary and stuff him with eggs
		// if you fed him a ovi-elixir he will grow them to large eggs; just keep the chastity-rings closed and wait
		// after some repeats he doesnt even need the elixir
		
		// give him some  ? to grow 3 rows of tittys
		// get the hellhounds to breed him for some stronger hellerhounds
		
		// he is reluctant for analsex at beginning but after some training (by player/monster/quest) gets more affine to it
		
		// alternative questline - this will mutate fenris into a demonic werwolf lord 
		// the caged questline should be finished before this is started, doesnt need to free him from the cage however
		// MAINQUEST_TRAINING1	//you start to do more combat training with him 
		// //you fed him stuff to make him grow stronger (black pepper), this will also fire up his libido
		// he grows more confident, well a little bit over confident and demanding; show him his place or else...
		// gets into trouble with kiha/Jojo ...??
		// joins the dark side and gets more and more corrupted
		// trys to dominate the player, fights him if he is not corrupted
		// ...??
		
		//those flags keep track of the mainquest history (bitwise)
		public static const MAINFLAG_STOLE_CLOTH:uint = 	1 << 0;	//PC stole loin cloth
		public static const MAINFLAG_SEARCH_DEEPWOOD:uint = 1 << 1;	//
		public static const MAINFLAG_SEARCH_MOUNTAIN:uint = 1 << 2;	//
		public static const MAINFLAG_SEARCH_FOREST:uint = 	1 << 3;	//
		public static const MAINFLAG_SEARCH_DESERT:uint = 	1 << 4;	//
		public static const MAINFLAG_CAGED_HELPHIM:uint = 	1 << 5;	//told him to help
		public static const MAINFLAG_SLAVEPRISON:uint = 	1 << 6; //captured by slavers (repeatable)
		
		//the following flags are not persistantly stored and are only used to modify screenoutput 
		public static const TEMPFLAG_CORRUPTION_UP:uint = 		1 << 0;	//his corruption has gone above one threshold since last met 
		public static const TEMPFLAG_CORRUPTION_DOWN:uint = 	1 << 1;	//his corruption has gone below one threshold since last met 
		public static const TEMPFLAG_BODY_UP:uint = 			1 << 2;	//his bodystrength has gone above one threshold since last met 
		public static const TEMPFLAG_BODY_DOWN:uint = 			1 << 3;	//his bodystrength has gone below one threshold since last met 
		public static const TEMPFLAG_SEXED_COOLDOWN:uint = 		1 << 4;	//a cooldown marker for disabling SexEd dialogs
		
		//{ --> stats
		//Todo: convert measurments to metrics if kFlags.USE_METRICS is set
		private var _Level:uint = 0; // lowest byte is level (1..254), the other bytes keep track of XP (0..16Mio)
		public function getLevel():uint { 
			return _Level & 0xFF;
		}
		/*returns true if level up
		 * */
		public function addXP(value:uint):Boolean { 
			var _Return:Boolean = false;
			var _XPbefore:uint = _Level / 0x100;
			value = value  +_XPbefore;
						
			var _XPrequired:uint = (uint(getLevel() * 100));  //copied from player.as		
			if (value >= _XPrequired ) { //level up
				trace("\nFenris leveled up", false);
				_Level = ((value -_XPrequired) * 0x100) + (_Level & 0xFF) + 1;
				_Return = true;
			} else {
				_Level = (value *0x100)+ (_Level & 0xFF); 
			}
			return _Return;
		} 
		public function getXP():uint {
			return _Level / 0x100;
		}
		// Todo: how about reset XP ?
		private function setLevel(value:uint):void { 
			_Level = (value & 0xFF) +  (_Level & 0xFFFFFF00 ); 
		} 

		private var _Corruption:uint =0;  // 2bytes Corruption 100/50000 per bit
		public function getCorruption():Number {
			return (Number(_Corruption & 0xFFFF)) * 0.002;;
		}
		public function increaseCorruption(x:Number, limit:Number):void {
			var _old:Number = getCorruption();
			setCorruption(increaseStat(_old, x, limit));
			var _new:Number = getCorruption();
			// set flag 
			var _i:int = detectThreshold(_old,_new,15)+ detectThreshold(_old,_new,30)*2+
						detectThreshold(_old, _new, 45)*4 + detectThreshold(_old, _new, 60)*8 +
					detectThreshold(_old, _new, 75)*16 + detectThreshold(_old, _new, 90)*32  ;	
			if (_i != 0) {
				setTempFlag(TEMPFLAG_CORRUPTION_DOWN, _i<0);
				setTempFlag(TEMPFLAG_CORRUPTION_UP, _i>0);
			}
			if (_i >= 8 ) setCock(100, 2);
			if (_i >= 16 ) setCock(100,4);
			if (_i >= 32) setCock(100, 6);
			if (_i <= -32 ) setCock(100, 4);
			if (_i <= -16 ) setCock(100,2);
			if (_i <= -8) setCock(0, 2);

		}
		public function setCorruption(x:Number):void {
			if (x < 0) return;
			_Corruption=(uint(x/0.002))&0xFFFF;
		}
		//stores info for his sexual knowledge; upgrading his knowledge unlocks better&longer sexcenes for PC and NPC
		//upgrading is done by talking, lessons, enemy encounters, quest?
		private var _SexEducat:uint = 0;	//4bit per topic => 8topics 0..15 ?
		// 0 never heard of sex
		// 1 heard about bees and flowers
		// 2 the basic m-f stuff ...
		// 0x100..0xF00  oral stuff.. licking, deepthroat, 69, 
		// 0x1000..0xF000 anal stuff.. pegging, fisting,rimming
		// pawjob, bondage, sadism...
		//0x10000000..0xF0000000
		public static const SEXED_TOPIC_BASE:uint = 	1 << 0;
		public static const SEXED_TOPIC_ORAL:uint = 	1 << 8;
		public static const SEXED_TOPIC_ANAL:uint = 	1 << 12;
		public static const SEXED_TOPIC_VAGINAL:uint = 	1 << 16;
		
		public function upgradeSexEd(Topic:uint):void {
			if (Topic < 0) return;
			var _tempMask:uint = ((uint)(0xF * Topic));
			var _temp:uint =  (Topic==0 ? (_SexEducat & _tempMask) : ((_SexEducat & _tempMask) / Topic));			
			if (_temp < 15) _temp++;
			_SexEducat = (_SexEducat & ~_tempMask) | (_temp * Topic);
		}
		public function getSexEd(Topic:uint):uint {
			var _tempMask:uint = ((uint)(0xF * Topic));
			var _temp:uint =  (Topic==0 ? (_SexEducat & _tempMask) : ((_SexEducat & _tempMask) / Topic));	
			return _temp;
		}
		private var _LibidoLust:uint =0;  // 2 bytes Libido & 2 bytes Lust 100/50000 per bit
		public function getLibido():Number {
			return (Number(_LibidoLust & 0xFFFF)) * 0.002;
		}
		public function increaseLibido(x:Number, limit:Number):void {
			setLibido(increaseStat(getLibido(),x,limit));
		}
		public function setLibido(x:Number):void {
			if (x < 0) return;
			_LibidoLust= (_LibidoLust & 0xFFFF0000 )+((uint(x/0.002))&0xFFFF);
		}
		public function getLust():Number {
			return (Number((_LibidoLust / 0x10000 ) & 0xFFFF)) * 0.002;
		}
		public function increaseLust(x:Number, limit:Number):void {
			setLust(increaseStat(getLust(),x,limit));
		}
		public function setLust(x:Number):void {
			if (x < 0) return;
			_LibidoLust=(_LibidoLust & 0xFFFF )+((uint(x/0.002))&0xFFFF)*0x10000;
		}
		private var _BodyStrength:uint = 0;
		/* returns fitness/masculinity of body  0=no muscles 100=bodybuilder on steroids  
		 */ 
		public function getBodyStrength():Number {
			return (Number(_BodyStrength & 0xFFFF)) * 0.002;
		}
		public function increaseBodyStrength(x:Number, limit:Number):void {
			var _old:Number = getBodyStrength();
			setBodyStrength(increaseStat(getBodyStrength(), x, limit));
			var _new:Number = getBodyStrength();
			// set flag 
			var _i:int = detectThreshold(_old,_new,15)+ detectThreshold(_old,_new,30)+
						detectThreshold(_old, _new, 45) + detectThreshold(_old, _new, 60) +
					detectThreshold(_old, _new, 75) + detectThreshold(_old, _new, 90)  ;	
			if (_i != 0) {
				setTempFlag(TEMPFLAG_BODY_DOWN, _i<0);
				setTempFlag(TEMPFLAG_BODY_UP, _i>0);
			}
		}
		//2 byte bodyStrength 100/50000 per bit
		public function setBodyStrength(x:Number):void {
			if (x < 0) return;
			_BodyStrength= (_BodyStrength & 0xFFFF0000 )+((uint(x/0.002))&0xFFFF);
		}
		public function getIntelligence():Number { // the stronger the dumber 
			return increaseStat(20,100-getBodyStrength()/2,maxAttributeForLevel());
		}
		public function getStrength():Number { // the stronger the stronger 
			return increaseStat(20,getBodyStrength(),maxAttributeForLevel());
		}
		public function getThoughness():Number { // the stronger the thougher 
			return increaseStat(20,getBodyStrength(),maxAttributeForLevel());
		}
		public function getSpeed():Number { // the stronger the slower 
			return increaseStat(20,100-getBodyStrength()/2,maxAttributeForLevel());
		}
		private function maxAttributeForLevel():Number { //calculates max attribute-limit depending on level&others
			var _level:uint = getLevel();
			var _max:Number = 25;
			if (_level >= 30) {
				_max = 100;
			} else if (_level < 5) {			
			} else {
				_max = _max + (100-_max) * ((_level - 5) / (30 - 5));		//lvl=20 -> 25+75*(15/25) = 70
			}
			return _max;
		}
		private var _SelfEsteem:uint = 0;
		/* returns confidence of himself, modifys chances for fullfilling others request:0= easy to dominate 100= dominating others 
		 */ 
		public function getSelfEsteem():Number {
			return _SelfEsteem;
		}
		public function setSelfEsteem(x:Number):void {
			_SelfEsteem=uint(x);
		}
		public function increaseSelfEsteem(x:Number, limit:Number):void {
			_SelfEsteem = uint(increaseStat(_SelfEsteem,x,limit));
		}
		private var _PlayerRelation:uint = 0;
		/** returns relation to player, 0= neutral, 100=lover, -100=nemesis
		 */ 
		public function getPlayerRelation():Number {
			var _ret:Number = Number(int(_PlayerRelation));
			return _ret;
		}
		/** adds/substracts x from stat if stat is lower/higher than limit
		 */
		public function increasePlayerRelation(x:Number, limit:Number):void {
			setPlayerRelation(increaseStat(getPlayerRelation(),x,limit));
		}
		public function setPlayerRelation(x:Number):void {
			_PlayerRelation=uint(x);
		}
		private function increaseStat(stat:Number , x:Number, limit:Number):Number {
			var Result:Number = stat;
			if (x >= 0) {
				Result = uint(Math.min(limit, x + stat));
			} else {
				Result = uint(Math.max(limit, x + stat));
			}
			return Result;
		}
		/* returns 1 if (old< threshold and New>=threshold) 
		 * returns -1 if (new< threshold and old>=threshold) 
		 * returns 0 otherwise
		 * */
		private function detectThreshold(Old:Number, New:Number, threshold:Number):int {
			if ( Old< threshold && New>=threshold) return 1;
			if ( New< threshold && Old>=threshold) return -1;
			return 0;
		}
		
		
		private var _TempFlags:uint = 0;
		public function getTempFlag():uint {
			return _TempFlags;
		}
		public function testTempFlag(Flag:uint):Boolean{
			return (_TempFlags & Flag ) == Flag;
		}
		public function setTempFlag(x:uint, set:Boolean):void {
			if (set) {
				_TempFlags = _TempFlags | x;
			} else {
				_TempFlags = _TempFlags ^ x;
			}
		}
		private var _MainQuestStage:uint = 0;
		private var _MainQuestFlags:uint = 0;
		public function getMainQuestFlag():uint {
			return _MainQuestFlags;
		}
		public function testMainQuestFlag(Flag:uint):Boolean{
			return (_MainQuestFlags & Flag ) == Flag;
		}
		public function setMainQuestFlag(x:uint, set:Boolean):void {
			if (set) {
				_MainQuestFlags = _MainQuestFlags | x;
			} else {
				_MainQuestFlags = _MainQuestFlags ^ x;
			}
		}
		public function setMainQuestStage(x:uint):void {
			var _Result:ReturnResult = new ReturnResult();
			if (x == MAINQUEST_Steal_Cloth) {
				setMainQuestFlag(MAINFLAG_STOLE_CLOTH, true);
				unequipItem(ITEMSLOT_UNDERWEAR, UNDERWEAR_LOINCLOTH, true, _Result);
			}
			if (x == MAINQUEST_IMPRISSONED) {
				setMainQuestFlag(MAINFLAG_SLAVEPRISON, true);				
			}
			if (x == MAINQUEST_IMPRISSONED3) {
				setMainQuestFlag(MAINFLAG_SLAVEPRISON, false);				
			}
			_MainQuestStage = x;
		}
		public function getMainQuestStage():uint {
			return _MainQuestStage;
		}
		//}
		//{  --> body 
		//  TODO definition of bodyparts 
		private var _BodyType:uint = 0; /*
		public static const BODY_HAND:uint 		= 0x0001;
		public static const BODY_FEET:uint 		= 0x0002;
		public static const BODY_TORSO:uint 	= 0x0004;
		public static const BODY_HEAD:uint 		= 0x0008;
		public static const BODY_TYPE:uint 		= 0x0010; 
		// up to public static const BODY_??:uint 	= 0x8000;
		//byte0&1 is the slot , byte 2&3 is the gear 	
		public static const B_HAND_WOLF:uint 	= 0x000001;
		public static const B_FEET_WOLF:uint 	= 0x000002;
		public static const B_TORSO_WOLF:uint 	= 0x000004;
		public static const B_HEAD_WOLF:uint 	= 0x000008;
		public static const B_TYPE_2LEG2ARM:uint 	= 0x000010; 
		public static const B_TYPE_4LEG:uint 		= 0x010010;  //feral
		public static const B_TYPE_4LEG2ARM:uint 	= 0x010010;  // taur with normal torso
		*/
		
		public function getCockSize(Index:int=0):Number {
			var _size:Number;
			if (Index == 0) { 
				_size = (Number(_CockStats & 0x1FF  )/0x1) / 10;
			} else if (Index == 1) {
				_size = (Number((_CockStats & 0x1FF000)/0x1000)) / 10;
			} else if (Index > 1 && Index < 7) { // Pentaclecocks
				_size = (Number((_CockStats & 0xFF000000)/0x1000000))*2 ;
			} else {
				_size = 0;
			}
			return _size;
		}
		public function getCockCount():int {
			var _count:int =0;//= (int((_CockStats & 0xE00000 ) / 0x200000));
			if (getCockSize(0) > 0) _count++;
			if (getCockSize(1) > 0) _count++;
			
			return _count;
		}
		public function getPentacleCockCount():int {
			var _count:int = (int((_CockStats & 0xE00000 ) / 0x200000));	
			return _count;
		}
		private var _CockStats:uint;  //
		/*set size to 0 to remove cock; index can only be 0,1 for normal cock and 2,4,6 for pentaclecocks
		 */ 
		public function setCock(Size:Number, Index:int):void {
			var _size:uint = uint(Math.min(Size * 10, 0x1FF));  //0.1 inch per bit 0x1FF bits => capped at 51.1"
			var _count:int = (int((_CockStats & 0xE00000 ) / 0x200000)); // count Pentaclecocks (0..7)
			//cocksize 1.cock bits 0to8  ; cocktype bits 9to11 Todo:currently just dogcock
			//cocksize 2.cock bits 12to20 ; same cocktype like 1.cock
			//Pentaclecocks use bits 24to31; 2inch per bit capped at 510"
			// bit-map: 3333 3333 ccc2 2222 2222 ttt1 1111 1111 
			//todo: oh my this is crap shifting bits forth and back, would be easier with arrays
			if (Index == 0 ) {
				if (_size <= 0) {
					// copy 2.cock to 1.
					_size = ((_CockStats & (0x001FF000))/0x1000);
					_CockStats = (_CockStats & 0xFFE00E00) | _size;
				} else {
					_CockStats = (_CockStats & 0xFFFFFE00) | _size;
				}
			} else if (Index == 1 ) {
				if (_size <= 0) {
					_size = _CockStats & 0xFFE00FFF;
				} else {
					_CockStats = (_CockStats & 0xFFE00FFF) | (_size*0x1000);
				}
			} else if (Index >= 2 && Index <= 6) { // Pentaclecocks
				_size =(Math.min(Size / 2, 0x1FF));
				if (_size <= 0) {  //remove pentaclcocks up to this index
					_count = Index - 2;
				} else { // add cocks up to this index
					_count = Math.max(_count, Index);
				}
				_CockStats = (_CockStats& 0x001FFFFF) | (_size*0x01000000) | (_count*0x00200000);
	
			}
			
		}
		private var _BallStats:uint;  //  
		public function setBalls(Size:Number, Count:int):void {
			var _size:uint = uint(Math.min(Size * 100, 0xFFF)) *  0x100000; //0.01 inch per bit 0xFFF bits => capped at 40.95"
			var _count:uint = uint(Count & 0x6); //bits 1&2 = count  (0,2,4,6)
			_BallStats = _size + _count;
		}
		public function getBallSize():Number {
			var _size:Number = (Number((_BallStats & 0xFFF00000 ) / 0x100000)) / 100;
			return _size;
		}
		public function getBallCount():int {
			var _count:int = (int((_BallStats & 0x6 )));
			return _count;
		}
		private var _VaginalStats:uint = 0;
		public function getVaginaSize():Number {
			return  0;
		}
		public function getVaginaVirgin():Boolean {
			return  true;
		}
		public function hasVagina():Boolean {
			return  false;
		}
		public function setVagina( Looseness:Number,  isVirgin:Boolean,  hasVagina:Boolean):void {
		}
		private var _AnalStats:uint = 0; //2 bytes Analsize ?00/50000 per bit ; 7bit AnalTraining ?; 1bit isVirgin
		public function getAnalSize():Number {
			return  0;
		}
		public function getAnalVirgin():Boolean {
			return  true;
		}
		public function setAnus( Looseness:Number,  isVirgin:Boolean, Wetness:Number):void {

		}
		public function setBreast (size:Number, Rows:int):void {
			
		}
		public function fenrisMF(man:String, woman:String):String	{
			return man;
		}
		//returns 0 if he eats it
		public function eatThis(Food:SimpleConsumable, Result:ReturnResult):void {
			if (Food == kGAMECLASS.consumables.VITAL_T) {
				Result.Code = 0;
				Result.Text = "[fenris Ey] uncorks the bottle and then gulps down its content without hesitation. The invigorating effect immediatly refreshs [fenris em]."
				//Todo: refresh HP?
				setPlayerRelation(getPlayerRelation() + 3);
			}else if (Food == kGAMECLASS.consumables.CANINEP) { 
				Result.Code = 0;
				Result.Text = "[fenris Ey] takes some bites from the fruit ";
				if (getBodyStrength() < 70) {
					setBodyStrength(getBodyStrength() + 3)
					Result.Text += "and [fenris eir] features seems to get slightly more like that of an predator. \n";
				} else {
					Result.Text += "but it doesnt seem to have an effect on [fenris em]. \n "
				}
				if (getCorruption() < 60) {
					setCorruption(getCorruption() + 3)
					Result.Text += "You get the impression that an dangerous spark is glinting in [fenris eir] eyes, but a moment later it's gone."
				} else {
				}
				
			}else if (Food == kGAMECLASS.consumables.SDELITE) { 
				Result.Code = 0;
				Result.Text = "[fenris Ey] uncorks the bottle, sniffs at it and take some sips on it.";
				if (getBodyStrength() < 70 && getCockSize()> 0) {
					setBodyStrength(getBodyStrength() + 3)
					Result.Text += "and [fenris eir] features seems to get slightly more like that of an predator. \n";
				} else {
					Result.Text += "It doesnt seem to taste well, so [fenris ey] spews out the little bit he drank. \n "
				}
				if (getCorruption() < 70) {
					setCorruption(getCorruption() + 3)
					Result.Text += "You get the impression that an dangerous spark is glinting in [fenris eir] eyes, but a moment later it's gone.\n"
				} else {
				}
			}else if ( Food == kGAMECLASS.consumables.PPHILTR) { 	
				Result.Code = 0;
				Result.Text = "[fenris Ey] uncorks the bottle, sniffs at it and take some sips off it.\n";
				if (getCorruption() > 8) {
					setCorruption(getCorruption() - 8)
					Result.Text += "You get the impression that [fenris ey] loose some of the dark taint.\n"
				} else {
				}
			} else {
				Result.Code = 1;
				Result.Text = "Fenris doesnt seem to like " + Food.shortName +" and gives it back to you."
				return ;
			}
		}
		//}  //
		//{ --> stuff related to Items
		//definition of items & equipment slots; actually only virtual items		
		public static const ITEMSLOT_UNDERWEAR:uint 		= 0x0001;
		public static const ITEMSLOT_WEAPON:uint 			= 0x0002;
		public static const ITEMSLOT_PIERC_BREAST:uint 	= 0x0004;
		public static const ITEMSLOT_HEAD:uint 			= 0x0008;
		public static const ITEMSLOT_FEET:uint 			= 0x0010; // & lower legs
		public static const ITEMSLOT_HAND:uint 			= 0x0020; // & lower arms
		public static const ITEMSLOT_NECK:uint 			= 0x0040;
		public static const ITEMSLOT_CHEST:uint 		= 0x0080;
		// up to public static const ITEMSLOT_??:uint 	= 0x8000;
		//byte0&1 is the slot , byte 2&3 is the gear - dont forget to also add description 				
		public static const UNDERWEAR_NONE:uint 			= 0x000001;
		public static const UNDERWEAR_LOINCLOTH:uint 		= 0x020001;  //his default loincloth	
		public static const UNDERWEAR_COCKCAGE:uint 		= 0x030001;  //cock or clitcage ; quest related
		public static const UNDERWEAR_COCKRING:uint 		= 0x040001; // a metal ring fitted around base of cock and balls; min lust 20 
		public static const UNDERWEAR_BALLSTRETCHER:uint 	= 0x050001; // a thick&heavy looking metal ring around his nutsack; ++tease  --evade
		public static const WEAPON_NONE:uint 			= 0x000002;
		public static const WEAPON_KNIFE:uint 			= 0x010002;  //his default tool-knife
		public static const WEAPON_PIPE:uint 			= 0x020002;  //
		public static const HEAD_NONE:uint 				= 0x000008;
		public static const HEAD_MUZZLE:uint 			= 0x010008;  //leatherstraps around muzzle, cannot bite
		public static const HEAD_MUZZLEFULL:uint 		= 0x020008;  //full head muzzle add. obscuring view and other senses
		public static const NECK_NONE:uint 				= 0x000040; 
		public static const NECK_LUCKPENDANT:uint 		= 0x010040;	// a talisman to shield him from bad events
		public static const NECK_PETCOLLAR:uint 		= 0x020040; // a red colored leahter collar with his name tag; 
		public static const NECK_SPIKEDCOLLAR:uint 		= 0x030040; // a thick black leather collar with metal spikes ; 
		
		
		private var _AvailableItems:Array = []; //unordered list of items
		public function getAllItems(): Array {
			return _AvailableItems;
		}
		public function setAllItems(items:Array):void {
			_AvailableItems = items;
		}
		private var _EquippedItems:Array = [];	//index of array is slot, value is item
		public function getEquippedItems(): Array {
			return _EquippedItems;
		}
		public function setEquippedItems(items:Array):void {
			_EquippedItems = items;
		}
		public function hasItem(item:uint):Boolean {					
			return getAllItems().indexOf(item) >= 0;	
		}
		public function getEquippedItem(slot:uint):uint {
			if (slot<=0 || slot >0x8000) return 0;
			return (uint)(getEquippedItems()[slot]);
		}

		public function getEquippedItemText(slot:uint, detailed:Boolean):String{
			var _item:uint = getEquippedItem(slot);
			var _text:String;
			switch(slot) {
				case ITEMSLOT_UNDERWEAR:
					switch (_item) {
						case UNDERWEAR_NONE:
							_text= "naked crotch";
							break;
						case UNDERWEAR_LOINCLOTH:
							_text= "selfmade loin cloth"
							break;
						case UNDERWEAR_COCKCAGE:
							_text= "full metal cockcage"
							break;
						default:
							_text= "invalid item";
					}
					break;
				case ITEMSLOT_WEAPON:
					switch (_item) {
						case WEAPON_NONE:
							_text= "barehanded";
							break;
						case WEAPON_KNIFE:
							_text= "plain knife"
							break;
						case WEAPON_PIPE:
							_text= "simple pipe"
							break;
						default:
							_text= "invalid item";
					}
					break;
				default: 
					_text="oh no-invalid slot";
			}	
			return _text;
		}
		/* translates between USEABLE and Fenris-Items
		 * */
		public function equipItemFromUseable(item:Useable , give:Boolean , Result:ReturnResult):void {
			if (item == kGAMECLASS.weapons.PIPE) {
				equipItem(ITEMSLOT_WEAPON, WEAPON_PIPE, true, Result);
			} else if (item == kGAMECLASS.undergarments.FURLOIN) {
				equipItem(ITEMSLOT_UNDERWEAR, UNDERWEAR_LOINCLOTH, true, Result);
			} else {
				Result.Code = 1;
				Result.Text = "Fenris cannot use this item.";
			}
			
		}
		/*returns 0 if ok or message if nok
		 * */
		public function equipItem(slot:uint, item:uint , give:Boolean , Result:ReturnResult):void {
			canEquipItem(slot, item, true, Result);
			if (Result.Code!= 0) return ;
			//check if we own this item and havent it already equipped
			if (!hasItem(item)) {
				if (!give) {
					Result.Text = "Fenris doesnt have this item";
					Result.Code = 1;
					return;
				} else {
					getAllItems().push(item);
				}
			} //Todo: if he already has this item we should not give him another one
			getEquippedItems()[slot] = item;
		}
		/*returns 0 if ok or message if nok
		 * */
		public function unequipItem(slot:uint,item:uint, take:Boolean, Result:ReturnResult):void {
			//check if we own this item and havent it already equipped
			if (!hasItem(item))	{
				Result.Text = "Fenris doesnt have this item";
				Result.Code = 1;
				return;
			}
			canUnequipItem(item,Result);
			if (Result.Code != 0) return ; 
			getEquippedItems()[slot] = slot;  //this slot is set to XYZ_NONE
			if (take) {
				getAllItems().splice(getAllItems().indexOf(item), 1);
			}

		}
		/*returns 0 if ok or message if nok
		 * */
		public function canEquipItem(slot:uint, item:uint,  withUnequip:Boolean, Result:ReturnResult):void {
			// check if item is appropiate for slot

			if (((item & 0xFF00) | slot) != slot) {
				Result.Text = "cannot equip this item in this slot";
				Result.Code = 1;
				return;
			} else if (getEquippedItem(slot) == item) { 
				Result.Text = "Fenris already has this item equipped";
				Result.Code = 1;
				return;
			} else if (getEquippedItem(slot) > 0 ) {
				if (withUnequip) {
					canUnequipItem(item, Result); 
					if (Result.Code != 0) return ;
				} else {
					Result.Text = "Fenris already has an item equipped";
					Result.Code = 1;
					return;
				}
			}
			if ((item ) == UNDERWEAR_COCKCAGE && this.getCockCount()<1) {
				Result.Text = "He needs a cock to use this item";
				Result.Code = 1;
				return;
			}
		}
		/*returns 0 if ok or message if nok
		 * */
		public function canUnequipItem(item:uint, Result:ReturnResult):void {
			// check if item can be removed
			//Todo: add quest related stuff
			if ((item ) == UNDERWEAR_COCKCAGE) {
				Result.Text = "Without the proper key you cannot remove the cockcage";
				Result.Code = 1;
				return;
			} else {
				Result.Code = 0;
			}
		}
		//}
		//{ --> constructor and such
		private var _BreastStore:BreastStore;
		private var pregnancy:PregnancyStore;
		private var _initDone:Boolean = false;	
		private static var _instance:Fenris;
		/**implemented as singleton because Fenris is unique
		 * */
		public static function getInstance():Fenris{
			if(!_instance){
				new Fenris();
			} 
			//workaround to initialise as soon as kGAMECLASS is valid
			if (kGAMECLASS != null && !_instance._initDone) {
				_instance.initFenris(false);
			}
			return _instance;
		}
		public function Fenris(){
			if(_instance){
				throw new Error("Singleton... use getInstance()");
			} 
			_instance = this;
			CoC.saveAwareClassAdd(this);
			CoC.timeAwareClassAdd(this);
			_BreastStore = new BreastStore(kFLAGS.FENRIS_BREAST);
			CoC.saveAwareClassAdd(_BreastStore);
		}
		
		/* for debug-Reset
		 */
		public function resetFenris():void {
			initFenris(true);
		}
		private function initFenris(forceInit:Boolean):void {
			if (!_initDone || forceInit) {
				//first time initialisation
				setVagina(0, true, false);
				setAnus(0, true,0);
				setCock(5.5 , 0);
				setBalls(1 , 2);
				setBreast(0, 1);
				setSelfEsteem(50);
				setBodyStrength(31);
				setCorruption(2);
				setPlayerRelation(10);
				setLevel( 1);
				setLust(0);
				setLibido(0);
				_MainQuestStage = 0;
				_MainQuestFlags = 0;
				_TempFlags = 0;
				var _Result:ReturnResult = new ReturnResult();
				equipItem(ITEMSLOT_UNDERWEAR,UNDERWEAR_LOINCLOTH,true,_Result);
				equipItem(ITEMSLOT_WEAPON,WEAPON_KNIFE,true,_Result);
			}
			_initDone = true;
		}	
		//}
		//{ --> Implementation of SaveAwareInterface
		
		private static const FENRIS_STORE_Flag:int = kFLAGS.FENRIS_FLAG;
		private static const MAX_FLAG_VALUE:int	= 2999;
		
		public function updateAfterLoad(game:CoC):void {
			var _Level:Number = Fenris.getInstance().getLevel(); //dummy to force init of Fenris if not already done
			if (FENRIS_STORE_Flag < 1 || FENRIS_STORE_Flag > MAX_FLAG_VALUE) return;
			
			var flagData:Array = String(game.flags[FENRIS_STORE_Flag]).split("^");
			var _oldversion:String = ((String) (flagData[0]));
			//if we need to change save-structure, create version , add code-fragment here and update version in updateBeforeSave
			//
			if ( _oldversion == "1" /*FENRIS_STORE_VERSION*/)  {	
				_oldversion = updateAfterLoadV1(flagData);
			}
			
			if (_oldversion == "2" ) {
				_oldversion = updateAfterLoadV2(flagData);					
			}
			resetFenris(); //
		}
		private function updateAfterLoadV2(flagData:Array):String {
			_Corruption				= uint(flagData[1]);
			_SelfEsteem				= uint(flagData[2]);
			_PlayerRelation			= uint(flagData[3]);
			_MainQuestStage			= uint(flagData[4]);
			_MainQuestFlags			= uint(flagData[5]);
			_CockStats				= uint(flagData[6]);
			_BallStats				= uint(flagData[7]);
			_LibidoLust				= uint(flagData[8]);
			_AnalStats				= uint(flagData[9]);
			_VaginalStats			= uint(flagData[10]);
			_BodyStrength 			= uint(flagData[11]);
			_Level					= uint(flagData[12]);
			_BodyType				= uint(flagData[13]);
			_SexEducat				= uint(flagData[14]);
			var _allItems:String	= String(flagData[15]);
			var _equItems:String  	= String(flagData[16]);
			updateItemsAfterLoad(_allItems,_equItems);		
			return "2";	//updated to version;	
		}
		private function updateAfterLoadV1(flagData:Array):String {
			//im to lazzy: check for flagData.length
			_Corruption				= uint(flagData[1]);
			_SelfEsteem				= uint(flagData[2]);
			_PlayerRelation			= uint(flagData[3]);
			_MainQuestStage			= uint(flagData[4]);
			_MainQuestFlags			= uint(flagData[5]);
			_CockStats				= uint(flagData[6]);
			_BallStats				= uint(flagData[7]);
			_LibidoLust				= uint(flagData[8]);
			_AnalStats				= uint(flagData[9]);
			_VaginalStats			= uint(flagData[10]);
			_BodyStrength 			= uint(flagData[11]);
			_Level					= uint(flagData[12]);
			var _allItems:String	= String(flagData[13]);
			var _equItems:String  	= String(flagData[14]);
			updateItemsAfterLoad(_allItems,_equItems);		
			return "1";	//updated to version;		
		}
		private function updateItemsAfterLoad(AllItems:String, EquipItems:String):void {
			var _allItemsArr:Array = AllItems.split("~");
			var _allItemsArr2:Array = []; 
			var _slot:Array;
			var item:String;
			for ( item in _allItemsArr) 	{ 
				_slot = _allItemsArr[item].split(":");
				if(_slot[0]!="") _allItemsArr2[uint(_slot[0])]=(uint(_slot[1]));
			}
			this._AvailableItems = _allItemsArr2;
			var _equItemsArr:Array = EquipItems.split("~");
			var _equItemsArr2:Array = []; 
			for ( item in _equItemsArr) 	{ 
				_slot = _equItemsArr[item].split(":");
				if(_slot[0]!="") _equItemsArr2[uint(_slot[0])]=(uint(_slot[1]));
			}
			this._EquippedItems = _equItemsArr2;
		}
		private static const FENRIS_STORE_VERSION:String	= "2";	//the actual save file version for fenris
		public function updateBeforeSave(game:CoC):void {
			if (FENRIS_STORE_Flag < 1 || FENRIS_STORE_Flag > MAX_FLAG_VALUE) return;
			var _allItems:String = "";
			var _allItemsArr:Array = this.getAllItems();
			var item:String;
			for ( item in _allItemsArr)	{
				_allItems += item+":"+(_allItemsArr[item]).toString() + "~";
			}
			var _equItems:String = "";
			var _equItemsArr:Array = this.getEquippedItems();
			for ( item in _equItemsArr)	{ 
				_equItems += item+":"+(_equItemsArr[item]).toString()+ "~";
			}
			//Save is only implemented for the last version; no need to save backward compatible version
			game.flags[FENRIS_STORE_Flag] = FENRIS_STORE_VERSION + "^" + 	//<== V2
			_Corruption 	+ "^" + 
			_SelfEsteem 	+ "^" + 
			_PlayerRelation + "^" + 
			_MainQuestStage + "^" + 
			_MainQuestFlags + "^" +
			_CockStats		+ "^" +
			_BallStats		+ "^" +
			_LibidoLust		+ "^" +
			_AnalStats		+ "^" +
			_VaginalStats	+ "^" +
			_BodyStrength 	+ "^" +
			_Level 			+ "^" +
			_BodyType		+ "^" +
			_SexEducat		+ "^" +
			_allItems 		+ "^" +
			_equItems;
		}
		//}
		//{ --> Implementation of TimeAwareInterface
		public function timeChange():Boolean
		{
			//pregnancy.pregnancyAdvance();
			trace("\nFenris time change: Time is " + kGAMECLASS.model.time.hours , false);
			var _Return:Boolean = getMainQuestStage() >= MAINQUEST_Greetings;
			if (_Return) {
				_Return = false;
				var _rand:Number; 
				var _XPChance:Number=0;
				//at 100lib increase lust by 48/24h, minimum of 20lib required for buildup
				var _lust:Number = getLust() + (getLibido()-20) * 2 / 100;  
				if (_lust > 90 ) _lust = 90;
				setLust(_lust);
				
				if (kGAMECLASS.model.time.hours >= 16 && kGAMECLASS.model.time.hours < 17) {
					//Todo: depending on quest, availbale areas a.s.o calculate chance for fenris to win/loose afight
					if (getLevel()< (kGAMECLASS.player.level+3)) {
						_rand = Utils.rand(100);
						_XPChance = _XPChance+40;
						if (testMainQuestFlag(MAINFLAG_SEARCH_DEEPWOOD)) _XPChance = _XPChance+10;
						if (testMainQuestFlag(MAINFLAG_SEARCH_DESERT)) _XPChance = _XPChance+10;
						if (testMainQuestFlag(MAINFLAG_SEARCH_FOREST)) _XPChance = _XPChance+ 10;
						if (testMainQuestFlag(MAINFLAG_SEARCH_MOUNTAIN)) _XPChance = _XPChance+ 10;
						if (_rand < _XPChance ) {
							if (addXP(10*getLevel())) {
								_Return = true;
								kGAMECLASS.outputText("You hear rumors that Fenris leveld up.\n");
							}
						}
					}
				}
				if (kGAMECLASS.player.hasStatusEffect(StatusEffects.FenrisCombatSupport)) { //? should be moved to player?
					if (kGAMECLASS.player.statusEffectv1(StatusEffects.FenrisCombatSupport) > 0) {
						kGAMECLASS.player.addStatusValue(StatusEffects.FenrisCombatSupport, 1, -1); //Decrement cooldown!
					}
				}
				setTempFlag(TEMPFLAG_SEXED_COOLDOWN, false); //unlock SexEd-dialog once per day
			}
			return _Return;
		}
	
		public function timeChangeLarge():Boolean {			
			return false;
		}
		//}
		//{ -->  functions for parser callbacks to convert pronouns
		// Todo:add herm and other converters
		public function get descrwithclothes():String { 
			var _str:String = "Fenris the wolfman wears "+this.getEquippedItemText(ITEMSLOT_UNDERWEAR, true) +" and uses " +this.getEquippedItemText(ITEMSLOT_WEAPON,true)+ " as weapon.\n";
			if (testTempFlag(TEMPFLAG_BODY_DOWN) || testTempFlag(TEMPFLAG_BODY_UP) ) {
				_str += "You notice that "+eir+" body has undergone some changes since you saw "+em  +". \n";
				setTempFlag(TEMPFLAG_BODY_DOWN, false);
				setTempFlag(TEMPFLAG_BODY_UP, false);
			}
			//Todo: add body description
			if (getBodyStrength() >= 90) {
				_str += "Thick muscels bulge around "+eir+" arms and legs. A taut set of sixpack and pectorials make a impressive eye-catch.\n";
			//} else if (getBodyStrength() >= 75) {
				
			//}else if (getBodyStrength() >= 60) {
				
			//}else if (getBodyStrength() >= 45) {
				
			}else if (getBodyStrength() >= 30) {
				_str += "Fenris has a rather slender body. You can see muscles here and there but it's not that impressive. \n";
				
			//}else if (getBodyStrength() >= 15) {
				
			} else {
				_str += "Fenris body is of slight, feminine build. \n";
			}
			_str += "Dense fur covers "+eir+ " entire body." //Todo coat description
			if (testTempFlag(TEMPFLAG_CORRUPTION_DOWN) || testTempFlag(TEMPFLAG_CORRUPTION_UP) ) {
				if (testTempFlag(TEMPFLAG_CORRUPTION_UP)) _str += Ey + " seems to be more corrupted than the last time. \n";
				else _str += Ey + " seems to be much less corrupted than the last time. \n";
				setTempFlag(TEMPFLAG_CORRUPTION_DOWN, false);
				setTempFlag(TEMPFLAG_CORRUPTION_UP, false);
			}
			//Todo: add demon feature description
			if (getCorruption() >= 90) {
				_str += "Corruption seeps from every inch of "+eir+" body. \n";
				
			//} else if (getCorruption() >= 75) {
				
			//}else if (getCorruption() >= 60) {
				
			//}else if (getCorruption() >= 45) {
				
			}else if (getCorruption() >= 30) {
				_str += "While been walking this strange land for a while, "+eir+" body and mind seems only sligthly tainted. \n";
				
			//}else if (getCorruption() >= 15) {
				
			} else {
				_str += Eir+" body and mind seems to be completely untained by the corruption of this world. \n";
			}
			//Todo add cock and vagina descr
			var _underwear:uint = getEquippedItem(ITEMSLOT_UNDERWEAR);
			if (_underwear == UNDERWEAR_NONE || _underwear==UNDERWEAR_BALLSTRETCHER || _underwear==UNDERWEAR_COCKCAGE) {
				_str += "You can see " + eir + getBallCount() +" gonads swinging below his sheath. Each orb measures around " + getBallSize() + " inches. \n"; 
				if (_underwear==UNDERWEAR_BALLSTRETCHER) _str+= "A heavy ballstretcher is fitted tightly around the base of [fenris eir] nutsack, giving it a constant tug downwards. "
				if (getLust()> 90 && (_underwear == UNDERWEAR_NONE || _underwear==UNDERWEAR_BALLSTRETCHER)) {
					_str += Eir + " throbing, "+getCockSize()+"inch long wolfhood stands proudly errect from "+eir+" sheath. \n";
				} else if (getLust() > 60 && (_underwear == UNDERWEAR_NONE || _underwear==UNDERWEAR_BALLSTRETCHER)) {
					_str += Eir + " halfhard schlong is mostly out of its sheath and is flapping around whenever he moves. You guess it would be " + getCockSize() + " inch long when fully errect. \n";
				}else if (getLust() > 30 && (_underwear == UNDERWEAR_NONE || _underwear==UNDERWEAR_BALLSTRETCHER)) {
					_str += "Only the tip of "+ eir + " dick is poking out of the fuzzy sheath. You guess it would be "+getCockSize()+"inch long when fully errect. \n";
				}else  if (_underwear != UNDERWEAR_COCKCAGE ){
					_str += Eir + " penis is savely hidden in its furred sheath. You guess it would be "+getCockSize()+"inch long when fully errect. \n";
				} else {
					_str += Eir + " sheath is securely engulfed by a solid looking cockcage. \n";
				}
			} else if(getEquippedItem(ITEMSLOT_UNDERWEAR) == UNDERWEAR_LOINCLOTH) {
				_str += Eir + " loincloth is obscuring the view of "+eir+" private bits." 
			}
			if (getPentacleCockCount()>0) {
				if (getLust()> 80) {
					_str += Eir + " "+getPentacleCockCount()+" slivering, bulging tentacles are frantically twisting behind is back. There bulging tips are convulsing and opening from time to time, continously seeping a suspicios slimy substance. Better not to get into reach of those things. \n";
				} else if (getLust() > 60) {
					_str += "At first you didn't want to take notice but now you can seen that there are some odd appendages swinging throug the air behind his back.\n";
					_str += getPentacleCockCount()+" twisting, purple tentacles , each of them thick as your wrist and glistening slimily. \n";
				}else if (getLust() > 40) {
					_str += "You are not sure but was there some movement on his back?\n";
				}
			}
			
			return _str;
		}
		
		public function get status():String {
			return "\nLevel " + this.getLevel() +" XP " +this.getXP()  + "\n Corruption " + this.getCorruption() + "\n Selfesteem " + this._SelfEsteem +
			"\n Libido " +this.getLibido() + " Lust " +getLust() +
			"\n Playerrelation " +this.getPlayerRelation() + "\n MainQuestStage " + this._MainQuestStage.toString() + "\n MainQuestFlag 0x" +this._MainQuestFlags.toString(16) +"\n";
			
		}
		public function get Ey():String {
			if (getCockCount() > 0) {
				if (hasVagina()) return "Shi";
				else return "He";
			}
			return "She";
		}
		public function get ey():String {
			return Ey.toLowerCase();
		}
		public function get Eir():String {
			if (getCockCount() > 0) { 
				if (hasVagina()) return "Hir";
				else return "His";
			}
			return "Her";
		}
		public function get eir():String {
			return Eir.toLowerCase();
		}
		public function get Em():String {
			if (getCockCount() > 0) {
				if (hasVagina()) return "Hir";
				else return "Him";
			}
			return "Her";
		}
		public function get em():String {
			return Em.toLowerCase();
		}
		public function get Eirs():String {
			if (getCockCount() > 0) {
				if (hasVagina()) return "Hirs";
				else return "His";
			}
			return "Hers";
		}
		public function get eirs():String {
			return Eirs.toLowerCase();
		}
		public function get Emself():String {
			if (getCockCount() > 0) {
				if (hasVagina()) return "Hirself";
				else return "Himself";
			}
			return "Herself";
		}
		public function get emself():String {
			return Emself.toLowerCase();
		}
		//} End functions for parser callbacks
		
		
	}

}