package managers.resize {

	/**
	 * ...
	 * @author Павел Гольцев
	 */
	public interface IResize {
		/**
		 * Обновляет позиции объектов при изменении размеров ролика.
		 * @param	newWidth Новое значение ширины ролика.
		 * @param	newHeight Новое значение высоты ролика.
		 */
		function updatePositionsAfterResize(newWidth:Number, newHeight:Number):void;
	}
	
}