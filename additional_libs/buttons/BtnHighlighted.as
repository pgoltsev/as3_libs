package buttons {
	import flash.display.Sprite;

	import caurina.transitions.Tweener;
	import caurina.transitions.properties.ColorShortcuts;

	import flash.display.DisplayObject;
	import flash.events.MouseEvent;

	/**
	 * Базовый класс для кнопки, которая при наведении становится ярче
	 * 
	 * @author Павел Гольцев
	 */
	public class BtnHighlighted extends BtnBase {
		/**
		 * Значение яркости при наведении
		 */
		protected var _overBrightness:Number;
		protected var _highlightContent:DisplayObject;
		protected var _animTime:Number;

		/**
		 * Конструктор
		 * 
		 * @param content Визуальная часть кнопки. 
		 * @param highlightIntensivity Интенсивность подсвечивания.
		 * @param highlightedContent Визуальная часть, которую необходимо подсветить при наведении мыщью на кнопку. 
		 * Если не задана, то в качестве клипа для закраски берется первый параметр.
		 * @default null.
		 */
		public function BtnHighlighted(content:Sprite, highlightIntensivity:Number = 0.4, highlightedContent:DisplayObject = null) {
			super(content);
			
			ColorShortcuts.init();
			
			_overBrightness = highlightIntensivity;
			_animTime = 0.2; // выставляем значение времени анимации по умолчанию
			
			_highlightContent = highlightedContent ? highlightedContent : content;
			
			_content.addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
			_content.addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function destroy():void {
			if (_highlightContent) {
				Tweener.removeTweens(_highlightContent, "_brightness");
				_highlightContent = null;
			}
			
			if (_content) {
				_content.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
				_content.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
			}
			
			super.destroy();
		}
		
		override protected function updateAlphaContent():void {
			if (_alphaAsDisabled && _highlightContent == content) {
				Tweener.removeTweens(_highlightContent);
			}
			
			super.updateAlphaContent();
		}
		
		/**
		 * Срабатывает при уведении курсора с кнопки
		 */
		protected function onRollOut(event:MouseEvent):void {
			if (!enabled) return;
			
			Tweener.addTween(_highlightContent, {
				_brightness: 0,
				time: _animTime,
				transition: "linear"
			});
		}
		
		/**
		 * Срабатывает при наведении курсора на кнопку
		 */
		protected function onRollOver(event:MouseEvent):void {
			if (!enabled) return;
			
			Tweener.addTween(_highlightContent, {
				_brightness: _overBrightness,
				time: _animTime,
				transition: "linear"
			});
		}
	}

}