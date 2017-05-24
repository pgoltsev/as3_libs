package popup {
	import caurina.transitions.Tweener;

	import core.casalib.CasaSpriteExtended;
	import core.events.AnimEvent;

	/**
	 * Базовый класс для всплывающих окон
	 * 
	 * @author Павел Гольцев
	 */
	public class Popup extends CasaSpriteExtended implements IPopup {
		protected var _fadeToAlpha:Boolean;
		protected var _animTime:Number;
		protected var _status:String;
		protected var _showupDelay:Number;
		protected var _stY:Number;
		protected var _yOffset:Number;
		
		private var _prevStatus:String;
		private var _animationInProgress:Boolean;
		
		/**
		 * Конструктор
		 * 
		 * @param animationTime Время анимации появления и исчезания окна в миллисекундах
		 * @default 0.3
		 * @param animationYOffset Смещение по оси Y, от которого происходит анимация окна до
		 * позиции по умолчанию
		 * @default 10
		 */
		public function Popup(animationTime:Number = 0.3, 
							  animationYOffset:Number = 10,
							  fadeToAlpha:Boolean = true) {
			super();
			
			_yOffset = animationYOffset;
			_animTime = animationTime;
			
			_showupDelay = 0;
			visible = false;
			_status = _prevStatus = PopupStatus.HIDED;
			_animationInProgress = false;
			_fadeToAlpha = fadeToAlpha;
		}
		
		/**
		 * @inheritDoc
		 */
		public function show(instantly:Boolean = false):Boolean {
			if (_status == PopupStatus.SHOWED ||
				_status == PopupStatus.SHOWING) return false;
				
			if (isNaN(_stY)) updateYPos();
			
			setStatus(PopupStatus.SHOWING);
			
			animStart();
			
			Tweener.removeTweens(this);
			
			if (instantly) {
				visible = true;
				
				if (_fadeToAlpha) alpha = 1;
				
				y = _stY;
				
				onAnimComplete();
			} else {
				if (_prevStatus == PopupStatus.HIDED ||
					!visible) {
					y = _stY + _yOffset;
					if (_fadeToAlpha) alpha = 0;
				}
				
				animate();
			}
			
			return true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function hide(instantly:Boolean = false):Boolean {
			if (_status == PopupStatus.HIDING || _status == PopupStatus.HIDED) return false;
			
			setStatus(PopupStatus.HIDING);
			
			animStart();
			
			Tweener.removeTweens(this);
			
			if (instantly) {
				if (_fadeToAlpha) alpha = 0;
				visible = false;
				
				onAnimComplete();
			} else {
				animate();
			}
			
			return true;
		}
		
		/**
		 * Обновляет позицию окна по умолчанию по оси Y на основе текущей позиции
		 */
		public function updateYPos():void {
			_stY = y;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get popupStatus():String { 
			return _status;
		}
		
		/**
		 * Определяет предыдущий статус окна
		 * 
		 * @see PopupStatus
		 */
		public function get previousPopupStatus():String { 
			return _prevStatus;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get animationInProgress():Boolean { 
			return _animationInProgress;
		}
		
		/**
		 * Определяет задержку в миллисекундах перед появлением окна
		 */
		public function get showupDelay():Number {
			return _showupDelay;
		}
		
		public function set showupDelay(value:Number):void {
			_showupDelay = value;
		}
		
		override public function destroy():void {
			Tweener.removeTweens(this);
			
			super.destroy();
		}
		
		/**
		 * Анимирует появление/исчезновение окна
		 */
		protected function animate():void {
			var animObj:Object = {
					time: _animTime,
					onCompleteScope: this
				};
			
			switch (_status) {
				case PopupStatus.HIDING:
					if (_fadeToAlpha) animObj.alpha = 0;
					animObj.y = _stY + _yOffset;
					animObj.transition = "easeInSine";
					animObj.onComplete = onHideAnimComplete;
					animObj.onCompleteScope = this;
				break;
				case PopupStatus.SHOWING:
					animObj.delay = _showupDelay;
					if (_fadeToAlpha) animObj.alpha = 1;
					animObj.y = _stY;
					animObj.transition = "easeOutSine";
					animObj.onStart = onAnimStartComplete;
					animObj.onStartScope = this;
					animObj.onComplete = onAnimComplete;
					animObj.onCompleteScope = this;
				break;
			}
			
			Tweener.addTween(this, animObj);
		}
		
		/**
		 * Выполняется в начале анимации
		 */
		protected function onAnimStartComplete():void{
			visible = true;
		}
		
		/**
		 * Выполняется в конце анимации исчезновения
		 */
		protected function onHideAnimComplete():void {
			visible = false;
			
			onAnimComplete();
		}
		
		/**
		 * Выставляет статус окна
		 */
		private function setStatus(new_status:String):void {
			_prevStatus = _status;
			_status = new_status;
		}
		
		/**
		 * Выполняется сразу после старта анимации
		 */
		protected function animStart():void {
			_animationInProgress = true;
			
			dispatchEvent(new AnimEvent(AnimEvent.START));
		}
		
		/**
		 * Выполняется сразу после завершения анимации
		 */
		protected function onAnimComplete():void {
			switch (_status) {
				case PopupStatus.SHOWING:
					setStatus(PopupStatus.SHOWED);
				break;
				case PopupStatus.HIDING:
					setStatus(PopupStatus.HIDED);
				break;
			}
			
			_animationInProgress = false;
			
			Tweener.removeTweens(this);
			
			dispatchEvent(new AnimEvent(AnimEvent.COMPLETE));
		}
	}
	
}