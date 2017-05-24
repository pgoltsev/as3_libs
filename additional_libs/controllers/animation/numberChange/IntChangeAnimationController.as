package controllers.animation.numberChange {
	import caurina.transitions.Tweener;

	import core.casalib.CasaEventDispatcherExtended;
	import core.events.AnimEvent;

	import flash.events.Event;
	
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
	 * Генерируется в каждом цикле анимации.
	 * 
	 * @eventType AnimEvent.UPDATE 
	 */
	 [Event(name = "aUpdate", type = "core.events.AnimEvent")]
	 
	 /**
	 * Генерируется при каждом анимированном изменении значения.
	 * 
	 * @eventType Event.CHANGE
	 */
	 [Event(name = "change", type = "flash.events.Event")]

	/**
	 * @author Павел Гольцев
	 */
	public class IntChangeAnimationController extends CasaEventDispatcherExtended {
		private static const DEFAULT_ANIMATION_TIME:Number = 1;		private static const DEFAULT_TRANSITION:String = "linear";
		
		private var _value:int;
		private var _animationTime:Number;
		private var _transition:String;
		private var _mediator:Mediator;
		private var _animationInProgress:Boolean;
		private var _endValue:int;

		/**
		 * Конструктор.
		 * 
		 * @param defaultValue Значение по умолчанию.
		 */
		public function IntChangeAnimationController(defaultValue:int = 0) {
			super();

			localInit(defaultValue);
		}

		/**
		 * Текущее значение в процессе анимации. Изменение происходит анимировано в процессе анимации.
		 */
		public function get currentValue():int {
			return _value;
		}

		/**
		 * Значение. 
		 */
		public function get value():int {
			return _endValue;
		}
		 
		public function set value(value:int):void {
			if (_endValue == value) return;
			
			_endValue = value;
			
			_mediator.value = _value;
			
			_animationInProgress = true;
			
			dispatchEvent(new AnimEvent(AnimEvent.START));
			
			Tweener.removeTweens(_mediator, "_value");
			Tweener.addTween(_mediator, {
				time: _animationTime, 
				value: value, 
				transition: _transition,
				onUpdate: updateValue,
				onUpdateScope: this,
				onComplete: animationComplete,
				onCompleteScope: this
			});
		}

		private function animationComplete():void {
			updateValue();
			
			_animationInProgress = false;
			
			dispatchEvent(new AnimEvent(AnimEvent.COMPLETE));
		}

		private function updateValue():void {
			_value = _mediator.value;
			
			dispatchEvent(new AnimEvent(AnimEvent.UPDATE));
			dispatchEvent(new Event(Event.CHANGE));
		}

		private function localInit(defaultValue:uint):void {
			_animationTime = DEFAULT_ANIMATION_TIME;
			_transition = DEFAULT_TRANSITION;
			_value = defaultValue;
			_mediator = new Mediator(_value);
		}

		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			Tweener.removeTweens(_mediator);
			
			super.destroy();
		}
		
		/**
		 * Время анимации в секундах.
		 */
		public function get animationTime():Number {
			return _animationTime;
		}
		
		public function set animationTime(animationTime:Number):void {
			_animationTime = isNaN(animationTime) ? DEFAULT_ANIMATION_TIME : animationTime;
		}
		
		/**
		 * Определяет, находится ли анимация в процессе.
		 */
		public function get animationInProgress():Boolean {
			return _animationInProgress;
		}
		
		/**
		 * Тип анимации.
		 */
		public function get transition():String {
			return _transition;
		}
		
		public function set transition(transition:String):void {
			_transition = transition;
		}
	}
}

class Mediator extends Object {
	public var _value:uint;

	public function Mediator(value:uint) {
		_value = value;
	}
	
	public function get value():uint {
		return _value;
	}
	
	public function set value(value:uint):void {
		_value = value;
	}
}