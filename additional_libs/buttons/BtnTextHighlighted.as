package buttons {
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	/**
	 * Базовый класс для кнопки с текстом, которая при наведении подсвечивается.
	 * 
	 * @author Павел Гольцев
	 */
	public class BtnTextHighlighted extends BtnHighlighted{
		protected var _text:String;
		
		/**
		 * Конструктор
		 * 
		 * @param content Визуальная часть кнопки. 
		 * @param highlightIntensivity Интенсивность подсвечивания.
		 * @param highlightedContent Визуальная часть, которую необходимо подсветить при наведении мыщью на кнопку. 
		 * Если не задана, то в качестве клипа для закраски берется первый параметр.
		 * @default null.
		 */
		public function BtnTextHighlighted(content:Sprite, highlightIntensivity:Number = 0.4, highlightedContent:DisplayObject = null) {
			super(content, highlightIntensivity, highlightedContent);
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