package buttons {
	import core.casalib.CasaObjectExtended;

	import flash.display.Sprite;

	/**
	 * Класс является базовым для всех кнопок и огранизует стандартные операции по
	 * преобразованию клипа в кнопку
	 * 
	 * @author Павел Гольцев
	 */
	public class BtnBase extends CasaObjectExtended {
		protected var _content:Sprite;
		protected var _alphaAsDisabled:Boolean;

		/**
		 * Конструктор
		 * 
		 * @param content Визуальная часть кнопки. 
		 */
		public function BtnBase(content:Sprite) {
			super();
			
			content.mouseChildren = false;
			content.buttonMode = true;
			
			_content = content;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			_content = null;
			
			super.destroy();
		}
		
		/**
		 * Определяет состояние кнопки, активная ли кнопка.
		 */
		public function get enabled():Boolean {
			return _content.mouseEnabled;
		}
		
		public function set enabled(value:Boolean):void {
			_content.mouseEnabled = value;
			
			updateAlphaContent();
		}
		
		/**
		 * Если выставлен в <code>true</code>, то кнопка при переходе в неактивное состояние 
		 * становится полупрозрачной. Иначе просто становится неактивной. По умолчанию имеет 
		 * значение <code>false</code>.
		 */
		public function get alphaAsDisabled():Boolean {
			return _alphaAsDisabled;
		}
		
		public function set alphaAsDisabled(alphaAsDisabled:Boolean):void {
			_alphaAsDisabled = alphaAsDisabled;
			
			updateAlphaContent();
		}

		protected function updateAlphaContent():void {
			if (_alphaAsDisabled) _content.alpha = _content.mouseEnabled ? 1 : 0.5;
		}
		
		/**
		 * Визуальное содержимое кнопки.
		 */
		public function get content():Sprite {
			return _content;
		}
	}
}