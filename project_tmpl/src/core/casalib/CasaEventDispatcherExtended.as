package core.casalib {
	import core.events.DestroyEvent;
	import flash.events.IEventDispatcher;
	import org.casalib.core.IDestroyable;
	import org.casalib.events.RemovableEventDispatcher;



	/**
	 * Расширение класса, добавляющее возможность автоматического уничтожения внутренних объектов.
	 * 
	 * @author Павел Гольцев
	 */
	public class CasaEventDispatcherExtended extends RemovableEventDispatcher implements IDestroyableObjectsManager {
		private var _objectManager:DestroyableObjectsManager;

		/**
		 * Конструктор.
		 */
		public function CasaEventDispatcherExtended(target:IEventDispatcher = null) {
			super(target);

			localInit();
		}

		private function localInit():void {
			_objectManager = new DestroyableObjectsManager();
		}

		/**
		 * @inheritDoc
		 */
		public function _addDestroyableObject(object:IDestroyable):void {
			_objectManager._addDestroyableObject(object);
		}

		/**
		 * @inheritDoc
		 */
		public function _removeDestroyableObject(object:IDestroyable, destroyAfterRemove:Boolean = false):void {
			_objectManager._removeDestroyableObject(object, destroyAfterRemove);
		}

		/**
		 * @inheritDoc
		 */
		public function _destroyManagerObject(object:IDestroyable, removeAfterDestroy:Boolean = true):void {
			_objectManager._destroyManagerObject(object, removeAfterDestroy);
		}

		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			if (_objectManager) {
				_objectManager.destroyAllObject();
				_objectManager.destroy();
				_objectManager = null;
			}

			super.destroy();

			dispatchEvent(new DestroyEvent(DestroyEvent.DESTROYED));
		}
	}
}
