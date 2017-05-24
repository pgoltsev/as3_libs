package controllers.groupScroll {
	import flash.display.DisplayObject;

	/**
	 * @author Павел Гольцев
	 */
	public class VerticalGroupContainer extends GroupContainer {
		public function VerticalGroupContainer() {
			super();
		}

		/**
		 * Инициализирует контейнер.
		 * 
		 * @param data Данные для инициализации.
		 * @param itemClass Класс для создания элементов.
		 * @param itemDimension Высота элемента.
		 * @param fillBackground Определяет, нужно ли прорисовывать прозрачный задник под элементами.
		 */
		override public function init(data:Array, itemClass:Class, itemDimension:Number, fillBackground:Boolean):void {
			super.init(data, itemClass, itemDimension, fillBackground);
		}

		override protected function updateItemVisualContentPosition(visualContent:DisplayObject, position:Number):void {
			visualContent.y = position;
		}
	}
}
