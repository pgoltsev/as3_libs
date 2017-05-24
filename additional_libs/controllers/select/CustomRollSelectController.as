package controllers.select {
	import flash.events.MouseEvent;

	/**
	 * Класс, контролирующий выбор объектов с отдельными функциями при наведении на объект и отведении 
	 * с объекта курсора мыши. Класс наследуется от <code>SelectController</code> и расширяет его 
	 * таким образом, что выбираемые объекты также должны соответствовать интерфейсу <code>IRollable</code>.
	 * 
	 * @author Павел Гольцев
	 * @version 1.0.3
	 */
	public class CustomRollSelectController extends SelectController{
		/**
		 * Конструктор.
		 */
		public function CustomRollSelectController() {
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function onItemRollOver(e:MouseEvent):void {
			var clp:IRollable = _items[e.currentTarget];
			var selected:Boolean = Boolean(clp == getSelected());
			
			if ((selected && _dispatchRollEventsBySelected) ||
				!selected) {
				dispatchEvent(new SelectControllerEvent(SelectControllerEvent.ROLL_OVER, ISelectable(clp)));
			}
			
			clp.rollOver(selected);
		}
		
		protected override function onItemRollOut(e:MouseEvent):void {
			var clp:IRollable = _items[e.currentTarget];
			var selected:Boolean = Boolean(clp == getSelected());
			
			if ((selected && _dispatchRollEventsBySelected) ||
				!selected) {
				dispatchEvent(new SelectControllerEvent(SelectControllerEvent.ROLL_OUT, ISelectable(clp)));
			}
			
			clp.rollOut(selected);
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function setSelected(obj:ISelectable, 
												deselectInstantly:Boolean = false):void {
			if (obj) obj.select();
			
			super.setSelected(obj, deselectInstantly);
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function isObjectAcceplable(obj:Object):Boolean {
			return super.isObjectAcceplable(obj) && obj is IRollable;
		}
	}

}