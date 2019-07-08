package classes.Scenes.Dungeons 
{
	import classes.CoC;
	import classes.internals.Utils;
	/**
	 * ...
	 * @author jk
	 */
	public class DngRoom {
		public function DngRoom(Name:String,Description:String, hidden:Boolean) 
		{	
			name = Name;
			descriptionString = Description == "" ? Name:Description;
			isHiddenBit = hidden;
		}

		public var isDungeonExit:Boolean = false; // player can leave to camp with Leave-button
		public var isDungeonEntry:Boolean = false; //when entering the dungeon player will be coming from here; there should only be one of this 
		private var directions:/*DngDirection*/Array = new Array(null, null, null, null, null, null);	//list of directions
		private var operations:/*DngOperations*/Array = []; //list of additional operations (= buttons you can press)

		//returns description-string; if you need to build description dynamically, you can assign a function to it. Default implementation returns text from constructor.
		public var getDescription:Function = getDescription_;
		protected function getDescription_():String {
			return descriptionString;
		}
		private var descriptionString:String = ""; 
		//returns boolean flag if room is visible on map; if you need to evaluate dynamically, you can assign a function to it. Default implementation returns flag from constructor.
		public var isHidden:Function = isHidden_;
		protected function isHidden_():Boolean {
			return isHiddenBit;
		}
		private var isHiddenBit:Boolean = false;	//the room and directions to it will not be dislayed on the map unless the player visited it once
		public function setDirection(DirEnum:int, direction:DngDirection):void { 
			directions.splice(DirEnum-1,1,direction);
		};
		public function getDirections():Array {
			return directions;
		}
		public function getDirection(DirEnum:int):DngDirection {
			return directions[DirEnum-1] as DngDirection;
		}
		//this is called after the direction onEnter-Event was called
		public function onEnter():Boolean { 
			isHiddenBit = false;
			if (onEnterFct == null) return false;
			return onEnterFct(this);
		}
		public var onEnterFct:Function = null;
		
		public function moveHere(from:DngRoom):void {
			origResumeFct = DungeonAbstractContent.inRoomedDungeonResume;
			fromRoom = from;
			it = 0;
			moveIterator();
		}

		// Whats that good for: onExit or onEnter might trigger an interaction/combat that we have to finish first befor displaying navigation buttons again.
		// iterator->onExit->startCombat->won->doNext(resume)->iterator
		private var origResumeFct:Function = null;
		private var it:int;
		private var fromRoom:DngRoom;
		private function moveIterator():void {
			var dir:DngDirection;
			var _it:int = 0;
			//call Exit function from previous room
			for each (var element:* in fromRoom.getDirections() ) {
				_it = _it +1; 
				if (element == null ) continue;
				if (_it <= it) continue;
				it = _it;
				dir = element as DngDirection;
				if (dir.roomA == fromRoom && dir.roomB==this) {
					if (dir.onExit())
					{
						DungeonAbstractContent.inRoomedDungeonResume = this.moveIterator
						return;
					}
				}
			}
			//call Entry function of this room
			for each (var element1:* in this.getDirections() ) {
				_it = _it +1; 
				if (element1 == null) continue;
				if (_it <= it) continue;
				it = _it;
				dir = element1 as DngDirection;
				if (dir.roomA==this && dir.roomB == fromRoom) {
					if (dir.onEnter()) {
						DungeonAbstractContent.inRoomedDungeonResume = this.moveIterator
						return;
					}
				}
			}
			_it = _it +1; 
			if (_it > it && onEnter()) {
				it = _it;
				DungeonAbstractContent.inRoomedDungeonResume = this.moveIterator
				return;
			}
			
			DungeonAbstractContent.inRoomedDungeonResume = origResumeFct;
			DungeonAbstractContent.inRoomedDungeonResume();
		
		}

		public var name:String = "";	//label of the room 
		public var floor:DngFloor = null;	//the floor where the room is assigned to
		//gets called when entering the floor or room; override it to update the other properties
		public function updateRoom():void { };
	
	}

}