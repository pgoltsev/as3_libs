package managers.popup {
	import flash.events.IEventDispatcher;
	import popup.IPopup;
	
	/**
	 * @author Павел Гольцев
	 */
	public interface IInitPopup extends IPopup, IEventDispatcher {
		/**
		 * Инициализиарует всплывающее окно. Вызывается единожды сразу после создания всплывающего окна.
		 */
		function initPopup(...args:*):void;
	}
}
