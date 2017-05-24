package controllers.groupScroll {
	import flash.events.Event;

	/**
	 * @author Павел Гольцев
	 */
	internal class GroupContainerEvent extends Event {
		public static const ITEM_CREATE:String = "scItemCreate";
	
		private var _item:IGroupScrollItem;
	
		/**
		 * Конструктор.
		 * 
		 * @param type Тип события.
		 * @param item Элемент, для которого генерируется событие.
		 * @param bubbles Определяет, является ли событие "всплывающим".
		 * @default false
		 * @param cancelable Определяет, является ли событие отменяемым.
		 * @default false
		 */
		public function GroupContainerEvent(type:String, item:IGroupScrollItem, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			
			_item = item;
		}

		override public function clone():Event {
			return new GroupContainerEvent(type, _item, bubbles, cancelable);
		}

		/**
		 * Элемент, для которого сгенерировано событие.
		 */
		public function get item():IGroupScrollItem {
			return _item;
		}
	}
}
