package controllers.groupScroll {
	import flash.display.Sprite;

	/**
	 * Класс имитирует вертикальную прокрутку групп элементов. Обязательным условием для корректной работы 
	 * является постоянный одинаковый размер всех элементов по высоте.
	 * 
	 * @author Павел Гольцев
	 * @version 1.0.0
	 */
	public class VerticalGroupScrollController extends HorizontalGroupScrollController {
		public function VerticalGroupScrollController(container:Sprite = null) {
			super(container);
		}

		/**
		 * Функция инициализации контроллера.
		 * 
		 * @param data Массив данных для создания элементов
		 * @param itemClass Класс, на основе которого создаются элементы контроллера. Должен удовлетворять 
		 * интерфейсу <code>IGroupScrollItem</code> и наследоваться от <code>DisplayObject</code>.
		 * @param itemDimension Размер элемента по высоте.
		 * @param activeAreaDimension Высота активной области элементов. 
		 * @param fillBackground Определяет, нужно ли прорисовывать прозрачный задник под элементами.
		 * @default true
		 * @param startIndex Индекс элемента, на который следует перейти при инициализации.
		 * @default 0
		 */
		override public function init(data:Array, itemClass:Class, itemDimension:Number, activeAreaDimension:Number, fillBackground:Boolean = true, startIndex:uint = 0):void {
			super.init(data, itemClass, itemDimension, activeAreaDimension, fillBackground, startIndex);
		}

		override protected function getPositionPropertyName():String {
			return "y";
		}

		override protected function createGroupContainer():GroupContainer {
			return new VerticalGroupContainer();
		}
	}
}
