package controllers.groupScroll {
	import flash.events.Event;

	/**
	 * Класс событий, генерируемых контроллером прокрутки групп элементов.
	 * 
	 * @author Павел Гольцев
	 */
	public class GroupScrollControllerEvent extends Event {
		/**
		 * Генерируется при создании элемента.
		 */
		public static const ITEM_CREATE:String = "gscItemCreate";
		
		/**
		 * Генерируется перед началом смены группы элементов.
		 */		public static const GROUP_CHANGE_START:String = "gscGroupChangeStart";
		
		/**
		 * Генерируется после смены группы элементов.
		 */		public static const GROUP_CHANGE_COMPLETE:String = "gscGroupChangeComplete";
		
		private var _item:IGroupScrollItem;

		/**
		 * Конструктор.
		 * 
		 * @param type Тип события.
		 * @param item Элемент, для которого генерируется событие.
		 * @default null
		 * @param bubbles Определяет, является ли событие "всплывающим".
		 * @default false
		 * @param cancelable Определяет, является ли событие отменяемым.
		 * @default false
		 */
		public function GroupScrollControllerEvent(type:String, item:IGroupScrollItem = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			
			_item = item;
		}

		override public function clone():Event {
			return new GroupScrollControllerEvent(type, _item, bubbles, cancelable);
		}

		/**
		 * Элемент, для которого сгенерировано событие.
		 */
		public function get item():IGroupScrollItem {
			return _item;
		}
	}
}
