package managers.popup {
	import core.casalib.CasaEventDispatcherExtended;
	import core.events.AnimEvent;

	import popup.PopupStatus;

	import org.casalib.core.IDestroyable;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.utils.Dictionary;

	/**
	 * Класс-менеджер для управления всплывающими окнами.
	 * 
	 * @author Павел Гольцев
	 */
	public final class PopupManager extends CasaEventDispatcherExtended {
		private var _popupParams:Dictionary;
		private var _popup:IInitPopup;
		private var _lockSprite:Sprite;
		private var _popupParent:DisplayObjectContainer;
		private var _showInstantly:Boolean;
		private var _currentPopupID:String;
		private var _temporaryPopupID:String;
		private var _container:Sprite;
		private var _centerPopup:Boolean;
		private var _initParams:Array;
		private var _addingToStage:Boolean;
		private var _movieWidth:Number;
		private var _movieHeight:Number;

		/**
		 * Конструктор.
		 * 
		 * @param popupParent Родительский контейнер для всех всплывающих окон. Если не задан, 
		 * то всплываемое окно никуда не добавляется. Если же задан, то всплываемое окно добавляется в 
		 * контейнер только в том случае, если является потомком <code>DisplayObject</code> класса.
		 * @param movieWidth Оригинальная ширина приложения в пикселях. 
		 * @param movieHeight Оригинальная высота приложения в пикселях. 
		 * @param lockSprite Объект для блокировки всего остального визуального содержимого под всплывающим окном. 
		 * Если не задан, то при появлении окна блокировка не производится.
		 */
		public function PopupManager(popupParent:DisplayObjectContainer, movieWidth:Number, movieHeight:Number, lockSprite:Sprite = null) {
			_movieHeight = movieHeight;
			_movieWidth = movieWidth;

			localInit(popupParent, lockSprite);
		}

		private function localInit(popupParent:DisplayObjectContainer, lockSprite:Sprite):void {
			_popupParent = popupParent;
			_lockSprite = lockSprite;

			_showInstantly = false;
			_container = new Sprite();
			_popupParams = new Dictionary();

			if (_lockSprite) _container.addChild(_lockSprite);
		}

		/**
		 * Определяет, присуствует ли в менджере окно с указанным идентификатором.
		 * 
		 * @param id Идентификатор окна для проверки на присутствие.
		 * @return <code>true</code>, если окно с указанным идентификатором уже есть в менеджере и 
		 * <code>false</code>, если такое окно отсутствует.  
		 */
		public function hasPopup(id:String):Boolean {
			return _popupParams[id];
		}

		/**
		 * Добавляет всплывающее окно в менеджер по идентификатору и классу. Если окно с указанным 
		 * идентификатором уже присутствует в менеджере, то будет сгенерирована ошибка. Для замены 
		 * окна под уже существующим идентификатором это окно нужно сначала удалить из менеджера 
		 * соответствующей функцией.  
		 * 
		 * @param id Идентификатор окна, на основе которого производится его отображение и 
		 * генерируются события с его участием.
		 * @param popupClass Класс, на основе которого создается всплывающее окно. Класс должен 
		 * удовлетворять интерфейсу <code>IInitPopup</code>, иначе при его создании будет сгенерирована 
		 * ошибка.
		 * @throws ArgumentError Если окно с указанным идентификатором уже присутствует в менеджере. 
		 */
		public function addPopup(id:String, popupClass:Class):void {
			if (_popupParams[id]) {
				throw new ArgumentError("Окно с указанным идентификатором уже присутствует в менеджере!");
				return;
			}

			_popupParams[id] = new PopupParams(id, popupClass);
		}

		/**
		 * Удаляет всплывающее окно из менеджера. Если удаляется окно, которое на текущий момент 
		 * находится на экране, то удаление окна происходит не только из менеджера, но и с экрана тоже.
		 * 
		 * @param id Идентификатор окна, которое необходимо удалить из менеджера.
		 * @return <code>true</code>, если удаляемое окно с присутствовало на экране, иначе <code>false</code>.   
		 */
		public function removePopup(id:String):Boolean {
			var result:Boolean = false;

			if (_popupParams[id]) {
				if (_popup == PopupParams(_popupParams[id]).popup) {
					result = true;
					removeCreatedPopup();
				}

				PopupParams(_popupParams[id]).destroy();

				_popupParams[id] = null;
				delete _popupParams[id];
			}

			return result;
		}

		/**
		 * Отображает окно.
		 * 
		 * @param id Идентификатор окна, которое необходимо отобразить.
		 * @param initParams Параметры, отправляемые в инициализационную функцию окна при его создании.
		 * @default null
		 * @param centerPopup Если <code>true</code>, то центрирует окно при отображении относительно <code>stage</code>, 
		 * если он доступен для контейнера, либо относительно родительского контейнера. 
		 * @default true
		 * @param hideCurrentInstantly Если <code>true</code>, то активное в данный момент 
		 * окно будет спрятано немедленно, иначе - с анимацией.
		 * @default false
		 * @param showInstantly Если <code>true</code>, то окно будет отображено без анимации, 
		 * иначе - с анимацией.
		 * @default false
		 * 
		 * @return <code>true</code>, если одно из окон менеджера было выбрано до вызова функции, иначе <code>false</code>.
		 * 
		 * @throws ArgumentError Если окно с указанным идентификатором отсутствует в менеджере. 		 * @throws TypeError Если для отображаемого окна неверно указан класс при добавлении в менеджер.
		 */
		public function showPopup(id:String, initParams:Array = null, centerPopup:Boolean = true, showInstantly:Boolean = false, hideCurrentInstantly:Boolean = false):Boolean {
			if (!hasPopup(id)) {
				throw new ArgumentError("Окно с указанным идентификатором отсутствует в менеджере!");
				return false;
			}

			if (_addingToStage) removeAddingToStagePopup();

			_initParams = initParams;
			_showInstantly = showInstantly;
			_temporaryPopupID = null;
			_centerPopup = centerPopup;

			_container.mouseChildren = false;

			if (_popup) {
				_temporaryPopupID = id;

				_popup.hide(hideCurrentInstantly);

				return true;
			} else {
				createPopup(id);

				return false;
			}
		}

		/**
		 * Прячет текущее окно.
		 * 
		 * @param hideInstantly Если <code>true</code>, то окно будет спрятано без анимации, 
		 * иначе - с анимацией.
		 * 
		 * @return <code>true</code>, если текущее окно имеется в менеджере, иначе, если текущее окно не 
		 * выбрано, то <code>false</code>.  
		 */
		public function hidePopup(hideInstantly:Boolean = false):Boolean {
			var result:Boolean = Boolean(_popup);

			if (result) {
				_temporaryPopupID = null;

				if (_addingToStage) removeAddingToStagePopup();
				else _popup.hide(hideInstantly);
			}

			return result;
		}

		private function removeAddingToStagePopup():void {
			removeCreatedPopup();
			_addingToStage = false;
		}

		private function createPopup(id:String):void {
			removeCreatedPopup();

			var popupClass:Class = PopupParams(_popupParams[id]).popupClass;
			_popup = new popupClass() as IInitPopup;

			if (!_popup) {
				throw new TypeError("Для отображаемого окна с идентификатором " + id + " неверно указан класс!");
				return;
			}

			PopupParams(_popupParams[id]).popup = _popup;

			_currentPopupID = id;

			_popup.addEventListener(AnimEvent.COMPLETE, onPopupAnimComplete, false, 0, true);
			_popup.addEventListener(AnimEvent.START, onPopupAnimStart, false, 0, true);
			_popup.addEventListener(AnimEvent.UPDATE, onPopupAnimUpdate, false, 0, true);

			if (_popup is DisplayObject && _popupParent) {
				_addingToStage = true;

				_popup.addEventListener(Event.ADDED_TO_STAGE, onPopupAddedToStage, false, 0, true);

				dispatchEvent(new PopupManagerEvent(PopupManagerEvent.POPUP_CREATE, _currentPopupID));

				_container.addChild(DisplayObject(_popup));
				_popupParent.addChild(_container);
			} else {
				dispatchEvent(new PopupManagerEvent(PopupManagerEvent.POPUP_CREATE, _currentPopupID));

				_popup.initPopup.apply(_popup, _initParams);
				_popup.show(_showInstantly);
			}
		}

		private function onPopupAddedToStage(event:Event):void {
			var addedPopup:IInitPopup = IInitPopup(event.target);
			if (_popup != addedPopup) {
				destroyPopup(addedPopup);

				return;
			}

			dispatchEvent(new PopupManagerEvent(PopupManagerEvent.POPUP_ADDED_TO_PARENT, _currentPopupID));

			_popup.initPopup.apply(_popup, _initParams);
			
			dispatchEvent(new PopupManagerEvent(PopupManagerEvent.POPUP_INITIALIZED, _currentPopupID));

			if (_centerPopup) {
				var _popupAsDO:DisplayObject = DisplayObject(_popup);
				centerAtStage(_popupAsDO, _popupAsDO.stage);
			}

			_addingToStage = false;

			_popup.show(_showInstantly);
		}

		private function centerAtStage(content:DisplayObject, stage:Stage, roundCoordinates:Boolean = true):void {
			if (stage && stage.align == StageAlign.TOP_LEFT) {
				content.x = (stage.stageWidth - content.width) / 2;
				content.y = (stage.stageHeight - content.height) / 2;
			} else {
				content.x = (_movieWidth - content.width) / 2;
				content.y = (_movieHeight - content.height) / 2;
			}

			if (roundCoordinates) {
				content.x = Math.round(content.x);
				content.y = Math.round(content.y);
			}
		}

		private function onPopupAnimUpdate(event:AnimEvent):void {
			dispatchEvent(new PopupManagerEvent(PopupManagerEvent.POPUP_ANIMATION_UPDATE, _currentPopupID));
		}

		private function onPopupAnimStart(event:AnimEvent):void {
			dispatchEvent(new PopupManagerEvent(PopupManagerEvent.POPUP_ANIMATION_START, _currentPopupID));
		}

		private function onPopupAnimComplete(event:AnimEvent):void {
			dispatchEvent(new PopupManagerEvent(PopupManagerEvent.POPUP_ANIMATION_COMPLETE, _currentPopupID));

			if (_popup.popupStatus == PopupStatus.HIDED) {
				removeCreatedPopup();

				if (_temporaryPopupID) {
					var id:String = _temporaryPopupID;
					_temporaryPopupID = null;

					createPopup(id);
				} else {
					_currentPopupID = null;
				}
			} else {
				_container.mouseChildren = true;
			}
		}

		private function removeCreatedPopup():void {
			if (!_popup) return;

			destroyPopup(_popup);
			if (_container.parent) _container.parent.removeChild(_container);
			_popup = null;
		}

		private function destroyPopup(popUp:IInitPopup):void {
			if (!popUp) return;

			for (var popupID:String in _popupParams) {
				if (popUp == PopupParams(_popupParams[popupID]).popup) {
					PopupParams(_popupParams[popupID]).popup = null;
					break;
				}
			}

			popUp.removeEventListener(AnimEvent.COMPLETE, onPopupAnimComplete);
			popUp.removeEventListener(AnimEvent.START, onPopupAnimStart);
			popUp.removeEventListener(AnimEvent.UPDATE, onPopupAnimUpdate);
			popUp.removeEventListener(Event.ADDED_TO_STAGE, onPopupAddedToStage);

			if (popUp is IDestroyable) IDestroyable(popUp).destroy();
			if (popUp is DisplayObject && DisplayObject(popUp).parent) DisplayObject(popUp).parent.removeChild(DisplayObject(popUp));
		}

		/**
		 * Ссылка на текущее всплывающее окно.
		 */
		public function get popup():IInitPopup {
			return _popup;
		}

		/**
		 * Идентификатор текущего окна.
		 */
		public function get popupID():String {
			return _currentPopupID;
		}

		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			for (var id:String in _popupParams) {
				removePopup(id);
			}

			_initParams = null;
			_currentPopupID = null;
			_temporaryPopupID = null;

			_popupParent = null;

			if (_lockSprite) {
				if (_container.contains(_lockSprite)) _container.removeChild(_lockSprite);
				_lockSprite = null;
			}

			super.destroy();
		}
	}
}
import managers.popup.IInitPopup;

import org.casalib.core.Destroyable;

/**
 * @author Павел Гольцев
 */
class PopupParams extends Destroyable {
	private var _popup:IInitPopup;
	private var _id:String;
	private var _popupClass:Class;

	public function PopupParams(id:String, popupClass:Class) {
		_popupClass = popupClass;
		_id = id;
	}

	override public function destroy():void {
		_popupClass = null;
		_popup = null;
	}

	public function get popup():IInitPopup {
		return _popup;
	}

	public function set popup(popup:IInitPopup):void {
		_popup = popup;
	}

	public function get popupClass():Class {
		return _popupClass;
	}

	public function get id():String {
		return _id;
	}
}
