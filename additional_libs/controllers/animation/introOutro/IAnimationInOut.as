package controllers.animation.introOutro {

	/**
	 * Интерфейс для объектов, в которых присутствует входная и выходная анимации и которым 
	 * нужно контролировать процесс анимации.
	 * 
	 * @author Павел Гольцев
	 */
	public interface IAnimationInOut {
		/**
		 * Определяет, доступная ли в данный момент входная анимация.
		 * 
		 * @param args Дополнительные параметры анимации.
		 * @return Если возвращает <code>true</code>, то анимация доступна. Инача анимация недоступна и 
		 * не будет запущена при вызове соответствующего метода.
		 */
		function isInAnimationAvailable(...args):Boolean;
		
		/**
		 * Определяет, доступная ли в данный момент выходная анимация.
		 *
		 * @param args Дополнительные параметры анимации.
		 * @return Если возвращает <code>true</code>, то анимация доступна. Инача анимация недоступна и 
		 * не будет запущена при вызове соответствующего метода.
		 */
		function isOutAnimationAvailable(...args):Boolean;

		/**
		 * Стартует входную анимацию.
		 * 
		 * @param args Дополнительные параметры анимации.
		 * @return Возвращает <code>true</code>, если анимация запущена, иначе 
		 * возвращает <code>false</code>.
		 */
		function _localStartInAnimation(...args):Boolean;
		
		/**
		 * Стартует выходную анимацию.
		 * 
		 * @param args Дополнительные параметры анимации.
		 * @return Возвращает <code>true</code>, если анимация запущена, иначе 
		 * возвращает <code>false</code>.
		 */
		function _localStartOutAnimation(...args):Boolean;
		
		/**
		 * Контроллер входной и выходной анимации.
		 */
		function get animationIOController():AnimationInOutController;
	}
}
