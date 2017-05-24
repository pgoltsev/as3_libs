package controllers.page {
	import core.casalib.CasaObjectExtended;

	/**
	 * Объект конфигурационных данных страницы.
	 * 
	 * @author Павел Гольцев
	 * @version 1.0.1
	 */
	public class PageConfig extends CasaObjectExtended {
		private var _pageID:String;
		private var _resources:Object;

		/**
		 * Конструктор.
		 * 
		 * @param pageID Уникальный идентификатор страницы.
		 * @param resources Объект с внешними ресурсами страницы.
		 */
		public function PageConfig(pageID:String,
								   resources:Object = null) {
			super();
			
			if (!pageID) {
				throw new Error("Не задан идентификатор страницы!");
			}
			
			_pageID = pageID;
			_resources = resources;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			_pageID = null;
			_resources = null;
			
			super.destroy();
		}

		/**
		 * Объект с внешними ресурсами страницы.
		 */
		public function get resources():Object { 
			return _resources; 
		}

		/**
		 * Уникальный идентификатор страницы.
		 */
		public function get pageID():String {
			return _pageID;
		}
		
		/**
		 * Клонирует объект.
		 */
		public function clone():PageConfig {
			return new PageConfig(_pageID, _resources);
		}
	}
}