package loaders.pageLoader {
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;

	import core.casalib.CasaEventDispatcherExtended;

	import flash.display.DisplayObject;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	/**
	 * Генерируется сразу после начала старта загрузки.
	 * 
	 * @eventType PageLoaderEvent.LOAD_START
	 */
	[Event(name="plLoadStart", type="loaders.pageLoader.PageLoaderEvent")]
	
	/**
	 * Генерируется сразу после окончания загрузки.
	 * 
	 * @eventType PageLoaderEvent.LOAD_COMPLETE
	 */
	[Event(name="plLoadComplete", type="loaders.pageLoader.PageLoaderEvent")]
	
	/**
	 * Генерируется сразу в процессе загрузки страницы и ее ресурсов.
	 * 
	 * @eventType PageLoaderEvent.LOAD_PROGRESS
	 */
	[Event(name="plLoadProgress", type="loaders.pageLoader.PageLoaderEvent")]
	
	/**
	 * Генерируется сразу в процессе загрузки страницы и ее ресурсов.
	 * 
	 * @eventType PageLoaderEvent.LOAD_CANCEL
	 */
	[Event(name="plLoadCancel", type="loaders.pageLoader.PageLoaderEvent")]

	/**
	 * Загрузчик страниц. Может быть использован для загрузки страниц, используемых в 
	 * контроллере страниц.
	 * 
	 * @author Павел Гольцев
	 * @version 1.0.0
	 */
	public class PageLoader extends CasaEventDispatcherExtended {
		private var _ldr:BulkLoader;
		private var _pageID:String;
		private var _url:String;
		private var _resources:Array;
		
		public function PageLoader() {
			super();
			
			localInit();
		}
		
		private function localInit():void {
			var uniqueLoaderName:String = BulkLoader.getUniqueName();
			_ldr = new BulkLoader(uniqueLoaderName);
			_ldr.addEventListener(BulkProgressEvent.COMPLETE, onLoadComplete, false, 0, true);
			_ldr.addEventListener(BulkProgressEvent.PROGRESS, onLoadProgress, false, 0, true);			
		}
		
		/**
		 * Сбрасывает загрузку страницы и всех ее данных. При этом генерируется событие LOAD_CANCEL.
		 */
		public function cancelLoading():void {
			_ldr.removeAll();
			
			dispatchEvent(new PageLoaderEvent(PageLoaderEvent.LOAD_CANCEL));
		}
		
		/**
		 * Запускает загрузку страницы и ее данных.
		 * 
		 * @param url Ссылка для загрузки визуальной составляющей страницы.
		 * @param pageId Уникальный идентификатор загружаемой страницы.
		 * @param resources Массив элементов типа PageContentProperties, загрузку которых нужно выполнить. 
		 * Это могут быть дополнительные ресурсы, нужные странице.
		 * @see loaders.pageLoader.PageContentProperties
		 */
		public function loadPage(url:String, pageID:String, resources:Array = null):void {
			_ldr.removeAll();
			
			_pageID = pageID;
			_url = url;
			
			// добавляем внешние ресурсы
			_resources = new Array();
			var properties:PageResourceProperties;
			var num:uint = resources.length;
			for (var i:uint = 0; i < num; i++) {
				if (resources[i] is PageResourceProperties) {
					properties = PageResourceProperties(resources[i]); 
					_ldr.add(properties.url, properties);
					
					_resources.push(properties.id);
				}
			}
			// ------------------------------------
			
			// добавляем страницу
			_ldr.add(url, {
				maxTries: PageResourceProperties.MAX_LOAD_TRIES,
				id: pageID,
				context: new LoaderContext(false, new ApplicationDomain())
			});
			// ---------------------------------------
			
			dispatchEvent(new PageLoaderEvent(PageLoaderEvent.LOAD_START));
			
			_ldr.start(); // стартуем загрузку
		}

		/**
		 * Возвращает загруженную страницу и все внешние ресурсы, соответствующие ей.
		 * 
		 * @param clearMemory Если выставлен в <code>true</code>, то ссылки на страницу и все ее внешние 
		 * загруженные ресурсы удаляются из загрузчика. Иначе ссылки сохраняются в загрузчике и могут быть 
		 * получены повторным вызовом функции.
		 * @default true
		 * 
		 * @return Объект со списком всех загруженных ресурсов и самой страницей. Если на момент вызова 
		 * функции еще не загружены все ресурсы, то возвращается <code>null</code>. 
		 */
		public function getPage(clearMemory:Boolean = true):PageLoaderResult {
			if (_ldr.isRunning) return null;
			
			var result:PageLoaderResult = new PageLoaderResult(_ldr.getContent(_pageID, clearMemory) as DisplayObject);
			
			var num:uint = _resources.length;
			for (var i:uint = 0; i < num; i++) {
				result.addResource(_resources[i], _ldr.getContent(_resources[i], clearMemory));
			}
			
			return result;
		}
		
		private function onLoadProgress(e:BulkProgressEvent):void {
			dispatchEvent(new PageLoaderEvent(PageLoaderEvent.LOAD_PROGRESS, false, false, 
							e.bytesLoaded, e.bytesTotal));
		}
		
		private function onLoadComplete(e:BulkProgressEvent):void {
			dispatchEvent(new PageLoaderEvent(PageLoaderEvent.LOAD_COMPLETE, false, false, 
							e.bytesLoaded, e.bytesTotal));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			if (_ldr) {
				_ldr.clear();
				_ldr.removeEventListener(BulkProgressEvent.COMPLETE, onLoadComplete);				_ldr.removeEventListener(BulkProgressEvent.PROGRESS, onLoadProgress);
				_ldr = null;
			}
			
			super.destroy();
		}
		
		/**
		 * Идентификатор загружаемой страницы.
		 */
		public function get pageID():String {
			return _pageID;
		}
		
		/**
		 * URL-ссылка на загружаемую страницу.
		 */
		public function get url():String {
			return _url;
		}
	}
}