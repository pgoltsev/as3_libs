package core.events {
	import flash.events.Event;

	/**
	 * @author Павел Гольцев
	 */
	public class DestroyEvent extends Event {
		/**
		 * Генерируется сразу после уничтожения объекта.
		 */
		public static const DESTROYED:String = "destroyed";
		
		public function DestroyEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new DestroyEvent(type, bubbles, cancelable);
		}
	}
}
