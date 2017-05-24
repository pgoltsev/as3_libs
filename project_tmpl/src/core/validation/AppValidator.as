package core.validation {
	import core.casalib.CasaObjectExtended;

	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	/**
	 * Класс выполняет проверку на правильность использования продукта.
	 * 
	 * @author Павел Гольцев
	 * @version 1.0.2
	 */
	public class AppValidator extends CasaObjectExtended {
		private static const EXPIRE_MESSAGE:String = "Пробный период приложения истек!\nНеобходимо приобрести полную версию, чтобы продолжить использовать приложение!\n\nThe trial period of the application has expired! It is necessary to get the full version to continue to use the application";
		private static const INTERNET_REQUIRED_MESSAGE:String = "Для использования данной версии приложения необходимо иметь доступ в интернет!\n\nFor use of the given version of the application it is necessary to have access to the Internet!";
		
		private static const CHECK_URL:String = "http://marty.newmail.ru/allow.xml";
		
		private var _ldr:URLLoader;
		private var _checkSuccess:Boolean;
		private var _content:DisplayObjectContainer;
		private var _checkValue:String;

		/**
		 * Конструктор.
		 * 
		 * @param content Главный клип приложения, используется для блокировки приложения
		 * @param checkValue Строка, которая проверяется при запросе к серверу проверок. Обычно домен, на котором расположено приложение
		 */
		public function AppValidator(content:DisplayObjectContainer, checkValue:String) {
			super();
			
			_checkValue = checkValue;
			
			_checkSuccess = false;
			
			_content = content;
			lockContent();
			
			var date:Date = new Date();
			
			createLdr();
			_ldr.load(new URLRequest(CHECK_URL + "?" + date.time));
		}
		
		private function lockContent():void{
			_content.mouseChildren = false;
			if (!(_content is Stage)) _content.mouseEnabled = false;
		}
		
		private function unlockContent():void {
			_content.mouseChildren = true;
			if (!(_content is Stage)) _content.mouseEnabled = true;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			_content = null;
			
			if (_ldr) {
				_ldr.removeEventListener(Event.COMPLETE, onCheckLoadComplete);
				_ldr.removeEventListener(IOErrorEvent.IO_ERROR, onCheckLoadError);
				_ldr.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onCheckLoadError);
				
				try {
					_ldr.close();
				} catch (err:Error){
					
				}
				
				_ldr = null;
			}
			
			super.destroy();
		}

		private function createLdr():void{
			_ldr = new URLLoader();
			_ldr.addEventListener(Event.COMPLETE, onCheckLoadComplete, false, 0, true);
			_ldr.addEventListener(IOErrorEvent.IO_ERROR, onCheckLoadError, false, 0, true);
			_ldr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onCheckLoadError, false, 0, true);
		}
		
		private function onCheckLoadComplete(e:Event):void {
			try {
				var xml:XML = new XML(URLLoader(e.target).data);
				
				_checkSuccess = xml.hasOwnProperty(_checkValue);
			} catch (err:Error) {
				
			}
			
			validate();
		}
		
		private function onCheckLoadError(e:ErrorEvent):void {
			showInfoWindow(INTERNET_REQUIRED_MESSAGE);
		}
		
		private function showInfoWindow(message:String):InfoWindow {
			var popup:InfoWindow = new InfoWindow();
			popup.text = message;
			
			_content.addChild(popup);
			
			// центрируем окно
			if (_content.stage) {
				popup.x = (_content.stage.stageWidth - popup.width) / 2;
				popup.y = (_content.stage.stageHeight - popup.height) / 2;
			} else {
				popup.x = (_content.width - popup.width) / 2;
				popup.y = (_content.height - popup.height) / 2;
			}
			// -------------------------------------
			
			return popup;
		}
		
		private function validate():void {
			if (_checkSuccess) {
				unlockContent();
			} else {
				showInfoWindow(EXPIRE_MESSAGE);
			}
		}
	}
}
import flash.display.Sprite;
import flash.text.AntiAliasType;
import flash.text.GridFitType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;

class InfoWindow extends Sprite {
	private var _textTf:TextField;
	private var _text:String;
	
	public function InfoWindow():void {
		super();
		
		createTextField();
		addChild(_textTf);
	}
	
	private function drawBackground():void {
		var xMargin:uint = 10;
		var yMargin:uint = 10;
		
		graphics.clear();
		graphics.beginFill(0xEEEEEE, 0.9);
		graphics.lineStyle(1, 0x0, 1, true);
		graphics.drawRoundRect(_textTf.x - xMargin, _textTf.y - yMargin, _textTf.width + 2 * xMargin, _textTf.height + 2 * yMargin, 10, 10);
		graphics.endFill();
	}
	
	private function createTextField():void{
		_textTf = new TextField();
		_textTf.type = TextFieldType.DYNAMIC;
		_textTf.selectable = false;
		_textTf.autoSize = TextFieldAutoSize.LEFT;
		_textTf.wordWrap = true;
		_textTf.multiline = true;
		_textTf.gridFitType = GridFitType.PIXEL;
		_textTf.antiAliasType = AntiAliasType.ADVANCED;
		_textTf.width = 500;
	}
	
	public function get text():String { return _text; }
	
	public function set text(value:String):void {
		_text = value;
		
		_textTf.htmlText = _text;
		
		drawBackground();
	}
}