package core.trace {
	/**
	 * Класс обработки <code>trace</code> запросов. Весь вывод в консоль 
	 * необходимо пускать через статичный метод этого класса.
	 * 
	 * @author Павел Гольцев
	 */
	public final class TraceMgr {
		
		/**
		 * Функция отправляет объект на вывод в консоль
		 * 
		 * @param obj Объект, который необходимо вывести в консоль
		 */
		public static function out(obj:Object):void {
			trace(obj);
		}
	}
	
}