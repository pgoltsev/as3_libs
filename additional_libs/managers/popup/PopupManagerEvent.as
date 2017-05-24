package managers.popup {
	import flash.events.Event;

	/**
	 * @author Павел Гольцев
	 */
	public class PopupManagerEvent extends Event {
		public static const POPUP_ANIMATION_START:String = "pmPopupAnimationStart";
		public static const POPUP_ANIMATION_COMPLETE:String = "pmPopupAnimationComplete";
		public static const POPUP_ANIMATION_UPDATE:String = "pmPopupAnimationUpdate";
		public static const POPUP_CREATE:String = "pmPopupCreate";
		public static const POPUP_ADDED_TO_PARENT:String = "pmPopupAddedToParent";
		public static const POPUP_INITIALIZED:String = "pmPopupInitialized";
		
		private var _id:String;

		/**
		 * Конструктор.
		 * 
		 * @param type Тип события.
		 * @param id Идентификатор окна, для которого генерируется событие.
		 * @param bubbles Определяет, является ли событие "всплывающим".
		 * @default false
		 * @param cancelable Определяет, является ли событие отменяемым.
		 * @default false
		 */
		public function PopupManagerEvent(type:String, id:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			
			_id = id;
		}

		override public function clone():Event {
			return new PopupManagerEvent(type, _id, bubbles, cancelable);
		}
		
		/**
		 * Идентификатор всплывающего окна, для которого генерируется событие.
		 */
		public function get id():String {
			return _id;
		}
	}
}
