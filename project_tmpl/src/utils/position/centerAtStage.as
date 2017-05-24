package utils.position {
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.display.StageAlign;

	/**
	 * @author Павел Гольцев
	 */
	public function centerAtStage(content:DisplayObject, stage:Stage, movieWidth:Number, movieHeight:Number, roundCoordinates:Boolean = false):void {
		if (stage && stage.align == StageAlign.TOP_LEFT) {
			content.x = (stage.stageWidth - content.width) / 2;
			content.y = (stage.stageHeight - content.height) / 2;
		} else {
			content.x = (movieWidth - content.width) / 2;
			content.y = (movieHeight - content.height) / 2;
		}

		if (roundCoordinates) {
			content.x = Math.round(content.x);
			content.y = Math.round(content.y);
		}
	}
}
