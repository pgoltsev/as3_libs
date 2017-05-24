package  core.interfaces {

	/**
	 * Интерфейс обеспечивает методы старта и останова анимации.
	 * 
	 * @author Павел Гольцев
	 */
	public interface IAnimated {
		/**
		 * Запускает анимацию.
		 */
		function startAnimation():void;
		
		/**
		 * Останавливает анимацию.
		 */
		function stopAnimation():void;
		
		/**
		 * Статус анимации, то есть в процессе или закончена/остановлена.
		 */
		function get animationInProgress():Boolean;
	}
	
}