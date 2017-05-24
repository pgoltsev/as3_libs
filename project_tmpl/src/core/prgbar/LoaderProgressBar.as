package core.prgbar {
	import lib.main.LoaderProgressBarContent;

	/**
	 * Класс является управляющим для основного загрузчика приложения.
	 * 
	 * @author Павел Гольцев
	 */
	public class LoaderProgressBar extends LoaderProgressBarContent implements IProgressBar {
		protected var _percent:Number;
		private var _totalFrames:int;

		/**
		 * Конструктор.
		 */
		public function LoaderProgressBar() {
			super();
			
			stop();
			
			_totalFrames = totalFrames;
		}
		
		/**
		 * Предоставляет доступ к процентам загрузчика.
		 *
		 */
		public function get percent():Number {
			return _percent;
		}
		
		public function set percent(value:Number):void {
			_percent = value;
			
			gotoAndStop(Math.round(_totalFrames * Math.round(_percent) / 100));
		}
		
	}

}