package controllers.page {
	import br.com.stimuli.loading.BulkLoader;

	import controllers.page.errors.PageAlreadyExistError;
	import controllers.page.errors.PageAlreadySetError;
	import controllers.page.errors.PageDoesNotExistError;

	import core.casalib.CasaEventDispatcherExtended;
	import core.events.AnimEvent;

	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;

	/**
	 * Возникает при старте входной анимации текущей страницы.
	 * 
	 * @eventType PageControllerEvent.PAGE_IN_ANIMATION_START
	 */
	 [Event(name = "pcPageIntroAnimationStart", type = "controllers.page.PageControllerEvent")]
	
	/**
	 * Возникает после завершения входной анимации текущей страницы.
	 * 
	 * @eventType PageControllerEvent.PAGE_IN_ANIMATION_COMPLETE
	 */
	 [Event(name = "pcPageIntroAnimationComplete", type = "controllers.page.PageControllerEvent")]
	 
	/**
	 * Возникает при старте выходной анимации предыдущей страницы.
	 * 
	 * @eventType PageControllerEvent.PAGE_OUT_ANIMATION_START
	 */
	 [Event(name = "pcPageOutAnimationStart", type = "controllers.page.PageControllerEvent")]
	 
	/**
	 * Возникает после завершения выходной анимации предыдущей страницы.
	 * 
	 * @eventType PageControllerEvent.PAGE_OUT_ANIMATION_COMPLETE
	 */
	 [Event(name = "pcPageOutAnimationComplete", type = "controllers.page.PageControllerEvent")]
	 
	/**
	 * Возникает при старте анимации смены страниц.
	 * 
	 * @eventType PageControllerEvent.ANIMATION_START
	 */
	 [Event(name = "pcPagesAnimationStart", type = "controllers.page.PageControllerEvent")]
	 
	/**
	 * Возникает после завершения анимации смены страниц.
	 * 
	 * @eventType PageControllerEvent.ANIMATION_COMPLETE
	 */
	 [Event(name = "pcPagesAnimationComplete", type = "controllers.page.PageControllerEvent")]
	 
	 /**
	 * Возникает после того, как предыдущая страница спрятана, а текущая готова к старту начальной анимации.
	 * 
	 * @eventType PageControllerEvent.PAGE_CHANGE
	 */
	 [Event(name = "pcPageChange", type = "controllers.page.PageControllerEvent")]
	
	/**
	 * Класс объекта для управления страницами (панелями).
	 * 
	 * @author Павел Гольцев
	 * @version 1.0.6
	 */
	public class PageController extends CasaEventDispatcherExtended {
		private static const CONFIG_NOT_SET_ERROR:String = "Не задан объект данных страницы!";
		private static const CONTENT_NOT_SET_ERROR:String = "Не задан объект визуального содержимого страницы!";
		
		private var _ldr:BulkLoader;
		private var _pages:Dictionary;
		private var _container:DisplayObjectContainer;
		private var _curPageId:String;
		private var _previousPageId:String;
		private var _pageAnimationType:String;
		private var _manualPagesSwitch:Boolean;
		private var _pagesSwitchPaused:Boolean;

		/**
		 * Конструктор.
		 */
		public function PageController(pagesContainer:DisplayObjectContainer = null) {
			super();
			
			init(pagesContainer);
		}
		
		private function init(container:DisplayObjectContainer):void {
			_container = container ? container : new Sprite();
			_pages = new Dictionary();
			
			_pageAnimationType = PageAnimationTypes.NO_ANIMATION;
			_curPageId = null;

			_pagesSwitchPaused = false;
			_manualPagesSwitch = false;
		}
		
		/**
		 * Позволяет получить текущую страницу контроллера. Если в качестве текущей страницы 
		 * ничего не выставлено, то возвращается <code>null</code>.
		 * 
		 * @return Текушая выбранная страница.
		 */
		public function getCurrentPage():SimplePage {
			return getPage(_curPageId);
		}
		
		/**
		 * Позволяет получить страницу по ее идентификатору.
		 * 
		 * @param pageId Идентификатор страницы, которую необходимо получить. Если 
		 * страница с указанным идентификатором не присутствует в контроллере, то возвращается 
		 * <code>null</code>
		 * 
		 * @return Страница с указанным идентификатором.
		 */
		public function getPage(pageId:String):SimplePage {
			return _pages[pageId] as SimplePage;
		}
		
		/**
		 * Делает страницу с указанным идентификатором текущей, проигрывая выходную анимацию 
		 * текущей страницы, затем входную анимацию страницы с указанным идентификатором, если таковая 
		 * имеется в контроллере.
		 * 
		 * @param pageId Идентификатор страницы, которую необходимо отобразить.
		 * 
		 * @throws PageAlreadySetError Генерируется, если страница с указанным идентификатором уже является 
		 * текущей.
		 * @throws PageDoesNotExistError Генерируется, если страница с указанным идентификатором не 
		 * присутствует в контроллере.
		 * 
		 * @see PageAlreadySetError
		 * @see PageDoesNotExistError
		 */
		public function setPage(pageId:String):void {
			if (!hasPage(pageId)) {
				throw new PageDoesNotExistError(pageId);
			}
			
			if (_curPageId == pageId) {
				throw new PageAlreadySetError(pageId);
			}
			
			stopCurrentActiveAnimation();
			
			_previousPageId = _curPageId;
			_curPageId = pageId;
			
			dispatchEvent(new PageControllerEvent(PageControllerEvent.ANIMATION_START, _curPageId));
			
			if (_previousPageId && !_pagesSwitchPaused) {
				var pageClp:SimplePage = SimplePage(_pages[_previousPageId]);
				
				_pageAnimationType = PageAnimationTypes.OUT_ANIMATION;
				
				dispatchEvent(new PageControllerEvent(PageControllerEvent.PAGE_OUT_ANIMATION_START, _previousPageId));
				
				pageClp.content.addEventListener(AnimEvent.COMPLETE, onOutPageAnimationComplete, false, 0, true);
				pageClp.startOutAnimation();
			} else {
				startCurrentPageInAnimation();
			}
		}
		
		private function stopCurrentActiveAnimation():void{
			if (_pageAnimationType == PageAnimationTypes.NO_ANIMATION) return;
			
			var pageClp:SimplePage;
			var pageId:String;
			
			switch(_pageAnimationType) {
				case PageAnimationTypes.IN_ANIMATION:
					pageClp = SimplePage(_pages[_curPageId]);
					
					pageId = _curPageId;
					
					pageClp.content.removeEventListener(AnimEvent.COMPLETE, onInCurrentPageAnimationComplete);
					pageClp.stopInAnimation();
					
					dispatchEvent(new PageControllerEvent(PageControllerEvent.PAGE_IN_ANIMATION_COMPLETE, pageClp.config.pageID));
				break;
				case PageAnimationTypes.OUT_ANIMATION:
					pageClp = SimplePage(_pages[_previousPageId]);
					
					pageId = _previousPageId;
					
					pageClp.content.removeEventListener(AnimEvent.COMPLETE, onOutPageAnimationComplete);
					pageClp.stopOutAnimation();
					
					dispatchEvent(new PageControllerEvent(PageControllerEvent.PAGE_OUT_ANIMATION_COMPLETE, pageClp.config.pageID));
				break;
			}
			
			dispatchEvent(new PageControllerEvent(PageControllerEvent.ANIMATION_COMPLETE, pageId));
			
			if (_container.contains(pageClp)) _container.removeChild(pageClp);
			_curPageId = null;
		}
		
		private function onOutPageAnimationComplete(e:Event):void {
			var pageClp:SimplePage = SimplePage(e.target.parent);
			pageClp.content.removeEventListener(AnimEvent.COMPLETE, onOutPageAnimationComplete);
			
			dispatchEvent(new PageControllerEvent(PageControllerEvent.PAGE_OUT_ANIMATION_COMPLETE, pageClp.config.pageID));
			
			if (_container.contains(pageClp)) _container.removeChild(pageClp);
			
			startCurrentPageInAnimation();
		}
		
		private function startCurrentPageInAnimation(checkManualPagesSwitchFlag:Boolean = true):void {
			if (checkManualPagesSwitchFlag && _manualPagesSwitch) {
				_pagesSwitchPaused = true;
				return;
			}

			_pagesSwitchPaused = false;

			var pageClp:SimplePage = SimplePage(_pages[_curPageId]);
			
			pageClp.addEventListener(Event.ADDED_TO_STAGE, onCurrentPageAddedToStage, false, 0, true);
			_container.addChild(pageClp);
		}
		
		private function onCurrentPageAddedToStage(e:Event):void {
			var pageClp:SimplePage = SimplePage(e.target);
			
			pageClp.removeEventListener(Event.ADDED_TO_STAGE, onCurrentPageAddedToStage);
			
			dispatchEvent(new PageControllerEvent(PageControllerEvent.PAGE_CHANGE, pageClp.config.pageID));
			
			_pageAnimationType = PageAnimationTypes.IN_ANIMATION;
			
			dispatchEvent(new PageControllerEvent(PageControllerEvent.PAGE_IN_ANIMATION_START, pageClp.config.pageID));
			
			pageClp.content.addEventListener(AnimEvent.COMPLETE, onInCurrentPageAnimationComplete, false, 0, true);
			pageClp.startInAnimation();
		}
		
		private function onInCurrentPageAnimationComplete(e:Event):void {
			var pageClp:SimplePage = SimplePage(e.target.parent);
			pageClp.content.removeEventListener(AnimEvent.COMPLETE, onInCurrentPageAnimationComplete);
			
			dispatchEvent(new PageControllerEvent(PageControllerEvent.PAGE_IN_ANIMATION_COMPLETE, pageClp.config.pageID));
			
			_pageAnimationType = PageAnimationTypes.NO_ANIMATION;
			
			dispatchEvent(new PageControllerEvent(PageControllerEvent.ANIMATION_COMPLETE, _curPageId));
		}
		
		/**
		 * Добавляет страницу в контроллер.
		 * 
		 * @param config Объект с конфигурационными данными страницы.
		 * @param content Визуальная составляющая страницы.
		 * 
		 * @throws PageAlreadyExistError Генерируется, если страница с указанным идентификатором 
		 * уже присутствует в контроллере.
		 * 
		 * @see PageAlreadyExistError
		 */
		public function addPage(config:PageConfig, 
								content:Sprite):void {
			if (!config) {
				throw new ReferenceError(CONFIG_NOT_SET_ERROR);
			}
			
			if (!content) {
				throw new ReferenceError(CONTENT_NOT_SET_ERROR);
			}
			
			if (hasPage(config.pageID)) {
				throw new PageAlreadyExistError(config.pageID);
			}
			
			_pages[config.pageID] = createPage(config, content);
		}
		
		/**
		 * Определяет, присутствует ли страница с указанным идентификатором в контроллере.
		 * 
		 * @param pageId Идентификатор страницы, наличие которой нужно определить.
		 * @return Возвращает <code>true</code>, если страница с указанным идентификатором 
		 * присутствует в контроллере, иначе возвращает <code>false</code>.
		 */
		public function hasPage(pageId:String):Boolean {
			return Boolean(_pages[pageId] as SimplePage);
		}
		
		/**
		 * Удаляет страницу из контроллера (из контейнера).
		 * 
		 * @param pageId Идентификатор страницы, которую нужно удалить.
		 * @param destroy Определяет, нужно ли уничтожать страницу после удаления ее из контроллера. 
		 * Если выставлен в <code>true</code>, то страница удаляется из контроллера страниц и уничтожается. 
		 * Если выставлен в <code>false</code>, то страница только удаляется из контроллера.
		 * @default true
		 * 
		 * @return Конфигурационные данные удаленной страницы.
		 * 
		 * @throws PageDoesNotExistError Генерируется, если удаляемая страница отсутствует в контроллере.
		 * 
		 * @see PageDoesNotExistError
		 */
		public function removePage(pageId:String, destroy:Boolean = true):PageConfig {
			var page:SimplePage = _pages[pageId] as SimplePage;
			
			if (!page) {
				throw new PageDoesNotExistError(pageId);
			}
			
			var config:PageConfig = page.config.clone();
			
			_pages[pageId] = null;
			delete _pages[pageId];
			
			if (destroy) {
				page.destroy();
			}
			
			if (_container.contains(page)) _container.removeChild(page);
			
			return config;
		}
		
		protected function createPage(config:PageConfig,
									  content:Sprite):SimplePage {
			return new SimplePage(config, content);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			if (_pages) {
				var pageClp:SimplePage;
				for each (var obj:Object in _pages) {
					pageClp = obj as SimplePage;
					if (!pageClp) continue;
					
					if (pageClp.content) {
						pageClp.content.removeEventListener(AnimEvent.COMPLETE, onInCurrentPageAnimationComplete);
						pageClp.content.removeEventListener(AnimEvent.COMPLETE, onOutPageAnimationComplete);
					}
					
					pageClp.removeEventListener(Event.ADDED_TO_STAGE, onCurrentPageAddedToStage);
					
					pageClp.destroy();
					
					if (_container &&
						_container.contains(pageClp)) _container.removeChild(pageClp);
				}
				
				_pages = null;
			}
			
			if (_ldr) {
				_ldr.clear();
				_ldr = null;
			}
			
			super.destroy();
		}
		
		/**
		 * Идентификатор текущей страницы. Выставляется сразу после вызова функции смены страниц.
		 */
		public function get currentPageID():String {
			return _curPageId;
		}

		/**
		 * Контейнер для страниц.
		 */
		public function get pagesContainer():DisplayObjectContainer { return _container; }
		
		/**
		 * Тип текущей анимации контроллера. Определяет текущий статус анимации.
		 * 
		 * @see PageAnimationTypes
		 */
		public function get animationType():String { return _pageAnimationType; }
		
		/**
		 * Статус анимации. Если имеет значение <code>true</code>, значит анимация в процессе. Иначе 
		 * анимация либо уже завершена, либо еще не запущена.
		 */
		public function get animationInProgress():Boolean {
			return !(_pageAnimationType == PageAnimationTypes.NO_ANIMATION);
		}
		
		/**
		 * Идентификатор предыдущей страницы. Выставляется сразу после вызова функции смены страниц.
		 */
		public function get previousPageId():String {
			return _previousPageId;
		}

		/**
		 * Определяет, нужно ли вручную менять страницы при смене страниц. Если выставлен в <code>true</code>, то
		 * в процессе смены одной страницы на другую при окончании выходной анимации предыдущей страницы, новая
		 * страница не добавляется автоматически в контейнер страниц и ее входная анимация не запускается. Для того,
		 * чтобы продолжить смену страниц, нужно вызвать функцию продолжения смены страниц. По умолчанию имеет
		 * значение <code>false</code>, то есть включена автоматическая смена страниц.
		 * @see #resumePagesSwitch()
		 */
		public function get manualPagesSwitch():Boolean {
			return _manualPagesSwitch;
		}

		public function set manualPagesSwitch(value:Boolean):void {
			_manualPagesSwitch = value;
		}

		/**
		 * Восстанавливает процесс переключения страниц.
		 * Вызов этой функции имеет смысл только в момент, когда отключена автоматическая смена страниц и закончена
		 * выходная анимация предыдущей страницы. В любое другое время вызов этой функции ничего не даст.
		 */
		public function resumePagesSwitch():void {
			if (_pagesSwitchPaused) {
				startCurrentPageInAnimation(false);
			}
		}

		/**
		 * Определяет состояние контроллера, находится ли он в паузе при переключении страниц.
		 */
		public function get pagesSwitchPaused():Boolean {
			return _pagesSwitchPaused;
		}
	}
}