package core.interfaces {

	/**
	 * Интерфейс гарантирует, что объекты, удовлетворяющие ему, 
	 * имеют методы для блокировки содержимого от нажатий левой 
	 * кнопкой мыши по ним.
	 * 
	 * @author Павел Гольцев
	 */
	public interface IEnable {
		/**
		 * Статус блокировки элемента от нажатий левой кнопкой мыши.
		 */
		function get enabled():Boolean;
		function set enabled(enabled:Boolean):void;
	}
}
