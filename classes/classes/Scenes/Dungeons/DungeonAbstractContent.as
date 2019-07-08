package classes.Scenes.Dungeons 
{
import classes.*;
import classes.Scenes.SceneLib;

/**
	 * ...
	 * @author Kitteh6660
	 */

	public class DungeonAbstractContent extends BaseContent
	{
        public static var inDungeon:Boolean = false;

        public static var dungeonLoc:int = 0;

        public static var inRoomedDungeon:Boolean = false;

        public static var inRoomedDungeonResume:Function = null;
		public static var inRoomedDungeonDefeat:Function = null;

        protected function get dungeons():DungeonEngine {
			return SceneLib.dungeons;
		}
		public function DungeonAbstractContent() 
		{	
		}
		public var description:String = ""; //text diplayed when entering the dungeon
		public var name:String = "";	//name of the dungeon
		private var floors:/*DngFloors*/Array = [];	//list of floors
		public function setFloors(Floors:Array):void { 
			floors = Floors;
		};
		public function allFloors():Array {
			return floors;
		}
		private var Mapper:DngMapper; 
		//enters the dungeon; also does some checks to verify that dungeon was properly setup
		public function enterDungeon_():void {
			Mapper = new DngMapper();
			actualRoom = null;
			var Entry:DngRoom = null;
			var Exit:DngRoom = null;
			var Room:DngRoom;
			//search the dungeon-Entry, has to be in first floor
			var rooms:Array = (this.floors[0] as DngFloor).allRooms();
			for (var i:int = 0; i < rooms.length; i++ ) {
				Room = (rooms[i] as DngRoom);
				if (Room.isDungeonEntry) {
					Entry = Room;
				}
				if (Room.isDungeonExit) {
					Exit = Room;
				}
			}
			if (Entry == null || Exit == null) {
				outputText("Error: Dungeon-Exit or Entry missing");//Todo throw error
			}
			dungeonLoc = -1; // not oldschool dungeon
			inDungeon = false;
			inRoomedDungeon = true;
			inRoomedDungeonDefeat = exitDungeon_;
			
			moveToRoom(Entry);
			playerMenu();
			
		}
		
		public function teleport(Floor:DngFloor, Room:DngRoom):void {
			actualRoom = null;
			moveToRoom(Room);
		}
		
		//public function getFloorFromRoom(Room:DngRoom):DngFloor {
		//}
		public var actualRoom:DngRoom = null;
		
		private function moveToRoom(newRoom:DngRoom):void {
			clearOutput();
			cheatTime(1 / 12);
			statScreenRefresh();
			//DungeonCore.setTopButtons();
			spriteSelect(-1);
			menu();
			var _actualRoom:DngRoom = actualRoom;
			actualRoom = newRoom;
			if (_actualRoom != null) {
				newRoom.moveHere(_actualRoom); //this will trigger onExit/onEnter
			} else {
				inRoomedDungeonResume = resumeRoom;
				inRoomedDungeonResume();
			}

			//if(!CoC.instance.inCombat) resumeRoom(); //resume after combat done
		}
		private function resumeRoom():void {
			clearOutput();
			statScreenRefresh();
			//setTopButtons();
			spriteSelect(-1);
			menu();
			actualRoom.updateRoom();
			outputText(actualRoom.getDescription());
			
			/*		Menu Layout
			 * 		[ Op1 ]	[ Op2 ]	[ Op3 ]	[ Op4 ]	[More ]
			 * 		[ Up  ]	[  N  ]	[Down ]	[Mast ]	[     ]
			 * 		[  W  ]	[  S  ]	[  E  ]	[ Inv ]	[ Map ]
			 *  
			 */
			var bt:int;
			var btMask:int = 0xE;
			actualRoom.getDirections().forEach( function(element:*, index:int, arr:Array):void {
				var Dir:DngDirection = element as DngDirection;
				if (Dir == null) return;
				bt = Dir.getDirEnum();
				if (bt == DngDirection.DirN) bt = 6;
				else if (bt == DngDirection.DirS) bt = 11;
				else if (bt == DngDirection.DirE) bt = 12;
				else if (bt == DngDirection.DirW) bt = 10;
				else if (bt == DngDirection.StairDown) bt = 7;
				else if (bt == DngDirection.StairUp) bt = 5;
				if(Dir.canExit()) {
					addButton(bt, Dir.name, moveToRoom, Dir.roomB);
				}else {
					addButtonDisabled(bt, Dir.name, Dir.tooltip);
				}
				btMask = btMask ^ (1 >>> bt);
			});
            if (player.lust >= 30) addButton(8, "Masturbate", SceneLib.masturbation.masturbateGo);
            addButton(13, "Inventory", inventory.inventoryMenu).hint("The inventory allows you to use an item.  Be careful as this leaves you open to a counterattack when in combat.");
			addButton(14, "Map", displayMap).hint("View the map of this dungeon.");
			if(actualRoom.isDungeonExit) {
				for (var i:int = 5; i < 15; i++ ) {	//find an empty navigation button for leave
					bt = i;
					if ( ((btMask << i) & 1) == 0) break;
				}
				addButton(bt, "Leave", exitDungeon_, false);
			}
		}
		private function displayMap():void {
		//gets called when you get defeated
			clearOutput();
			Mapper.createMap(actualRoom.floor);
			rawOutputText( this.name +" "+ Mapper.printMap(actualRoom));
			doNext(resumeRoom);
		}
		public function exitDungeon_(byDefeat:Boolean):void {
			clearOutput();
			inDungeon = inRoomedDungeon = false;
			if (byDefeat) {
				outputText("After your defeat, you somehow turned up back in your camp.");
				doNext(camp.returnToCampUseEightHours);
			}else {
				outputText("You leave the " + this.name + "and walk back towards camp.");
				doNext(camp.returnToCampUseOneHour);
			}
		}
	}

	

}