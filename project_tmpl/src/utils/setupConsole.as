package utils {
	import com.junkbyte.console.Cc;

	import flash.display.DisplayObject;

	public function setupConsole(consoleParent:DisplayObject):void {
		Cc.startOnStage(consoleParent, "`");
		Cc.visible = true;

		Cc.config.commandLineAllowed = true;
		Cc.config.tracing = true;

		Cc.remotingPassword = null;
		Cc.remoting = true;

		Cc.commandLine = true;

		Cc.setRollerCaptureKey("c");

		Cc.height = 220;

		Cc.visible = false;
	}
}
