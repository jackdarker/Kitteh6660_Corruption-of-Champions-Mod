package classes.Scenes.Dungeons 
{
	/**
	 * ...
	 * @author jk
	 */
	//represents a button the player can press for directions N,E,S,W; this will also be used to generate the map
	//if you have to connect 2 rooms, you have to define direction in both of them
	public class DngDirection {
		
		//creates direction between 2 rooms and assigns them to them; you can then modify them
		public static function createDirection(DirEnum:int, RoomA:DngRoom, RoomB:DngRoom, onlyAtoB:Boolean=false):void {
			var Label:String = DirEnumToString(DirEnum);
			var DirAtoB:DngDirection = new DngDirection(DirEnum,Label, "");
			var inverseDir:int = inverseDirection(DirEnum);
			var backLabel:String = DirEnumToString(inverseDir);
			var DirBtoA:DngDirection = new DngDirection(inverseDir,backLabel, "");
			DirAtoB.roomA = DirBtoA.roomB = RoomA;
			DirAtoB.roomB = DirBtoA.roomA = RoomB;
			if(RoomA != null) RoomA.setDirection(DirEnum, DirAtoB);
			if(RoomB != null) RoomB.setDirection(inverseDir, DirBtoA);
		}
		//returns the opposite direction f.e up-down
		public static function inverseDirection(DirEnum:int):int {
			switch(DirEnum) {
				case DirN: 
					return DirS;
					break;
				case DirS: 
					return DirN;
					break;
				case DirE: 
					return DirW;
				case DirW: 
					return DirE;
					break;
				case StairDown: 
					return StairUp;
					break;
				case StairUp: 
					return StairDown;
					break;
				default: 
					break;
			}
			return 0;
		}
		//converts direction enum to label
		public static function DirEnumToString(DirEnum:int):String {
			var backLabel:String = "";
			switch(DirEnum) {
				case DirN: 
					backLabel = "N";
					break;
				case DirS: 
					backLabel = "S";
					break;
				case DirE: 
					backLabel = "E";
					break;
				case DirW: 
					backLabel = "W";
					break;
				case StairUp: 
					backLabel = "Stair up";
					break;
				case StairDown: 
					backLabel = "Stair down";
					break;
				default: 
					break;
			}
			return backLabel;
		}
		//Enum for possible directions
		public static const DirW:int = 4;
		public static const DirE:int = 3;
		public static const DirN:int = 1;
		public static const DirS:int = 2;
		public static const StairUp:int = 6;	
		public static const StairDown:int = 5;
				
		// default functions for callbacks
		public static function FALSE(Me:DngDirection):Boolean { return false; };
		public static function TRUE(Me:DngDirection):Boolean { return true; };
		
		public function DngDirection(DirEnum:int,Name:String,Description:String) 
		{	
			name = Name;
			description = Description=="" ? Name:Description;
			Direction = DirEnum;
		}
		//gets called when player enters from this direction
		/*public function onEnterAtoB():void { 
			onEnterAtoBFct();
		}*/
		public function onEnter():Boolean { 
			if (onEnterFct == null) return false;
			return onEnterFct(this);
		}
		//gets called when player  exits into this direction
		/*public function onExitBtoA():void { 
			onExitBtoAFct();
		};*/
		public function onExit():Boolean { 
			if (onExitFct == null) return false;
			return onExitFct(this);
		};
		//function to check if player can use this direction; you should also set tooltip for display
		public function canExit():Boolean { 
			if (canExitFct == null) return true;
			return canExitFct(this); 
		}
		/*public function canExitBtoA():Boolean { 
			return canExitBtoAFct(); 
		}*/
		
		//public var onEnterAtoBFct:Function = NOP;
		public var onExitFct:Function = null;
		public var canExitFct:Function = null;
		public var onEnterFct:Function = null;
		//public var onExitBtoAFct:Function = NOP;
		//public var canExitBtoAFct:Function = NOP;
		private var Direction:int;
		public function getDirEnum():int { return Direction; }
		public var roomA:DngRoom;	//source room
		public var roomB:DngRoom;	//target room
		public var name:String = "";	//label of the button
		public var tooltip:String = "";	//tooltip of the button
		public var description:String = ""; 
		//the direction is hidden if one of the connected rooms is hidden
		public function hidden():Boolean {
			return roomA.isHidden() || roomB.isHidden();
		}
	}


}