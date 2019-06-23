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
			var allrooms2:Array = new Array(0);
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
			allrooms2[0] = 0;
			for (var i:int = 0; i < allrooms.length; i++ ) {
				m = (allrooms2[i] as int);
				room = (allrooms[m] as DngRoom);
				roomInfo = (allinfo[m] as DngMapperInfo);
				dirs = room.getDirections();
				for (var k:int=0; k < dirs.length; k++ ) {
					if (dirs[k] == null) continue;
					dir = dirs[k] as DngDirection;
					room2 = dir.roomB;
					roomInfo.Connect = roomInfo.Connect + (1 << dir.getDirEnum());
					m = allrooms.indexOf(room2);
					if (m >= 0) {
						roomInfo2 = new DngMapperInfo();
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
						
						allinfo[m] = roomInfo2;
						if(allrooms2.indexOf(m)<0) allrooms2.push(m);
					}
				}
			}
		/* now we have a dictonary of all rooms, their coordinate and flags
		 * create 2DArray of size ( 2*(maxX-minX) , 2*(maxY-minY)) ; even indices store rooms "[ ]", uneven indices store directions " - "
		 * for every room in dictionary
		 * 		update Array[2*(X-minX)][2*(Y-minY)] with room-information
		 * 		update Array[2*(X-1-minX)][2*(Y-0-minY)] with W-direction
		 * 		update Array[2*(X-0-minX)][2*(Y-1-minY)] with N-direction
		 * 		aso.
		 * ...
		*/


		}
		/*
		 * 
		 * now we can print something like this:
		 * 	[ ]-[ ]-[ ]-[S]
		 *   |	 |	 |   |	
		 *  [ ]-[P]-[ ]-[ ]
		*/
		public function printMap():String {
			//Todo update player location
			var _line:String ="";
			var map:Array;
			var roomInfo:DngMapperInfo;
			var i:int;
			map = new Array(2*(maxX - minX)+1); 
			for (i = 0; i < map.length; i++) {  
				var submap:Array = new Array(2*(maxY - minY)+1); 
				for (var j:int = 0; j < submap.length; j++) {   
					submap[j] = "   ";   
				}
				map[i] = submap;
			}
			for (i = 0; i < allinfo.length; i++ ) {
				if (allinfo[i] == null) continue;
				roomInfo = allinfo[i] as DngMapperInfo;
				map[2*(roomInfo.X-minX)][2*(roomInfo.Y-minY)] = roomInfo.Connect.toString();
			}
			
			_line += (/*Dungeon.name + " " +*/ floor.name +"\n");
			for (i = 0; i < (2*(maxX - minX)+1); i++) {  
				for (var j:int = 0; j < (2*(maxY - minY)+1); j++) {   
					_line += map[i][j];   
				}
				_line += "\n";
			}
			return _line;
		}
	}

}