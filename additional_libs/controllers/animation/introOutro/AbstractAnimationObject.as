package controllers.animation.introOutro {
	import core.casalib.CasaEventDispatcherExtended;

	import flash.utils.getQualifiedClassName;

	/**
	 * Абстрактный класс, упрощающий создание объектов анимации.
	 * @author Павел Гольцев
	 */
	public class AbstractAnimationObject extends CasaEventDispatcherExtended implements IAnimationInOut {
		protected var _content:Object;
		protected var _animCtrl:AnimationInOutController;

		public function AbstractAnimationObject(content:Object) {
			super();
			
			if (getQualifiedClassName(this) == getQualifiedClassName(AbstractAnimationObject)) {
				throw new ArgumentError('Объект класса ' + getQualifiedClassName(this) + ' не может быть создан, т. к. класс является абстрактным.');
			}
			
			_content = content;
			
			_animCtrl = new AnimationInOutController(this);
			_addDestroyableObject(_animCtrl);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			_content = null;
		}
		
		public function isInAnimationAvailable(...args):Boolean {
			return true;
		}
		
		public function isOutAnimationAvailable(...args):Boolean {
			return true;
		}
		
		public function _localStartInAnimation(...args):Boolean {
			return true;
		}
		
		public function _localStartOutAnimation(...args):Boolean {
			return true;
		}
		
		public function get animationIOController():AnimationInOutController {
			return _animCtrl;
		}
	}
}
