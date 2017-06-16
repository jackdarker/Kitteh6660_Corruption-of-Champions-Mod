package classes.Scenes.Areas.Lake 
{
	import classes.Scenes.NPCs.FenrisScene;
	
	/**
	 * ...
	 * @author jk
	 */
	public class FenrisSceneLake extends FenrisScene 
	{
		
	public function FenrisSceneLake() 
	{	}
	public override function encounterChance():Number {
		return 1;
	}
	public override function execEncounter():void {
		encounterTracking("Lake");		
	}
		
	}

}