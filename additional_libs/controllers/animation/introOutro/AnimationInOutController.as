package controllers.animation.introOutro {
	import core.casalib.CasaEventDispatcherExtended;
	import core.events.AnimEvent;

	/**
	 * Возникает при старте анимации. При этом значение <code>animationInProgress</code>
	 * уже выставлено в <code>true</code>, а значение <code>animationType</code> имеет тип
	 * текущей анимации.
	 * 
	 * @eventType AnimEvent.START 
	 */
	 [Event(name = "aStart", type = "core.events.AnimEvent")]
	 
	/**
	 * Возникает в конце анимации. При этом значение <code>animationInProgress</code>
	 * уже выставлено в <code>false</code>, а значение <code>animationType</code> имеет тип
	 * текущей анимации.
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
	 * Контроллер анимаций для объектов, в которых присутствуют входная и выходная анимации. 
	 * Класс содержит параметры контроля типа и процесса анимации, а также генерирует соответствующие 
	 * события в процессе анимации, при ее старте и после ее окончания.  
	 * 
	 * @author Павел Гольцев
	 * @version 1.0.1
	 */
	public class AnimationInOutController extends CasaEventDispatcherExtended {
		private var _animationType:String;
		private var _animationInProgress:Boolean;
		private var _animationObject:IAnimationInOut;

		/**
		 * Конструктор.
		 * 
		 * @param animationObject Объект, анимацию которого необходимо контролировать.
		 */
		public function AnimationInOutController(animationObject:IAnimationInOut) {
			super();
			
			_animationInProgress = false;
			_animationType = AnimationInOutType.OUT;
			_animationObject = animationObject;
		}

		/**
		 * Стартует входную анимацию.
		 * 
		 * @param args Дополнительные параметры анимации. Передаются в исходном виде в функцию старта 
		 * анимации контролируемого объекта.
		 * @return Возвращает <code>true</code>, если анимация запущена, иначе 
		 * возвращает <code>false</code>.
		 */
		public function startInAnimation(...args):Boolean {
			if (!_animationObject.isInAnimationAvailable.apply(_animationObject, args) || _animationType == AnimationInOutType.IN) return false;

			_animationInProgress = true;
			_animationType = AnimationInOutType.IN;
			
			dispatchEvent(new AnimEvent(AnimEvent.START));
			
			if (!_animationObject._localStartInAnimation.apply(_animationObject, args)) {
				animationComplete();
				return false;
			}
			
			return true;
		}
		
		/**
		 * Стартует выходную анимацию.
		 * 
		 * @param args Дополнительные параметры анимации. Передаются в исходном виде в функцию старта 
		 * анимации контролируемого объекта.
		 * @return Возвращает <code>true</code>, если анимация запущена, иначе 
		 * возвращает <code>false</code>.
		 */
		public function startOutAnimation(...args):Boolean {
			if (!_animationObject.isOutAnimationAvailable.apply(_animationObject, args) || _animationType == AnimationInOutType.OUT) return false;
			
			_animationType = AnimationInOutType.OUT;
			_animationInProgress = true;
			
			dispatchEvent(new AnimEvent(AnimEvent.START));
			
			if (!_animationObject._localStartOutAnimation.apply(_animationObject, args)) {
				animationComplete();
				return false;
			}
			
			return true;
		}

		/**
		 * Метод должен вызываться после окончания анимации.
		 */
		public function animationComplete():void {
			_animationInProgress = false;
				
			dispatchEvent(new AnimEvent(AnimEvent.COMPLETE));
		}

		/**
		 * Должен вызываться в каждом цикле анимации.
		 */
		public function animationUpdate():void {
			dispatchEvent(new AnimEvent(AnimEvent.UPDATE));
		}
		
		/**
		 * Тип текущей анимации.
		 */
		public function get animationType():String {
			return _animationType;
		}
		
		/**
		 * Определяет, производится ли в данный момент анимация. 
		 */
		public function get animationInProgress():Boolean {
			return _animationInProgress;
		}
		
		/**
		 * Объект, для которого происходит управление анимацией. 
		 */
		public function get animationObject():IAnimationInOut {
			return _animationObject;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			_animationObject = null;
			
			super.destroy();
		}
	}
}
