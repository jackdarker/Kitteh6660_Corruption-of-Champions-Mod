package classes.Scenes.Dungeons 
{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author jk
	 */
	// builds the map from the dungeons info and actualRoom
	// it is expected that all rooms in a floor are somehow connected with each other - no isolated rooms !
	
	//Not completed !
	public class DngMapper 
	{
		
		public function DngMapper() 
		{
			
		}
		public var Dungeon:DungeonAbstractContent = null;
		private var allinfo:Array;
		private var maxX:int;
		private var maxY:int;
		private var minX:int;
		private var minY:int;
		private var floor:DngFloor;
		
		public function createMap(Floor:DngFloor):void {
			floor = Floor;
			var allrooms:Array = Floor.allRooms();
			var roomIndexs:Array = new Array(0);
			allinfo = new Array(allrooms.length);
			var dirs:Array;
			var dir:DngDirection;
			var room:DngRoom;
			var room2:DngRoom;
			var x:int;
			var y:int;

			var m:int;
			
			var roomInfo:DngMapperInfo = new DngMapperInfo();
			var roomInfo2:DngMapperInfo ;
			roomInfo.X = x = maxX = minX = 0;
			roomInfo.Y = y = maxY = minY = 0;
		/*  put 1.room of actual floor to dictionary, set coord XY ={0,0]
		 *  get next room from dictionary until no more
		 *  	for every direction of room
		 * 			get targt room and place into dictionary
		 * 			depending of direction, add flags to source & target room
		 * 			calculate coord of target room  (f.e. direction =E then X/Y = {+1 , +0})
		 * 		...
		 *  ...
		 */ 
			allinfo[0] = roomInfo;
			roomIndexs[0] = 0;
			for (var i:int = 0; i < allrooms.length; i++ ) {
				m = (roomIndexs[i] as int);
				room = (allrooms[m] as DngRoom);
				roomInfo = (allinfo[m] as DngMapperInfo);
				roomInfo.Name = room.name;
				roomInfo.Hidden = roomInfo.Hidden || room.isHidden();
				dirs = room.getDirections();
				for (var k:int=0; k < dirs.length; k++ ) {
					if (dirs[k] == null) continue;
					dir = dirs[k] as DngDirection;
					room2 = dir.roomB;
					roomInfo.Connect = roomInfo.Connect + (1 << dir.getDirEnum());
					m = allrooms.indexOf(room2);
					if (m >= 0) {	//create new roominfo and set coordinate
						roomInfo2 = new DngMapperInfo();
						roomInfo2.Hidden = dir.hidden();
						switch (dir.getDirEnum()) {
							case DngDirection.DirN: 
								roomInfo2.X = roomInfo.X;
								roomInfo2.Y = roomInfo.Y-1;
								break;
							case DngDirection.DirS: 
								roomInfo2.X = roomInfo.X;
								roomInfo2.Y = roomInfo.Y+1;
								break;
							case DngDirection.DirE: 
								roomInfo2.X = roomInfo.X+1;
								roomInfo2.Y = roomInfo.Y;
								break;
							case DngDirection.DirW: 
								roomInfo2.X = roomInfo.X-1;
								roomInfo2.Y = roomInfo.Y;
								break;
							default:
								break;
						}
						if (roomInfo2.X < minX) minX = roomInfo2.X;
						if (roomInfo2.X > maxX) maxX = roomInfo2.X;
						if (roomInfo2.Y < minY) minY = roomInfo2.Y;
						if (roomInfo2.Y > maxY) maxY = roomInfo2.Y;
						
						
						if (roomIndexs.indexOf(m) < 0) 
						{
							roomIndexs.push(m);
							allinfo[m] = roomInfo2;
						}
					}
				}
			
			}

			return;
		}

		/* now we have a dictonary of all rooms, their coordinate and flags
		 * create 2DArray of size ( 2*(maxX-minX) , 2*(maxY-minY)) ; even indices store rooms "[ ]", uneven indices store directions " - "
		 * for every room in dictionary
		 * 		update Array[2*(X-minX)][2*(Y-minY)] with room-information
		 * 		update Array[2*(X-1-minX)][2*(Y-0-minY)] with W-direction
		 * 		update Array[2*(X-0-minX)][2*(Y-1-minY)] with N-direction
		 * 		aso.
		 * ...
		 * now we can print something like this:
		 * 	[ ]-[ ]-[ ]-[S]
		 *   |	 |	 |   |	
		 *  [ ]-[P]-[ ]-[ ]
		*/
		public function printMap(playerRoom:DngRoom):String {
			//Todo update player location
			var _line:String ="";
			var map:Array;
			var roomInfo:DngMapperInfo;
			var i:int;
			var j:int ;
			//create 2d-array to store textual representation of room and connection between them
			map = new Array(2*(maxX - minX)+1); 
			for (i = 0; i < map.length; i++) {  
				var submap:Array = new Array(2*(maxY - minY)+1); 
				for (j = 0; j < submap.length; j++) {   
					submap[j] = "   ";   
				}
				map[i] = submap;
			}
			//convert the MapperInfo to textual representation
			for (i = 0; i < allinfo.length; i++ ) {
				if (allinfo[i] == null) continue;
				roomInfo = allinfo[i] as DngMapperInfo;
				_line = " ";
				if ((roomInfo.Connect & (1 << DngDirection.StairDown)) ||
					(roomInfo.Connect & (1 << DngDirection.StairUp)) ) {
					_line = "S";
				}
				if (playerRoom != null && playerRoom.name == roomInfo.Name) {
					_line = "P";
				}
				//_line = roomInfo.Name;
				if (!roomInfo.Hidden) {
					_line = "[" +_line+ "]";
					map[2 * (roomInfo.X - minX)][2 * (roomInfo.Y - minY)] = _line; 
				
					if ((roomInfo.Connect & (1 << DngDirection.DirN))) {
						_line = " | ";
						map[2 * (roomInfo.X - minX) + 0][2 * (roomInfo.Y - minY) - 1] = _line;
					}
					if ((roomInfo.Connect & (1 << DngDirection.DirE))) {
						_line = "-";
						map[2 * (roomInfo.X - minX) + 1][2 * (roomInfo.Y - minY) + 0] = _line;
					}
					if ((roomInfo.Connect & (1 << DngDirection.DirS))) {
						_line = " | ";
						map[2 * (roomInfo.X - minX) + 0][2 * (roomInfo.Y - minY) + 1] = _line;
					}
					if ((roomInfo.Connect & (1 << DngDirection.DirW))) {
						_line = "-";
						map[2 * (roomInfo.X - minX) - 1][2 * (roomInfo.Y - minY) - 0] = _line;
					}
				}
			}
			//print
			_line = (/*Dungeon.name +*/ " " + floor.name +"\n");
			for (j= 0; j < (2 * (maxY - minY) + 1); j++) {   
				for (i = 0; i < (2*(maxX - minX)+1); i++) { 
					_line += map[i][j]+"\t";   //need to use tabs for proper formating
				}
				_line += "\n";
			}
			return _line;
		}
	}

}