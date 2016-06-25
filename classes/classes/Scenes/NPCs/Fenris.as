package classes.Scenes.NPCs
{

	import classes.BreastRowClass;
	import classes.BreastStore;
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
	import classes.SaveAwareInterface;

	public class Fenris implements SaveAwareInterface, TimeAwareInterface //extends Monster 
	{
		//those are the main quest stages
		public static const MAINQUEST_Not_Met:uint = 0;		//initial value
		public static const MAINQUEST_Spotted:uint = 1;		//PC heard him in the bushes
		public static const MAINQUEST_Spotted2:uint = 2;	//PC saw him at the lake
		public static const MAINQUEST_Greetings:uint = 3;	//PC talked to him first time
		public static const MAINQUEST_Steal_Cloth:uint = 4; //PC decided to steal his loin cloth
		public static const MAINQUEST_SEARCH_DEEPWOOD:uint = 5; //
		public static const MAINQUEST_AVOID_DEEPWOOD:uint = 6; //
		public static const MAINQUEST_SEARCH_MOUNTAIN:uint = 7; //
		public static const MAINQUEST_AVOID_MOUNTAIN:uint = 8; //
		public static const MAINQUEST_SEARCH_FOREST:uint = 9; //
		public static const MAINQUEST_AVOID_FOREST:uint = 10; //
		//those flags keep track of the mainquest history (bitwise)
		public static const MAINFLAG_Stole_Cloth:uint = 	1 << 0;	//PC stole loin cloth
		public static const MAINFLAG_SEARCH_DEEPWOOD:uint = 1 << 1;	//
		public static const MAINFLAG_SEARCH_MOUNTAIN:uint = 1 << 2;	//
		public static const MAINFLAG_SEARCH_FOREST:uint = 	1 << 3;	//
		public static const MAINFLAG_SEARCH_DESERT:uint = 	1 << 4;	//
		{// --> stats
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
		// Todo: how about XP adjustment
		private function setLevel(value:uint):void { 
			_Level = (value & 0xFF) +  (_Level & 0xFFFFFF00 ); 
		} 
		public function getCockSize():Number {
			return 5.5;
		}
		private var _Corruption:Number =0;
		public function getCorruption():Number {
			return _Corruption;
		}
		public function setCorruption(x:Number):void {
			_Corruption=(x);
		}
		private var _BodyStrength:Number = 0;
		/* returns fitness/masculinity of body  0=no muscles 100=bodybuilder on steroids  
		 */ 
		public function getBodyStrength():Number {
			return _BodyStrength;
		}
		public function setBodyStrength(x:Number):void {
			_BodyStrength=(x);
		}
		private var _SelfEsteem:Number = 0;
		/* returns confidence of himself, modifys chances for fullfilling others request:0= easy to dominate 100= dominating others 
		 */ 
		public function getSelfEsteem():Number {
			return _SelfEsteem;
		}
		public function setSelfEsteem(x:Number):void {
			_SelfEsteem=(x);
		}
		private var _PlayerRelation:Number = 0;
		/* returns relation to player, 0= neutral, 100=lover, -100=nemesis
		 */ 
		public function getPlayerRelation():Number {
			return _PlayerRelation;
		}
		public function setPlayerRelation(x:Number):void {
			_PlayerRelation=(x);
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
			if (x == MAINQUEST_Steal_Cloth) {
				setMainQuestFlag(MAINFLAG_Stole_Cloth, true);
				unequipItem(ITEMSLOT_UNDERWEAR, UNDERWEAR_LOINCLOTH, true);
			}
			_MainQuestStage = x;
		}
		public function getMainQuestStage():uint {
			return _MainQuestStage;
		}
		public function getCockCount():Number {
			return  1;
		}
		public function setCock(Size:Number, isVirgin:Boolean,  Count:Number):void {
		}
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
		
		public function getAnalSize():Number {
			return  0;
		}
		public function getAnalVirgin():Boolean {
			return  true;
		}
		public function setAnus( Looseness:Number,  isVirgin:Boolean):void {
		}
		public function setBreast (size:Number, Rows:int):void {
			
		}
		public function fenrisMF(man:String, woman:String):String
		{
			return man;
		}

		}
		{ // --> stuff related to Items
		//definition of items & equipment slots; actually only virtual items
		public static var ITEMSLOT_UNDERWEAR:uint 		= 0x0100;
		public static var ITEMSLOT_WEAPON:uint 			= 0x0200;
		public static var ITEMSLOT_PIERC_BREAST:uint 	= 0x0400;
		public static var ITEMSLOT_HEAD:uint 			= 0x0800;
		public static var UNDERWEAR_NONE:uint = 0x100;
		public static var UNDERWEAR_LOINCLOTH:uint = 0x102;
		public static var UNDERWEAR_COCKCAGE:uint = 0x103;
		public static var WEAPON_NONE:uint = 0x200;
		public static var WEAPON_KNIFE:uint = 0x202;
		public static var HEAD_NONE:uint 				= 0x800;
		public static var HEAD_MUZZLE:uint 				= 0x801;
		
		private var _AvailableItems:Array = []; //uint
		public function getAllItems(): Array {
			return _AvailableItems;
		}
		public function setAllItems(items:Array):void {
			_AvailableItems = items;
		}
		private var _EquippedItems:Array = [];	//uint
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
		/*returns null if ok or message if nok
		 * */
		public function equipItem(slot:uint, item:uint , give:Boolean ):String {
			var _ret:String;
			_ret = canEquipItem(slot, item,true);
			if (_ret != null) return _ret;
			//check if we own this item and havent it already equipped
			if (!hasItem(item)) {
				if (!give) {
					return "Fenris doesnt have this item";
				} else {
					getAllItems().push(item);
				}
			} //Todo: if he already has this item we should not give him another one
			getEquippedItems()[slot] = item;
			
			return null;
		}
		/*returns null if ok or message if nok
		 * */
		public function unequipItem(slot:uint,item:uint, take:Boolean):String {
			var _ret:String;
			//check if we own this item and havent it already equipped
			if (!hasItem(item))	return "Fenris doesnt have this item";
			_ret = canUnequipItem(item);
			if (_ret != null) return _ret; 
			getEquippedItems()[slot] = 0;
			if (take) {
				getAllItems().splice(getAllItems().indexOf(item), 1);
			}
			return null;

		}
		/*returns null if ok or message if nok
		 * */
		public function canEquipItem(slot:uint, item:uint,  withUnequip:Boolean):String {
			// check if item is appropiate for slot
			var _ret:String;
			if (((item & 0xFF00) | slot) != slot) return "cannot equip this item in this slot";
			if (getEquippedItem(slot) == item) return "Fenris already has this item equipped";
			if (getEquippedItem(slot) > 0 ) {
				if (withUnequip) {
					_ret =  canUnequipItem(item);
					if (_ret != null) return _ret;
				} else {
					return "Fenris already has an item equipped"
				}
			}
			return null;		
		}
		/*returns null if ok or message if nok
		 * */
		public function canUnequipItem(item:uint):String {
			// check if item can be removed
			//Todo: add quest related stuff
			if ((item ) == UNDERWEAR_COCKCAGE) return "Without the proper key you cannot remove the cockcage";
			
			return null;		
		}
		}
		{// --> constructor and such
		private var _BreastStore:BreastStore;
		private var pregnancy:PregnancyStore;
		private static var _initDone:Boolean = false;	
		private static var _instance:Fenris;
		/**implemented as singleton because Fenris is unique
		 * */
		public static function getInstance():Fenris{
			if(!_instance){
				new Fenris();
			} 
			//workaround to initialise as soon as kGAMECLASS is valid
			if (kGAMECLASS != null && !_initDone) {
				_instance.initFenris();
			}
			return _instance;
		}
		public function Fenris()
		{
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
				setAnus(0, true);
				setCock(5.5 , true, 1);
				setBreast(0, 1);
				setSelfEsteem(50);
				setBodyStrength(50);
				setCorruption(2);
				setPlayerRelation(50);
				setLevel( 1);
			}
			_initDone = true;
		}	
		}
		{// --> Implementation of SaveAwareInterface
		private static const FENRIS_STORE_VERSION_1:String	= "1";
		private static const Flag:int = kFLAGS.FENRIS_FLAG;
		private static const MAX_FLAG_VALUE:int	= 2999;
		
		public function updateAfterLoad(game:CoC):void {
			var _Level:Number = Fenris.getInstance().getLevel(); //dummy to force init of Fenris if not already done
			if (Flag < 1 || Flag > MAX_FLAG_VALUE) return;
			var _allItems:String = "";
			var _equItems:String = "";
			var flagData:Array = String(game.flags[Flag]).split("^");
			if (((String) (flagData[0])) == "1" ){//im to lazzy: && flagData.length == 7) {
				_Corruption				= Number(flagData[1]);
				_SelfEsteem				= Number(flagData[2]);
				_PlayerRelation			= int(flagData[3]);
				_MainQuestStage			= uint(flagData[4]);
				_MainQuestFlags			= uint(flagData[5]);
				_Level					= Number(flagData[6]);
				//_allItems				= String(flagData[7]);
				//_equItems				= String(flagData[8]);
			}
			var _allItemsArr:Array = _allItems.split("~");
			var _allItemsArr2:Array = []; 
			var i:String;
			for ( i in _allItemsArr) 	{ 
				if(i!="") _allItemsArr2.push(uint(i));
			}
			this._AvailableItems = _allItemsArr2;
			var _equItemsArr:Array = _equItems.split("~");
			var _equItemsArr2:Array = []; 
			for ( i in _equItemsArr) 	{ 
				if(i!="") _equItemsArr2.push(uint(i));
			}
			this._EquippedItems = _equItemsArr2;

		}

		public function updateBeforeSave(game:CoC):void {
			if (Flag < 1 || Flag > MAX_FLAG_VALUE) return;
			var _allItems:String = "";
			var _allItemsArr:Array = this.getAllItems();
			var i:String;
			for (i in _allItemsArr) 	{ 
				_allItems += i + "~";
			}
			var _equItems:String = "";
			var _equItemsArr:Array = this.getEquippedItems();
			for ( i in _equItemsArr) 	{ 
				_equItems += i + "~";
			}
			game.flags[Flag] = FENRIS_STORE_VERSION_1 + "^" + 
			_Corruption + "^" + 
			_SelfEsteem + "^" + 
			_PlayerRelation + "^" + 
			_MainQuestStage + "^" + 
			_MainQuestFlags + "^" +
			_Level + "^" +
			_allItems + "^" +
			_equItems;
		}
		//End of Interface Implementation
		}
		{// --> Implementation of TimeAwareInterface
		public function timeChange():Boolean
		{
			//pregnancy.pregnancyAdvance();
			trace("\nFenris time change: Time is " + kGAMECLASS.model.time.hours , false);
			var _Return:Boolean = getMainQuestStage() >= MAINQUEST_Greetings;
			if (_Return) {
				_Return = false;
				var _rand:Number; 
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
		}
		{// -->  functions for parser callbacks to convert pronouns
		// Todo:add herm and other converters
		public function get descrwithclothes():String { 
			var _str:String = "Fenris the wolfman";
			_str += "underwear " +this.getEquippedItemText(ITEMSLOT_UNDERWEAR, true) + "\nweapon "+this.getEquippedItemText(ITEMSLOT_WEAPON,true);
			return _str;
		}
		
		public function get status():String {
			return "\nLevel " + this.getLevel() +" XP " +this._Level/0x100  + "\n Corruption " + this._Corruption + "\n Selfesteem " + this._SelfEsteem +
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
		}}// End functions for parser callbacks
		
		
	}

}
