package controllers{
	import core.casalib.CasaEventDispatcherExtended;
	import core.data.DataCollector;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Rectangle;

	/**
	 * Контроллер скроллбара. Способен прокручивать графический клип под маской.
	 * @author Павел Гольцев
	 */
	public class ScrollBarController extends CasaEventDispatcherExtended {
		private var _draggedClip:DisplayObject;
		private var _maskClip:DisplayObject;
		private var _ruler:Sprite;
		private var _background:DisplayObject;
		private var _hitArea:DisplayObject;
		private var _blurred:Boolean;
		private var _yFactor:Number;
		private var _minY:Number;
		private var _maxY:Number;
		private var _contentStartY:Number;
		private var _bf:BlurFilter;
		private var _updateVisibility:Boolean;
		private var _activated:Boolean;
		private var _enterFrameClip:Sprite;

		/**
		 * Конструктор.
		 * @param draggedClip Клип, который необходимо прокручивать.
		 * @param maskClip Маска для прокручиваемого клипа, по которой производится высчитывание высоты прокрутки.
		 * @param ruler Графический элемент скроллбара, за который нужно потянуть мышью, чтобы прокрутить
		 * прокручиваемый клип.
		 * @param background Задник скроллбара. Нужен для предыдущего параметра, чтобы высчитывать максимальное и
		 * минимальное возможные положения прокрутки по высоте.
		 * @param hitArea Графический элемент, при нахождении над которым колесо мыши прокручивает скролируемую область.
		 * Если не задана, то прокрутка мышью не задействуется.
		 * @param blurred Блюрить ли прокручиваемый клип при прокрутке.
		 * @default false
		 * @param yFactor Значение определяет кинетику прокрутки.
		 * @default 4
		 */
		public function ScrollBarController(draggedClip:DisplayObject, maskClip:DisplayObject, ruler:Sprite,
											background:DisplayObject, hitArea:DisplayObject = null,
											blurred:Boolean = false, yFactor:Number = 4) {
			super();

			_draggedClip = draggedClip;
			_maskClip = maskClip;
			_ruler = ruler;
			_background = background;
			_hitArea = hitArea;
			_blurred = blurred;
			_yFactor = yFactor;

			localInit();
		}

		/**
		 * Активирует скроллбар.
		 */
		public function activate():void {
			_activated = true;

			DataCollector.stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp, false, 0, true);
			if (_hitArea) {
				DataCollector.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onStageWheel, true, 0, true);
			}

			_enterFrameClip.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
		}

		/**
		 * Деактивирует скроллбра.
		 */
		public function deactivate():void {
			_activated = false;

			DataCollector.stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			if (_hitArea) {
				DataCollector.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onStageWheel, true);
			}

			_enterFrameClip.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		/**
		 * Активен ли скроллбар в данный момент.
		 */
		public function get activated():Boolean {
			return _activated;
		}

		public function localInit():void {
			_updateVisibility = true;

			_enterFrameClip = new Sprite();

			setVisibility(false);

			_bf = new BlurFilter(0, 0, 1);

			this._draggedClip.filters = new Array(_bf);
			this._draggedClip.cacheAsBitmap = true;

			this._minY = _background.y;

			this._ruler.buttonMode = true;

			this._contentStartY = _draggedClip.y;

			_ruler.addEventListener(MouseEvent.MOUSE_DOWN, onRulerClick, false, 0, true);
		}
		
		override public function destroy():void {
			if (_ruler) _ruler.removeEventListener(MouseEvent.MOUSE_DOWN, onRulerClick);
			
			deactivate();
			
			super.destroy();

			_ruler = null;
			_background = null;
			_draggedClip = null;
			_hitArea = null;
			_maskClip = null;
		}

		public function turnOffVisibilityControl():void {
			_updateVisibility = false;
		}

		public function turnOnVisibilityControl():void {
			_updateVisibility = true;
		}

		/**
		 * Позиция ползунка в процентах.
		 */
		public function get positionPercent():Number {
			return _ruler.y * 100 / (_background.height - _ruler.height);
		}

		public function set positionPercent(percent:Number):void {
			if (percent < 0) percent = 0;
			else if (percent > 100) percent = 100;

			_ruler.y = (_background.height - _ruler.height) * percent / 100;

			positionContent();
		}

		private function onRulerClick(e:MouseEvent):void {
			var rect:Rectangle = new Rectangle(_ruler.x, _minY, 0, _maxY + 1);
			_ruler.startDrag(false, rect);
		}

		private function onStageMouseUp(e:MouseEvent):void {
			_ruler.stopDrag();
		}

		private function onStageWheel(e:MouseEvent):void {
			if (_hitArea.hitTestPoint(DataCollector.stage.mouseX, DataCollector.stage.mouseY, false)) {
				scrollData(e.delta);
			}
		}

		private function onEnterFrame(e:Event):void {
			positionContent();
		}

		private function scrollData(q:int):void {
			var d:Number;
			var rulerY:Number;

			var quantity:Number = _maskClip.height / 10 * (_maxY - _minY) / _draggedClip.height;

			d = -q * Math.abs(quantity);

			if (d > 0) {
				rulerY = Math.min(_maxY, _ruler.y + d);
			}
			if (d < 0) {
				rulerY = Math.max(_minY, _ruler.y + d);
			}

			_ruler.y = rulerY;

			positionContent();
		}

		private function positionContent():void {
			var upY:Number;
			var downY:Number;

			/* thanks to Kalicious (http://www.kalicious.com/) */
			// this._ruler.height = (this._mask.height / this._dragged.height) * this._background.height;
			this._maxY = this._background.height - this._ruler.height;
			/*	*/

			var limit:Number = this._background.height - this._ruler.height;

			if (this._ruler.y > limit) {
				this._ruler.y = limit;
			}

			checkContentLength();

			var percent:uint = (100 / _maxY) * _ruler.y;

			upY = 0;
			downY = _draggedClip.height - (_maskClip.height / 2);

			var fx:Number = _contentStartY - (((downY - (_maskClip.height / 2)) / 100) * percent);

			var curry:Number = _draggedClip.y;
			if (curry != fx) {
				var diff:Number = fx - curry;
				curry += diff / _yFactor;

				var bfactor:Number = Math.abs(diff) / 8;
				_bf.blurY = bfactor / 2;
				if (_blurred) {
					_draggedClip.filters = new Array(_bf);
				}
			}

			_draggedClip.y = curry;

			dispatchEvent(new Event(Event.SCROLL));
		}

		private function checkContentLength():void {
			if (_draggedClip.height < _maskClip.height) {
				setVisibility(false);

				reset();
			} else {
				setVisibility(true);
			}
		}

		private function setVisibility(visiblility:Boolean):void {
			if (!_updateVisibility)
				return;

			var previousVisibility:Boolean = _ruler.visible;

			_ruler.visible = _background.visible = visiblility;

			if (previousVisibility != _ruler.visible) {
				dispatchEvent(new Event(Event.CHANGE));
			}
		}

		/**
		 * Сбрасывает позицию ползунка в ноль.
		 */
		public function reset():void {
			_draggedClip.y = _contentStartY;
			_ruler.y = 0;
		}
	}
}