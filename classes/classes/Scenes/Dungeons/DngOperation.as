package classes.Scenes.Dungeons 
{
	/**
	 * ...
	 * @author jk
	 */

	 // an additional operation that the player can trigger by pressing a button
	public class DngOperation 
	{
		
		public function DngOperation() 
		{
			
		}
		public var destination:DngDirection;	//description to be displayed when entering room
		public var name:String = "";	//label of the button
		//function to check if player can use this button
		public function canTrigger():Boolean { return false; }
		public function onTrigger():void { };
	}

}