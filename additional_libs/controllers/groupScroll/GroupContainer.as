package controllers.groupScroll {
	import core.casalib.CasaSpriteExtended;

	import org.casalib.core.IDestroyable;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.Dictionary;

	/**
	  * Генерируется при создании элемента.
	  * 
	  * @eventType SubContainerEvent.ITEM_CREATE
	  */
	 [Event(name="scItemCreate", type="controllers.groupScroll.GroupContainerEvent")]

	/**
	 * @author Павел Гольцев
	 */
	internal class GroupContainer extends CasaSpriteExtended {
		private var _items:Dictionary;
		
		public function GroupContainer() {
			super();
		}
		
		/**
		 * Инициализирует контейнер.
		 * 
		 * @param data Данные для инициализации.
		 * @param itemClass Класс для создания элементов.
		 * @param itemDimension Ширина элемента.
		 * @param fillBackground Определяет, нужно ли прорисовывать прозрачный задник под элементами.
		 */
		public function init(data:Array, itemClass:Class, itemDimension:Number, fillBackground:Boolean):void {
			removeAllChildren();
			
			_items = new Dictionary();
			
			var item:IGroupScrollItem;
			var num:uint = data.length;
			var position:Number = 0;
			for (var i:uint = 0; i < num; i++) {
				item = new itemClass() as IGroupScrollItem;
				if (!item) {
					throw new Error("Класс элементов должен удовлетворять интерфейсу IGroupScrollItem!");
					return;
				}
				
				_items[item.visualContent] = item;
				
				item.initByGroupScroll(data[i]);
				
				item.visualContent.addEventListener(Event.ADDED_TO_STAGE, onItemAddedToStage, false, 0, true);
				updateItemVisualContentPosition(item.visualContent, position);
				addChild(item.visualContent);
				
				position += itemDimension;
			}
	
			if (fillBackground) drawBackground();
		}

		protected function updateItemVisualContentPosition(visualContent:DisplayObject, position:Number):void {
			visualContent.x = position;
		}

		private function onItemAddedToStage(event:Event):void {
			var visualContent:DisplayObject = DisplayObject(event.target);
			visualContent.removeEventListener(Event.ADDED_TO_STAGE, onItemAddedToStage);
			
			dispatchEvent(new GroupContainerEvent(GroupContainerEvent.ITEM_CREATE, IGroupScrollItem(_items[visualContent])));
		}
	
		private function drawBackground():void {
			graphics.clear();
			graphics.beginFill(0xFF0000, 0);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
		}
	
		/**
		 * Удаляет все элементы из контейнера.
		 */
		public function removeAllChildren():void {
			var item:IGroupScrollItem;
			
			for (var visualContent:Object in _items) {
				item = _items[visualContent];
				item.visualContent.removeEventListener(Event.ADDED_TO_STAGE, onItemAddedToStage);
				if (contains(item.visualContent)) removeChild(item.visualContent);
				if (item is IDestroyable) IDestroyable(item).destroy();
			}
			
			_items = null;
			
			graphics.clear();
		}
		
		/**
		 * Элементы контейнера.
		 */
		public function get items():Array {
			var items:Array = new Array();
			for (var content:Object in _items) {
				items.push(_items[content]);
			}
			
			return items;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			removeAllChildren();
			
			super.destroy();
		}
	}
}