package fonts {
	import flash.display.Sprite;
	import flash.text.Font;
	
	[SWF (width = "900", height = "600", frameRate = "25", backgroundColor = "0xCCCCCC")]
	
	/**
	 * Библиотека шрифтов.
	 * @author Павел Гольцев
	 */
	public class FontsLibrary extends Sprite {
		/*
		Common unicode ranges:
		Uppercase   : U+0020,U+0041-U+005A
		Lowercase   : U+0020,U+0061-U+007A
		Numerals    : U+0030-U+0039,U+002E
		Punctuation : U+0020-U+002F,U+003A-U+0040,U+005B-U+0060,U+007B-U+007E
		Basic Latin : U+0020-U+002F,U+0030-U+0039,U+003A-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E
		Latin I     : U+0020,U+00A1-U+00FF,U+2000-U+206F,U+20A0-U+20CF,U+2100-U+2183
		Latin Ext. A: U+0100-U+01FF,U+2000-U+206F,U+20A0-U+20CF,U+2100-U+2183
		Latin Ext. B: U+0180-U+024F,U+2000-U+206F,U+20A0-U+20CF,U+2100-U+2183
		Greek       : U+0374-U+03F2,U+1F00-U+1FFE,U+2000-U+206f,U+20A0-U+20CF,U+2100-U+2183
		Cyrillic    : U+0400-U+04CE,U+2000-U+206F,U+20A0-U+20CF,U+2100-U+2183
		Armenian    : U+0530-U+058F,U+FB13-U+FB17
		Arabic      : U+0600-U+06FF,U+FB50-U+FDFF,U+FE70-U+FEFF
		Hebrew      : U+05B0-U+05FF,U+FB1D-U+FB4F,U+2000-U+206f,U+20A0-U+20CF,U+2100-U+2183
		
		About 'embedAsCFF' attribute:
		- is Flex 4 only
		- is 'true' by default, meaning the font is embedded for the new TextLayout engine only
		- you must set explicitely to 'false' for use in regular TextFields
		
		More information:
		http://help.adobe.com/en_US/Flex/4.0/UsingSDK/WS2db454920e96a9e51e63e3d11c0bf69084-7f5f.html
		*/
		
		[Embed(source='../../fonts/arial.ttf'
		,fontName  ='font1'
		,fontStyle   ='normal' // normal|italic
		,fontWeight  ='normal' // normal|bold
		,unicodeRange='U+00A9,U+00B2,U+00AB,U+00BB,U+0020,U+0041-U+005A,U+0020,U+0061-U+007A,U+0030-U+0039,U+002E,U+0020-U+002F,U+003A-U+0040,U+005B-U+0060,U+007B-U+007E,U+0020-U+002F,U+0030-U+0039,U+003A-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E,U+0400-U+04CE,U+2000-U+206F,U+20A0-U+20CF,U+2100-U+2183'
		,embedAsCFF='false'
		)]
		public static const font1:Class;
		
		public function FontsLibrary() {
			Font.registerFont(font1);			
		}
		
	}
	
}