package classes
{
	
	import classes.Items.ConsumableLib;
	import classes.internals.SerializationUtils;
	import org.hamcrest.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasProperty;
	
	public class ItemSlotTest
	{
		private static var consumables:ConsumableLib = new ConsumableLib();
		
		private static const QUANTITY:int = 3;
		private static const ITYPE:ItemType = consumables.CANINEP;
		private static const UNLOCKED:Boolean = false;
		private static const DAMAGE:int = 6;
		
		
		
		private var deserialized:ItemSlot;
		private var serializedClass:*;
		private var cut:ItemSlot;
		
		[Before]
		public function setUp():void
		{
			cut = new ItemSlot();
			cut.setItemAndQty(ITYPE, QUANTITY);
			cut.unlocked = UNLOCKED;
			cut.damage = DAMAGE;
			
			deserialized = new ItemSlot();
			serializedClass = [];
			
			SerializationUtils.serialize(serializedClass, cut);
			SerializationUtils.deserialize(serializedClass, deserialized);
		}
		
		[Test]
		public function serializeQuantity():void
		{
			assertThat(serializedClass, hasProperty("quantity", QUANTITY));
		}
		
		[Test]
		public function serializeItype():void
		{
			assertThat(serializedClass, hasProperty("id", ITYPE.id));
		}
		
		[Test]
		public function serializeUnlocked():void
		{
			assertThat(serializedClass, hasProperty("unlocked", UNLOCKED));
		}
		
		[Test]
		public function serializeDamage():void
		{
			assertThat(serializedClass, hasProperty("damage", DAMAGE));
		}
		
		[Test]
		public function deserializeQuantity():void
		{
			assertThat(deserialized.quantity, equalTo(QUANTITY));
		}
		
		[Test]
		public function deserializeItype():void
		{
			assertThat(deserialized.itype.id, equalTo(ITYPE.id));
		}
		
		[Test]
		public function deserializeItypeWithLegacyShortName():void
		{
			delete serializedClass["serializationVersion"];
			delete serializedClass["id"];
			serializedClass.shortName = ITYPE.shortName;
			
			SerializationUtils.deserialize(serializedClass, deserialized);
			
			assertThat(deserialized.itype.id, equalTo(ITYPE.id));
		}
		
		[Test]
		public function deserializeItypeWithUnversionedID():void
		{
			delete serializedClass["serializationVersion"];
			
			SerializationUtils.deserialize(serializedClass, deserialized);
			
			assertThat(deserialized.itype.id, equalTo(ITYPE.id));
		}
		
		[Test]
		public function upgradeLegacyGroPlusShortName():void
		{
			delete serializedClass["serializationVersion"];
			delete serializedClass["id"];
			serializedClass.shortName = "Gro+";
			
			SerializationUtils.deserialize(serializedClass, deserialized);
			
			assertThat(deserialized.itype.id, equalTo(consumables.GROPLUS.id));
		}
		
		[Test]
		public function upgradeLegacySpecialHoneyShortName():void
		{
			delete serializedClass["serializationVersion"];
			delete serializedClass["id"];
			serializedClass.shortName = "Sp Honey";
			
			SerializationUtils.deserialize(serializedClass, deserialized);
			
			assertThat(deserialized.itype.id, equalTo(consumables.SPHONEY.id));
		}
		
		[Test]
		public function deserializeUnlocked():void
		{
			assertThat(deserialized.unlocked, equalTo(UNLOCKED));
		}
		
		[Test]
		public function deserializeDamage():void
		{
			assertThat(deserialized.damage, equalTo(DAMAGE));
		}
	}
}
