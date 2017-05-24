package projectName {
	import core.casalib.CasaSpriteExtended;

	import flash.events.Event;

	/**
	 * Класс, который создается сразу после загрузки всего приложения. Является контейнером
	 * для всех клипов в приложении, кроме главного загрузчика, для которого контейнером
	 * явялется базовый класс приложения.
	 * 
	 * @author Павел Гольцев
	 */
	public class Main extends CasaSpriteExtended {
		/**
		 * Конструктор.
		 */
		public function Main() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
		}

		/**
		 * Произоводит основную инициализацию 
		 */
		private function init():void {
		}

		private function onAddedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			init();
		}
	}
}