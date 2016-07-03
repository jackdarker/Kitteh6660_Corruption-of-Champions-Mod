package classes.Scenes.NPCs{

	import classes.BreastRowClass;
	import classes.BreastStore;
	import classes.Items.Weapon;
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
	import classes.CockTypesEnum;
	import classes.Items.Consumables.SimpleConsumable;
	import classes.ItemType;
	import classes.SaveAwareInterface;

	//dont extends Monster because we need to change stats and features
	public class Fenris implements SaveAwareInterface, TimeAwareInterface 
	{
		//those are the main quest stages
		public static const MAINQUEST_Not_Met:uint = 		0;		//initial value
		public static const MAINQUEST_Spotted:uint = 		1;		//PC heard him in the bushes
		public static const MAINQUEST_Spotted2:uint = 		2;	//PC saw him at the lake
		public static const MAINQUEST_Greetings:uint = 		3;	//PC talked to him first time
		public static const MAINQUEST_Steal_Cloth:uint = 	4; //PC decided to steal his loin cloth
		public static const MAINQUEST_CAGED_Init:uint = 	5; //Fenris got COCKCAGE from Fetish guys
		public static const MAINQUEST_CAGED:uint = 			6; //Fenris got COCKCAGE from Fetish guys; you talked with him already

		//those flags keep track of the mainquest history (bitwise)
		public static const MAINFLAG_Stole_Cloth:uint = 	1 << 0;	//PC stole loin cloth
		public static const MAINFLAG_SEARCH_DEEPWOOD:uint = 1 << 1;	//
		public static const MAINFLAG_SEARCH_MOUNTAIN:uint = 1 << 2;	//
		public static const MAINFLAG_SEARCH_FOREST:uint = 	1 << 3;	//
		public static const MAINFLAG_SEARCH_DESERT:uint = 	1 << 4;	//
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
		public function setCorruption(x:Number):void {
			if (x < 0) return;
			_Corruption=(uint(x/0.002))&0xFFFF;
		}
		private var _LibidoLust:uint =0;  // 2 bytes Libido & 2 bytes Lust 100/50000 per bit
		public function getLibido():Number {
			return (Number(_LibidoLust & 0xFFFF)) * 0.002;
		}
		public function setLibido(x:Number):void {
			if (x < 0) return;
			_LibidoLust= (_LibidoLust & 0xFFFF0000 )+((uint(x/0.002))&0xFFFF);
		}
		public function getLust():Number {
			return (Number((_LibidoLust / 0x10000 ) & 0xFFFF)) * 0.002;
		}
		public function setLust(x:Number):void {
			if (x < 0) return;
			_LibidoLust=(_LibidoLust & 0xFFFF )+((uint(x/0.002))&0xFFFF)*0x10000;
		}
		private var _BodyStrength:uint = 0;
		/* returns fitness/masculinity of body  0=no muscles 100=bodybuilder on steroids  
		 */ 
		public function getBodyStrength():Number {
			return _BodyStrength;
		}
		public function setBodyStrength(x:Number):void {
			_BodyStrength=uint(x);
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
			return _PlayerRelation;
		}
		/** adds/substracts x from stat if stat is lower/higher than limit
		 */
		public function increasePlayerRelation(x:Number, limit:Number):void {
			_PlayerRelation = uint(increaseStat(_PlayerRelation,x,limit));
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
		
		public function setPlayerRelation(x:Number):void {
			_PlayerRelation=uint(x);
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
				setMainQuestFlag(MAINFLAG_Stole_Cloth, true);
				unequipItem(ITEMSLOT_UNDERWEAR, UNDERWEAR_LOINCLOTH, true, _Result);
			}
			_MainQuestStage = x;
		}
		public function getMainQuestStage():uint {
			return _MainQuestStage;
		}
		public function getCockSize(Index:int=0):Number {
			var _size:Number;
			if (Index == 0) { 
				_size = (Number(_CockStats & 0x1FF  )/0x1) / 10;
			} else if (Index == 1) {
				_size = (Number((_CockStats & 0x1FF000)/0x1000)) / 10;
			} else if (Index > 1 && Index < 7) { // Pentaclecocks
				_size = (Number((_CockStats & 0xFF000000)/0x1000000)) ;
			} else {
				_size = 0;
			}
			return _size;
		}
		public function getCockCount():int {
			var _count:int = (int((_CockStats & 0xE00000 ) / 0x200000));
			if (getCockSize(0) > 0) _count++;
			if (getCockSize(1) > 0) _count++;
			
			return _count;
		}
		private var _CockStats:uint;  //
		/*set size to 0 to remove cock; index can only be 0..1 actually
		 */ 
		public function setCock(Size:Number, Index:int):void {
			var _size:uint = uint(Math.max(Size * 10, 0x1FF));  //0.1 inch per bit 0x1FF bits => capped at 51.1"
			var _count:int = (int((_CockStats & 0xE00000 ) / 0x200000)); // count Pentaclecocks (0..7)
			//cocksize 1.cock bits 0to8  ; cocktype bits 9to11 Todo:currently just dogcock
			//cocksize 2.cock bits 12to20 ; same cocktype like 1.cock
			//Pentaclecocks use bits 24to31; 1inch per bit capped at 255"
			// bit-map: 3333 3333 ccc2 2222 2222 ttt1 1111 1111 
			//todo: oh my this is crap shifting bits forth and back, would be easier with arrays
			/*if (Index == 0 ) {
				if (_size <= 0) {
					_count = Math.max(0, _count -1);
					// copy 2.cock to 1.
					_size = ((_CockStats && (0x001FF000))/0x1000);
				} else {
					_count = _count | 0x1;
					
				}
			} else if (Index == 1 ) {
				if (_size <= 0) {
					_count = Math.max(0, _count -1);
					_size = _CockStats && !(0xFFE00FFF);
				} else {
					
				}
			} else if (Index > 1 && Index < 7) { // Pentaclecocks
				//Todo:
			}*/
			_CockStats = _size + _count;
		}
		private var _BallStats:uint;  //  
		public function setBalls(Size:Number, Count:int):void {
			var _size:uint = uint(Math.max(Size * 100, 0xFFF)) *  0x100000; //0.01 inch per bit 0xFFF bits => capped at 40.95"
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
		private var _AnalStats:uint = 0;
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
				if (getCorruption() < 70) {
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
				
			} else {
				Result.Code = 1;
				Result.Text = "Fenris doesnt seem to like " + Food.shortName +" and gives it back to you."
				return ;
			}
		}
		//}  //
		//{ --> stuff related to Items
		//definition of items & equipment slots; actually only virtual items
		//byte0&1 is the slot , byte 2&3 is the gear 
		public static var ITEMSLOT_UNDERWEAR:uint 		= 0x0001;
		public static var ITEMSLOT_WEAPON:uint 			= 0x0002;
		public static var ITEMSLOT_PIERC_BREAST:uint 	= 0x0004;
		public static var ITEMSLOT_HEAD:uint 			= 0x0008;
		public static var ITEMSLOT_FEET:uint 			= 0x0010;
		public static var ITEMSLOT_HAND:uint 			= 0x0020;
		public static var ITEMSLOT_NECK:uint 			= 0x0040;
						
		public static var UNDERWEAR_NONE:uint 			= 0x000001;
		public static var UNDERWEAR_LOINCLOTH:uint 		= 0x020001;  //his default loincloth	
		public static var UNDERWEAR_COCKCAGE:uint 		= 0x030001;
		public static var UNDERWEAR_COCKRING:uint 		= 0x040001;
		public static var WEAPON_NONE:uint 				= 0x000002;
		public static var WEAPON_KNIFE:uint 			= 0x010002;  //his default tool-knife
		public static var HEAD_NONE:uint 				= 0x000008;
		public static var HEAD_MUZZLE:uint 				= 0x010008;  //leatherstraps around muzzle, cannot bite
		public static var HEAD_MUZZLEFULL:uint 			= 0x020008;  //full head muzzle add. obscuring view and other senses
		
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
			if (slot<0 || slot >ITEMSLOT_PIERC_BREAST) return 0;
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
						default:
							_text= "invalid item";
					}
					break;
				default: 
					_text="oh no-invalid slot";
			}	
			return _text;
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
				_instance.initFenris();
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
		private function initFenris():void {
			if (!_initDone) {
				//first time initialisation
				setVagina(0, true, false);
				setAnus(0, true,0);
				setCock(5.5 , 0);
				setBalls(1 , 2);
				setBreast(0, 1);
				setSelfEsteem(50);
				setBodyStrength(40);
				setCorruption(2);
				setPlayerRelation(50);
				setLevel( 1);
				var _Result:ReturnResult = new ReturnResult();
				equipItem(ITEMSLOT_UNDERWEAR,UNDERWEAR_LOINCLOTH,true,_Result);
				equipItem(ITEMSLOT_WEAPON,WEAPON_KNIFE,true,_Result);
			}
			_initDone = true;
		}	
		//}
		//{ --> Implementation of SaveAwareInterface
		private static const FENRIS_STORE_VERSION_1:String	= "1";
		private static const FENRIS_STORE_Flag:int = kFLAGS.FENRIS_FLAG;
		private static const MAX_FLAG_VALUE:int	= 2999;
		
		public function updateAfterLoad(game:CoC):void {
			var _Level:Number = Fenris.getInstance().getLevel(); //dummy to force init of Fenris if not already done
			if (FENRIS_STORE_Flag < 1 || FENRIS_STORE_Flag > MAX_FLAG_VALUE) return;
			var _allItems:String = "";
			var _equItems:String = "";
			var i:int = -1;
			var flagData:Array = String(game.flags[FENRIS_STORE_Flag]).split("^");
			if (((String) (flagData[0])) == "1" ){//im to lazzy: && flagData.length == 7) {
				_Corruption				= uint(flagData[i++]);
				_SelfEsteem				= uint(flagData[i++]);
				_PlayerRelation			= uint(flagData[i++]);
				_MainQuestStage			= uint(flagData[i++]);
				_MainQuestFlags			= uint(flagData[i++]);
				_CockStats				= uint(flagData[i++]);
				_BallStats				= uint(flagData[i++]);
				_LibidoLust				= uint(flagData[i++]);
				_AnalStats				= uint(flagData[i++]);
				_VaginalStats			= uint(flagData[i++]);
				_BodyStrength 			= uint(flagData[i++]);
				_Level					= uint(flagData[i++]);
				_allItems				= String(flagData[i++]);
				_equItems				= String(flagData[i++]);
			
				var _allItemsArr:Array = _allItems.split("~");
				var _allItemsArr2:Array = []; 
				var item:String;
				for ( item in _allItemsArr) 	{ 
					if(item!="") _allItemsArr2.push(uint(item));
				}
				this._AvailableItems = _allItemsArr2;
				var _equItemsArr:Array = _equItems.split("~");
				var _equItemsArr2:Array = []; 
				for ( item in _equItemsArr) 	{ 
					if(item!="") _equItemsArr2.push(uint(item));
				}
				this._EquippedItems = _equItemsArr2;
			}
		}

		public function updateBeforeSave(game:CoC):void {
			if (FENRIS_STORE_Flag < 1 || FENRIS_STORE_Flag > MAX_FLAG_VALUE) return;
			var _allItems:String = "";
			var _allItemsArr:Array = this.getAllItems();
			var item:String;
			for (item in _allItemsArr) 	{ 
				_allItems += item + "~";
			}
			var _equItems:String = "";
			var _equItemsArr:Array = this.getEquippedItems();
			for ( item in _equItemsArr) 	{ 
				_equItems += item + "~";
			}
			game.flags[FENRIS_STORE_Flag] = FENRIS_STORE_VERSION_1 + "^" + 
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
				//update lust, if we hit 100, masturbate
				var _lust:Number = getLust() + (getLibido()-20) * 2 / 100;  //at 100lib increase lust by 48/24h
				if (_lust > 90 ) _lust = 90;
				setLust(_lust);
				
				if (kGAMECLASS.model.time.hours >= 16 && kGAMECLASS.model.time.hours < 17) {
					//Todo: depending on quest, availbale areas a.s.o calculate chance for fenris to win/loose afight
					if (getLevel()< (kGAMECLASS.player.level+3)) {
						_rand = Utils.rand(10);
						/*if (_rand > 8 )*/ {
							if (addXP(10)) {
								_Return = true;
								kGAMECLASS.outputText("You hear rumors that Fenris leveld up.\n");
							}
						}
					}
				}
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
			if (getEquippedItem(ITEMSLOT_UNDERWEAR) == UNDERWEAR_NONE) {
				_str += "You can see "+ eir + getBallCount() +" gonads swinging below his sheath. Each orb measures around " + getBallSize() + " inches. \n"; 
				if (getLust()> 90) {
					_str += Eir + " throbing, "+getCockSize()+"inch long wolfhood stands proudly errect from his sheath. \n";
				} else if (getLust() > 60) {
					_str += "[fenris Eir] halfhard schlong is mostly out of its sheath and is flapping around whenever he moves. You guess it would be "+getCockSize()+"inch long when fully errect. \n";
				}else if (getLust() > 30) {
					_str += "Only the tip of "+ eir + " dick is poking out of the fuzzy sheath. You guess it would be "+getCockSize()+"inch long when fully errect. \n";
				}else  {
					_str += Eir + " penis is savely hidden in its furred sheath. You guess it would be "+getCockSize()+"inch long when fully errect. \n";
				}
			} else if(getEquippedItem(ITEMSLOT_UNDERWEAR) == UNDERWEAR_LOINCLOTH) {
				_str += Eir + " loincloth is obscuring the view of his private bits." 
			}
			return _str;
		}
		
		public function get status():String {
			return "\nLevel " + this.getLevel() +" XP " +this.getXP()  + "\n Corruption " + this.getCorruption() + "\n Selfesteem " + this._SelfEsteem +
			"\n Libido " +this.getLibido() + " Lust " +getLust() +
			"\n Playerrelation " +this._PlayerRelation + "\n MainQuestStage " + this._MainQuestStage + "\n MainQuestFlag " +this._MainQuestFlags +"\n";
			
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
