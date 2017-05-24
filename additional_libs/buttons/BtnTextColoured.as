package buttons {
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	/**
	 * Базовый класс для кнопки с текстом, которая при наведении закрашивается в нужный цвет.
	 * 
	 * @author Павел Гольцев
	 */
	public class BtnTextColoured extends BtnColoured {
		protected var _text:String;
		
		/**
		 * Конструктор
		 * @param content Визуальная часть кнопки.
		 * @param rollOverColor Цвет кнопки при наведении на нее мышью.
		 * @param colouredContent Визуальная часть, которую необходимо закрасить цветом при наведении мышью на кнопку. 
		 * Если не задана, то в качестве клипа для закраски берется первый параметр.
		 * @default null 
		 */
		public function BtnTextColoured(content:Sprite, rollOverColor:Number, colouredContent:DisplayObject = null) {
			super(content, rollOverColor, colouredContent);
		}
		
		public function get text():String { return _text; }
		
		public function set text(value:String):void {
			updateButtonText(value);
			
			drawHitArea();
		}
		
		protected function drawHitArea():void {
			_content.graphics.clear();
			_content.graphics.beginFill(0xFF0000, 0);
			_content.graphics.drawRect(0, 0, _content.width, _content.height);
			_content.graphics.endFill();
		}
		
		protected function updateButtonText(text:String):void{
			_text = text;
		}
	}

}