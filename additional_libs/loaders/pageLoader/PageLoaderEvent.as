package loaders.pageLoader {
	import flash.events.Event;

	/**
	 * Класс событий, генерируемых загрузчиком страниц.
	 * @author Павел Гольцев
	 */
	public class PageLoaderEvent extends Event {
		/**
		 * Генерируется в начале загрузки страницы и ее данных.
		 */
		public static const LOAD_START:String = "plLoadStart";
		
		/**
		 * Генерируется в конце загрузки страницы и ее данных.
		 */
		public static const LOAD_COMPLETE:String = "plLoadComplete";
		
		/**
		 * Генерируется в процессе загрузки страницы и ее данных.
		 */
		public static const LOAD_PROGRESS:String = "plLoadProgress";
		
		/**
		 * Генерируется, если загрузка была отменена.
		 */
		public static const LOAD_CANCEL:String = "plLoadCancel";
		
		private var _bytesTotal:Number;
		private var _bytesLoaded:Number;
		
		/**
		 * Конструктор.
		 * 
		 * @param type Тип генерируемого события.
		 * @param bubbles Определяет, является ли генерируемое событие "всплываемым".
		 * @default false
		 * @param cancelable Определяет, является ли генерируемое событие отменяемым.
		 * @default false
		 * @param bytesLoaded Количество загруженных байт данных.
		 * @default 0
		 * @param bytesTotal Общее количестов байт данных для загрузки.
		 * @default 0
		 */
		public function PageLoaderEvent(type:String, 
										bubbles:Boolean = false, 
										cancelable:Boolean = false,
										bytesLoaded:Number = 0,
										bytesTotal:Number = 0) { 
			super(type, bubbles, cancelable);
			
			_bytesLoaded = bytesLoaded;
			_bytesTotal = bytesTotal;
		} 
		
		public override function clone():Event { 
			return new PageLoaderEvent(type, bubbles, cancelable, _bytesLoaded, _bytesTotal);
		} 
		
		public override function toString():String { 
			return formatToString("PageLoaderEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		/**
		 * Общее количество байт данных для загрузки.
		 */
		public function get bytesTotal():Number { return _bytesTotal; }
		
		/**
		 * Загруженное на текущий момент количество байт данных.
		 */
		public function get bytesLoaded():Number { return _bytesLoaded; }
	}
	
}