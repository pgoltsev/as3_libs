package resource {
	import core.casalib.CasaTextFieldExtended;

	import flash.display.BlendMode;
	import flash.events.*;
	import flash.system.*;
	import flash.text.*;
	import flash.utils.*;

	public class FpsBox extends CasaTextFieldExtended {
		protected var _frames:uint = 0;
		protected var _format:TextFormat;
		
		private var _timer:Timer;
		
		public function FpsBox(){
			blendMode = BlendMode.INVERT;
			_format = new TextFormat();
			super();
			_timer = new Timer(1000);
			_format.color = 0;
			_format.size = 10;
			autoSize = TextFieldAutoSize.LEFT;
			defaultTextFormat = _format;
			text = "-- FPS";
			_timer.addEventListener(TimerEvent.TIMER, tick, false, 0, true);
			addEventListener(Event.ENTER_FRAME, everyFrame, false, 0, true);
			_timer.start();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function destroy():void {
			if (_timer) {
				_timer.reset();
				_timer.removeEventListener(TimerEvent.TIMER, tick);
				_timer = null;
			}
			
			super.destroy();
		}
		
		private function everyFrame(e:Event):void {
			_frames++;
		}

		private function tick(e:TimerEvent):void {
			text = _frames + " FPS " + Number(System.totalMemory / 1024 / 1024).toFixed(2) + " MB";
			_frames = 0;
		}
	}
}
