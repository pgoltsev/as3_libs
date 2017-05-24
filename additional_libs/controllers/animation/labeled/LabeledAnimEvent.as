package controllers.animation.labeled{
	import core.events.*;
	import flash.events.Event;

	/**
	 * События контроллера анимации по меткам.
	 *
	 * @author Павел Гольцев
	 */
	public class LabeledAnimEvent extends AnimEvent {
		/**
		 * При проигрывании анимации в цикле генерируется каждый раз, когда цикл анимации завершается.
		 */
		public static const LOOP_COMPLETE:String = "aLoopComplete";

		private var _label:String;
		private var _isLooped:Boolean;
		private var _isForward:Boolean;

		/**
		 * Конструктор.
		 * @param label Метка старта анимации.
		 * @param isForward Определяет тип анимации. Если <code>true</code>, то анимация прямая, иначе - обратная.
		 * @param isLooped Определяет, является ли анимация циклической.
		 */
		public function LabeledAnimEvent(type:String, label:String, isForward:Boolean, isLooped:Boolean, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_label = label;
			_isForward = isForward;
			_isLooped = isLooped;
		}

		override public function clone():Event {
			return new LabeledAnimEvent(type, _label, bubbles, cancelable);
		}

		/**
		 * Метка старта анимации.
		 */
		public function get label():String {
			return _label;
		}

		/**
		 * Определяет, является ли анимация циклической. Если <code>true</code>, то анимация проигрывается циклически,
		 * иначе - один раз.
		 */
		public function get isLooped():Boolean {
			return _isLooped;
		}

		/**
		 * Определяет тип анимации. Если <code>true</code>, то анимация прямая, иначе - обратная.
		 */
		public function get isForward():Boolean {
			return _isForward;
		}
	}
}
