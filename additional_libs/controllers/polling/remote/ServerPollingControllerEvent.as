package controllers.polling.remote {
	import flash.events.ErrorEvent;
	import flash.events.Event;

	/**
	 * Класс констант событий, генерируемых контроллером опроса сервера.
	 * 
	 * @author Павел Гольцев
	 */
	public class ServerPollingControllerEvent extends Event {
		/**
		 * Генерируется после получения каждого ответа от сервера. 
		 */
		public static const POLL_COMPLETE:String = "spcPollComplete";
		
		/**
		 * Генерируется сразу перед началом отправки запроса на сервер. 
		 */
		public static const POLL_START:String = "spcPollStart";
		
		/**
		 * Генерируется каждый раз, когда возникает ошибка при попытке опроса сервера. 
		 * Если же ошибка относится к ошибке безопасности, то опрос сервера прекращается, т. к. ошибка 
		 * критичная и дальнейший опрос не имеет смысла.
		 */		public static const POLL_ERROR:String = "spcPollError";
		
		private var _data:Object;
		private var _errorEvent:ErrorEvent;

		public function ServerPollingControllerEvent(type:String, data:Object, errorEvent:ErrorEvent = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			
			_errorEvent = errorEvent;
			_data = data;
		}
		
		/**
		 * Данные, которые пришли от сервера. При возникновении ошибки имеет значение <code>null</code>.
		 */
		public function get data():Object {
			return _data;
		}
		
		/**
		 * Объект события ошибки. Если запрос выполнен успешно, то имеет значение <code>null</code>. 
		 */
		public function get errorEvent():ErrorEvent {
			return _errorEvent;
		}
	}
}
