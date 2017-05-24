package managers.resize {
	import core.casalib.CasaEventDispatcherExtended;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	/**
	 * Менеджер изменения размеров ролика.
	 * @author Павел Гольцев
	 */
	public class ResizeManager extends CasaEventDispatcherExtended {
		private static var _instance:ResizeManager;

		private var _stage:Stage;
		private var _objects:Dictionary;
		
		/**
		 * Конструктор.
		 */
		public function ResizeManager() {
			super();

			if (_instance) {
				throw new Error("Используйте параметр 'instance', чтобы получить доступ к объекту синглтона!");
			}
		}

		/**
		 * Синглтон.
		 */
		public static function get instance():ResizeManager {
			if (!_instance) {
				_instance = new ResizeManager()
			}

			return _instance;
		}

		/**
		 * Главная функция инициализации.
		 * @param stage Объект типа <code>Stage</code>.
		 * @param	automaticAddAndRemoveObjects Если выставлен в <code>true</code>, то при добавлении в список отображения ролика
		 * новых объектов и удаления их оттуда, если объект удовлетворяет интерфейсу изменения размера, то такой объект автоматом
		 * добавляется в менеджер и автоматом удаляется из него.
		 * @default false
		 */
		public function initialize(stage:Stage, automaticAddAndRemoveObjects:Boolean = false):void {
			if (_stage) return;

			_stage = stage;
			clear();

			_stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);

			if (automaticAddAndRemoveObjects) {
				_stage.addEventListener(Event.ADDED, onStageAdded, false, 0, true);
				_stage.addEventListener(Event.REMOVED, onStageRemoved, false, 0, true);
			}
		}

		private function onStageRemoved(e:Event):void {
			if (e.target is IResize) remove(IResize(e.target));
		}
		
		private function onStageAdded(e:Event):void {
			if (e.target is IResize) add(IResize(e.target), true);
		}
		
		private function onStageResize(e:Event):void {
			forceResize();
		}
		
		/**
		 * Добавляет объект в менеджер.
		 * @param object Объект, который необходимо добавить в менеджер
		 * @param makeResizeAction Указывает, нужно ли имитировать изменение размера для 
		 * вновь добавленного объекта сразу после его добавления в менеджер.
		 * @return Если объект отсутствовал в менеджере и был в него успещно добавлен, то 
		 * возвращает <code>true</code>, если же объект уже присутствует в менеджере, возвращает 
		 * <code>false</code>.
		 */
		public function add(object:IResize, makeResizeAction:Boolean = false):Boolean {
			if (_objects[object]) return false;
			
			_objects[object] = true;
			
			if (makeResizeAction) object.updatePositionsAfterResize(_stage.stageWidth, _stage.stageHeight);
			
			return true;
		}
		
		/**
		 * Удаляет объект из менеджера.
		 * @param	object Объект, который нужно удалить.
		 * @return Возвращает <code>true</code>, если объект присутствовал в менеджере и был успешно удален, 
		 * иначе возвращает <code>false</code>.
		 */
		public function remove(object:IResize):Boolean {
			if (_objects[object]) {
				_objects[object] = null;
				delete _objects[object];
				
				return true;
			}
			
			return false;
		}
		
		/**
		 * Очищает менеджер, удаляя все объекты, которые были в него добавлены.
		 */
		private function clear():void{
			_objects = new Dictionary(true);
		}
		
		/**
		 * Имитирует изменение размера ролика для всех объектов менеджера.
		 * 
		 * @param object Объект, для которого необходимо имитировать изменение размеров ролика. 
		 * Если параметр не задан, имитация производится для всех объектов в менеджере.
		 * @default null  
		 */
		public function forceResize(object:IResize = null):void {
			if (object) {
				object.updatePositionsAfterResize(_stage.stageWidth, _stage.stageHeight);
			} else {
				for (var localObject:Object in _objects) {
					if (localObject) IResize(localObject).updatePositionsAfterResize(_stage.stageWidth, _stage.stageHeight);
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			if (_stage) {
				_stage.removeEventListener(Event.RESIZE, onStageResize);
				_stage.removeEventListener(Event.ADDED, onStageAdded);
				_stage.removeEventListener(Event.REMOVED, onStageRemoved);
				_stage = null;
			}
			
			_objects = null;
			
			super.destroy();
		}
	}

}