package classes.internals 
{
	/**
	 * ...
	 * @author jk
	 */
	/*helper class if you have to return more than one value from a function f.e. 
	 * 
	 *   var Result:ReturnResult;
	 *   eatThis(MyFood, Return);
	 *   outputText(Return.Text);
	 *   if (Return.Code==0) {
	 *       outputText("Hmm, tasty.")
	 *   } else {
	 *      outputText("I wont eat this.")
	 *   }
	 * 
	 * public function eatThis(Food:SimpleConsumable, Result:ReturnResult):void {
	 * 		if(Food==consumables.VITAL_T) {
	 * 			Result.Text = "Munching down a Potion";
	 * 			Result.Code = 0;
	 * 		} else {
	 * 			Result.Text = "You call that food?";
	 * 			Result.Code = 1;
	 * 		}
	 * }
	 * 
	 * 
	 * */
	public class ReturnResult 
	{
		private var _text:String = "";
		private var _code:int = 0;
		/*Text to diplay to the player
		 * */
		public function get Text():String { return _text; }
		public function set Text(value:String):void { _text = value; }
		/*0 if OK, anyother code depends on function
		 */ 
		public function get Code():int { return _code; }
		public function set Code(value:int):void { _code = value; }
		public function ReturnResult() 
		{
		}
		
	}

}