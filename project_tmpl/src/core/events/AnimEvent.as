package core.events {
	import flash.events.Event;

	/**
	 * Класс событий, которые генерируются в процессе анимации.
	 * 
	 * @author Павел Гольцев
	 */
	public class AnimEvent extends Event {
		/**
		 * Генерируется в начале анимации.
		 * 
		 * @eventType start
		 */
		public static const START:String = "aStart";
		/**
		 * Генерируется в конце анимации.
		 * 
		 * @eventType complete
		 */
		public static const COMPLETE:String = "aComplete";
		/**
		 * Генерируется после принудительной остановки анимации.
		 * 
		 * @eventType complete
		 */
		public static const STOP:String = "aStop";
		/**
		 * Генерируется на каждый такт анимации.
		 * 
		 * @eventType update
		 */
		public static const UPDATE:String = "aUpdate";

		/**
		 * Конструктор.
		 * 
		 * @param type Тип события.
		 * @param bubbles Определяет, является ли событие "всплывающим".
		 * @default false
		 * @param cancelable Определяет, является ли событие отменяемым.
		 * @default false
		 */
		public function AnimEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}

		/**
		 * Возвращает точную копию текущего объекта.
		 */
		public override function clone():Event {
			return new AnimEvent(type, bubbles, cancelable);
		}

		/**
		 * Возвращает объект в виде читабельной строки.
		 */
		public override function toString():String {
			return formatToString("AnimEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
	}
}