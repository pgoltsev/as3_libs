package projectName {
	/**
	 * @author Павел Гольцев
	 */
	public final class LocalDataCollector {
		timeline_available static var _movieHeight:uint;
		timeline_available static var _movieWidth:uint;

		/**
		 * Оригинальная ширина окна приложения.
		 */
		public static function get MOVIE_W():uint {
			return timeline_available::_movieWidth;
		}

		/**
		 * Оригинальная высота окна приложения.
		 */
		public static function get MOVIE_H():uint {
			return timeline_available::_movieHeight;
		}

		/**
		 * Количество попыток загрузки внешних ресурсов
		 */
		public static const MAX_LOAD_TRIES:uint = 3;
	}
}
