package loaders.visual {
	import core.casalib.CasaSpriteExtended;
	import core.interfaces.IAnimated;

	import utils.addCacheBusterParam;
	import utils.clone.cloneURLRequest;

	import org.casalib.core.IDestroyable;

	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.net.*;
	import flash.system.LoaderContext;
	import flash.utils.Timer;

	/**
	 * Генерируется при приходе от сервера HTTP кода в загрузчик.
	 * 
	 * @eventType flash.events.HTTPStatusEvent.HTTP_STATUS
	 */
	[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")] 

	/**
	 * Генерируется при загрузке.
	 * 
	 * @eventType flash.events.ProgressEvent.PROGRESS
	 */
	[Event(name="progress", type="flash.events.ProgressEvent")] 

	/**
	 * Генерируется при успешном открытии удаленного файла и начале его загрузки.
	 * 
	 * @eventType flash.events.Event.OPEN
	 */
	[Event(name="open", type="flash.events.Event")] 

	/**
	 * Генерируется при возникновении ошибки ввода/вывода в процессе загрузки.
	 * 
	 * @eventType flash.events.IOErrorEvent.IO_ERROR
	 */
	[Event(name="ioError", type="flash.events.IOErrorEvent")] 

	/**
	 * Генерируется, когда загруженный объект готов к использованию.
	 * 
	 * @eventType flash.events.Event.INIT
	 */
	[Event(name="init", type="flash.events.Event")] 

	/**
	 * Генерируется сразу после окончания загрузки объекта.
	 * 
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * Класс контейнера для загрузки визуальных объектов (клипы и изображения).
	 * 
	 * @author Павел Гольцев
	 * @version 1.0.7
	 */
	public class ExtendedLoader extends CasaSpriteExtended {
		private var _loadRetryCount:Number;
		private var _loadRetryDecrement:Number;
		private var _fitRect:Rectangle;
		private var _visualLdr:DisplayObject;
		private var _loading:Boolean;
		private var _content:DisplayObject;
		private var _context:LoaderContext;
		private var _request:URLRequest;
		private var _smoothing:Boolean;
		private var _ldr:Loader;
		private var _constrainProportions:Boolean;
		private var _visualLdrShowDelayTimer:Timer;
		private var _changeImageAfterLoaded:Boolean;
		
		/**
		 * Конструктор.
		 */
		public function ExtendedLoader () {
			super();
			
			localInit();
		}
		
		private function localInit():void {
			_loadRetryCount = 2;
			_loading = false;
			_smoothing = false;
			_changeImageAfterLoaded = true;
			
			createLoader();
			
			createVisualLdrShowDelayTimer();
		}
		
		private function createVisualLdrShowDelayTimer():void{
			_visualLdrShowDelayTimer = new Timer(500, 1);
			_visualLdrShowDelayTimer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
		}
		
		private function onTimer(e:TimerEvent):void {
			actualShowLdr();
		}
		
		private function createLoader():void {
			_ldr = new Loader();
			_ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete, false, 0, true);
			_ldr.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress, false, 0, true);
			_ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadIOError, false, 0, true);
			_ldr.contentLoaderInfo.addEventListener(Event.INIT, onLoadInit, false, 0, true);
			_ldr.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS , onLoaderEvent, false, 0, true);
			_ldr.contentLoaderInfo.addEventListener(Event.OPEN, onLoaderEvent, false, 0, true);
		}
		
		/**
		 * Отменяет загрузку, если она в процессе.
		 */
		public function cancel():void {
			try {
				_ldr.close();
			} catch (err:Error){
				
			}
			
			_ldr.unload();
			
			_loading = false;
			hideLdr();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			cancel();
			
			removeContent();
			_content = null;
			
			if (_ldr) {
				_ldr.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
				_ldr.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
				_ldr.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
				_ldr.contentLoaderInfo.removeEventListener(Event.INIT, onLoadInit);
				_ldr.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onLoaderEvent);
				_ldr.contentLoaderInfo.removeEventListener(Event.OPEN, onLoaderEvent);
				
				try {
					_ldr.close();
				} catch (error:Error) {
					
				}
				
				if (_ldr.parent) _ldr.parent.removeChild(_ldr);
				_ldr = null;
			}
			
			if (_visualLdrShowDelayTimer) {
				_visualLdrShowDelayTimer.reset();
				_visualLdrShowDelayTimer.removeEventListener(TimerEvent.TIMER, onTimer);
				_visualLdrShowDelayTimer = null;
			}
			
			if (_visualLdr) {
				if (_visualLdr is IAnimated && ((_visualLdr is IDestroyable && !IDestroyable(_visualLdr).destroyed) || !(_visualLdr is IDestroyable))) IAnimated(_visualLdr).stopAnimation();
				if (_visualLdr.parent) _visualLdr.parent.removeChild(_visualLdr);
				_visualLdr = null;
			}
			
			super.destroy();
		}
		
		/**
		 * Запускает загрузку объекта.
		 * 
		 * @param request Объект для загрузки.
		 * @param context Контекст объекта загрузки.
		 * @param bustCache Если выставлен в <code>true</code>, то объект загружается с сервера 
		 * независимо от того, содержится ли он в кэше браузера или нет. Если параметр выставлен 
		 * в <code>false</code>, то объект загружается из кэша браузера, если такая возможность 
		 * имеется.
		 * @default false
		 */
		public function load(request:URLRequest, context:LoaderContext = null, bustCache:Boolean = false):void {
			_request = cloneURLRequest(request);
			if (bustCache) _request.url = addCacheBusterParam(_request.url);
			
			_context = context;
			_loadRetryDecrement = _loadRetryCount;
			
			loadImage();
		}
		
		private function loadImage():void {
			_loading = true;
			
			if (_changeImageAfterLoaded && _content) {
				
			} else {
				removeContent();
				showLdr();
			}
			
			try {
				_ldr.load(_request, _context);
			} catch (err:Error){
				_loading = false;
				hideLdr();
				
				throw err;
				return;
			}
		}
			
		private function showLdr():void {
			_visualLdrShowDelayTimer.start();
		}
		
		private function actualShowLdr():void {
			if (!_visualLdr) return;
			
			addChildAt(_visualLdr, 0);
			if (_visualLdr is IAnimated) IAnimated(_visualLdr).startAnimation();
		}
		
		private function hideLdr():void {
			_visualLdrShowDelayTimer.reset();
			
			if (!_visualLdr) return;
			
			if (_visualLdr is IAnimated && ((_visualLdr is IDestroyable && !IDestroyable(_visualLdr).destroyed) || !(_visualLdr is IDestroyable))) IAnimated(_visualLdr).stopAnimation();
			if (contains(_visualLdr)) removeChild(_visualLdr);
		}
		
		private function onLoadInit(e:Event):void {
			removeContent();
			_content = _ldr.content;
			if (_content is Bitmap) Bitmap(_content).smoothing = _smoothing;
			updateContentSizeAndPosition();
			addChild(_content);
			
			dispatchEvent(e.clone());
		}
		
		private function onLoaderEvent(e:Event):void {
			dispatchEvent(e.clone());
		}
		
		private function onLoadProgress(e:ProgressEvent):void {
			dispatchEvent(e.clone());
		}
		
		private function onLoadIOError(e:IOErrorEvent):void {
			if (_loadRetryDecrement-- > 0) {
				loadImage();
			} else {
				hideLdr();
				
				_loading = false;
				
				dispatchEvent(e.clone());
			}
		}
		
		private function onLoadComplete(e:Event):void {
			_loading = false;
			
			_ldr.unload();
			
			hideLdr();
			
			dispatchEvent(e.clone());
		}
		
		private function removeContent():void {
			if (!_content) return;
			
			if (_content is Bitmap) {
				Bitmap(_content).bitmapData.dispose();
			} else if (_content is MovieClip) {
				MovieClip(_content).stop();
			}
			
			if (contains(_content)) removeChild(_content);
		}
		
		/**
		 * Визуальный загрузчик.
		 */
		public function get visualLdr():DisplayObject { return _visualLdr; }
		
		public function set visualLdr(value:DisplayObject):void {
			if (value) {
				_visualLdr = value;
				
				if (_loading) {
					showLdr();
				} else {
					hideLdr();
				}
			} else {
				hideLdr();
				
				_visualLdr = null;
			}
		}
		
		/**
		 * Область, в которую необходимо вписать изображение после загрузки.
		 */
		public function get fitRect():Rectangle { return _fitRect; }
		
		public function set fitRect(value:Rectangle):void {
			_fitRect = value;
			
			updateContentSizeAndPosition();
		}
		
		/**
		 * Количество повторных попыток при неудачной загрузке.
		 */
		public function get loadRetryCount():Number { return _loadRetryCount; }
		
		public function set loadRetryCount(value:Number):void {
			_loadRetryCount = value;
		}
		
		/**
		 * Сглаживание. Имеет смысл только если загружается растровое изображение.
		 */
		public function get smoothing():Boolean { return _smoothing; }
		
		public function set smoothing(value:Boolean):void {
			_smoothing = value;
		}
		
		/**
		 * Загруженный объект.
		 */
		public function get content():DisplayObject { return _content; }
		
		/**
		 * Статус загрузчика. Если <code>true</code>, то объект загружается в данный момент. Иначе 
		 * oбъект либо загрузился, либо загрузка еще не была запущена.
		 */
		public function get isLoading():Boolean {
			return _loading;
		}
		
		/**
		 * Объект <code>URLRequest</code>, с помощью которого производится загрузка.
		 */
		public function get request():URLRequest { return _request; }
		
		/**
		 * Соблюдение пропорций при масштабировании загруженного объекта. При 
		 * соблюдении пропорций берется наименьшее из значений ширины и высоты и относительно 
		 * этого параметра высчитывается второе значение.
		 */
		public function get constrainProportions():Boolean { return _constrainProportions; }
		
		public function set constrainProportions(value:Boolean):void {
			_constrainProportions = value;
		}
		
		/**
		 * Способ реагирования при загрузке объекта, если в загрузчике уже есть загруженный объект. 
		 * Если выставлен в <code>true</code>, тогда при запуске загрузки еще одного объекта старый объект 
		 * не удаляется до тех пор, пока не загрузится новый. Если выставлен в <code>false</code>, то 
		 * при запуске загрузки нового объекта старый удаляется сразу и на его месте отображается загрузчик, 
		 * если он был задан.
		 */
		public function get changeImageAfterLoaded():Boolean { return _changeImageAfterLoaded; }
		
		public function set changeImageAfterLoaded(value:Boolean):void {
			_changeImageAfterLoaded = value;
			
			if (_loading) {
				if (!_changeImageAfterLoaded) {
					removeContent();
					showLdr();
				}
			}
		}
		
		private function updateContentSizeAndPosition():void{
			if (!_fitRect || !_content) return;
			
			if (_constrainProportions) {
				constrainProportionsFit(_content, _fitRect.width, _fitRect.height);
			} else {
				_content.width = _fitRect.width;
				_content.height = _fitRect.height;
			}
			
			_content.x = _fitRect.x;
			_content.y = _fitRect.y;
		}
		
		private function constrainProportionsFit(resizeClip:DisplayObject,
											maxWidth:Number, maxHeight:Number):Boolean {
			var origW:Number = resizeClip.width;
			var origH:Number = resizeClip.height;
			
			if (resizeClip.loaderInfo.width > maxWidth) {
				resizeClip.width *= maxWidth / resizeClip.loaderInfo.width;
				resizeClip.scaleY = resizeClip.scaleX;
			}
			
			var resizedDim:Number = resizeClip.loaderInfo.height * resizeClip.scaleY;
			
			if (resizedDim > maxHeight) {
				resizeClip.height *= maxHeight / resizedDim;
				resizeClip.scaleX = resizeClip.scaleY;
			}
			
			return (origW != resizeClip.width || 
					origH != resizeClip.height);
		}
	}
}