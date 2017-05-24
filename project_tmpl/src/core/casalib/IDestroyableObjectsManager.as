package core.casalib {
	import org.casalib.core.IDestroyable;

	/**
	 * @author Павел Гольцев
	 */
	public interface IDestroyableObjectsManager {
		/**
		 * Добавляет уничтожаемый объект в менеджер.
		 * 
		 * @param object Объект, который можно уничтожить.
		 */
		function _addDestroyableObject(object:IDestroyable):void;

		/**
		 * Удаляет объект из менеджера.
		 * 
		 * @param object Объект, который нужно удалить из менеджера.
		 * @param destroyAfterRemove Нужно ли уничтожать объект после его удаления из менеджера.
		 * @default false 
		 */
		function _removeDestroyableObject(object:IDestroyable, destroyAfterRemove:Boolean = false):void;

		/**
		 * Уничтожает объект, помещенный в менеджер.
		 * 
		 * @param object Объект, который нужно уничтожить.
		 * @param removeAfterDestroy Определяет, нужно ли удалять уничтоженный объект из менеджера.
		 * @default true
		 */
		function _destroyManagerObject(object:IDestroyable, removeAfterDestroy:Boolean = true):void;
	}
}
