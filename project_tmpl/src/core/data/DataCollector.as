package core.data {
	import br.com.stimuli.loading.BulkLoader;

	import flash.display.MovieClip;
	import flash.display.Stage;

	/**
	 * Класс используется для хранения данных. Является своего рода глобальным
	 * хранилищем, к которому можно получить доступ из любой точки приложения.
	 * Поэтому доступ к данным осуществляется через статические параметры.
	 * 
	 * @author Павел Гольцев
	 */
	public class DataCollector {
		/**
		 * Имя узла, в котором содержится список для загрузки внешних ресурсов
		 */
		private static const EXTERNAL_RESOURCE_NODE_NAME:String = "externalResources";
		
		/**
		 * XML основного файла конфигурации приложения
		 */
		private static var _configXML:XML;
		
		/**
		 * Ссылка на объект stage
		 */
		private static var _stage:Stage;
		
		/**
		 * Загрузчик внешних ресурсов
		 */
		private static var _resLdr:BulkLoader;
		
		/**
		 * Параметр предоставляет доступ к XML объекту основного конфигурационного файла
		 *
		 */
		public static function get configXML():XML {
			return _configXML;
		}
		
		public static function set configXML(value:XML):void {
			_configXML = value;
		}
		
		/**
		 * Параметр предоставляет доступ к основному конфигурационному 
		 * узлу основного конфигурационного файла
		 *
		 */
		public static function get config():XMLList {
			return _configXML.config;
		}
		
		/**
		 * Предоставляет доступ к объекту <code>stage</code> приложения.
		 *
		 */
		public static function get stage():Stage {
			return _stage;
		}
		
		public static function set stage(value:Stage):void {
			_stage = value;
		}
		
		/**
		 * Определяет объект, содержащий данные (ключ => значение), переданные в приложение при
		 * встраивании его в страницу.
		 */
		public static function get flashVars():Object {
			var retObj:Object = _stage ? _stage.loaderInfo.parameters : new Object();
			
			// DEBUG: ОТЛАДОЧНЫЙ КОД
			var len:uint = config.debug.children().length();
			var list:XMLList = config.debug.children();
			for (var i:uint = 0; i < len; i++) {
				retObj[list[i].name()] = String(list[i]);
			}
			// -------------------------
			
			return retObj;
		}
		
		/**
		 * Предоставляет доступ к текстовым сообщениям основного конфигурационного файла.
		 *
		 */
		public static function get textResources():XMLList {
			return configXML.txt;
		}
		
		/**
		 * Предоставляет доступ к загрузчику дополнительных внешних ресурсов
		 *
		 */
		public static function get resLdr():BulkLoader {
			return _resLdr;
		}
		
		public static function set resLdr(value:BulkLoader):void {
			_resLdr = value;
		}
		
		/**
		 * Предоставляет доступ к списку внешних ресурсов.
		 */
		public static function get externalResourceList():XMLList {
			return config.hasOwnProperty(EXTERNAL_RESOURCE_NODE_NAME) ? 
				config[EXTERNAL_RESOURCE_NODE_NAME].children() : null;
		}
		
		/**
		 * Организует доступ к классам во внешних файлах. Файлы подгружаются как внешние
		 * ресурсы.
		 * 
		 * @param libraryId Идентификатор библиотеки, из которой необходимо получить нужный
		 * класс.
		 * @param className Имя класса, который необходимо получить.
		 */
		public static function getExternalClass(libraryId:String, className:String):Class {
			var clp:MovieClip = _resLdr.getMovieClip(libraryId);
			return clp ? clp.loaderInfo.applicationDomain.getDefinition(className) as Class : null;
		}
	}

}