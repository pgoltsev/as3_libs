package controllers.select {
	import flash.events.Event;
	
	/**
	 * Класс событий контроллера выбора.
	 * 
	 * @author Павел Гольцев
	 */
	public class SelectControllerEvent extends Event {
		/**
		 * Генерируется при выборе элемента из списка.
		 * 
		 * @eventType scSelect
		 */
		public static const SELECT:String = "scSelect";
		
		/**
		 * Генерируется при наведении мышью на элемент списка.
		 * 
		 * @eventType scRollOver
		 */
		public static const ROLL_OVER:String = "scRollOver";
		
		/**
		 * Генерируется при отведении мыши с элемента списка.
		 * 
		 * @eventType scRollOut
		 */
		public static const ROLL_OUT:String = "scRollOut";
		
		private var _targetItem:ISelectable;
		
		/**
		 * Конструктор.
		 * 
		 * @param type Тип события.
		 * @param targetItem Элемент, сгенерировавщий событие.
		 * @param bubbles Определяет, является ли событие "всплывающим".
		 * @default false
		 * @param cancelable Определяет, является ли событие отменяемым.
		 * @default false
		 */
		public function SelectControllerEvent(type:String, 
											  targetItem:ISelectable,
											  bubbles:Boolean = false,
											  cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			
			_targetItem = targetItem;
		} 
		
		/**
		 * Возвращает точную копию текущего объекта.
		 */
		public override function clone():Event { 
			return new SelectControllerEvent(type, _targetItem, bubbles, cancelable);
		} 
		
		/**
		 * Возвращает объект в виде читабельной строки.
		 */
		public override function toString():String { 
			return formatToString("SelectControllerEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		/**
		 * Элемент, для которого сгенерировано событие.
		 */
		public function get targetItem():ISelectable { return _targetItem; }
		
	}
	
}