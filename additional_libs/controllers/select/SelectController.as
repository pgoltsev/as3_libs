package controllers.select {
	import core.casalib.CasaEventDispatcherExtended;

	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

	/**
	 * Генерируется при выборе элемента или при отмене выбора.
	 * В последнем случае параметр <code>selected</code> определяется
	 * как null
	 * 
	 * @eventType SelectControllerEvent.SELECT
	 */
	 [Event(name = "scSelect", type = "controllers.select.SelectControllerEvent")]
	 
	/**
	 * Генерируется при наведении мышью на элемент.
	 * 
	 * @eventType SelectControllerEvent.ROLL_OVER
	 */
	 [Event(name = "scRollOver", type = "controllers.select.SelectControllerEvent")]
	 
	/**
	 * Генерируется при отведении мыши с элемента.
	 * 
	 * @eventType SelectControllerEvent.ROLL_OUT
	 */
	 [Event(name = "scRollOut", type = "controllers.select.SelectControllerEvent")]
	
	/**
	 * Класс, контролирующий выбор объектов. Суть контроллера такова, что при выборе
	 * какого-либо элемента, выбранный ранее элемент автоматом отменяется.
	 * 
	 * @author Павел Гольцев
	 * @version 1.2.1
	 */
	public class SelectController extends CasaEventDispatcherExtended {
		protected var _items:Dictionary;
		protected var _registerClickEvent:Boolean; // флаг, указывающий, нужно ли обрабатывать событие нажатия мышью и последующее выделение
		protected var _dispatchRollEventsBySelected:Boolean;
		protected var _selected:Dictionary;
		protected var _previousSelected:Dictionary;

		/**
		 * Конструктор
		 */
		public function SelectController() {
			super();
			
			_registerClickEvent = true;
			_dispatchRollEventsBySelected = false;
		}
		
		/**
		 * Функция инициализации контроллера
		 * 
		 * @param source Источник данных для контроллера. Может быть 2 типов: массив (<code>Array</code>) 
		 * или контейнер (<code>DisplayObjectContainer</code>). Каждый элемент источника данных, соответствующий
		 * интерфейсу <code>ISelectable</code>, будет добавлен в контроллер. Все остальные элементы в источнике будут проигнорированы
		 */
		public function init(source:*):void {
			removeItemsAllListeners();
			
			_items = new Dictionary(true);
			
			var i:uint;
			var clp:Object;
			if (source is Array) {
				for (i = 0; i < source.length; i++) {
					clp = source[i];
					if (initItem(clp)) _items[clp.interactiveClip] = clp;
				}
			} else if (source is DisplayObjectContainer) {
				for (i = 0; i < source.numChildren; i++) {
					clp = source.getChildAt(i);
					if (initItem(clp)) _items[clp.interactiveClip] = clp;
				}	
			}
			
			clearSelected();
			clearPrevSelected();
		}
		
		/**
		 * Определяет текущий выбранный элемент. При установке параметра происходит анимированный выбор элемента
		 */
		public function set selected(obj:ISelectable):void {
			if (!obj) {
				setSelected(obj);
			} else if (_items[obj.interactiveClip]) {
				obj.select();
				setSelected(obj);
			} else {
				throw new ReferenceError("Указаный элемент не найден!");
			}
		}
		
		public function get selected():ISelectable { 
			return getSelected();
		}
		
		/**
		 * При установке параметра происходит мгновенный выбор указанного элемента без какой-либо анимации
		 */
		public function set selectedInstantly(obj:ISelectable):void {
			if (!obj) {
				setSelected(obj, true);
			} else if (_items[obj.interactiveClip]) {
				obj.select(true);
				setSelected(obj, true);
			} else {
				throw new ReferenceError("Указаный элемент не найден!");
			}
		}
		
		/**
		 * Определяет предыдущий выбранный элемент
		 */
		public function get previousSelected():ISelectable {
			return getPrevSelected();
		}
		
		/**
		 * Определяет обработку события нажатия и последующего выделения объекта
		 * для всех объектов, входящих в контроллер
		 */
		public function get registerClickEvent():Boolean {
			return _registerClickEvent;
		}
		
		public function set registerClickEvent(value:Boolean):void {
			if (value == _registerClickEvent) return;
			
			_registerClickEvent = value;
			
			// меняем состояние текущих объектов контроллера
			var item:ISelectable;
			if (_registerClickEvent) {
				for each (item in _items) {
					if (item) item.interactiveClip.addEventListener(MouseEvent.CLICK, onItemClick, false, 0, true);
				}
			} else {
				for each (item in _items) {
					if (item) item.interactiveClip.removeEventListener(MouseEvent.CLICK, onItemClick);
				}
			}
			// ------------------------------------------------
		}
		
		/**
		 * Определяет, нужно ли генерировать события наведения и отведения мыши для 
		 * выбранного элемента. Если <code>true</code>, то события генерируются независимо от того, 
		 * выбран ли элемент. Если же выставлен в <code>false</code>, то события генерируются только 
		 * если элемент не является выбранным. По умолчанию имеет значение <code>false</code>.
		 */
		public function get dispatchRollEventsBySelected():Boolean { return _dispatchRollEventsBySelected; }
		
		public function set dispatchRollEventsBySelected(value:Boolean):void {
			_dispatchRollEventsBySelected = value;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			removeItemsAllListeners();
			
			_items = null;
			_selected = null;
			_previousSelected = null;
			
			super.destroy();
		}
		
		protected function removeItemsAllListeners():void {
			for each (var item:Object in _items) {
				if (item.interactiveClip) {
					item.interactiveClip.removeEventListener(MouseEvent.ROLL_OVER, onItemRollOver);
					item.interactiveClip.removeEventListener(MouseEvent.ROLL_OUT, onItemRollOut);
					item.interactiveClip.removeEventListener(MouseEvent.CLICK, onItemClick);
				}
			}
		}
		
		/**
		 * Инициализирует элемент контроллера, выставляя слушатели его 
		 * интерактивному объекту
		 * 
		 * @param obj Элемент контроллера, который необходимо инициализировать
		 * @return Возвращает <code>true</code>, если объект соответствует требованиям и был успешно инициализирован,
		 * иначе возвращает <code>false</code>
		 */
		protected function initItem(obj:Object):Boolean {
			var item:ISelectable;
			
			if (isObjectAcceplable(obj)) {
				item = ISelectable(obj);
				
				item.interactiveClip.addEventListener(MouseEvent.ROLL_OVER, onItemRollOver, false, 0, true);
				item.interactiveClip.addEventListener(MouseEvent.ROLL_OUT, onItemRollOut, false, 0, true);
				if (_registerClickEvent) item.interactiveClip.addEventListener(MouseEvent.CLICK, onItemClick, false, 0, true);
				item.interactiveClip.buttonMode = true;
				
				item.deselect(true); // отменяем выделение
				
				return true;
			}
			
			return false;
		}
		
		protected function isObjectAcceplable(obj:Object):Boolean {
			return (obj is ISelectable);
		}

		/**
		 * Возвращает текущей выделенный элемент
		 */
		protected function getSelected():ISelectable {
			for each (var item:Object in _selected) {
				return ISelectable(item);
			}
			
			return null;
		}
		
		/**
		 * Возвращает предыдущий выделенный элемент
		 */
		private function getPrevSelected():ISelectable {
			for each (var item:Object in _previousSelected) {
				return ISelectable(item);
			}
			
			return null;
		}
		
		/**
		 * Выделяет указанный элемент контроллера и делает его текущим
		 * 
		 * @param obj Выделяемый элемент
		 * @param deselectInstantly Определяет, как должна происходить отмена текущего выделенного
		 * элемента. Если <code>false</code>, то происходит анимированная отмена выделения элемента,
		 * иначе отмена происходит мгновенно.
		 */
		protected function setSelected(obj:ISelectable, 
									   deselectInstantly:Boolean = false):void {
			var sel:ISelectable = getSelected();
			if (sel) {
				if (sel == obj) return;
				
				sel.deselect(deselectInstantly);
			}
			
			_previousSelected = _selected;
			clearSelected();
			if (obj) _selected[obj.interactiveClip] = obj;
			
			dispatchEvent(new SelectControllerEvent(SelectControllerEvent.SELECT, obj));
		}
		
		/**
		 * Очищает объект, где хранится текущий выделенный элемент
		 */
		protected function clearSelected():void{
			_selected = new Dictionary(true);
		}
		
		/**
		 * Очищает объект, где хранится предыдущий выделенный элемент
		 */
		private function clearPrevSelected():void {
			_previousSelected = new Dictionary(true);
		}
		
		protected function getItemByInteractiveObj(item:Object):ISelectable {
			return _items[item];
		}
		
		/**
		 * Выполняется при уводе мыши с элемента
		 */
		protected function onItemRollOut(e:MouseEvent):void {
			var item:ISelectable = getItemByInteractiveObj(e.currentTarget);
			
			if (getSelected() == item) {
				if (_dispatchRollEventsBySelected) dispatchEvent(new SelectControllerEvent(SelectControllerEvent.ROLL_OUT, item));
				
				return;
			}
			
			dispatchEvent(new SelectControllerEvent(SelectControllerEvent.ROLL_OUT, item));
			
			item.deselect();
		}
		
		/**
		 * Выполняется при наведении мышью на любой элемент
		 */
		protected function onItemRollOver(e:MouseEvent):void {
			var item:ISelectable = getItemByInteractiveObj(e.currentTarget);
			
			if (getSelected() == item) {
				if (_dispatchRollEventsBySelected) dispatchEvent(new SelectControllerEvent(SelectControllerEvent.ROLL_OVER, item));
				
				return;
			}
			
			dispatchEvent(new SelectControllerEvent(SelectControllerEvent.ROLL_OVER, item));
			
			item.select();
		}
		
		/**
		 * Выполняется при наведении нажатии кнопкой мыши на элементе
		 */
		protected function onItemClick(e:MouseEvent):void {
			var item:ISelectable = getItemByInteractiveObj(e.currentTarget);
			
			setSelected(item);
		}
	}
}