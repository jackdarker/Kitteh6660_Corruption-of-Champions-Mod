/**
 * jd
 */
package classes.StatusEffects {
import classes.StatusEffectClass;
import classes.StatusEffectType;
import classes.PerkLib;
import classes.Creature;
import classes.EngineCore;
import coc.view.UIUtils;

//craving for a males cum. 
//this is somewhat duplicated to slimecraving and minotaur cum addiction but applies not just to goo-TF
//if the player starts to drink cum (consensual or nonconsenual) (s)he starts to evolve some quirks around it:
//stage1: this just keeps track if the player feeds cum regulary; no effect
//stage2: player recovers some health & fatigue by drinking cum
//stage3: additional player stats buff but also debuff if not fed regulary
//stage4: additonal cum-craving if fighting against males
//stage is switched forward when enough total cum is fed or backward if not enough cum is fed for a time
//state is stored in value1-4:
//value1 = stage
//value2 = countdown that is reset when you feed cum
//value3 = cum fed counter (in l) for switching stage forward
//value4 = cum storage that gets decreased hourly

public class CumThirstEffect extends  StatusEffectClass {	//Todo extends Basecontent for outputText; no better way??
	public static const TYPE:StatusEffectType = register("Cum Thirst", CumThirstEffect);
	public function CumThirstEffect() {
		super(TYPE);
	}
	
	//drains cum from the target; depends on the target and player capacity how much
	public function drink(target:Creature):void {
		var amount:Number = (Math.min(target.cumQ(), maxThirst())); 
        modSatiety(amount);
    }
	public function maxThirst():Number {
		var maxThi:Number = (value1*2)+1;
		return maxThi;
	}
	public function get CumAddicted():Boolean {
		return(value1 >= 4);
	}
	public function hourlyHunger():void {
		value2 = value2 - 1; //countdown decrease
		modSatiety( -0.05);
		//TODO healt&fatigue recovery
	}
    public function modSatiety(delta:Number):void {
		var oldstage:Number = value1;
		var newstage:Number = value1;
		var oldBoost:Number = currentBoost;
		var maxThirst:Number = maxThirst();
		var countdown:Number = value2;
		value4 = boundFloat( -10, value4 + delta, maxThirst);
		if (delta > 0) {
			//the higher the countdown, the more difficult is it to downgrade the stage:
			//stage1:24h, stage2:36h, stage3:48h, stage4:60h if filled to the brim
			countdown = Math.min(countdown + (oldstage + 1) * 12 * delta / maxThirst,(oldstage + 1) * 12);
			value3 = value3 + Math.min(delta, maxThirst);
		}
		//upgrade or downgrade stage
		if (oldstage >= 4) {
			if (countdown < 0) {
				newstage -= 1;
				countdown = 48;
			}
			//Todo
		} else if (oldstage >= 3) {
			if (countdown < 0) {
				newstage -= 1;
				countdown = 48;
			} else if (value3 > maxThirst*5) {
				newstage += 1;
				value3 = 0;
			}
			
		} else if (oldstage >= 2) {
			if (countdown < 0) {
				newstage -= 1;
				countdown = 48;
			} else if (value3 > maxThirst*3) {
				newstage += 1;
				value3 = 0;
			}
			
		}else if (oldstage >= 0) {
			if (countdown < 0) {
				countdown = 0; //no downgrade from 1 to 0
			} else if (value3 > maxThirst*3) {
				newstage += 1;
				value3 = 0;
			}
		}
		value1 = newstage;
		value2 = countdown;
        var change:Number = currentBoost - oldBoost;
        host.dynStats("str", change,
                "spe", change,
                "int", change,
                "lib", change,
                "max", false,
                "scale", false);
		if (oldstage != newstage) {
			var text:String;
			if (oldstage < newstage) {
				text="After tasting so many males cum, your body and mind adapts to this circumstance. "
			} else {
				text="Since you havent fed cum for some time now, your body adapts to this situation."
			}
			if (newstage == 4 ) {
				text += "<b>You feel a craving for males tasty cum.</b>";
			} else if (newstage == 3 ) {
				text += "<b>Besides health and fatigue restoration, you also receive a stat boost from a males cum.</b>";
			} else if (newstage == 2 ) {
				text += "<b>When drinking a males semen, you restore some health and fatigue.</b>";
			} else if (newstage <= 1 ) {
				text += "";
			}
			
			EngineCore.outputText(text);
		}
    }
	
	public function get currentBoost():int {
        //if (value4 <= 0) return 0;
		if (value1 <= 2) return 0; //no boost below stage 3
        return value4*((1 + game.player.newGamePlusMod()) * 2);
    }

    public function getStatusText():String {
		var text:String="";
		if (value1 >= 4) {
			text = "You are craving males tasty cum.";
		} else if (value1 >= 3) {
			text = "Besides health and fatigue restoration, you also receive a stat boost from a males cum.";
		} else if (value1 >= 2) {
			text = "When drinking a males semen, you restore some health and fatigue.";
		}
		if(value1>=0) {
			text += " You receive an actual buff of "+currentBoost+" because you are currently filled with " + value4 + "l cum that should you keep running for at least " + value2 + "h. You might got " + value3 + "l in total.\n";
		}
		return text;
	}
    override public function onRemove():void {
        host.dynStats("str", -currentBoost,
                "spe", -currentBoost,
                "int", -currentBoost,
                "lib", -currentBoost,
                "max", false,
                "scale", false);
    }
}
}
