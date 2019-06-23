//Side Dungeon: Bee Hive
/**
 * ...
 * @author Liadri and others
 */
package classes.Scenes.Dungeons 
{
import classes.EventParser;
import classes.internals.LookupTable;
import classes.Scenes.Areas.Forest.BeeGirl;
import classes.ItemType;

	public class BeeHive extends DungeonAbstractContent
	{
		
		public function BeeHive() 
		{
			this.name = "BeeHive";
			this.description = "There seem to live alot of giant bees here.";
			buildFloors();
		}
		
		
		
		private function buildFloors():void {
			var _floors:Array = new Array();
			var firstFloor:DngFloor;
			var stairUp:DngRoom;
			var stairDown:DngRoom;
			firstFloor = new DngFloor();
			firstFloor.description = "This is the lowest floor of the beehive.";
			firstFloor.name = "1.Floor";
			var room:DngRoom;
			var rooms:LookupTable = new LookupTable(); 
		 /* first floor
		 * 	A1 - A2 - A3 - A4
		 *  	 |	  |    |	
		 *  B1 - B2   B3   B4
		 *  |    |    |    |
		 *  E    C2   C3   S
		 * */
			rooms.AddElement("Entrance", new DngRoom("Entrance", "Entrance"));
			rooms.AddElement("B1", new DngRoom("B1", "B1"));
			rooms.AddElement("A1",new DngRoom("A1", "A1"));
			rooms.AddElement("B2",new DngRoom("B2", "B2"));
			rooms.AddElement("A2",new DngRoom("A2", "A2"));
			rooms.AddElement("B3",new DngRoom("B3", ""));
			rooms.AddElement("A3",new DngRoom("A3", ""));
			rooms.AddElement("B4",new DngRoom("B4", ""));
			rooms.AddElement("A4",new DngRoom("A4", ""));
			rooms.AddElement("Stairs",new DngRoom("Stairs", ""));
			DngDirection.createDirection(DngDirection.DirN, rooms.GetElement("Entrance") , rooms.GetElement("B1"));
			DngDirection.createDirection(DngDirection.DirE, rooms.GetElement("B1" ), rooms.GetElement("B2"));
			DngDirection.createDirection(DngDirection.DirN, rooms.GetElement("B2" ), rooms.GetElement("A2"));
			DngDirection.createDirection(DngDirection.DirW, rooms.GetElement("A2" ), rooms.GetElement("A1"));
			DngDirection.createDirection(DngDirection.DirE, rooms.GetElement("A2" ), rooms.GetElement("A3"));
			DngDirection.createDirection(DngDirection.DirE, rooms.GetElement("A3" ), rooms.GetElement("A4"));
			DngDirection.createDirection(DngDirection.DirS, rooms.GetElement("A4" ), rooms.GetElement("B4"));
			DngDirection.createDirection(DngDirection.DirS, rooms.GetElement("B4" ), rooms.GetElement("Stairs"));
			room = (rooms.GetElement("Entrance") as DngRoom);
			room.isDungeonEntry = room.isDungeonExit = true;
			room = (rooms.GetElement("B2") as DngRoom);
			room.onEnterFct = encounterBee2;
			room.getDirection(DngDirection.DirW).onEnterFct = encounterBee;
			room = (rooms.GetElement("B2") as DngRoom);
			room.getDirection(DngDirection.DirN).canExitFct = hasItem;
			stairUp = (rooms.GetElement("Stairs") as DngRoom);
			
			firstFloor.setRooms(rooms.GetValuesAsArray());
			_floors.push(firstFloor);
			
			
			var secondFloor:DngFloor;
			secondFloor = new DngFloor();
			secondFloor.description = "This is the second floor of the beehive.";
			secondFloor.name = "2.Floor";
			rooms= new LookupTable(); 
		 /* second floor
		 * 	A1 - A2 - A3 - A4
		 *  |	 |	  |    |	
		 *  B1 - B2 - B3 - B4
		 *  |    |    |    |
		 *  C1 - C2 - C3 - S
		 * */
			rooms.AddElement("C1", new DngRoom("C1", ""));
			rooms.AddElement("B1", new DngRoom("B1", ""));
			rooms.AddElement("A1", new DngRoom("A1", ""));
			rooms.AddElement("C2", new DngRoom("C2", ""));
			rooms.AddElement("B2",new DngRoom("B2", ""));
			rooms.AddElement("A2", new DngRoom("A2", ""));
			rooms.AddElement("C3", new DngRoom("C1", ""));
			rooms.AddElement("B3",new DngRoom("B3", ""));
			rooms.AddElement("A3", new DngRoom("A3", ""));
			rooms.AddElement("StairsDown",new DngRoom("StairsDown", ""));
			rooms.AddElement("B4",new DngRoom("B4", ""));
			rooms.AddElement("A4", new DngRoom("A4", ""));
			DngDirection.createDirection(DngDirection.DirS, rooms.GetElement("B4" ), rooms.GetElement("StairsDown"));
			DngDirection.createDirection(DngDirection.DirE, rooms.GetElement("C3" ), rooms.GetElement("StairsDown"));
			DngDirection.createDirection(DngDirection.DirE, rooms.GetElement("C2" ), rooms.GetElement("C3"));
			DngDirection.createDirection(DngDirection.DirE, rooms.GetElement("C1" ), rooms.GetElement("C2"));
			room = (rooms.GetElement("B4") as DngRoom);

			stairDown = room = (rooms.GetElement("StairsDown") as DngRoom);
			room.getDirection(DngDirection.DirN).onExitFct = trapDoor;	//its a trap
			
			secondFloor.setRooms(rooms.GetValuesAsArray());
			_floors.push(secondFloor);
			//now create floor links
			DngDirection.createDirection(DngDirection.StairUp, stairUp , stairDown);
			setFloors(_floors);
		}
		
		private function encounterBee(Me:DngDirection):Boolean {
			outputText("\nThere is a beegirl.");
			startCombat(new BeeGirl());
			doNext(playerMenu);
			return true;
		}
		private function encounterBee2(Me:DngRoom):Boolean {
			outputText("\nThere is another beegirl.");
			startCombat(new BeeGirl());
			doNext(playerMenu);
			return true;
		}
		private function hasItem(Me:DngDirection):Boolean {
			if (!player.hasItem(ItemType.lookupItem("BeeHony"), 1))
			{
				Me.tooltip = "You dont have a vial of beehoney";
				return false;
			}
			return true;
		}
		//player falls down to 1.floor when entering the room
		private function trapDoor(Me:DngDirection):Boolean {
			outputText("\nYou crash down through the floor and find yourself back on the lowest level of the beehive.\n")
			var floor1:DngFloor = this.allFloors()[0] as DngFloor;
			var Room:DngRoom = floor1.getRoom(Me.roomB.name);
			if (Room != null) {
				doNext(curry(this.teleport, floor1, Room)); //this.teleport( floor1, Room);	//Todo and if not found??
				return true;
			}
			return false; 	
			
		}
	}

}