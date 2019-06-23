package classes.Scenes.Dungeons 
{
	/**
	 * ...
	 * @author jk
	 */
	//a floor of the dungeon
	public class DngFloor {
		private var rooms:/*DngRoom*/Array = [];	//list of rooms
		public function addRoom(room:DngRoom):void { 
			rooms.push(room);
		};
		public function setRooms(Rooms:Array):void { 
			rooms = Rooms;
		};
		public function allRooms():Array {
			return rooms;
		}
		public function getRoom(Name:String):DngRoom {
			var found:DngRoom = null;
			for each (var element:* in rooms ) {
				if (element == null) continue;
				found = (element as DngRoom);
				if (found.name == Name) {
					break;
				}
				found = null;
			}
			return found;
		}
		public var description:String = ""; 
		public var name:String = "";	//label of the floor 
	}

}