package controllers.page.errors {

	/**
	 * Ошибка, возникающая, когда операция выполняется над несуществующей страницей.
	 * 
	 * @author Павел Гольцев
	 */
	public class PageDoesNotExistError extends PageOperationResultError {
		/**
		 * Сообщение об ошибке.
		 */
		public static const MESSAGE:String = "Ошибка при выполнении операции над несуществующей страницей!";
		
		/**
		 * Конструктор.
		 * 
		 * @param pageId Идентификатор несуществующей страницы.
		 * @param id Идентификатор ошибки.
		 */
		public function PageDoesNotExistError(pageId:String = null, id:* = 0) {
			super(pageId, MESSAGE, id);
		}
		
	}

}