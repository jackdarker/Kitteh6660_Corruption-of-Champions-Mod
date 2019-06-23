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
				case 0: 
					return 1;
					break;
				case 1: 
					return 0;
					break;
				case 2: 
					return 3;
				case 3: 
					return 2;
					break;
				case 4: 
					return 5;
					break;
				case 5: 
					return 4;
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
				case 0: 
					backLabel = "N";
					break;
				case 1: 
					backLabel = "S";
					break;
				case 2: 
					backLabel = "E";
					break;
				case 3: 
					backLabel = "W";
					break;
				case 4: 
					backLabel = "Stair up";
					break;
				case 5: 
					backLabel = "Stair down";
					break;
				default: 
					break;
			}
			return backLabel;
		}
		//Enum for possible directions
		public static const DirW:int = 3;
		public static const DirE:int = 2;
		public static const DirN:int = 0;
		public static const DirS:int = 1;
		public static const StairUp:int = 4;	
		public static const StairDown:int = 5;
				
		// default functions for callbacks
		public static function FALSE(Me:DngDirection):Boolean { return false; };
		public static function TRUE(Me:DngDirection):Boolean { return true; };
		public static function NOP(Me:DngDirection):Boolean { return true; };
		
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
		public function onEnter():void { 
			onEnterFct(this);
		}
		//gets called when player  exits into this direction
		/*public function onExitBtoA():void { 
			onExitBtoAFct();
		};*/
		public function onExit():void { 
			onExitFct(this);
		};
		//function to check if player can use this direction; you should also set tooltip for display
		public function canExit():Boolean { 
			return canExitFct(this); 
		}
		/*public function canExitBtoA():Boolean { 
			return canExitBtoAFct(); 
		}*/
		
		//public var onEnterAtoBFct:Function = NOP;
		public var onExitFct:Function = NOP;
		public var canExitFct:Function = TRUE;
		public var onEnterFct:Function = NOP;
		//public var onExitBtoAFct:Function = NOP;
		//public var canExitBtoAFct:Function = NOP;
		private var Direction:int;
		public function getDirEnum():int { return Direction; }
		public var roomA:DngRoom;	//source room
		public var roomB:DngRoom;	//target room
		public var name:String = "";	//label of the button
		public var tooltip:String = "";	//tooltip of the button
		public var description:String = ""; 
	}


}