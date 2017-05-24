package projectName {
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;

	import core.casalib.CasaMovieClipExtended;
	import core.data.DataCollector;
	import core.prgbar.LoaderProgressBar;
	import core.trace.TraceMgr;

	import loaders.text.ExtendedURLLoader;
	import loaders.text.ExtendedURLLoaderIOErrorEvent;

	import utils.convert.convertStringToBoolean;

	import org.casalib.core.IDestroyable;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Timer;

	[SWF (width = "900", height = "600", frameRate = "25", backgroundColor = "0xCCCCCC")]
	
	/**
	 * Базовый класс, определение главной временной линейки клипа. Этот класс 
	 * производит загрузку всех необходимых дополнительных внешних ресурсов. К внешним
	 * ресурсам относятся xml-файлы, музыка, изображения, видео, flash-ролики и т. д.
	 * В классе создается визуальное представление главного загрузчика.
	 * С этого класса начинается выполнение приложения.
	 * 
	 * @author Павел Гольцев
	 */
	public class Timeline extends CasaMovieClipExtended {
		// TODO: К параметрам основной конфигурации сборки нужно добавить -frame start <путь к классу Main> -static-link-runtime-shared-libraries=true
		
		// TODO: Поменять projectName на название пакета
		/**
		 * Имя главного класса приложения
		 */
		private static const MAIN_CLASS:String = "projectName.Main";
		
		/**
		 * Визуальное представление загрузчика
		 */
		private var _prgBar:LoaderProgressBar;
		
		/**
		 * Загрузчик основного конфигурационного файла
		 */
		private var _mainConfigLdr:ExtendedURLLoader;
		
		/**
		 * Ссылка на основной файл конфигурации
		 */
		private var _mainConfigUrl:String;
		
		/**
		 * Параметр контроля загрузки дополнительных элементов
		 */
		private var _allLoaded:uint;
		
		/**
		 * Общее количество дополнительных элементов,
		 * подлежащих загрузке
		 */
		private var _totalLoaded:uint;
		
		/**
		 * Таймер задержки показа загрузки. Используется, чтобы
		 * не отображать загрузчик сразу при мгновенной загрузке 
		 * приложения.
		 */
		private var _timerLdrShowUp:Timer;
		
		/**
		 * Флаг, указывающий, загрузилось ли приложение
		 */
		private var _loadComplete:Boolean;
		
		/**
		 * Основной клип приложения
		 */
		private var _mainClp:Sprite;
		
		/**
		 * Конструктор.
		 */
		public function Timeline () {
			super();
			
			stop();
			
			addEventListener(Event.ENTER_FRAME, onCheckMovieDimensionEnterFrame, false, 0, true);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			if (stage) stage.removeEventListener(Event.RESIZE, onStageResize);
			else if (DataCollector.stage) DataCollector.stage.removeEventListener(Event.RESIZE, onStageResize);
			
			removeEventListener(Event.ENTER_FRAME, onCheckMovieDimensionEnterFrame);
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			removeListeners();
			
			destroyTimer();
			
			removeProgressBar(); // удаляем визуальный загрузчик			
			
			_mainConfigLdr.destroy();
			
			if (_mainClp) {
				if (_mainClp is IDestroyable) IDestroyable(_mainClp).destroy();
				if (_mainClp.parent) _mainClp.parent.removeChild(_mainClp);
				
				_mainClp = null;
			}
			
			DataCollector.stage = null;
			
			if (DataCollector.resLdr) {
				DataCollector.resLdr.clear();
				DataCollector.resLdr = null;
			}
		}
		
		// ВНУТРЕННИЕ ФУНКЦИИ КЛАССА
		
		/**
		 * Функция начальной инициализации приложения после добавления
		 * в лист отображения (точка входа приложения)
		 */
		private function init():void{
			DataCollector.stage = stage;
			
			createProgressBar();
			
			_loadComplete = false;
			
			_prgBar.visible = false;
			
			initApplicationParams();
			initLdr();
			
			// добавляем обработчики на загрузку главного клипа
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress, false, 0, true);
			loaderInfo.addEventListener(Event.COMPLETE, onLoadComplete, false, 0, true);
			// ---------------------------------------
			
			// инит таймера на показ загрузчика
			_timerLdrShowUp = new Timer(2000);
			_timerLdrShowUp.addEventListener(TimerEvent.TIMER, onTimerLdrShowUpComplete, false, 0, true);
			_timerLdrShowUp.start();
			// -------------------------------------
			
			updateProgressBarPosition();
			stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);
			
			checkBytesLoaded();
		}

		private function onCheckMovieDimensionEnterFrame(event:Event):void {
			if (loaderInfo.height && loaderInfo.width) {
				removeEventListener(Event.ENTER_FRAME, onCheckMovieDimensionEnterFrame);

				LocalDataCollector.timeline_available::_movieWidth = loaderInfo.width;
				LocalDataCollector.timeline_available::_movieHeight = loaderInfo.height;

				if (stage) init();
				else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			}
		}
		
		/**
		 * Функция инициализации загрузки
		 */
		private function initLdr ():void {
			// TODO: Поменять projectName на название проекта
			TraceMgr.out("projectName 1.0.0 beta"); // сообщение о номере версии
			
			_allLoaded = 0;
			_totalLoaded = 1; // единица для хмл
			
			// загружаем хмл
			_mainConfigUrl = stage.loaderInfo.parameters.xmlUrl ?
						    stage.loaderInfo.parameters.xmlUrl : "xml/init.xml";
			
			_mainConfigLdr = new ExtendedURLLoader();
			_mainConfigLdr.addEventListener(Event.COMPLETE, onMainXmlLoadComplete, false, 0, true);
			_mainConfigLdr.addEventListener(ExtendedURLLoaderIOErrorEvent.IO_ERROR, onMainXmlLoadError, false, 0, true);
			_mainConfigLdr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onMainXmlLoadError, false, 0, true);
			loadMainConfig();
			// -------------------------------------
		}
		
		/**
		 * Загружает основной файл конфигурации
		 */
		private function loadMainConfig():void {
			_mainConfigLdr.load(new URLRequest(_mainConfigUrl));
		}
		
		/**
		 * Загружает все внешние ресурсы.
		 */
		private function loadResources():void {
			DataCollector.resLdr = new BulkLoader("external");
			var propsObj:Object = { maxTries: LocalDataCollector.MAX_LOAD_TRIES };
			var resList:XMLList = DataCollector.externalResourceList;
			var len:int = resList ? resList.length() : 0;
			var ldrItem:LoadingItem;
			var isSameAppDomain:Boolean;
			
			if (len > 0) {
				_totalLoaded++;
				
				for (var i:uint = 0; i < len; i++) {
					if (resList[i].hasOwnProperty("@type")) {
						propsObj.type = String(resList[i].@type);
					} else {
						delete propsObj.type;
					}
					
					propsObj.id = String(resList[i].name());
					ldrItem = DataCollector.resLdr.add(String(resList[i].@url), propsObj);
					
					if (ldrItem.type == BulkLoader.TYPE_MOVIECLIP) {
						DataCollector.resLdr.remove(String(resList[i].@url));
						
						isSameAppDomain = resList[i].hasOwnProperty("@sameApplicationDomain") ? convertStringToBoolean(resList[i].@sameApplicationDomain) : true;
						propsObj.context = isSameAppDomain ? null : new LoaderContext(false, new ApplicationDomain());
						
						DataCollector.resLdr.add(String(resList[i].@url), propsObj);
						
						delete propsObj.context;
					}
				}
				
				DataCollector.resLdr.addEventListener(BulkProgressEvent.COMPLETE, onResourceLoadComplete);
				DataCollector.resLdr.addEventListener(BulkProgressEvent.PROGRESS, onLoadProgress);
			
				DataCollector.resLdr.start();
			}
		}
		
		/**
		 * Инициализирует параметры приложения
		 */
		private function initApplicationParams():void{
			// инит параметров ролика
			stage.align = StageAlign.TOP_LEFT;
			stage.showDefaultContextMenu = false;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			tabEnabled = false;
			stage.stageFocusRect = false;
			stage.quality = StageQuality.HIGH;
			
			//Security.allowDomain("*");
			//Security.allowInsecureDomain("*");
			// ---------------------------------
		}
		
		private function createMain():void {
			// создаем главный клип
			var mainClass:Class = loaderInfo.applicationDomain.getDefinition(MAIN_CLASS) as Class;
			_mainClp = new mainClass() as Sprite;
			_mainClp.name = "main";
			addChild(_mainClp);
			// ---------------------------------------
		}
		
		private function createProgressBar():void{
			_prgBar = new LoaderProgressBar();
			addChild(_prgBar);
		}
		
		private function removeProgressBar():void{
			if (!_prgBar) return;
			
			if (_prgBar is IDestroyable) IDestroyable(_prgBar).destroy();
			if (_prgBar.parent) _prgBar.parent.removeChild(_prgBar);
			_prgBar = null;
		}
		
		private function startLoadCheck():void {
			if (!_loadComplete) addEventListener(Event.ENTER_FRAME, onEnterFrameCheckLoadStatus, false, 0, true);
		}
		
		private function updateProgressBarPosition():void {
			if (stage.align == StageAlign.TOP_LEFT) {
				_prgBar.x = (stage.stageWidth - _prgBar.width) / 2;
				_prgBar.y = (stage.stageHeight - _prgBar.height) / 2;
			} else {
				_prgBar.x = (LocalDataCollector.MOVIE_W - _prgBar.width) / 2;
				_prgBar.y = (LocalDataCollector.MOVIE_H - _prgBar.height) / 2;
			}
		}
		
		private function removeListeners():void {
			if (stage) stage.removeEventListener(Event.RESIZE, onStageResize);
			else if (DataCollector.stage) DataCollector.stage.removeEventListener(Event.RESIZE, onStageResize);
			
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			loaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			
			removeEventListener(Event.ENTER_FRAME, onEnterFrameCheckLoadStatus);
			
			if (_mainConfigLdr) {
				_mainConfigLdr.removeEventListener(Event.COMPLETE, onMainXmlLoadComplete);
				_mainConfigLdr.removeEventListener(ExtendedURLLoaderIOErrorEvent.IO_ERROR, onMainXmlLoadError);
				_mainConfigLdr.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onMainXmlLoadError);
			}
			
			if (DataCollector.resLdr) {
				DataCollector.resLdr.removeEventListener(BulkProgressEvent.COMPLETE, onResourceLoadComplete);
				DataCollector.resLdr.removeEventListener(BulkProgressEvent.PROGRESS, onLoadProgress);
			}
		}
		
		/**
		 * Уничтожает таймер показа загрузчика.
		 */
		private function destroyTimer():void {
			if (_timerLdrShowUp) {
				_timerLdrShowUp.reset();
				_timerLdrShowUp.removeEventListener(TimerEvent.TIMER, onTimerLdrShowUpComplete);
				_timerLdrShowUp = null;
			}
		}
		
		// СОБЫТИЯ
		private function onResourceLoadComplete(e:Event):void {
			_allLoaded++;
		}
		
		private function onMainXmlLoadError(e:Event):void {
			TraceMgr.out("Загрузка главного конфига невозможна!\n"+e.toString());
		}
		
		private function onMainXmlLoadComplete(e:Event):void {
			try {
				DataCollector.configXML = new XML(e.target.data);
					
				TraceMgr.out("Инит загружен!");
				
				loadResources(); // загружаем внешние библиотеки
			} catch (err:TypeError) {
				TraceMgr.out("Ошибка парсинга XML!\n"+err.message);
				return;
			}			
			
			_allLoaded++;
		}
		
		private function onTimerLdrShowUpComplete (e:TimerEvent):void {
			_prgBar.visible = true;
		}
		
		private function onLoadProgress (e:ProgressEvent):void {
			var loaded:uint = loaderInfo.bytesLoaded + _mainConfigLdr.bytesLoaded;
			var total:uint = loaderInfo.bytesTotal + _mainConfigLdr.bytesTotal;
			
			var perc:uint = Math.round(loaded * 100 / total);
			
			if (DataCollector.resLdr && !isNaN(DataCollector.resLdr.weightPercent)) {
				perc +=  DataCollector.resLdr.weightPercent * 100;
				perc /= 2;
			}
			
			_prgBar.percent = perc;
			
			// заглушка, когда при wmode=transparent не срабатывает Event.COMPLETE
			checkBytesLoaded();			
		}

		private function checkBytesLoaded():void {
			if (loaderInfo.bytesLoaded == loaderInfo.bytesTotal) {
				startLoadCheck();
			}
		}
		
		private function onLoadComplete(e:Event):void {
			startLoadCheck();
		}
		
		private function onEnterFrameCheckLoadStatus(e:Event):void {
			if (_allLoaded == _totalLoaded) {
				destroyTimer(); // убираем таймер показа загрузчика

				removeListeners(); // убираем все предыдущие обработчики (уже не нужны)
				
				removeProgressBar(); // убираем загрузчик
				
				addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
				
				_loadComplete = true;
				
				play();
			}
		}
		
		private function onEnterFrame(e:Event):void {
			if (currentFrame >= totalFrames) {
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				stop();
				
				createMain();
			}
		}
		
		private function onStageResize(e:Event):void {
			updateProgressBarPosition();
		}
		
		private function onAddedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			init();
		}
	}
}