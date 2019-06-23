package classes.Scenes.Dungeons 
{
	import classes.CoC;
	import classes.internals.Utils;
	/**
	 * ...
	 * @author jk
	 */
	public class DngRoom {
		public function DngRoom(Name:String,Description:String) 
		{	
			name = Name;
			description = Description=="" ? Name:Description;
		}
		public static function NOP(Me:DngRoom):Boolean { return true; };
		public var isDungeonExit:Boolean = false; // player can leave to camp with Leave-button
		public var isDungeonEntry:Boolean = false; //when entering the dungeon player will be coming from here; there should only be one of this 
		private var directions:/*DngDirection*/Array = new Array(null, null, null, null, null, null);	//list of directions
		private var operations:/*DngOperations*/Array = []; //list of additional operations (= buttons you can press)

		public function setDirection(DirEnum:int, direction:DngDirection):void { 
			directions.splice(DirEnum,1,direction);
		};
		public function getDirections():Array {
			return directions;
		}
		public function getDirection(DirEnum:int):DngDirection {
			return directions[DirEnum] as DngDirection;
		}
		//this is called after the direction onEnter-Event was called
		public function onEnter():void { 
			onEnterFct(this);
		}
		public var onEnterFct:Function = NOP;
		
		public function moveHere(from:DngRoom):void {
			var dir:DngDirection;
			//call Exit function from previous room
			for each (var element:* in from.getDirections() ) {
				if (element == null) continue;
				dir = element as DngDirection;
				if (dir.roomA == from && dir.roomB==this) {
					dir.onExit(); 
				}/*else if (dir.roomB == from) {
					dir.onExitBtoA();
				}*/
			}
			//call Entry function of this room
			for each (var element1:* in this.getDirections() ) {
				if (element1 == null) continue;
				dir = element1 as DngDirection;
				if (dir.roomA==this && dir.roomB == from) {
					dir.onEnter();
				}
			}
			if(from != this && !CoC.instance.inCombat) onEnter();  //Todo if there was combat started in direction.onEnter, room.onEnter should be called after ombat done
		}
		public var description:String = ""; 
		public var isHidden:Boolean = false;	//the room and directions to it will not be dislayed on the map unless the player visited it once
		public var name:String = "";	//label of the room 
		
		//gets called when entering the floor or room; override it to update the other properties
		public function updateRoom():void { };
	
	}

}