package core.prgbar {
	
	/**
	 * Интерфейс определяет необходимые параметры для линеек уровня.
	 * 
	 * @author Павел Гольцев
	 */
	public interface IProgressBar {
		/**
		 * Должен определять процент линейки уровня.
		 */
		function set percent(value:Number):void;
		function get percent():Number;
	}
	
}