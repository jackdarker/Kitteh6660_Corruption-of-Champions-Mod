package classes.internals 
{
	/**
	 * ...
	 * @author jk
	 */
	public class TakeoutDrop implements RandomDrop
	{
		private var items:Array = [];
		private var sum:Number = 0;
		/*Fill a box with ites and then you can call repeatedly roll to take out one random item one after another
		 * until rool returns null (=box empty).
		 * Similiar like wheigtedDrop
		 * */
		public function TakeoutDrop(first:* = null, firstWeight:Number = 0)
		{
			if (first != null)
			{
				items.push([first, firstWeight]);
				sum += firstWeight;
			}
		}
		
		public function add(item:*, weight:Number = 1):TakeoutDrop
		{
			items.push([item, weight]);
			sum += weight;
			return this;
		}
		
		public function addMany(weight:Number, ... _items):TakeoutDrop
		{
			for each (var item:*in _items)
			{
				items.push([item, weight]);
				sum += weight;
			}
			return this;
		}
		public function roll():*
		{
			var random:Number = Math.random() * sum;
			var item:* = null;
			var index:uint = 0;
			var x:Number = 0;
			var dx:Number = 0;
			while (index < items.length)
			{
				var pair:Array = items[index];
				dx = pair[1];
				if (random > x && random <= (x + dx)) {
					item = pair[0];
					items.splice(index, 1);
					sum = sum -dx;
					break;	
				} else {
					x = x + dx;
					index++;
				}
			}
			return item;
		}
		
		public function clone():TakeoutDrop
		{
			var other:TakeoutDrop = new TakeoutDrop();
			other.items = items.slice();
			other.sum = sum;
			return other;
		}
	}
}