package controllers.page.errors {

	/**
	 * Базовый класс для классов ошибок при выполнении операций со страницами.
	 * 
	 * @author Павел Гольцев
	 */
	public class PageOperationResultError extends Error{
		protected var _pageId:String;
		
		/**
		 * Конструктор.
		 * 
		 * @param pageId Идентификатор страницы, операция над которой инициировала ошибку.
		 * @param message Сообщение об ошибке.
		 * @param id Идентификатор ошибки.
		 */
		public function PageOperationResultError(pageId:String = null, message:* = "", id:* = 0) {
			super(message, id);
			
			_pageId = pageId;
		}
		
		/**
		 * Идентификатор страницы, операция над которой инициировала ошибку.
		 */
		public function get pageId():String { return _pageId; }
		
	}

}