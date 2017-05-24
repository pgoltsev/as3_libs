package controllers.polling.remote {
	import core.casalib.CasaEventDispatcherExtended;

	import loaders.text.ExtendedURLLoader;
	import loaders.text.ExtendedURLLoaderIOErrorEvent;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	
	/**
	 * Генерируется после получения каждого ответа от сервера. 
	 * 
	 * @eventType ServerPollingControllerEvent.POLL_COMPLETE
	 */
	[Event(name="spcPollComplete", type="controllers.polling.remote.ServerPollingControllerEvent")]
	
	/**
	 * Генерируется сразу перед началом отправки запроса на сервер. 
	 * 
	 * @eventType ServerPollingControllerEvent.POLL_START
	 */
	[Event(name="spcPollStart", type="controllers.polling.remote.ServerPollingControllerEvent")]
	
	/**
	 * Генерируется каждый раз, когда возникает ошибка при попытке опроса сервера. 
	 * Если же ошибка относится к ошибке безопасности, то опрос сервера прекращается, т. к. ошибка 
	 * критичная и дальнейший опрос не имеет смысла.
	 * 
	 * @eventType ServerPollingControllerEvent.POLL_ERROR
	 */
	[Event(name="spcPollError", type="controllers.polling.remote.ServerPollingControllerEvent")]

	/**
	 * Класс реализует опрос сервера по указанной ссылке через определенные 
	 * промежутки времени.
	 * 
	 * @author Павел Гольцев
	 */
	public class ServerPollingController extends CasaEventDispatcherExtended {
		public static const DEFAULT_POLLING_INTERVAL:uint = 10000;		public static const DEFAULT_POLLING_METHOD:String = URLRequestMethod.POST;
		
		protected var _ldr:ExtendedURLLoader;
		
		private var _errorsCount:int;
		private var _pollingInterval:uint;
		private var _pollingUrl:String;
		private var _pollingVariables:URLVariables;
		private var _pollingMethod:String;
		private var _delayTimer:Timer;
		private var _pollingInProgress:Boolean;
		private var _requestInProgress:Boolean;

		public function ServerPollingController() {
			super();
			
			localInit();
		}

		private function localInit():void {
			_errorsCount = 0;
			_pollingInterval = DEFAULT_POLLING_INTERVAL;
			_pollingMethod = DEFAULT_POLLING_METHOD;
			_pollingInProgress = false;
			_requestInProgress = false;
			
			createLoader();
			
			createDelayTimer();
		}

		private function createDelayTimer():void {
			_delayTimer = new Timer(_pollingInterval, 1);
			_delayTimer.addEventListener(TimerEvent.TIMER, onDelayTimer, false, 0, true);
		}

		private function onDelayTimer(event:TimerEvent):void {
			makeRequest();
		}

		private function createLoader():void {
			_ldr = createDataLoader();
			_ldr.addEventListener(Event.COMPLETE, onPollComplete, false, 0, true);
			_ldr.addEventListener(ExtendedURLLoaderIOErrorEvent.IO_ERROR, onPollError, false, 0, true);			_ldr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onPollError, false, 0, true);
			
			_addDestroyableObject(_ldr);
		}

		protected function createDataLoader():ExtendedURLLoader {
			return new ExtendedURLLoader();
		}

		/**
		 * Запускает опрос сервера по указанному адресу.
		 * 
		 * @param url Ссылка, которую необходимо опрашивать.
		 */
		public function start(url:String):void {
			if (!url) {
				throw new ReferenceError("Не определена ссылка для выполнения опроса!");
				return;
			}
			
			stop();
			
			_pollingInProgress = true;
			
			_pollingUrl = url;
			
			makeRequest();
		}

		/**
		 * Останавливает опрос сервера. 
		 */
		public function stop():void {
			try {
				_ldr.close();
			} catch (error:Error) {
				
			}
			
			if (_delayTimer.running) _delayTimer.reset();
			
			_pollingInProgress = false;
		}

		private function onPollError(event:ErrorEvent):void {
			_requestInProgress = false;
			
			dispatchEvent(new ServerPollingControllerEvent(ServerPollingControllerEvent.POLL_ERROR, null, event));
			
			if (event is ExtendedURLLoaderIOErrorEvent) startNextPollIfAvailable();
		}

		protected function onPollComplete(event:Event):void {
			_requestInProgress = false;
			
			dispatchEvent(new ServerPollingControllerEvent(ServerPollingControllerEvent.POLL_COMPLETE, URLLoader(event.target).data));
			
			startNextPollIfAvailable();
		}
		
		protected function startNextPollIfAvailable():void {
			if (_pollingInProgress) {
				_delayTimer.reset();
				_delayTimer.start();
			}
		}

		private function makeRequest():void {
			_requestInProgress = true;
			
			dispatchEvent(new ServerPollingControllerEvent(ServerPollingControllerEvent.POLL_START, null));
			
			var request:URLRequest = new URLRequest(_pollingUrl);
			if (_pollingVariables) request.data = _pollingVariables;
			if (_pollingMethod) request.method = _pollingMethod;
			
			_ldr.loadNoCache(request);
		}

		/**
		 * Интервал опроса в миллисекундах. По умолчанию равен значению статичной константы <code>DEFAULT_POLLING_INTERVAL</code>.
		 */
		public function get pollingInterval():uint {
			return _pollingInterval;
		}
		
		public function set pollingInterval(pollingInterval:uint):void {
			_pollingInterval = pollingInterval;
			
			_delayTimer.delay = _pollingInterval;
		}

		/**
		 * Данные, отсылаемые на сервер при опросе.
		 */
		public function get pollingVariables():URLVariables {
			return _pollingVariables;
		}
		
		public function set pollingVariables(pollingVariables:URLVariables):void {
			_pollingVariables = pollingVariables;
		}
		
		/**
		 * Метод отправки данных при опросе. По умолчанию <code>URLRequestMethod.POST</code>.
		 * 
		 * @see flash.net.URLRequestMethod 
		 */
		public function get pollingMethod():String {
			return _pollingMethod;
		}
		
		public function set pollingMethod(pollingMethod:String):void {
			_pollingMethod = pollingMethod;
		}

		/**
		 * Принудительно отправляет запрос на сервер, независимо от того, запущен ли опрос сервера или нет.
		 */
		public function forcePoll():void {
			if (_requestInProgress) return;
			
			_delayTimer.reset();
			
			makeRequest();
		}

		/**
		 * Определяет, запущен ли опрос сервера.
		 */
		public function get pollingInProgress():Boolean {
			return _pollingInProgress;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			if (_delayTimer) {
				_delayTimer.removeEventListener(TimerEvent.TIMER, onDelayTimer);
				_delayTimer.reset();
				_delayTimer = null;
			}
			
			_pollingVariables = null;
			
			super.destroy();
		}
	}
}
