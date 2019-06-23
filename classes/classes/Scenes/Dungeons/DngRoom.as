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

		public var isDungeonExit:Boolean = false; // player can leave to camp with Leave-button
		public var isDungeonEntry:Boolean = false; //when entering the dungeon player will be coming from here; there should only be one of this 
		private var directions:/*DngDirection*/Array = new Array(null, null, null, null, null, null);	//list of directions
		private var operations:/*DngOperations*/Array = []; //list of additional operations (= buttons you can press)

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
		private var origResumeFct:Function = null;
		private var it:int;
		private var fromRoom:DngRoom;
		// Whats that good for: onExit or onEnter might trigger an interaction/combat that we have to finish first befor displaying navigation buttons again.
		// iterator->onExit->startCombat->won->doNext(resume)->iterator
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
		public var description:String = ""; 
		public var isHidden:Boolean = false;	//the room and directions to it will not be dislayed on the map unless the player visited it once
		public var name:String = "";	//label of the room 
		
		//gets called when entering the floor or room; override it to update the other properties
		public function updateRoom():void { };
	
	}

}