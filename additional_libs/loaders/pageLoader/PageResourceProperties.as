package loaders.pageLoader {
	import flash.media.SoundLoaderContext;
	import flash.system.LoaderContext;

	/**
	 * Объект свойств дополнительных ресурсов страницы. Используется для добавления 
	 * дополнительных ресурсов страницы в  
	 * загрузчик страницы, например, таких как внешние изображения, дополнительные 
	 * конфигурационные файлы и т. д.
	 * 
	 * @author Павел Гольцев
	 * @version 1.0.0
	 */
	public dynamic class PageResourceProperties extends Object {
		public static const MAX_LOAD_TRIES:uint = 3;
		
		private var _id:String;
		private var _url:String;
		private var _context:*;
		private var _pausedAtStart:Boolean;
		private var _preventCache:Boolean;
		private var _type:String;
		private var _priority:int;
		private var _headers:Array;

		/**
		 * Конструктор.
		 * 
		 * @param url Ссылка на ресурс.
		 * @param id Уникальный идентификатор ресурса.
		 * @param context Контекст для загрузки файлов типа <code>MovieClip</code> и <code>Sound</code>. 
		 * Для остальных типов данных не имеет смысла.
		 * @default null 
		 */
		public function PageResourceProperties(url:String, id:String) {
			if (!url) {
				throw new Error("Не задана ссылка на ресурс!");
				return;	
			}
			
			if (!id) {
				throw new Error("Не задан идентификатор ресурса!");
				return;	
			}
			
			_url = url;
			_id = id;
		}
		
		/**
		 * Идентификатор ресурса.
		 */
		public function get id():String {
			return _id;
		}
		
		/**
		 * Ссылка на ресурс.
		 */
		public function get url():String {
			return _url;
		}
		
		/**
		 * Контекст для загрузки ресурса. Может быть двух типов: <code>LoaderContext</code> или 
		 * <code>SoundLoaderContext</code> в зависимости от типа загружаемых данных. Имеет смысл, если 
		 * загружаются объекты типа <code>MovieClip</code> или <code>Sound</code>, иначе параметр должен 
		 * быть выставлен в <code>null</code>.
		 */
		public function get context():* {
			return _context;
		}
		
		
		public function set context(context:*):void {
			if (!(context is SoundLoaderContext || context is LoaderContext)) {
				throw new Error("Неверный тип данных для context!");
				return;
			}
			
			_context = context;
		}

		/**
		 * Максимальное количество попыток загрузки.
		 */
		public function get maxTries():Number {
			return MAX_LOAD_TRIES;
		}
		
		/**
		 * Останавливать видео сразу после загрузки. Имеет смысл, только если 
		 * загружается видео. 
		 */
		public function get pausedAtStart():Boolean {
			return _pausedAtStart;
		}
		
		public function set pausedAtStart(pausedAtStart:Boolean):void {
			_pausedAtStart = pausedAtStart;
		}
		
		/**
		 * Если выставлен в <code>true</code>, то объект загружается с сервера, независимо от того, 
		 * находится ли он в кэше браузера. Иначе, если объект находится в кэше, он берется оттуда.
		 */
		public function get preventCache():Boolean {
			return _preventCache;
		}
		
		public function set preventCache(preventCache:Boolean):void {
			_preventCache = preventCache;
		}
		
		/**
		 * Тип загружаемых данных.
		 * @see br.com.stimuli.loading.BulkLoader
		 */
		public function get type():String {
			return _type;
		}
		
		public function set type(type:String):void {
			_type = type;
		}
		
		/**
		 * Приоритет загрузки ресурса перед остальными.
		 */
		public function get priority():int {
			return _priority;
		}
		
		public function set priority(priority:int):void {
			_priority = priority;
		}
		
		/**
		 * Отсылаемые на сервер заголовки при загрузке данных. 
		 */
		public function get headers():Array {
			return _headers;
		}
		
		public function set headers(headers:Array):void {
			_headers = headers;
		}
	}
}
