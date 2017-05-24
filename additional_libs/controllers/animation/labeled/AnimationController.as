package controllers.animation.labeled {
	import core.casalib.CasaEventDispatcherExtended;
	import core.events.AnimEvent;

	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.Dictionary;

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
	 * Возникает после принудительной остановки анимации.
	 *
	 * @eventType AnimEvent.STOP
	 */
	[Event(name = "aStop", type = "core.events.AnimEvent")]

	/**
	 * Генерируется на каждый кадр при запущенной анимации.
	 *
	 * @eventType AnimEvent.UPDATE
	 */
	[Event(name = "aUpdate", type = "core.events.AnimEvent")]

	/**
	 * При проигрывании анимации в цикле генерируется по завершении каждого цикла.
	 *
	 * @eventType LabeledAnimEvent.LOOP_COMPLETE
	 */
	[Event(name = "aLoopComplete", type = "controllers.animation.labeled.LabeledAnimEvent")]


	/**
	 * Контроллер анимаций по меткам. Позволяет проигрывать анимацию по меткам, от одного кадра
	 * до другого и от одной метки до другой. Анимация может быть как прямая, так и обратная. 
	 *
	 * @author Павел Гольцев
	 */
	public class AnimationController extends CasaEventDispatcherExtended {
		private var _animationObject:MovieClip;
		private var _isForward:Boolean;
		private var _animationInProgress:Boolean;
		private var _endFrame:int;
		private var _startFrame:int;
		private var _isLooped:Boolean;
		private var _labels:Dictionary;
		private var _currentAnimationLabel:String;

		/**
		 * Конструктор.
		 * @param animationObject Объект с анимацией.
		 */
		public function AnimationController(animationObject:MovieClip) {
			super();

			_animationObject = animationObject;

			_isForward = false;
			_animationInProgress = false;
			_endFrame = 0;
			_startFrame = 0;
			_isLooped = false;

			localInit();
		}

		private function localInit():void {
			_animationObject.gotoAndStop(1);

			collectLabels();
		}

		/**
		 * Собирает информацию обо всех метках объекта анимации.
		 */
		private function collectLabels():void {
			if (!_labels) {
				_labels = new Dictionary();

				var labels:Array = _animationObject.currentLabels;
				var animationParams:AnimationParameters;

				for (var i:uint = 0; i < labels.length; i++) {
					var label:FrameLabel = labels[i];

					if (animationParams) {
						animationParams.frameEnd = label.frame - 1;
					}

					animationParams = new AnimationParameters(label.name, label.frame, i);

					_labels[animationParams.label] = animationParams;
				}

				if (animationParams) animationParams.frameEnd = animationObject.totalFrames;
			}
		}

		/**
		 * Уничтожает контроллер, очищая все ссылки внутри контроллера.
		 * После вызова функции дальнейшее использование контроллера запрещено.
		 */
		override public function destroy():void {
			stopLocal();

			_animationObject = null;

			super.destroy();
		}

		/**
		 * Останавливает текущую анимацию и генерирует соотв. событие.
		 */
		public function stop():void {
			if (_animationInProgress) {
				stopLocal();

				dispatchLabeledEvent(AnimEvent.STOP);
			}
		}

		/**
		 * Останавливает анимацию.
		 */
		private function stopLocal():void {
			_animationInProgress = false;

			if (_isForward) {
				_animationObject.stop();
			}

			_animationObject.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		/**
		 * Позволяет проиграть анимацию в цикле.
		 * @param startFrame Номер первого кадра анимации. Если 0, то анимация будет проигрываться с
		 * текущего кадра.
		 * @default 0
		 * @param endFrame Номер кадра конца анимации. Если меньше начального кадра, то анимация будет
		 * проигрываться в обратную сторону.
		 * @default 0
		 */
		public function playToLoop(startFrame:uint = 0, endFrame:uint = 0):void {
			_currentAnimationLabel = null;

			playLocal(startFrame, endFrame, true);
		}

		/**
		 * Проигрывать интервал анимации заданный номерами кадров.
		 * @param startFrame Номер первого кадра анимации. Если 0, то анимация будет проигрываться с
		 * текущего кадра.
		 * @default 0
		 * @param endFrame Номер кадра конца анимации. Если меньше начального кадра, то анимация будет
		 * проигрываться в обратную сторону.
		 * @default 0
		 */
		public function playTo(startFrame:uint = 0, endFrame:uint = 0):void {
			_currentAnimationLabel = null;

			playLocal(startFrame, endFrame, false);
		}

		/**
		 * Проверка наличия кадра с заданным именем.
		 * @param label Метка, выставленная в кадре.
		 * @return <code>true</code>, если такой кадр есть, иначе <code>false</code>.
		 */
		public function hasLabel(label:String):Boolean {
			return _labels[label];
		}

		/**
		 * Проигрывает aнимацию с указанной метки до следующей метки на временной линейке объекта анимации, либо до
		 * конца временной линейки, если меток больше нет.
		 * @param label Метка кадра. Если не задана, то анимация проигрывается с начала временной линейки объекта
		 * анимации до ее конца.
		 * @default null
		 * @throws ReferenceError Если указанная метка не найдена в объекте анимации.
		 */
		public function playForward(label:String = null):void {
			play(true, false, label);
		}

		/**
		 * Проигрывает aнимацию с указанной метки до предыдущей метки на временной линейке объекта анимации, либо до
		 * начала временной линейки, если меток больше нет. Анимация проигрывается в обратном направлении.
		 * @param label Метка кадра. Если не задана, анимация проигрывается с конца временной линейки до ее начала.
		 * @default null
		 * @throws ReferenceError Если указанная метка не найдена в объекте анимации.
		 */
		public function playReverse(label:String = null):void {
			play(false, false, label);
		}

		/**
		 * Запускает анимацию с указанными параметрами.
		 * @param isForward Играть анимацию в прямом или в обратном направлении.
		 * @param isLooped Играть ли анимацию циклически.
		 * @default true
		 * @param label Метка начала анимации. Если не задана, то анимация проигрывается либо с начала временной
		 * линейки до ее конца, либо с конца временной линейки до ее начала. Направление определяется соответствующим
		 * параметром.
		 * @default null
		 */
		public function play(isForward:Boolean, isLooped:Boolean = false, label:String = null):void {
			var startFrame:Number;
			var endFrame:Number;

			_currentAnimationLabel = label;

			if (label) {
				checkLabelExistence(label);

				var animationParams:AnimationParameters = _labels[label];

				if (isForward) {
					startFrame = animationParams.frameStart;
					endFrame = animationParams.frameEnd;
				} else {
					startFrame = animationParams.frameEnd;
					endFrame = animationParams.frameStart;
				}
			} else {
				if (isForward) {
					startFrame = 1;
					endFrame = _animationObject.totalFrames;
				} else {
					startFrame = _animationObject.totalFrames;
					endFrame = 1;
				}
			}

			playLocal(startFrame, endFrame, isLooped);
		}

		/**
		 * Проверяет наличие указанной метки в объекте анимации.
		 * @param label Метка, наличие которой нужно проверить.
		 * @throws ReferenceError Если метка не найдена.
		 */
		private function checkLabelExistence(label:String):void {
			if (!_labels[label]) {
				throw new ReferenceError("Label '" + label + "' not found in animation object!");
			}
		}

		/**
		 * Проигрывает aнимацию с указанной метки до следующей метки на временной линейке объекта анимации, либо до
		 * конца временной линейки, если меток больше нет. Анимация проигрывается циклически.
		 * @param label Метка кадра. Если не задана, то анимация проигрывается с начала временной линейки объекта
		 * анимации до ее конца.
		 * @default null
		 * @throws ReferenceError Если указанная метка не найдена в объекте анимации.
		 */
		public function playForwardLooped(label:String = null):void {
			play(true, true, label);
		}

		/**
		 * Проигрывает aнимацию с указанной метки до предыдущей метки на временной линейке объекта анимации, либо до
		 * начала временной линейки, если меток больше нет. Анимация проигрывается в обратном направлении.
		 * @param label Метка кадра. Если не задана, анимация проигрывается с конца временной линейки до ее начала.
		 * @default null
		 * @throws ReferenceError Если указанная метка не найдена в объекте анимации.
		 */
		public function playReverseLooped(label:String = null):void {
			play(false, true, label);
		}

		private function onEnterFrame(e:Event):void {
			dispatchLabeledEvent(AnimEvent.UPDATE);

			if (_animationObject.currentFrame == _endFrame) {
				if (_isLooped) {
					dispatchLabeledEvent(LabeledAnimEvent.LOOP_COMPLETE);

					if (_isForward) {
						_animationObject.gotoAndPlay(_startFrame);
					} else {
						_animationObject.gotoAndStop(_startFrame);
					}
				} else {
					completeAnimation();
				}
			} else {
				if (!_isForward) {
					_animationObject.prevFrame();
				}
			}
		}

		private function playLocal(startFrame:uint, endFrame:uint, isLooped:Boolean):void {
			_endFrame = updateFrame(endFrame);
			_startFrame = updateFrame(startFrame);

			_isForward = _endFrame - _startFrame >= 0;
			_isLooped = isLooped;

			dispatchLabeledEvent(AnimEvent.START);

			_animationInProgress = true;

			if (_startFrame == _endFrame) {
				completeAnimation();
			} else {
				if (_isForward) {
					_animationObject.gotoAndPlay(_startFrame);
				} else {
					_animationObject.gotoAndStop(_startFrame);
				}

				_animationObject.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}

		private function updateFrame(frame:uint):uint {
			var result:int;

			if (frame == 0) {
				result = _animationObject.currentFrame;
			} else {
				result = Math.min(frame, _animationObject.totalFrames);
			}

			return result;
		}

		private function completeAnimation():void {
			stopLocal();

			dispatchLabeledEvent(AnimEvent.COMPLETE);
		}

		private function dispatchLabeledEvent(eventType:String):void {
			dispatchEvent(new LabeledAnimEvent(eventType, _currentAnimationLabel, _isForward, _isLooped));
		}

		/**
		 * Объект анимации, управляемый контроллером.
		 */
		public function get animationObject():MovieClip {
			return _animationObject;
		}

		/**
		 * Количество анимаций в объекте анимации.
		 */
		public function get labelsCount():int {
			return _animationObject.currentLabels.length;
		}

		/**
		 * Набор анимаций. Ключ - имя анимации (имя метки), а значение -
		 * объект <code>AnimationParameters</code>.
		 * @see controllers.animation.labeled.AnimationParameters
		 */
		public function get labels():Dictionary {
			var result:Dictionary = new Dictionary();
			
			for (var label:String in _labels) {
				result[label] = AnimationParameters(_labels[label]).clone();
			}

			return result;
		}

		/**
		 * Определяет состояние контроллера. Если <code>true</code>, то анимация в процессе проигрывания, иначе
		 * анимация не запущена.
		 */
		public function get animationInProgress():Boolean {
			return _animationInProgress;
		}

		/**
		 * Определяет тип анимации. Если <code>true</code>, то анимация прямая, иначе - обратная.
		 * Параметр задается при запуске анимации.
		 */
		public function get isForward():Boolean {
			return _isForward;
		}

		/**
		 * Определяет, является ли анимация циклической. Если <code>true</code>, то анимация проигрывается циклически,
		 * иначе - один раз. Параметр задается при запуске анимации.
		 */
		public function get isLooped():Boolean {
			return _isLooped;
		}

		/**
		 * Метка текущей анимации. Если анимация запущена без указания метки, то параметр имеет значение <code>null</code>.
		 */
		public function get currentAnimationLabel():String {
			return _currentAnimationLabel;
		}
	}
}