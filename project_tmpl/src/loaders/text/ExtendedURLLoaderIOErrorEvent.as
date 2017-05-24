package loaders.text {
	import flash.events.*;
		
	/**
	 * Класс событий, генерируемых одноименным классом загрузки текстовых данных.
	 * 
	 * @author Павел Гольцев
	 */
	public class ExtendedURLLoaderIOErrorEvent extends IOErrorEvent {
		/**
		 * Определяет событие, генерируемое в том случае, если все дополнительные
		 * попытки загрузки данных завершились с ошибками.
		 */
		public static const IO_ERROR:String = "eulIOError";
		
		/**
		 * Конструктор.
		 * 
		 * @param type Тип генерируемого события.
		 * @param bubbles Определяет, является ли генерируемое событие "всплываемым".
		 * @default false
		 * @param cancelable Определяет, является ли генерируемое событие отменяемым.
		 * @default false
		 */
		public function ExtendedURLLoaderIOErrorEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) { 
			super(type, bubbles, cancelable);
		} 
		
		/**
		 * Возвращает точную копию текущего объекта.
		 */
		public override function clone():Event { 
			return new ExtendedURLLoaderIOErrorEvent(type, bubbles, cancelable);
		} 
		
		/**
		 * Возвращает объект в виде читабельной строки.
		 */
		public override function toString():String { 
			return formatToString("ExtendedURLLoaderIOErrorEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}