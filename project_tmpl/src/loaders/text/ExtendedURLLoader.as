package loaders.text {
	import core.trace.TraceMgr;

	import utils.addCacheBusterParam;
	import utils.clone.cloneURLRequest;

	import org.casalib.core.IDestroyable;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	/**
	 * Возникает, когда все дополнительные попытки запроса
	 * не увенчались успехом.
	 * 
	 * @eventType ExtendedURLLoaderIOErrorEvent.IO_ERROR
	 */
	 [Event(name = "eulIOError", type = "loaders.text.ExtendedURLLoaderIOErrorEvent")]
	
	/**
	 * Объект класса используется для загрузки текстовых данных.
	 * Наследуется от обычного <code>URLLoader</code>, имеет те же самые свойства,
	 * но добавляет возможность при возникновении ошибки загрузки выполнить 
	 * повторный запрос еще несколько раз.
	 * 
	 * @author Павел Гольцев
	 * @version 1.0.5
	 */
	public class ExtendedURLLoader extends URLLoader implements IDestroyable {
		/**
		 * Задержка в миллисекундах по умолчанию перед следующей попыткой загрузки данных.
		 * 
		 * @see #retryTimeout
		 */
		public static const DEFAULT_RETRY_TIMEOUT:uint = 100;
		
		/**
		 * Количество попыток загрузки данных по умолчанию. 
		 * 
		 * @see #numberOfRetries
		 */
		public static const DEFAULT_NUMBER_OF_RETRIES:uint = 3;
		
		private var _timer:Timer; // таймер выполнения доп. попыток загрузки
		private var _retryTimeout:uint; // задержка повторных попыток загрузки
		private var _request:URLRequest; // объект запроса
		private var _retryCount:uint;
		// количество повторных попыток загрузки
		private var _currentRetry:uint; // текущая попытка загрузки данных
		private var _destroyed:Boolean;
		
		/**
		 * Конструктор.
		 * 
		 * @param request Объект со ссылкой на
		 * ресурс для загрузки. Если объект задан, то загрузка стартует сразу 
		 * после создания объекта.
		 * @default null
		 */
		public function ExtendedURLLoader(request:URLRequest = null) {
			_destroyed = false;
			_request = request;
			_retryCount = DEFAULT_NUMBER_OF_RETRIES;
			
			initTimer();
			
			super(request);
			
			addEventListener(IOErrorEvent.IO_ERROR, onLoadIOError, false, 0, true);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadSecurityError, false, 0, true);
			addEventListener(Event.COMPLETE, onLoadComplete, false, 0, true);
		}
	
		/**
		 * Инициирует процесс загрузки.
		 * 
		 * @param request Объект со ссылкой на ресурс для загрузки.
		 */
		override public function load(request:URLRequest):void {
			_request = request;			
			
			initTimer();
			
			super.load(request);
		}
		
		/**
		 * Инициирует процесс загрузки без использования кэша браузера.
		 * 
		 * @param request Объект со ссылкой на ресурс для загрузки.
		 */
		public function loadNoCache(request:URLRequest):void {
			var localRequest:URLRequest = cloneURLRequest(request);
			request.url = addCacheBusterParam(request.url);
			
			load(localRequest);
		}
		
		/**
		 * @inheritDoc
		 */
		public function destroy():void {
			cleanUp();
			
			try {
				close();
			} catch (err:Error){
				
			}
			
			removeEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
			removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadSecurityError);
			removeEventListener(Event.COMPLETE, onLoadComplete);
			
			_destroyed = true;
		}
		
		/**
		 * Определяет задержку в миллисекундах перед повторным
		 * началом повторной загрузки.
		 * 
		 * @see #DEFAULT_RETRY_TIMEOUT
		 */
		public function get retryTimeout():uint {
			return _retryTimeout;
		}
		
		public function set retryTimeout(value:uint):void {
			_retryTimeout = value;
		}
		
		/**
		 * Определяет количество дополнительных попыток загрузки 
		 * данных при неудачной основной.
		 * 
		 * @see #DEFAULT_NUMBER_OF_RETRIES
		 */
		public function get numberOfRetries():uint {
			return _retryCount;
		}
		
		public function set numberOfRetries(value:uint):void {
			_retryCount = value;
		}
		
		// ВНУТРЕННИЕ ФУНКЦИИ
		
		/**
		 * Убивает таймер дополнительных попыток загрузки.
		 */
		private function cleanUp():void {
			if (_timer) {
				_timer.reset();
				_timer.removeEventListener(TimerEvent.TIMER, onTimer);
				_timer = null;
			}
		}
		
		/**
		 * Инициализирует таймер дополнительных попыток загрузки.
		 */
		private function initTimer():void {
			cleanUp();
			
			_currentRetry = 0;
			
			_timer = new Timer(!_retryTimeout ? DEFAULT_RETRY_TIMEOUT : _retryTimeout, 1);
			_timer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
		}
		
		/**
		 * Выполняется при завершении загрузки.
		 */
		private function onLoadComplete(e:Event):void {
			cleanUp();
		}
		
		/**
		 * Выполняется при возникновении ошибки безопасности.
		 */
		private function onLoadSecurityError(e:SecurityErrorEvent):void {
			cleanUp();
		}
		
		/**
		 * Выполняется при возникновении ошибки ввода/вывода в запросе.
		 */
		private function onLoadIOError(e:IOErrorEvent):void {
			if (_currentRetry >= _retryCount) {
				cleanUp();
			
				TraceMgr.out("Конечная ошибка ввода/вывода при загрузке данных по адресу " + _request.url + "!");
				
				dispatchEvent(new ExtendedURLLoaderIOErrorEvent(ExtendedURLLoaderIOErrorEvent.IO_ERROR));
			} else {
				var traceStr:String = "Ошибка ввода/вывода при загрузке данных по адресу " + 
					_request.url + "!";
				if (_timer.repeatCount) traceStr += "\nОсталось " + (_retryCount - _currentRetry) + " попыток!";
				TraceMgr.out(traceStr + "\n" + e.toString());
				
				_currentRetry++;
				
				_timer.start();
			}
		}
		
		/**
		 * Срабатывает по завершении таймера.
		 */
		private function onTimer(e:TimerEvent):void {
			super.load(_request);
		}
		
		/**
		 * Объект с данными запроса.
		 */
		public function get request():URLRequest {
			return _request;
		}

		/**
		 * @inheritDoc
		 */
		public function get destroyed():Boolean {
			return _destroyed;
		}
	}
}