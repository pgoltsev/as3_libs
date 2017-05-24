package controllers.groupScroll.custom {
	import buttons.BtnBase;

	import controllers.groupScroll.GroupScrollControllerEvent;
	import controllers.groupScroll.HorizontalGroupScrollController;
	import controllers.select.CustomRollSelectController;
	import controllers.select.ISelectable;
	import controllers.select.SelectController;
	import controllers.select.SelectControllerEvent;

	/**
	 * @author Павел Гольцев
	 */
	public class SelectableHorizontalGroupScrollAndButtonsController extends HorizontalGroupScrollController {
		protected var _selCtrl:SelectController;
		
		private var _btnScrollNext:BtnBase;
		private var _btnScrollPrev:BtnBase;
		private var _selectedID:String;
		private var _selectedItem:IUniqueID;
		private var _useCustomRoll:Boolean;

		/**
		 * Конструктор.
		 * 
		 * @param useCustomRoll Определяет, какие элементы необходимо включать в список выбора. Если <code>true</code>, то 
		 * включаемые элементы должны удовлетворять интерфейсам <code>IRollable</code> и <code>ISelectable</code>. 
		 * Если <code>false</code>, то включаемые элементы должны удовлетворять только интерфейсу <code>ISelectable</code>. 
		 * @default false
		 */
		public function SelectableHorizontalGroupScrollAndButtonsController(useCustomRoll:Boolean = false) {
			_useCustomRoll = useCustomRoll;
			
			localInit();
		}
		
		private function localInit():void {
			createSelectController(); // создаем контроллер выбора элементов
			
			addListeners(); // создаем контроллеер списка прокрутки групп элементов 
		}
		
		/**
		 * Обновляет видимость кнопок на основе разрешения со стороны контроллера групп 
		 * на прокрутку.
		 */
		private function updateScrollButtonsAvailability():void {
			if (_btnScrollNext && _btnScrollNext.content) _btnScrollNext.content.visible = moveNextAvailable;
			if (_btnScrollPrev && _btnScrollPrev.content) _btnScrollPrev.content.visible = movePreviousAvailable;
		}

		private function addListeners():void {
			addEventListener(GroupScrollControllerEvent.ITEM_CREATE, onGroupScrollControllerItemCreate, false, 0, true);
			addEventListener(GroupScrollControllerEvent.GROUP_CHANGE_START, onGroupScrollControllerGroupChangeStart, false, 0, true);
			addEventListener(GroupScrollControllerEvent.GROUP_CHANGE_COMPLETE, onGroupScrollControllerGroupChangeComplete, false, 0, true);
		}

		/**
		 * @inheritDoc
		 */
		override public function init(data:Array, itemClass:Class, itemWidth:Number, activeAreaWidth:Number, fillBackground:Boolean = true, startIndex:uint = 0):void {
			_selCtrl.init([]); // очищаем контроллер выбора элементов
			
			super.init(data, itemClass, itemWidth, activeAreaWidth, fillBackground, startIndex);
			
			// обновляем видимость кнопок в зависимости от общего количества элементов
			updateScrollButtonsAvailability(); 
		}

		/**
		 * Срабатывает перед изменением группы с элементами для списка прокрутки. В момент 
		 * генерации доступен массив элементов, которые будут удалены.
		 */
		protected function onGroupScrollControllerGroupChangeStart(event:GroupScrollControllerEvent):void {
			container.mouseChildren = false; // блокируем список от взаимодействия с пользователем
			
			_selectedItem = null;
		}

		protected function onGroupScrollControllerGroupChangeComplete(event:GroupScrollControllerEvent):void {
			container.mouseChildren = true; // разблокируем список для взаимодействия с пользователем
			
			// производим инициализацию коонтроллера выбора элементами нового списка из контроллера прокрутки
			initSelectControllerByItemsArray(currentGroupItems);
		}

		/**
		 * Функция генерирует из массива элементов контроллера списка прокрутки групп 
		 * массив для идентификации контроллера выбора актеров и производит идентификацию этого 
		 * самого контроллера. Сделано потому, что сам элемент группового списка содержит в 
		 * себе несколько элементов, которые должны выбираться по отдельности.
		 * 
		 * @param actorsPanelItems Массив элементов контроллера прокрутки групп. 
		 */
		private function initSelectControllerByItemsArray(items:Array):void {
			var userDataControllers:Array; 
			var resultArray:Array = new Array();
			var item:IItemsSet;
			var num:uint = items.length;
			for (var i:uint = 0; i < num; i++) {
				item = items[i] as IItemsSet;
				if (!item) continue;
				
				userDataControllers = item.items;
				
				var num1:uint = userDataControllers.length;
				for (var j:uint = 0; j < num1; j++) {
					resultArray.push(userDataControllers[j]);
				}
			}
			
			_selCtrl.init(resultArray);
			
			updateSelectionAfterGroupChangeComplete();
		}

		protected function updateSelectionAfterGroupChangeComplete():void {
			if (_selectedItem) {
				_selCtrl.removeEventListener(SelectControllerEvent.SELECT, onItemSelect);
				_selCtrl.selected = ISelectable(_selectedItem);
				_selCtrl.addEventListener(SelectControllerEvent.SELECT, onItemSelect, false, 0, true);
			}
		}

		/**
		 * Обработчик события создания элементов в контроллере прокрутки групп.   
		 */
		protected function onGroupScrollControllerItemCreate(event:GroupScrollControllerEvent):void {
			if (_selectedID && !_selectedItem && event.item is IItemsSet) {
				var items:Array = IItemsSet(event.item).items;
				
				var item:IUniqueID;
				var num:uint = items.length;
				for (var i:uint = 0; i < num; i++) {
					item = items[i] as IUniqueID;
					if (!item) continue;
					
					if (_selectedID == item.groupScrollUniqueID) {
						_selectedItem = item;
						break;
					}
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function moveToGroupAtIndex(groupIndex:uint, instantly:Boolean = false):Boolean {
			var result:Boolean = super.moveToGroupAtIndex(groupIndex, instantly);
			updateScrollButtonsAvailability();
			return result;
		}

		/**
		 * @inheritDoc
		 */
		override public function moveToPreviousGroup(instantly:Boolean = false):Boolean {
			var result:Boolean = super.moveToPreviousGroup(instantly);
			updateScrollButtonsAvailability();
			return result; 
		}

		/**
		 * @inheritDoc
		 */
		override public function moveToNextGroup(instantly:Boolean = false):Boolean {
			var result:Boolean = super.moveToNextGroup(instantly);
			updateScrollButtonsAvailability();
			return result;
		}

		protected function createSelectController():void {
			_selCtrl = createSelectControllerLocal();
			_selCtrl.addEventListener(SelectControllerEvent.SELECT, onItemSelect, false, 0, true);
		}

		protected function createSelectControllerLocal():SelectController {
			return _useCustomRoll ? new CustomRollSelectController() : new SelectController();
		}

		protected function onItemSelect(event:SelectControllerEvent):void {
			_selectedID = event.targetItem is IUniqueID ? IUniqueID(event.targetItem).groupScrollUniqueID : null; 
			
			dispatchEvent(event.clone());
		}

		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			removeEventListener(GroupScrollControllerEvent.ITEM_CREATE, onGroupScrollControllerItemCreate);
			removeEventListener(GroupScrollControllerEvent.GROUP_CHANGE_START, onGroupScrollControllerGroupChangeStart);
			removeEventListener(GroupScrollControllerEvent.GROUP_CHANGE_COMPLETE, onGroupScrollControllerGroupChangeComplete);
			
			if (_selCtrl) {
				_selCtrl.removeEventListener(SelectControllerEvent.SELECT, onItemSelect);
				_selCtrl.destroy();
				_selCtrl = null;
			}
			
			_btnScrollNext = null;
			_btnScrollPrev = null;
			
			_selectedItem = null;
		}

		/**
		 * Кнопка перехода к следующему списку элементов.
		 */
		public function get scrollNextButton():BtnBase {
			return _btnScrollNext;
		}
		
		public function set scrollNextButton(scrollNextButton:BtnBase):void {
			_btnScrollNext = scrollNextButton;
			
			updateScrollButtonsAvailability();
		}
		
		/**
		 * Кнопка перехода к предыдущему списку элементов.
		 */
		public function get scrollPreviousButton():BtnBase {
			return _btnScrollPrev;
		}
		
		public function set scrollPreviousButton(scrollPreviousButton:BtnBase):void {
			_btnScrollPrev = scrollPreviousButton;
			
			updateScrollButtonsAvailability();
		}
		
		/**
		 * Идентификатор выбранного в текущий момент времени элемента.
		 */
		public function get selectedID():String {
			return _selectedID;
		}
		
		public function set selectedID(selectedID:String):void {
			_selectedID = selectedID;
			
			var num:uint = container.numChildren;
			var item:IItemsSet;
			var selectableItems:Array;
			var uniqueIDItem:IUniqueID;
			for (var i:uint = 0; i < num; i++) {
				item = container.getChildAt(i) as IItemsSet;
				if (!item) continue;
				
				selectableItems = item.items;
				var num1:uint = selectableItems.length;
				for (var j:uint = 0; j < num1; j++) {
					uniqueIDItem = selectableItems[j] as IUniqueID;
					if (_selectedID == uniqueIDItem.groupScrollUniqueID && uniqueIDItem is ISelectable) {
						_selectedItem = uniqueIDItem;
						
						break;
					}
				}
			}
			
			_selCtrl.selected = uniqueIDItem as ISelectable;
		}
	}
}
