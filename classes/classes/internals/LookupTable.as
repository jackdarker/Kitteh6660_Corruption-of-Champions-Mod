package classes.internals 
{
	/**
	 * ...
	 * @author jk
	 * you can use MyArray["Henry"] to fetch and retrieve additional info. But this info is not stored in the array but in some dynamic properties.
	 * So you cannot use the array operations on those elements !
	 * on the opposite you can use Dictionary but there you have to use objects as keys instead of simple keys.
	 * MyDictionary[new String("Henry")] will not be the same element as MyDictionary["Henry"] !
	 * 
	 * So I created this lookuptable. It stores the keys in one array and the values in another. The index of the key is the same as for the value.
	 */
	// this class is not multithread safe !
	public class LookupTable
	{

		private var Keys:Array = new Array();
		private var Values:Array = new Array();
		public function LookupTable() 
		{
		}
		public function GetLength():int {
			return Keys.length;
		}
		public function HasKey(key:String):int {
			var index:int = -1;
			for ( var i:int= 0; i < Keys.length; i++) {
				if (Keys[i] == key) {
					index = i;
					break;
				}
			}
			return index;
		}
		public function GetValuesAsArray():Array {
			return (Values.slice()); //copyconstructor ?!
		}
		public function GetKeysAsArray():Array {
			return (Keys.slice()); //copyconstructor ?!
		}
		public function GetElement(key:String):* {
			var index:int = HasKey(key);
			if (index >= 0) {
				return Values[index];
			}
			return null;
		}
		public function AddElement(key:String, value:*):void {
			var index:int = HasKey(key);
			if (index < 0) {
				Keys.push(key);
				Values.push(value);
			} else {
				Values[index] = value;
			}
		}
		public function RemoveElement(key:String):void {
			var index:int = HasKey(key);
			if (index >= 0) {
				Keys.slice(index, 1);
				Values.slice(index, 1);
			}
		}

		
	}

}