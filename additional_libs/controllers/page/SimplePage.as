package controllers.page {
	import core.casalib.CasaSpriteExtended;
	import core.trace.TraceMgr;

	import flash.display.Sprite;
	import flash.events.Event;

	import org.casalib.core.IDestroyable;

	/**
	 * Базовый класс для страниц.
	 * 
	 * @author Павел Гольцев
	 * @version 1.0.5
	 */
	public class SimplePage extends CasaSpriteExtended {
		public static const FUNC_NAME_INIT_BY_CONFIG:String = "initByConfig";
		
		public static const FUNC_NAME_START_IN_ANIMATION:String = "startInAnimation";
		public static const FUNC_NAME_STOP_IN_ANIMATION:String = "stopInAnimation";

		public static const FUNC_NAME_START_OUT_ANIMATION:String = "startOutAnimation";
		public static const FUNC_NAME_STOP_OUT_ANIMATION:String = "stopOutAnimation";

		private var _config:PageConfig;
		private var _content:Sprite;

		/**
		 * Конструктор.
		 * @param config Объект конфигурации страницы.
		 * @param content Графический клип страницы.
		 */
		public function SimplePage(config:PageConfig,
								   content:Sprite) {
			super();
			
			_config = config;
			_addDestroyableObject(_config);
			_content = content;
			if (_content is IDestroyable) {
				_addDestroyableObject(IDestroyable(_content));
			}
			
			init();
		}
		
		/**
		 * Стартует анимацию появления страницы.
		 */
		public function startInAnimation():void {
			addChild(_content);
			
			callContentFunction(FUNC_NAME_START_IN_ANIMATION);
		}

		/**
		 * Останавливает анимацию появления страницы.
		 */
		public function stopInAnimation():void {
			callContentFunction(FUNC_NAME_STOP_IN_ANIMATION);
		}
		
		/**
		 * Стартует анимацию исчезновения страницы.
		 */
		public function startOutAnimation():void {
			callContentFunction(FUNC_NAME_START_OUT_ANIMATION);
		}

		/**
		 * Останавливает анимацию исчезновения страницы.
		 */
		public function stopOutAnimation():void {
			callContentFunction(FUNC_NAME_STOP_OUT_ANIMATION);
		}
		
		private function init():void {
			addEventListener(Event.ADDED, onAdded, false, 0, true);
		}
		
		private function onAdded(e:Event):void {
			if (_content && e.target == _content) {
				removeEventListener(Event.ADDED, onAdded);
				
				callContentFunction(FUNC_NAME_INIT_BY_CONFIG, _config);
			}
		}
		
		/**
		 * Определяет, существует ли указанная функция в содержимом страницы.
		 * 
		 * @param functionName Имя функции, наличие которой необходимо проверить.
		 * @return Возвращает <code>true</code>, если функция существует.
		 */
		public function isContentFunctionExists(functionName:String):Boolean {
			return Boolean(_content[functionName] as Function);
		}
		
		/**
		 * Вызывает функцию содержимого страницы.
		 * 
		 * @param functionName Имя функции для вызова.
		 * @return Возвращает то, что приходит в ответ от функции содержимого страницы.
		 */
		public function callContentFunction(functionName:String, ... args):* {
			var contentFunction:Function = _content[functionName] as Function;
			if (Boolean(contentFunction)) {
				try {
					return contentFunction.apply(_content, args);
				} catch (err:Error) {
					TraceMgr.out("Ошибка при вызове функции с именем " + functionName + " для содержимого страницы с идентификатором " + _config.pageID + "!\n" + err.message);
					throw err;
				}
			} else {
				TraceMgr.out("Ошибка при вызове функции с именем " + functionName + " для содержимого страницы! Данная функция не существует!");
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			if (_content) {
				if (_content is IDestroyable ||
					isContentFunctionExists("destroy")) Object(_content).destroy();
				
				if (contains(_content)) removeChild(_content);
				if (_content.loaderInfo && _content.loaderInfo.loader) _content.loaderInfo.loader.unloadAndStop();
				_content = null;
			}
			
			super.destroy();
		}
		
		/**
		 * Содержимое страницы.
		 */
		public function get content():Sprite { return _content; }
		
		/**
		 * Конфигурационные данные страницы.
		 */
		public function get config():PageConfig { return _config; }		
	}
}