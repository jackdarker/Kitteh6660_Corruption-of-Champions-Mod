/**
 * ...
 * @author Melchi ...
 */
package classes.Items.Shields 
{
	import classes.GlobalFlags.kFLAGS;
	import classes.GlobalFlags.kGAMECLASS;
	import classes.Items.Shield;
	import classes.Player;
	
	public class woodshield extends Shield
	{
		
		public function woodshield() 
		{
			super("woodSh", "WoodShld", "wood shield", "a wooden shield", 6, 10, "A simple wooden shield.  It doesn't look very sturdy");
		}
		
	}

}