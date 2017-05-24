package buttons {
	import caurina.transitions.Tweener;
	import caurina.transitions.properties.ColorShortcuts;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * Базовый класс кнопки, которая при наведении меняет цветовую гамму
	 * 
	 * @author Павел Гольцев
	 */
	public class BtnColoured extends BtnBase {
		protected var _colouredContent:DisplayObject;
		protected var _colorMatrix:Array;
		protected var _animTime:Number;
		protected var _rollColor:Number;

		/**
		 * Конструктор
		 * @param content Визуальная часть кнопки.
		 * @param rollOverColor Цвет кнопки при наведении на нее мышью.
		 * @param colouredContent Визуальная часть, которую необходимо закрасить цветом при наведении мышью на кнопку. 
		 * Если не задана, то в качестве клипа для закраски берется первый параметр.
		 * @default null 
		 */
		public function BtnColoured(content:Sprite, rollOverColor:Number, colouredContent:DisplayObject = null) {
			super(content);
			
			ColorShortcuts.init();
			
			_rollColor = rollOverColor;
			_animTime = 0.3; 
			
			_colouredContent = colouredContent ? colouredContent : content;
			
			_content.addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
			_content.addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function destroy():void {
			if (_colouredContent) {
				Tweener.removeTweens(_colouredContent, "_color");
				_colouredContent = null;
			}
			
			if (_content) {
				_content.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
				_content.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
			}
			
			super.destroy();
		}
		
		override protected function updateAlphaContent():void {
			if (_alphaAsDisabled && _colouredContent == content) {
				Tweener.removeTweens(_colouredContent);
			}
			
			super.updateAlphaContent();
		}
		
		/**
		 * Срабатывает при уведении курсора с кнопки
		 */
		protected function onRollOut(event:MouseEvent):void {
			if (!enabled) return;
			
			Tweener.addTween(_colouredContent, {
				_color: null,
				time: _animTime,
				transition: "linear"
			});
		}

		/**
		 * Срабатывает при наведении курсора на кнопку
		 */
		protected function onRollOver(event:MouseEvent):void {
			if (!enabled) return;
			
			Tweener.addTween(_colouredContent, {
				_color: _rollColor, 
				time: _animTime, 
				transition: "linear"
			});
		}
	}

}