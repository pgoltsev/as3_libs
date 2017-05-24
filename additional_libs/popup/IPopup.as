package popup {

	/**
	 * Интерфейс для высплывающих окон.
	 * 
	 * @author Павел Гольцев
	 */
	public interface IPopup {
		/**
		 * Выводит окно на экран
		 * 
		 * @param instantly Если выставлен в <code>true</code>, то появление окна происходит мгновенно.
		 * Иначе появление окна анимируется в течение времени, задаваемом в конструкторе при создании объекта
		 * @default false
		 * @return Возвращает <code>true</code>, если процесс вывода окна был запущен, иначе (если окно уже выводится на 
		 * экран или уже выведено) <code>false</code>.
		 */
		function show(instantly:Boolean = false):Boolean;

		/**
		 * Убирает окно с экрана
		 * 
		 * @param instantly Если выставлен в <code>true</code>, то исчезновение окна происходит мгновенно.
		 * Иначе исчезновение окна анимируется в течение времени, задаваемом в конструкторе при создании объекта
		 * @default false
		 * @return Возвращает <code>true</code>, если процесс убирания окна был запущен, иначе (если окно уже 
		 * прячется или уже спрятано) <code>false</code>.
		 */
		function hide(instantly:Boolean = false):Boolean;

		/**
		 * Содержит текущий статус анимации окна. Если <code>true</code>, то
		 * окно находится в процессе анимации.
		 */
		function get animationInProgress():Boolean;

		/**
		 * Определяет текущий статус окна.
		 * 
		 * @see popup.PopupStatus
		 */
		function get popupStatus():String;
	}
}