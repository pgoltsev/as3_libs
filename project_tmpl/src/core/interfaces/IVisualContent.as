package core.interfaces {
	import flash.display.DisplayObject;

	/**
	 * Интерфейс обеспечивает доступ к визуальному содержимому объекта, 
	 * класс которого удовлетворяет данному интерфейсу.
	 * 
	 * @author Павел Гольцев
	 */
	public interface IVisualContent {
		/**
		 * Визуальное содержимое объекта.
		 */
		function get visualContent():DisplayObject;
	}
}
