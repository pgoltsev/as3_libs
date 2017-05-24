package controllers.groupScroll {
	import core.interfaces.IVisualContent;

	/**
	 * Интерфейс, которому должны удовлетворять элементы, создаваемые в 
	 * контроллере. 
	 * 
	 * @author Павел Гольцев
	 */
	public interface IGroupScrollItem extends IVisualContent {
		/**
		 * Производит инициализацию элемента контроллера данными.
		 * Функция вызывается при создании и при каждом последующем изменении данных в 
		 * элементе при прокрутке. 
		 */
		function initByGroupScroll(data:Object):void;
	}
}
