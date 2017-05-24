package loaders.pageLoader {
	import core.casalib.CasaObjectExtended;

	import flash.display.DisplayObject;
	import flash.utils.Dictionary;

	/**
	 * Результат загрузки страницы.
	 * 
	 * @author Павел Гольцев
	 * @version 1.0.0
	 */
	public class PageLoaderResult extends CasaObjectExtended {
		private var _pageDisplayObject:DisplayObject;
		private var _resources:Dictionary;
		
		public function PageLoaderResult(pageDispayObject:DisplayObject) {
			super();
			
			_pageDisplayObject = pageDispayObject;
			_resources = new Dictionary(false);
		}
		
		/**
		 * Добавляет идентификатор и ссылку на объект ресурса загруженной страницы.
		 * 
		 * @param id Идентификатор ресурса.
		 * @param content Ссылка на объект ресурс.
		 */
		internal function addResource(id:String, content:*):void {
			_resources[id] = content;
		}

		public function getPageResource(id:String):* {
			return _resources[id];
		}

		/**
		 * Визуальная часть страницы.
		 */
		public function get page():DisplayObject { return _pageDisplayObject; }
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			_resources = null;
			_pageDisplayObject = null;
			
			super.destroy();
		}
		
		/**
		 * Cсылка на словарь с загруженными ресурсами.
		 */
		public function get resources():Dictionary {
			return _resources;
		}
	}
}