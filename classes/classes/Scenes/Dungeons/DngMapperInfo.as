package classes.Scenes.Dungeons 
{
	/**
	 * ...
	 * @author jk
	 *
	 */
	// a helper class to store info for a room
	public class DngMapperInfo 
	{
		
		public function DngMapperInfo() 
		{
			
		}
		public var X:int = 0;
		public var Y:int = 0;
		public var Name:String;
		public var Hidden:Boolean = false;
		public var Connect:int = 0;	//bitwise encoding of directions
		
		
	}

}