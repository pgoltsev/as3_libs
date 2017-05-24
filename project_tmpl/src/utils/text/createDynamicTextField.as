package utils.text {
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	/**
	 * @author Павел Гольцев
	 */
	public function createDynamicTextField(fontName:String, 
										   multiline:Boolean = true, 
										   autoSize:String = "left", 
										   fontSize:Number = 12, fontColor:Number = 0x0, 
										   wordWrap:Boolean = false, leading:Object = null, letterSpacing:Object = null):TextField {
		var _textTf:TextField = new TextField();
		_textTf.mouseEnabled = false;
		
		var tf:TextFormat = new TextFormat(fontName, fontSize, fontColor);
		tf.leading = leading;
		tf.letterSpacing = letterSpacing;
		_textTf.defaultTextFormat = tf;
		
		_textTf.embedFonts = true;
		_textTf.type = TextFieldType.DYNAMIC;
		_textTf.selectable = false;
		_textTf.autoSize = autoSize;
		_textTf.wordWrap = wordWrap;
		_textTf.multiline = multiline;
		_textTf.gridFitType = GridFitType.PIXEL;
		_textTf.antiAliasType = AntiAliasType.ADVANCED;
		
		return _textTf;
	}
}