/**
 * Hell-Hound-Companion
 * @author Foxxling (idea & writing) & JD (coding)
 */
package classes.Scenes.NPCs {
	
	import classes.*;
	import classes.internals.*;
	import classes.CoC;
	import classes.GlobalFlags.*;
	import classes.GlobalFlags.kFLAGS;
	import classes.Scenes.Camp;
		
	public class HHCFollower extends NPCAwareContent {
		private var _MainQuestFlag:uint = 0;	//can be used as additional counter/flag for the curent statemachine-state
		
		private var _MainQuestStage:uint = 0;	//stores the Questprogress (statemachine-state)
		public static const MAINQUEST_Not_Met:uint = 		0;		//initial value
		public static const MAINQUEST_Disabled:uint = 		1;		//chhosed to not meet it ever again
		public static const MAINQUEST_Fed_Him:uint = 		10;		//gave him some food to patch him up
		public static const MAINQUEST_Hunt_With_Him:uint = 	20;		//hunting down some critters
		public static const MAINQUEST_ReadyToBond:uint = 	30;		//create a bond between him and yourself
		
		CoC.instance.flags[kFLAGS.HHC_FOLLOWER] = 0;	//flag used for saving/loading
		
		private var _initDone:Boolean = false;	
		private static var _instance:HHCFollower;
		/**implemented as singleton because is unique
		 * */
		public static function getInstance():HHCFollower{
			if(!_instance){
				new HHCFollower();
			} 
			//workaround to initialise as soon as kGAMECLASS is valid
			if (CoC.instance!= null && !_instance._initDone) {
				_instance.init(false);
			}
			return _instance;
		}
		public function HHCFollower(){
			if(_instance){
				throw new Error("Singleton... use getInstance()");
			} 
			_instance = this;
			//classes.Saves.saveAwareClassAdd(this);		TODO
			//EventParser.timeAwareClassAdd(this);
			//_BreastStore = new BreastStore(kFLAGS.FENRIS_BREAST);
			//classes.Saves.saveAwareClassAdd(_BreastStore);
		}
		
		/* for debug-Reset
		 */
		public function reset():void {
			init(true);
		}
		private function init(forceInit:Boolean):void {
			if (!_initDone || forceInit) {
				//first time initialisation
				_MainQuestStage = 0;
			}
			_initDone = true;
		}
		public function getMainQuestStage():uint {
			return _MainQuestStage;
		}
		public function getMainQuestFlag():uint {
			return _MainQuestFlag;
		}
		public function setMainQuestStage(x:uint):void {
			if (x == _MainQuestStage) { _MainQuestFlag++; }	//increase counter on reoccuring states
			else { _MainQuestFlag = 0; }
			_MainQuestStage = x;
		}

	}
}
