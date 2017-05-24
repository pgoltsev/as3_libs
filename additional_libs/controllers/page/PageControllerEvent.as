package controllers.page {
	import flash.events.Event;

	/**
	 * Класс событий контроллера страниц.
	 * 
	 * @author Павел Гольцев
	 */
	public class PageControllerEvent extends Event {
		private var _pageID:String;
		
		/**
		 * Генерируется в начале входной анимации текущей страницы.
		 */
		public static const PAGE_IN_ANIMATION_START:String = "pcPageIntroAnimationStart";
		
		/**
		 * Генерируется в конце входной анимации текущей страницы.
		 */
		public static const PAGE_IN_ANIMATION_COMPLETE:String = "pcPageIntroAnimationComplete";

		/**
		 * Генерируется в начале выходной анимации предыдущей страницы.
		 */
		public static const PAGE_OUT_ANIMATION_START:String = "pcPageOutAnimationStart";

		/**
		 * Генерируется в конце выходной анимации предыдущей страницы.
		 */
		public static const PAGE_OUT_ANIMATION_COMPLETE:String = "pcPageOutAnimationComplete";

		/**
		 * Генерируется в начале анимации смены страниц.
		 */
		public static const ANIMATION_START:String = "pcPagesAnimationStart";

		/**
		 * Генерируется в конце анимации смены страниц.
		 */
		public static const ANIMATION_COMPLETE:String = "pcPagesAnimationComplete";

		/**
		 * Генерируется, когда одна страница уже закрыта и контроллер готов к открытию новой страницы.
		 */
		public static const PAGE_CHANGE:String = "pcPageChange";

		/**
		 * Конструктор.
		 * 
		 * @param type Тип события.
		 * @param pageID Идентификатор страницы, для которой сгенерировано событие.
		 * @default null
		 * @param bubbles Определяет, является ли событие "всплывающим".
		 * @default false
		 * @param cancelable Определяет, является ли событие отменяемым.
		 * @default false
		 */
		public function PageControllerEvent(type:String, 
											pageID:String,
											bubbles:Boolean = false,
											cancelable:Boolean = false) { 
			super(type, bubbles, cancelable);
			
			_pageID = pageID;
		}

		/**
		 * Возвращает точную копию текущего объекта.
		 */
		public override function clone():Event { 
			return new PageControllerEvent(type, _pageID, bubbles, cancelable);
		} 

		/**
		 * Возвращает объект в виде читабельной строки.
		 */
		public override function toString():String { 
			return formatToString("PageControllerEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}

		/**
		 * Идентификатор страницы, для которой сгенерировано событие.
		 */
		public function get pageID():String {
			return _pageID;
		}
	}
}