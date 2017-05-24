package controllers.animation.labeled {
	import utils.getClassNameOnly;

	/**
	 * Параметры анимации по меткам.
	 *
	 * @author Павел Гольцев
	 */
	public class AnimationParameters extends Object {
		private static const className:String = getClassNameOnly(AnimationParameters);

		private var _label:String;
		private var _frameStart:int;
		private var _frameEnd:int;
		private var _index:uint;

		/**
		 * Конструктор.
		 * @param label Метка начала анимации.
		 * @param frameStart Кадр метки начала анимации.
		 * @param index Индекс метки на временной линейке слева направо.
		 */
		public function AnimationParameters(label:String, frameStart:int, index:uint) {
			_label = label;
			_frameStart = frameStart;
			_index = index;
		}

		/**
		 * Метка начала анимации.
		 */
		public function get label():String {
			return _label;
		}

		public function set label(value:String):void {
			_label = value;
		}

		/**
		 * Кадр метки начала анимации.
		 */
		public function get frameStart():int {
			return _frameStart;
		}

		public function set frameStart(value:int):void {
			_frameStart = value;
		}

		/**
		 * Кадр конца анимации.
		 */
		public function get frameEnd():int {
			return _frameEnd;
		}

		public function set frameEnd(value:int):void {
			_frameEnd = value;
		}

		/**
		 * Индекс метки на временной линейке слева направо.
		 */
		public function get index():uint {
			return _index;
		}

		public function set index(value:uint):void {
			_index = value;
		}

		/**
		 * Создает копию текущего объекта.
		 * @return Копия текущего объекта.
		 */
		public function clone():AnimationParameters {
			var params:AnimationParameters = new AnimationParameters(_label, _frameStart, _index);
			params.frameEnd = _frameEnd;
			return params;
		}

		/**
		 * @private
		 */
		public function toString():String {
			return "[" + className + " label = '" + _label + "' index = '" + _index + "' frameStart = " + _frameStart + " frameEnd = " + _frameEnd + "]";
		}
	}
}
