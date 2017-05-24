package controllers.groupScroll {
	import caurina.transitions.Tweener;

	import core.casalib.CasaEventDispatcherExtended;
	import core.events.AnimEvent;

	import flash.display.Sprite;

	/**
	 * Возникает при старте анимации. При этом значение <code>animationInProgress</code>
	 * уже выставлено в <code>true</code>.
	 * 
	 * @eventType AnimEvent.START 
	 */
	[Event(name = "aStart", type = "core.events.AnimEvent")]
	/**
	 * Возникает в конце анимации. При этом значение <code>animationInProgress</code>
	 * уже выставлено в <code>false</code>.
	 * 
	 * @eventType AnimEvent.COMPLETE
	 */
	[Event(name = "aComplete", type = "core.events.AnimEvent")]
	/**
	 * Генерируется на каждый кадр при запущенной анимации.
	 * 
	 * @eventType AnimEvent.UPDATE 
	 */
	[Event(name = "aUpdate", type = "core.events.AnimEvent")]
	/**
	 * Генерируется при создании элемента.
	 * 
	 * @eventType GroupScrollControllerEvent.ITEM_CREATE
	 */
	[Event(name="gscItemCreate", type="controllers.groupScroll.GroupScrollControllerEvent")]
	/**
	 * Генерируется перед началом изменения группы элементов.
	 * 
	 * @eventType GroupScrollControllerEvent.GROUP_CHANGE_START
	 */
	[Event(name="gscGroupChangeStart", type="controllers.groupScroll.GroupScrollControllerEvent")]
	/**
	 * Генерируется после изменения группы элементов.
	 * 
	 * @eventType GroupScrollControllerEvent.GROUP_CHANGE_COMPLETE
	 */
	[Event(name="gscGroupChangeComplete", type="controllers.groupScroll.GroupScrollControllerEvent")]
	/**
	 * Класс имитирует горизонтальную прокрутку групп элементов. Обязательным условием для корректной работы 
	 * является постоянный одинаковый размер всех элементов по ширине.
	 * 
	 * @author Павел Гольцев
	 * @version 1.0.1
	 */
	public class HorizontalGroupScrollController extends CasaEventDispatcherExtended {
		public static const DEFAULT_ANIMATION_TIME:Number = 0.7;
		public static const DEFAULT_ANIMATION_TRANSITION:String = "easeInOutSine";
		private var _groupContainerActive:GroupContainer;
		private var _activeAreaDimension:Number;
		private var _container:Sprite;
		private var _itemClass:Class;
		private var _data:Array;
		private var _groupContainer1:GroupContainer;
		private var _groupContainer2:GroupContainer;
		private var _itemDimension:Number;
		private var _fillBackground:Boolean;
		private var _itemsInGroupCount:uint;
		private var _totalGroupsCount:uint;
		private var _currentGroupIndex:uint;
		private var _animationTransition:String;
		private var _animationTime:Number;
		private var _animationInProgress:Boolean;

		/**
		 * Конструктор.
		 * 
		 * @param container Контейнер для элементов. Если не задан, то создается при 
		 * создании контроллера.
		 * @default null
		 */
		public function HorizontalGroupScrollController(container:Sprite = null) {
			super();

			localInit(container);
		}

		private function localInit(container:Sprite):void {
			_animationTime = DEFAULT_ANIMATION_TIME;
			_animationTransition = DEFAULT_ANIMATION_TRANSITION;

			if (!container) container = new Sprite();
			_container = container;

			createSubContainers();
		}

		private function createSubContainers():void {
			_groupContainer1 = createGroupContainer();
			_groupContainer2 = createGroupContainer();
			_groupContainer1.name = "sub1";
			_groupContainer2.name = "sub2";

			_groupContainer1.addEventListener(GroupContainerEvent.ITEM_CREATE, onSubContainerItemCreate, false, 0, true);
			_groupContainer2.addEventListener(GroupContainerEvent.ITEM_CREATE, onSubContainerItemCreate, false, 0, true);

			_container.addChild(_groupContainer1);
			_container.addChild(_groupContainer2);
		}

		protected function createGroupContainer():GroupContainer {
			return new GroupContainer();
		}

		private function onSubContainerItemCreate(event:GroupContainerEvent):void {
			dispatchEvent(new GroupScrollControllerEvent(GroupScrollControllerEvent.ITEM_CREATE, event.item));
		}

		/**
		 * Функция инициализации контроллера.
		 * 
		 * @param data Массив данных для создания элементов
		 * @param itemClass Класс, на основе которого создаются элементы контроллера. Должен удовлетворять 
		 * интерфейсу <code>IGroupScrollItem</code> и наследоваться от <code>DisplayObject</code>.
		 * @param itemDimension Размер элемента по ширине.
		 * @param activeAreaDimension Ширина активной области элементов. 
		 * @param fillBackground Определяет, нужно ли прорисовывать прозрачный задник под элементами.
		 * @default true
		 * @param startIndex Индекс элемента, на который следует перейти при инициализации.
		 * @default 0
		 */
		public function init(data:Array, itemClass:Class, itemDimension:Number, activeAreaDimension:Number, fillBackground:Boolean = true, startIndex:uint = 0):void {
			removeAllItems();

			_activeAreaDimension = activeAreaDimension;
			_itemClass = itemClass;
			_data = data.slice();
			_itemDimension = itemDimension;
			_fillBackground = fillBackground;

			if (startIndex >= data.length) startIndex = Math.max(0, data.length - 1);
			// корректируем индекс, если выходит за границы массива

			_itemsInGroupCount = Math.floor(_activeAreaDimension / itemDimension);
			_totalGroupsCount = Math.ceil(data.length / _itemsInGroupCount);
			_currentGroupIndex = Math.ceil(startIndex / _itemsInGroupCount);

			if (!_groupContainerActive) _groupContainerActive = _groupContainer1;

			initSubContainer(_groupContainerActive, _currentGroupIndex);
		}

		/**
		 * Производит перемещение к группе под указанным индексом. Если индекс выходит за допустимые пределы, 
		 * то берется ближайшее к нему возможное значение.
		 * 
		 * @param groupIndex Индекс группы, к которой необходимо переместиться.
		 * @param instantly Определяет характер анимации. Если <code>true</code>, то происходит 
		 * мгновенная смена группы, фактически без анимации. Иначе смена группы происходит анимировано.
		 * @default false 
		 * @return Возвращает <code>false</code>, если перемщение невозможно (анимация уже в процессе, например, или 
		 * группа с указанным индексом является текущей). Если перемещение успешно запущено, то возвращает <code>true</code>.
		 */
		public function moveToGroupAtIndex(groupIndex:uint, instantly:Boolean = false):Boolean {
			if (!_data) {
				throw new Error("Объект не инициализирован данными!");
				return false;
			}

			if (_animationInProgress) return false;
			if (groupIndex >= _totalGroupsCount) groupIndex = _totalGroupsCount - 1;

			if (groupIndex == _currentGroupIndex) return false;

			var groupContainerActive:GroupContainer = getAvailableSubContainer();
			if (_currentGroupIndex < groupIndex) animateToNextGroup(initSubContainer(groupContainerActive, groupIndex), instantly);
			else animateToPrevGroup(initSubContainer(groupContainerActive, groupIndex), instantly);

			return true;
		}

		/**
		 * Производит перемещение к следующей группе.
		 * 
		 * @param instantly Определяет характер анимации. Если <code>true</code>, то происходит 
		 * мгновенная смена группы, фактически без анимации. Иначе смена группы происходит анимировано.
		 * @default false 
		 * @return Возвращает <code>false</code>, если перемщение невозможно (достигнута конечная группа элементов, например, 
		 * или анимация уже в процессе). Если перемещение успешно запущено, то возвращает <code>true</code>.
		 */
		public function moveToNextGroup(instantly:Boolean = false):Boolean {
			if (!_data) {
				throw new Error("Объект не инициализирован данными!");
				return false;
			}

			if (_animationInProgress || _currentGroupIndex + 1 >= _totalGroupsCount) return false;

			var groupContainerActive:GroupContainer = getAvailableSubContainer();
			animateToNextGroup(initSubContainer(groupContainerActive, ++_currentGroupIndex), instantly);

			return true;
		}

		/**
		 * Производит перемещение к предыдущей группе.
		 * 
		 * @param instantly Определяет характер анимации. Если <code>true</code>, то происходит 
		 * мгновенная смена группы, фактически без анимации. Иначе смена группы происходит анимировано.
		 * @default false 
		 * @return Возвращает <code>false</code>, если перемщение невозможно (достигнута начальная группа элементов, например,
		 * или анимация уже в процессе). Если перемещение успешно запущено, то возвращает <code>true</code>.
		 */
		public function moveToPreviousGroup(instantly:Boolean = false):Boolean {
			if (!_data) {
				throw new Error("Объект не инициализирован данными!");
				return false;
			}

			if (_animationInProgress || _currentGroupIndex == 0) return false;

			var groupContainerActive:GroupContainer = getAvailableSubContainer();
			animateToPrevGroup(initSubContainer(groupContainerActive, --_currentGroupIndex), instantly);

			return true;
		}

		private function animateToNextGroup(groupContainerActive:GroupContainer, instantly:Boolean):void {
			animationStart();

			var animObject:Object = new Object();
			var propName:String = getPositionPropertyName();

			_groupContainerActive[propName] = _activeAreaDimension;

			animObject[propName] = -_activeAreaDimension;
			animateGroup(groupContainerActive, animObject, instantly);

			animObject[propName] = 0;
			animObject.onComplete = animationComplete;
			animObject.onUpdate = animationUpdate;
			animateGroup(_groupContainerActive, animObject, instantly);
		}

		private function animateToPrevGroup(groupContainerActive:GroupContainer, instantly:Boolean):void {
			animationStart();

			var animObject:Object = new Object();
			var propName:String = getPositionPropertyName();

			_groupContainerActive[propName] = -_activeAreaDimension;

			animObject[propName] = _activeAreaDimension;
			animateGroup(groupContainerActive, animObject, instantly);

			animObject[propName] = 0;
			animObject.onComplete = animationComplete;
			animObject.onUpdate = animationUpdate;
			animateGroup(_groupContainerActive, animObject, instantly);
		}

		private function updateActiveContainer(groupContainerActive:GroupContainer):GroupContainer {
			var prevActiveContainer:GroupContainer = _groupContainerActive;
			_groupContainerActive = groupContainerActive;

			dispatchEvent(new GroupScrollControllerEvent(GroupScrollControllerEvent.GROUP_CHANGE_COMPLETE));

			return prevActiveContainer;
		}

		protected function getPositionPropertyName():String {
			return "x";
		}

		private function animationStart():void {
			_animationInProgress = true;

			dispatchEvent(new AnimEvent(AnimEvent.START));
		}

		private function animateGroup(subContainerActive:GroupContainer, animationProperties:Object, instantly:Boolean):void {
			removeTweens(subContainerActive);

			var name:String;

			if (instantly) {
				for (name in animationProperties) {
					if (subContainerActive.hasOwnProperty(name)) subContainerActive[name] = animationProperties[name];
				}

				if (animationProperties.hasOwnProperty("onComplete")) animationProperties.onComplete();
			} else {
				var animObj:Object = { time: _animationTime, transition: _animationTransition, onCompleteScope: this, onUpdateScope: this };

				for (name in animationProperties) {
					animObj[name] = animationProperties[name];
				}

				Tweener.addTween(subContainerActive, animObj);
			}
		}

		private function removeTweens(subContainerActive:GroupContainer):void {
			Tweener.removeTweens(subContainerActive);
		}

		private function animationUpdate():void {
			dispatchEvent(new AnimEvent(AnimEvent.UPDATE));
		}

		private function animationComplete():void {
			_animationInProgress = false;

			dispatchEvent(new AnimEvent(AnimEvent.COMPLETE));
		}

		private function getAvailableSubContainer():GroupContainer {
			return _groupContainerActive == _groupContainer1 ? _groupContainer2 : _groupContainer1;
		}

		private function initSubContainer(container:GroupContainer, groupIndex:uint):GroupContainer {
			var startIndex:uint = _itemsInGroupCount * groupIndex;
			var subContainerData:Array = _data.slice(startIndex, startIndex + _itemsInGroupCount);

			dispatchEvent(new GroupScrollControllerEvent(GroupScrollControllerEvent.GROUP_CHANGE_START));

			container.init(subContainerData, _itemClass, _itemDimension, _fillBackground);

			return updateActiveContainer(container);
		}

		private function removeAllItems():void {
			_groupContainer1.removeAllChildren();
			_groupContainer2.removeAllChildren();
		}

		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			_container = null;

			destroySubContainer(_groupContainer1);
			_groupContainer1 = null;
			destroySubContainer(_groupContainer2);
			_groupContainer2 = null;

			_groupContainerActive = null;

			_data = null;
			_itemClass = null;

			super.destroy();
		}

		private function destroySubContainer(subContainer:GroupContainer):void {
			if (subContainer) {
				removeTweens(subContainer);
				subContainer.destroy();
				if (subContainer.parent) subContainer.parent.removeChild(subContainer);
			}
		}

		/**
		 * Определяет, доступно ли перемещение на следующую группу.
		 */
		public function get moveNextAvailable():Boolean {
			return _currentGroupIndex < _totalGroupsCount - 1;
		}

		/**
		 * Определяет, доступно ли перемещение на следующую группу.
		 */
		public function get movePreviousAvailable():Boolean {
			return _currentGroupIndex > 0;
		}

		/**
		 * Определяет, доступно ли перемещение при текущем объеме данных.
		 */
		public function get movementAvailable():Boolean {
			return Boolean(!isNaN(_totalGroupsCount) && _totalGroupsCount > 1);
		}

		/**
		 * Контейнер с группами элементов
		 */
		public function get container():Sprite {
			return _container;
		}

		/**
		 * Время анимации перемещения в секундах.
		 */
		public function get animationTime():Number {
			return _animationTime;
		}

		public function set animationTime(animationTime:Number):void {
			_animationTime = isNaN(animationTime) ? DEFAULT_ANIMATION_TIME : animationTime;
		}

		/**
		 * Тип анимации перемещения групп элементов.
		 */
		public function get animationTransition():String {
			return _animationTransition;
		}

		public function set animationTransition(animationTransition:String):void {
			_animationTransition = animationTransition;
		}

		/**
		 * Определяет, находится ли анимация по перемещению групп элементов в процессе.
		 */
		public function get animationInProgress():Boolean {
			return _animationInProgress;
		}

		/**
		 * Массив элементов активной группы.
		 */
		public function get currentGroupItems():Array {
			return _groupContainerActive ? _groupContainerActive.items : new Array();
		}

		/**
		 * Индекс текущей группы элементов.
		 */
		public function get currentGroupIndex():uint {
			return _currentGroupIndex;
		}

		/**
		 * Общее количество групп.
		 */
		public function get totalGroupsCount():uint {
			return _totalGroupsCount;
		}

		/**
		 * Количество элементов в группе.
		 */
		public function get itemsInGroupCount():uint {
			return _itemsInGroupCount;
		}
	}
}