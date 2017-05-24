package controllers.page.errors {

	/**
	 * Ошибка, возникающая, когда в качестве текущей страницы контроллера выставляется страница, которая уже 
	 * является текущей.
	 * 
	 * @author Павел Гольцев
	 */
	public class PageAlreadySetError extends PageOperationResultError{
		/**
		 * Сообщение об ошибке.
		 */
		public static const MESSAGE:String = "Страница с указанным идентификатором уже является текущей!";
		
		/**
		 * Конструктор.
		 * 
		 * @param pageId Идентификатор страницы, операция над которой инициировала ошибку.
		 * @param id Идентификатор ошибки.
		 */
		public function PageAlreadySetError(pageId:String, id:* = 0) {
			super(pageId, MESSAGE, id);
		}
	}

}