package classes.Scenes.Dungeons 
{
	/**
	 * ...
	 * @author jk
	 */
	//builds the map from the dungeons info and actualRoom
	
	//Not completed !
	public class DngMapper 
	{
		
		public function DngMapper() 
		{
			
		}
		public var Dungeon:DungeonAbstractContent = null;
		
		/*
		 *  start with 1.room at coord XY =0,0
		*/
		public function printMap():void {
			rawOutputText(Dungeon.name);
			if (DungeonAbstractContent.dungeonLoc == 68) {
				rawOutputText(", Floor 1");
				rawOutputText("\n        [ ]    ");
				rawOutputText("\n |       |     ");
				rawOutputText("\n[ ]-[ ]-[ ]    ");
				rawOutputText("\n     |       | ");
				rawOutputText("\n    [ ]-[ ]-[ ]");
				rawOutputText("\n     |       | ");
				rawOutputText("\n[P]-[ ]     [S]");
			}
		}
	}

}