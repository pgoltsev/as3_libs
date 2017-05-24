package controllers.page.errors {

	/**
	 * Ошибка, возникающая, когда операция выполняется над страницей, которая уже существует и 
	 * ее повторная инициализация не допустима.
	 * 
	 * @author Павел Гольцев
	 */
	public class PageAlreadyExistError extends PageOperationResultError {
		/**
		 * Сообщение об ошибке.
		 */
		public static const MESSAGE:String = "Страница с указанным идентификатором уже существует!";
		
		/**
		 * Конструктор.
		 * 
		 * @param pageId Идентификатор страницы, операция над которой инициировала ошибку.
		 * @param id Идентификатор ошибки.
		 */
		public function PageAlreadyExistError(pageId:String, id:* = 0) {
			super(pageId, MESSAGE, id);
		}
	}

}