package core.casalib {
	import core.events.DestroyEvent;
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import org.casalib.core.Destroyable;
	import org.casalib.core.IDestroyable;
	import org.casalib.util.DisplayObjectUtil;


	/**
	 * Менеджер объектов, которые подлежат удалению.
	 * 
	 * @author Павел Гольцев
	 */
	public class DestroyableObjectsManager extends Destroyable implements IDestroyableObjectsManager {
		private var _objects:Dictionary;

		public function DestroyableObjectsManager() {
			super();

			localInit();
		}

		private function localInit():void {
			createObjectsDictionary();
		}

		private function createObjectsDictionary():void {
			_objects = new Dictionary(true);
		}

		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			_objects = null;

			super.destroy();
		}

		/**
		 * @inheritDoc
		 */
		public function _addDestroyableObject(object:IDestroyable):void {
			if (!object) return;
			
			if (object is IEventDispatcher) IEventDispatcher(object).addEventListener(DestroyEvent.DESTROYED, onObjectDestroyed, false, 0, true);

			_objects[object] = true;
		}

		private function onObjectDestroyed(event:DestroyEvent):void {
			_removeDestroyableObject(IDestroyable(event.target));
		}

		/**
		 * @inheritDoc
		 */
		public function _removeDestroyableObject(object:IDestroyable, destroyAfterRemove:Boolean = false):void {
			if (!object) return;
			
			if (object is IEventDispatcher) IEventDispatcher(object).removeEventListener(DestroyEvent.DESTROYED, onObjectDestroyed);

			delete _objects[object];
			if (destroyAfterRemove) _destroyManagerObject(object, false);
		}

		/**
		 * @inheritDoc
		 */
		public function _destroyManagerObject(object:IDestroyable, removeAfterDestroy:Boolean = true):void {
			if (object && _objects[object]) {
				if (!IDestroyable(object).destroyed) {
					if (object is DisplayObject) DisplayObjectUtil.removeChildren(DisplayObject(object), true, true);
					IDestroyable(object).destroy();
					if (object is DisplayObject && DisplayObject(object).parent) DisplayObject(object).parent.removeChild(DisplayObject(object));
				}

				if (removeAfterDestroy) _removeDestroyableObject(object);
			}
		}

		/**
		 * Уничтожает все объекты, помещенные в менеджер.
		 */
		public function destroyAllObject():void {
			for (var object:Object in _objects) {
				_destroyManagerObject(IDestroyable(object), false);
			}

			createObjectsDictionary();
		}
	}
}
