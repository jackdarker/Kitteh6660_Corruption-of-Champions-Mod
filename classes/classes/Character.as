﻿package classes 
{
import classes.Scenes.Places.TelAdre.UmasShop;
import classes.Items.JewelryLib;
import classes.GlobalFlags.kFLAGS;

/**
	 * Character class for player and NPCs. Has subclasses Player and NonPlayer.
	 * @author Yoffy
	 */
	public class Character extends Creature
	{
		//BEARDS! Not used anywhere right now but WHO WANTS A BEARD?
		//Kitteh6660: I want a beard! I'll code in obtainable beard. (DONE!)

		//Used for hip ratings
		public var thickness:Number = 0;
		
		//Body tone i.e. Lithe, stocky, etc
		public var tone:Number = 0;
		
		private var _pregnancyType:int = 0;
		public function get pregnancyType():int { return _pregnancyType; }

		private var _pregnancyIncubation:int = 0;
		public function get pregnancyIncubation():int { return _pregnancyIncubation; }

		private var _buttPregnancyType:int = 0;
		public function get buttPregnancyType():int { return _buttPregnancyType; }

		private var _buttPregnancyIncubation:int = 0;
		public function get buttPregnancyIncubation():int { return _buttPregnancyIncubation; }


		
		//Key items
		public var keyItems:/*KeyItemClass*/Array;
		
		public function Character()
		{
			keyItems = [];
		}
		
		//Return bonus fertility

		//return total fertility

		public function faceDesc():String
		{
			var faceo:String = "";
			//0-10
			if (femininity < 10)
			{
				faceo = "a square chin";
				if (!hasBeard())
					faceo += " and chiseled jawline";
				else
					faceo += ", chiseled jawline, and " + beard();
			}
			//10+ -20
			else if (femininity < 20)
			{
				faceo = "a rugged looking " + face() + " ";
				if (hasBeard())
					faceo += "and " + beard();
				faceo += "that's surely handsome";
			}
			//21-28
			else if (femininity < 28)
				faceo = "a well-defined jawline and a fairly masculine profile";
			//28+-35 
			else if (femininity < 35)
				faceo = "a somewhat masculine, angular jawline";
			//35-45
			else if (femininity < 45)
				faceo = "the barest hint of masculinity on its features";
			//45-55
			else if (femininity <= 55)
				faceo = "an androgynous set of features that would look normal on a male or female";
			//55+-65
			else if (femininity <= 65)
				faceo = "a tiny touch of femininity to it, with gentle curves";
			//65+-72
			else if (femininity <= 72)
				faceo = "a nice set of cheekbones and lips that have the barest hint of pout";
			//72+-80
			else if (femininity <= 80)
				faceo = "a beautiful, feminine shapeliness that's sure to draw the attention of males";
			//81-90
			else if (femininity <= 90)
				faceo = "a gorgeous profile with full lips, a button nose, and noticeable eyelashes";
			//91-100
			else
				faceo = "a jaw-droppingly feminine shape with full, pouting lips, an adorable nose, and long, beautiful eyelashes";
			return faceo;
		}
		
		//Modify femininity!
		public function modFem(goal:Number, strength:Number = 1):String
		{
			var output:String = "";
			var old:String = faceDesc();
			var oldN:Number = femininity;
			var Changed:Boolean = false;
			//If already perfect!
			if (goal == femininity)
				return "";
			//If turning MANLYMAN
			if (goal < femininity && goal <= 50)
			{
				femininity -= strength;
				//YOUVE GONE TOO FAR! TURN BACK!
				if (femininity < goal)
					femininity = goal;
				Changed = true;
			}
			//if turning GIRLGIRLY, like duh!
			if (goal > femininity && goal >= 50)
			{
				femininity += strength;
				//YOUVE GONE TOO FAR! TURN BACK!
				if (femininity > goal)
					femininity = goal;
				Changed = true;
			}
			//Fix if it went out of bounds!
			if (findPerk(PerkLib.Androgyny) < 0)
				fixFemininity();
			//Abort if nothing changed!
			if (!Changed)
				return "";
			//See if a change happened!
			if (old != faceDesc())
			{
				//Gain fem?
				if (goal > oldN)
					output = "\n\n<b>Your facial features soften as your body becomes more feminine. (+" + strength + ")</b>";
				if (goal < oldN)
					output = "\n\n<b>Your facial features harden as your body becomes more masculine. (+" + strength + ")</b>";
			}
			//Barely noticable change!
			else
			{
				if (goal > oldN)
					output = "\n\nThere's a tingling in your " + face() + " as it changes imperceptibly towards being more feminine. (+" + strength + ")";
				else if (goal < oldN)
					output = "\n\nThere's a tingling in your " + face() + " as it changes imperciptibly towards being more masculine. (+" + strength + ")";
			}
			return output;
		}
		
		public function modThickness(goal:Number, strength:Number = 1):String
		{
			if (goal == thickness)
				return "";
			//Lose weight fatty!
			if (goal < thickness && goal < 50)
			{
				thickness -= strength;
				//YOUVE GONE TOO FAR! TURN BACK!
				if (thickness < goal)
					thickness = goal;
			}
			//Sup tubby!
			if (goal > thickness && goal > 50)
			{
				thickness += strength;
				//YOUVE GONE TOO FAR! TURN BACK!
				if (thickness > goal)
					thickness = goal;
			}
			trace("MOD THICKNESS FIRE");
			//DIsplay 'U GOT FAT'
			if (goal >= thickness && goal >= 50)
				return "\n\nYour center of balance changes a little bit as your body noticeably widens. (+" + strength + " body thickness)";
			//GET THIN BITCH
			else if (goal <= thickness && goal <= 50)
				return "\n\nEach movement feels a tiny bit easier than the last.  Did you just lose a little weight!? (+" + strength + " thin)";
			return "";
		}
		
		public function modTone(goal:Number, strength:Number = 1):String
		{
			if (goal == tone)
				return "";
			//Lose muscle visibility!
			if (goal < tone && goal < 50)
			{
				tone -= strength;
				//YOUVE GONE TOO FAR! TURN BACK!
				if (tone < goal)
				{
					tone = goal;
					return "\n\nYou've lost some tone, but can't lose any more this way. (-" + strength + " muscle tone)";
				}
			}
			//MOAR hulkness
			if (goal > tone && goal > 50)
			{
				tone += strength;
				//YOUVE GONE TOO FAR! TURN BACK!
				if (tone > goal)
				{
					tone = goal;
					return "\n\nYou've gained some muscle tone, but can't gain any more this way. (+" + strength + " muscle tone)";
				}
			}
			//DIsplay BITCH I WORK OUT
			if (goal >= tone && goal > 50)
				return "\n\nYour body feels a little more solid as you move, and your muscles look slightly more visible. (+" + strength + " muscle tone)";
			//Display DERP I HAVE GIRL MUSCLES
			else if (goal <= tone && goal < 50)
				return "\n\nMoving brings with it a little more jiggle than you're used to.  You don't seem to have gained weight, but your muscles look less visible. (-" + strength + " muscle tone)";
			return "";
		}
		
		//Run this every hour to 'fix' femininity.
		public function fixFemininity():String
		{
			var output:String = "";
			//Genderless/herms share the same bounds
			if (gender == 0 || gender == 3)
			{
				if (femininity < 20)
				{
					output += "\n<b>Your incredibly masculine, chiseled features become a little bit softer from your body's changing hormones.";
					/*if (hasBeard())
					{
						output += "  As if that wasn't bad enough, your " + beard() + " falls out too!";
						beardLength = 0;
						beardStyle = 0;
					}*/
					output += "</b>\n";
					femininity = 20;
				}
				else if (femininity > 85)
				{
					output += "\n<b>You find your overly feminine face loses a little bit of its former female beauty due to your body's changing hormones.</b>\n";
					femininity = 85;
				}
			}
			//GURLS!
			else if (gender == 2)
			{
				if (femininity < 30)
				{
					output += "\n<b>Your incredibly masculine, chiseled features become a little bit softer from your body's changing hormones.";
					/*if (hasBeard())
					{
						output += "  As if that wasn't bad enough, your " + beard() + " falls out too!";
						beardLength = 0;
						beardStyle = 0;
					}*/
					output += "</b>\n";
					femininity = 30;
				}
			}
			//BOIZ!
			else if (gender == 1)
			{
				if (femininity > 70)
				{
					output += "\n<b>You find your overly feminine face loses a little bit of its former female beauty due to your body's changing hormones.</b>\n";
					femininity = 70;
				}
				/*if (femininity > 40 && hasBeard())
				{
					output += "\n<b>Your beard falls out, leaving you with " + faceDesc() + ".</b>\n";
					beardLength = 0;
					beardStyle = 0;
				}*/
			}
			/*if (gender != 1 && hasBeard())
			{
				output += "\n<b>Your beard falls out, leaving you with " + faceDesc() + ".</b>\n";
				beardLength = 0;
				beardStyle = 0;
			}*/
			return output;
		}
		
		public function hasBeard():Boolean
		{
			return beardLength > 0;
		}
		
		public function beard():String
		{
			if (hasBeard())
				return "beard";
			else
			{
				//CoC_Settings.error("");
				return "ERROR: NO BEARD! <b>YOU ARE NOT A VIKING AND SHOULD TELL KITTEH IMMEDIATELY.</b>";
			}
		}

		public function hasMuzzle():Boolean
		{
			if (faceType == FACE_HORSE || faceType == FACE_DOG || faceType == FACE_CAT || faceType == FACE_LIZARD || faceType == FACE_KANGAROO || faceType == FACE_FOX || faceType == FACE_DRAGON || faceType == FACE_RHINO || faceType == FACE_ECHIDNA || faceType == FACE_DEER || faceType == FACE_WOLF)
				return true;
			return false;
		}
		
		public function face():String
		{
			var stringo:String = "";
			//0 - human
			//5 - Human w/Naga fangz
			//8 - bunnah faceahhh bunbun
			//10 - spidah-face (humanish)
			if (faceType == 0)
				return "face";
			//1 - horse
			//2 - dogface
			//6 - kittah face
			//7 - lizard face (durned argonians!)
			//9 - kangaface
			if (hasMuzzle())
			{
				if (int(Math.random() * 3) == 0 && faceType == FACE_HORSE)
					stringo = "long ";
				if (int(Math.random() * 3) == 0 && faceType == FACE_CAT)
					stringo = "feline ";
				if (int(Math.random() * 3) == 0 && faceType == FACE_RHINO)
					stringo = "rhino ";
				if (int(Math.random() * 3) == 0 && (faceType == FACE_LIZARD || faceType == FACE_DRAGON))
					stringo = "reptilian ";
				if (int(Math.random() * 3) == 0 && faceType == FACE_WOLF)
					stringo = "canine ";
				switch(rand(3)) {
					case 0:
						return stringo + "muzzle";
					case 1:
						return stringo + "snout";
					case 2:
						return stringo + "face";
					default:
						return stringo + "face";
				}
			}
			//3 - cowface
			if (faceType == FACE_COW_MINOTAUR)
			{
				if (Math.floor(Math.random() * 4) == 0)
					stringo = "bovine ";
				if (int(Math.random() * 2) == 0)
					return "muzzle";
				return stringo + "face";
			}
			//4 - sharkface-teeth
			if (faceType == FACE_SHARK_TEETH)
			{
				if (Math.floor(Math.random() * 4) == 0)
					stringo = "angular ";
				return stringo + "face";
			}
			if (faceType == FACE_PIG || faceType == FACE_BOAR)
			{
				if (Math.floor(Math.random() * 4) == 0)
					stringo = (faceType == FACE_PIG ? "pig" : "boar") + "-like ";
				if (Math.floor(Math.random() * 4) == 0)
					return stringo + "snout";
				return stringo + "face";
			}
			return "face";
		}
		
		public function hasLongTail():Boolean
		{
			//7 - shark tail!
			//8 - catTAIIIIIL
			//9 - lizard tail
			//10 - bunbuntail
			//11 - harpybutt
			//12 - rootail
			//13 - foxtail
			//14 - dagron tail
			if (isNaga())
				return true;
			if (tailType == 2 || tailType == 3 || tailType == 4 || tailType == 7 || tailType == 8 || tailType == 9 || tailType == 12 || tailType == 13 || tailType == 14 || tailType == 15 || tailType == 16 || tailType == 17 || tailType == 18 || tailType == 20)
				return true;
			return false;
		}

		public function isPregnant():Boolean { return _pregnancyType != 0; }

		public function isButtPregnant():Boolean { return _buttPregnancyType != 0; }
	
		
		/**
		 * Impregnate the character with the given pregnancy type if the total fertility 
		 * is greater or equal to the roll.
		 * @param	type the type of pregnancy (@see PregnancyStore.PREGNANCY_xxx)
		 * @param	incubationDuration the incubation duration
		 * @param	maxRoll the possible maximum roll for an impregnation check
		 * @param	forcePregnancy specify a large bonus or malus to fertility (0 = no bonus, positive number = guaranteed pregnancy, negative number = no pregnancy)
		 */
		public function knockUp(type:int = 0, incubationDuration:int = 0, maxRoll:int = 100, forcePregnancy:int = 0):void
		{
			//TODO push this down into player?
			//Contraceptives cancel!
			if (hasStatusEffect(StatusEffects.Contraceptives) && forcePregnancy < 1)
				return;
				
			var bonus:int = 0;
			
			// apply fertility bonus or malus
			if (forcePregnancy >= 1)
				bonus = 9000;
			if (forcePregnancy <= -1)
				bonus = -9000;
				
			//If not pregnant and fertility wins out:
			if (pregnancyIncubation == 0 && totalFertility() + bonus > Math.floor(Math.random() * maxRoll) && hasVagina())
			{
				knockUpForce(type, incubationDuration);
				trace("PC Knocked up with pregnancy type: " + type + " for " + incubationDuration + " incubation.");
			}
			
			//Chance for eggs fertilization - ovi elixir and imps excluded!
			if (type != PregnancyStore.PREGNANCY_IMP && type != PregnancyStore.PREGNANCY_OVIELIXIR_EGGS && type != PregnancyStore.PREGNANCY_ANEMONE)
			{
				if (findPerk(PerkLib.SpiderOvipositor) >= 0 || findPerk(PerkLib.BeeOvipositor) >= 0)
				{
					if (totalFertility() + bonus > Math.floor(Math.random() * maxRoll))
					{
						fertilizeEggs();
					}
				}
			}
		}


		
		 /**
		  * Forcefully override the characters pregnancy. If no pregnancy type is provided,
		  * any current pregancy is cleared.
		  * 
		  * Note: A more complex pregnancy function used by the character is Character.knockUp
		  * The character doesn't need to be told of the last event triggered, so the code here is quite a bit simpler than that in PregnancyStore.
		  * @param	type the type of pregnancy (@see PregnancyStore.PREGNANCY_xxx)
		  * @param	incubationDuration the incubation duration
		  */
		public function knockUpForce(type:int = 0, incubationDuration:int = 0):void
		{
			//TODO push this down into player?
			_pregnancyType = type;
			_pregnancyIncubation = (type == 0 ? 0 : incubationDuration); //Won't allow incubation time without pregnancy type
		}
	
		//fertility must be >= random(0-beat)
		public function buttKnockUp(type:int = 0, incubation:int = 0, beat:int = 100, arg:int = 0):void
		{
			//Contraceptives cancel!
			if (hasStatusEffect(StatusEffects.Contraceptives) && arg < 1)
				return;
			var bonus:int = 0;
			//If arg = 1 (always pregnant), bonus = 9000
			if (arg >= 1)
				bonus = 9000;
			if (arg <= -1)
				bonus = -9000;
			//If unpregnant and fertility wins out:
			if (buttPregnancyIncubation == 0 && totalFertility() + bonus > Math.floor(Math.random() * beat))
			{
				buttKnockUpForce(type, incubation);
				trace("PC Butt Knocked up with pregnancy type: " + type + " for " + incubation + " incubation.");
			}
		}

		//The more complex buttKnockUp function used by the player is defined in Character.as
		public function buttKnockUpForce(type:int = 0, incubation:int = 0):void
		{
			_buttPregnancyType = type;
			_buttPregnancyIncubation = (type == 0 ? 0 : incubation); //Won't allow incubation time without pregnancy type
		}

		public function pregnancyAdvance():Boolean {
			if (_pregnancyIncubation > 0) _pregnancyIncubation--;
			if (_pregnancyIncubation < 0) _pregnancyIncubation = 0;
			if (_buttPregnancyIncubation > 0) _buttPregnancyIncubation--;
			if (_buttPregnancyIncubation < 0) _buttPregnancyIncubation = 0;
			return pregnancyUpdate();
		}

		public function pregnancyUpdate():Boolean { return false; }

		//Create a keyItem
		public function createKeyItem(keyName:String, value1:Number, value2:Number, value3:Number, value4:Number):void
		{
			var newKeyItem:KeyItemClass = new KeyItemClass();
			//used to denote that the array has already had its new spot pushed on.
			var arrayed:Boolean = false;
			//used to store where the array goes
			var keySlot:Number = 0;
			var counter:Number = 0;
			//Start the array if its the first bit
			if (keyItems.length == 0)
			{
				//trace("New Key Item Started Array! " + keyName);
				keyItems.push(newKeyItem);
				arrayed = true;
				keySlot = 0;
			}
			//If it belongs at the end, push it on
			if (keyItems[keyItems.length - 1].keyName < keyName && !arrayed)
			{
				//trace("New Key Item Belongs at the end!! " + keyName);
				keyItems.push(newKeyItem);
				arrayed = true;
				keySlot = keyItems.length - 1;
			}
			//If it belongs in the beginning, splice it in
			if (keyItems[0].keyName > keyName && !arrayed)
			{
				//trace("New Key Item Belongs at the beginning! " + keyName);
				keyItems.splice(0, 0, newKeyItem);
				arrayed = true;
				keySlot = 0;
			}
			//Find the spot it needs to go in and splice it in.
			if (!arrayed)
			{
				//trace("New Key Item using alphabetizer! " + keyName);
				counter = keyItems.length;
				while (counter > 0 && !arrayed)
				{
					counter--;
					//If the current slot is later than new key
					if (keyItems[counter].keyName > keyName)
					{
						//If the earlier slot is earlier than new key && a real spot
						if (counter - 1 >= 0)
						{
							//If the earlier slot is earlier slot in!
							if (keyItems[counter - 1].keyName <= keyName)
							{
								arrayed = true;
								keyItems.splice(counter, 0, newKeyItem);
								keySlot = counter;
							}
						}
						//If the item after 0 slot is later put here!
						else
						{
							//If the next slot is later we are go
							if (keyItems[counter].keyName <= keyName)
							{
								arrayed = true;
								keyItems.splice(counter, 0, newKeyItem);
								keySlot = counter;
							}
						}
					}
				}
			}
			//Fallback
			if (!arrayed)
			{
				//trace("New Key Item Belongs at the end!! " + keyName);
				keyItems.push(newKeyItem);
				keySlot = keyItems.length - 1;
			}
			
			keyItems[keySlot].keyName = keyName;
			keyItems[keySlot].value1 = value1;
			keyItems[keySlot].value2 = value2;
			keyItems[keySlot].value3 = value3;
			keyItems[keySlot].value4 = value4;
			//trace("NEW KEYITEM FOR PLAYER in slot " + keySlot + ": " + keyItems[keySlot].keyName);
		}
		
		//Remove a key item
		public function removeKeyItem(itemName:String):void
		{
			var counter:Number = keyItems.length;
			//Various Errors preventing action
			if (keyItems.length <= 0)
			{
				//trace("ERROR: KeyItem could not be removed because player has no key items.");
				return;
			}
			while (counter > 0)
			{
				counter--;
				if (keyItems[counter].keyName == itemName)
				{
					keyItems.splice(counter, 1);
					trace("Attempted to remove \"" + itemName + "\" keyItem.");
					counter = 0;
				}
			}
		}
		
		public function addKeyValue(statusName:String, statusValueNum:Number = 1, newNum:Number = 0):void
		{
			var counter:Number = keyItems.length;
			//Various Errors preventing action
			if (keyItems.length <= 0)
			{
				return;
					//trace("ERROR: Looking for keyitem '" + statusName + "' to change value " + statusValueNum + ", and player has no key items.");
			}
			while (counter > 0)
			{
				counter--;
				//Find it, change it, quit out
				if (keyItems[counter].keyName == statusName)
				{
					if (statusValueNum < 1 || statusValueNum > 4)
					{
						//trace("ERROR: AddKeyValue called with invalid key value number.");
						return;
					}
					if (statusValueNum == 1)
						keyItems[counter].value1 += newNum;
					if (statusValueNum == 2)
						keyItems[counter].value2 += newNum;
					if (statusValueNum == 3)
						keyItems[counter].value3 += newNum;
					if (statusValueNum == 4)
						keyItems[counter].value4 += newNum;
					return;
				}
			}
			//trace("ERROR: Looking for keyitem '" + statusName + "' to change value " + statusValueNum + ", and player does not have the key item.");
		}
		
		public function keyItemv1(statusName:String):Number
		{
			var counter:Number = keyItems.length;
			//Various Errors preventing action
			if (keyItems.length <= 0)
			{
				return 0;
					//trace("ERROR: Looking for keyItem '" + statusName + "', and player has no key items.");
			}
			while (counter > 0)
			{
				counter--;
				if (keyItems[counter].keyName == statusName)
					return keyItems[counter].value1;
			}
			//trace("ERROR: Looking for key item '" + statusName + "', but player does not have it.");
			return 0;
		}
		
		public function keyItemv2(statusName:String):Number
		{
			var counter:Number = keyItems.length;
			//Various Errors preventing action
			if (keyItems.length <= 0)
			{
				return 0;
					//trace("ERROR: Looking for keyItem '" + statusName + "', and player has no key items.");
			}
			while (counter > 0)
			{
				counter--;
				if (keyItems[counter].keyName == statusName)
					return keyItems[counter].value2;
			}
			//trace("ERROR: Looking for key item '" + statusName + "', but player does not have it.");
			return 0;
		}
		
		public function keyItemv3(statusName:String):Number
		{
			var counter:Number = keyItems.length;
			//Various Errors preventing action
			if (keyItems.length <= 0)
			{
				return 0;
					//trace("ERROR: Looking for keyItem '" + statusName + "', and player has no key items.");
			}
			while (counter > 0)
			{
				counter--;
				if (keyItems[counter].keyName == statusName)
					return keyItems[counter].value3;
			}
			//trace("ERROR: Looking for key item '" + statusName + "', but player does not have it.");
			return 0;
		}
		
		public function keyItemv4(statusName:String):Number
		{
			var counter:Number = keyItems.length;
			//Various Errors preventing action
			if (keyItems.length <= 0)
			{
				return 0;
					//trace("ERROR: Looking for keyItem '" + statusName + "', and player has no key items.");
			}
			while (counter > 0)
			{
				counter--;
				if (keyItems[counter].keyName == statusName)
					return keyItems[counter].value4;
			}
			//trace("ERROR: Looking for key item '" + statusName + "', but player does not have it.");
			return 0;
		}
		
		public function removeKeyItems():void
		{
			var counter:Number = keyItems.length;
			while (counter > 0)
			{
				counter--;
				keyItems.splice(counter, 1);
			}
		}
		
		public function hasKeyItem(keyName:String):Number
		{
			var counter:Number = keyItems.length;
			//Various Errors preventing action
			if (keyItems.length <= 0)
				return -2;
			while (counter > 0)
			{
				counter--;
				if (keyItems[counter].keyName == keyName)
					return counter;
			}
			return -1;
		}
		
		//Grow

		//BreastCup

		/*OLD AND UNUSED
		   public function breastCupS(rowNum:Number):String {
		   if (breastRows[rowNum].breastRating < 1) return "tiny";
		   else if (breastRows[rowNum].breastRating < 2) return "A";
		   else if (breastRows[rowNum].breastRating < 3) return "B";
		   else if (breastRows[rowNum].breastRating < 4) return "C";
		   else if (breastRows[rowNum].breastRating < 5) return "D";
		   else if (breastRows[rowNum].breastRating < 6) return "DD";
		   else if (breastRows[rowNum].breastRating < 7) return "E";
		   else if (breastRows[rowNum].breastRating < 8) return "F";
		   else if (breastRows[rowNum].breastRating < 9) return "G";
		   else if (breastRows[rowNum].breastRating < 10) return "GG";
		   else if (breastRows[rowNum].breastRating < 11) return "H";
		   else if (breastRows[rowNum].breastRating < 12) return "HH";
		   else if (breastRows[rowNum].breastRating < 13) return "HHH";
		   return "massive custom-made";
		 }*/
		public function viridianChange():Boolean
		{
			var count:int = cockTotal();
			if (count == 0)
				return false;
			while (count > 0)
			{
				count--;
				if (cocks[count].sock == "amaranthine" && cocks[count].cockType != CockTypesEnum.DISPLACER)
					return true;
			}
			return false;
		}
		
		public function hasKnot(arg:int = 0):Boolean
		{
			if (arg > cockTotal() - 1 || arg < 0)
				return false;
			return cocks[arg].hasKnot();
		}


		public function maxHP():Number
		{
			var max:Number = 0;
			max += int(tou * 2 + 50);
			if (findPerk(PerkLib.Tank) >= 0) max += 50;
			if (findPerk(PerkLib.Tank2) >= 0) max += Math.round(tou);
			if (findPerk(PerkLib.ChiReflowDefense) >= 0) max += UmasShop.NEEDLEWORK_DEFENSE_EXTRA_HP;
			if (flags[kFLAGS.GRIMDARK_MODE] >= 1)
				max += level * 5;
			else
				max += level * 15;
			if (jewelryEffectId == JewelryLib.MODIFIER_HP) max += jewelryEffectMagnitude;
			max *= 1 + (countCockSocks("green") * 0.02);
			max = Math.round(max);
			if (max > 9999) max = 9999;
			return max;
		}
		
		public function maxLust():Number
		{
			var max:Number = 100;
			if (game.player.demonScore() >= 4) max += 20;
			if (findPerk(PerkLib.ImprovedSelfControl) >= 0) max += 20;
			if (findPerk(PerkLib.BroBody) >= 0 || findPerk(PerkLib.BimboBody) >= 0 || findPerk(PerkLib.FutaForm) >= 0) max += 20;
			if (findPerk(PerkLib.OmnibusGift) >= 0) max += 15;
			if (findPerk(PerkLib.AscensionDesires) >= 0) max += perkv1(PerkLib.AscensionDesires) * 5;
			if (max > 999) max = 999;
			return max;
		}
		
		public function maxHunger():Number
		{
			return 100;
		}
		
		public function growHair(amount:Number = .1):Boolean {
			//Grow hair!
			var tempHair:Number = hairLength;
			if (hairType == HAIR_BASILISK_SPINES) return false;
			hairLength += amount;
			if (hairType == HAIR_BASILISK_PLUME && hairLength > 8) hairLength = 8;
			if (hairLength > 0 && tempHair == 0) {
				game.outputText("\n<b>You are no longer bald.  You now have " + hairDescript() + " coating your head.\n</b>", false);
				return true;
			}
			else if (
				(hairLength >= 1 && tempHair < 1) ||
				(hairLength >= 3 && tempHair < 3) ||
				(hairLength >= 6 && tempHair < 6) ||
				(hairLength >= 10 && tempHair < 10) ||
				(hairLength >= 16 && tempHair < 16) ||
				(hairLength >= 26 && tempHair < 26) ||
				(hairLength >= 40 && tempHair < 40) ||
				(hairLength >= 40 && hairLength >= tallness && tempHair < tallness)
			) {
				game.outputText("\n<b>Your hair's growth has reached a new threshhold, giving you " + hairDescript() + ".\n</b>", false);
				return true;
			}
			return false;
		}

		public function growBeard(amount:Number = .1):Boolean {
			//Grow beard!
			var tempBeard:Number = beardLength;
			beardLength += amount;
			if (beardLength > 0 && tempBeard == 0) {
				game.outputText("\n<b>You feel a tingling in your cheeks and chin.  You now have " + beardDescript() + " coating your cheeks and chin.\n</b>", false);
				return true;
			}
			else if (beardLength >= 0.2 && tempBeard < 0.2) {
				game.outputText("\n<b>Your beard's growth has reached a new threshhold, giving you " + beardDescript() + ".\n</b>", false);
				return true;
			}
			else if (beardLength >= 0.5 && tempBeard < 0.5) {
				game.outputText("\n<b>Your beard's growth has reached a new threshhold, giving you " + beardDescript() + ".\n</b>", false);
				return true;
			}
			else if (beardLength >= 1.5 && tempBeard < 1.5) {
				game.outputText("\n<b>Your beard's growth has reached a new threshhold, giving you " + beardDescript() + ".\n</b>", false);
				return true;
			}
			else if (beardLength >= 3 && tempBeard < 3) {
				game.outputText("\n<b>Your beard's growth has reached a new threshhold, giving you " + beardDescript() + ".\n</b>", false);
				return true;
			}
			else if (beardLength >= 6 && tempBeard < 6) {
				game.outputText("\n<b>Your beard's growth has reached a new threshhold, giving you " + beardDescript() + ".\n</b>", false);
				return true;
			}

			return false;
		}
		
		public function hairOrFur():String
		{
			return Appearance.hairOrFur(this);
		}
		
		public function hairDescript():String
		{
			return Appearance.hairDescription(this);
		}

		public function beardDescript():String
		{
			return Appearance.beardDescription(this);
		}
		
		public function hipDescript():String
		{
			return Appearance.hipDescription(this);
		}
		
		public function assDescript():String
		{
			return buttDescript();
		}
		
		public function buttDescript():String
		{
			return Appearance.buttDescription(this);
		}

		public function tongueDescript():String
		{
			return Appearance.tongueDescription(this);
		}
		
		public function hornDescript():String
		{
			return Appearance.DEFAULT_HORNS_NAMES[hornType] + " horns";
		}

		public function tailDescript():String
		{
			return Appearance.tailDescript(this);
		}
		
		public function oneTailDescript():String
		{
			return Appearance.oneTailDescript(this);
		}
		
		public function wingsDescript():String
		{
			return Appearance.wingsDescript(this);
		}

		public function eyesDescript():String
		{
			return Appearance.eyesDescript(this);
		}

		public function nagaLowerBodyColor2():String
		{
			return Appearance.nagaLowerBodyColor2(this);
		}
	}

}
