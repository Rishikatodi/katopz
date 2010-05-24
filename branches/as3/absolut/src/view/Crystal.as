package view
{
	import com.sleepydesign.core.IDestroyable;
	import com.sleepydesign.display.DrawUtil;
	import com.sleepydesign.display.SDSprite;
	import com.sleepydesign.text.SDTextField;

	import flash.display.MovieClip;
	import flash.display.Sprite;

	public class Crystal extends SDSprite implements IDestroyable
	{
		// status
		public static const STATUS_FALL:String = "STATUS_FALL";
		public static const STATUS_READY:String = "STATUS_READY";
		public static const STATUS_TOBE_REMOVE:String = "STATUS_TOBE_REMOVE";
		public static const STATUS_REMOVED:String = "STATUS_REMOVED";

		public var status:String = STATUS_READY;

		// asset
		[Embed(source="assets/game.swf", symbol="CrystalClip")]
		private const _CrystalClip:Class;
		private var _crystalClip:MovieClip = new _CrystalClip();

		private var _id:int;

		public function get id():int
		{
			return _id;
		}

		public function set id(value:int):void
		{
			_id = value;
			label.htmlText = String(_id);
		}

		public var swapID:int;

		private var _width:Number = config.CYSTAL_SIZE;

		override public function get width():Number
		{
			return _width;
		}

		private var _height:Number = config.CYSTAL_SIZE;

		override public function get height():Number
		{
			return _height;
		}

		private var _skinIndex:int;

		public function get skinIndex():int
		{
			return _skinIndex; //_crystalClip.currentFrame - 1;
		}

		public function set skinIndex(value:int):void
		{
			_skinIndex = value;
			_crystalClip.gotoAndStop(_skinIndex + 1);
		}

		private var _focus:Boolean;

		public function Crystal()
		{
			addChild(_crystalClip);

			_crystalClip.cacheAsBitmap = true;
			_crystalClip.stop();

			_crystalClip["hilightClip"].visible = false;

			useHandCursor = true;
			buttonMode = true;
			cacheAsBitmap = true;

			hitArea = addChild(DrawUtil.drawRect(_width, _height, 0x000000, 0)) as Sprite;

			addChild(label = new SDTextField);
		}

		public var label:SDTextField;

		public function spin(value:int = -1):void
		{
			_skinIndex = (value == -1) ? int((_crystalClip.totalFrames - 1) * Math.random()) : value;
			_crystalClip.gotoAndStop(_skinIndex + 1);

			swapID = -1;
		}

		public function set focus(value:Boolean):void
		{
			_crystalClip["hilightClip"].visible = _focus = value;
		}

		public function get focus():Boolean
		{
			return _focus;
		}

		override public function destroy():void
		{
			_crystalClip = null;

			super.destroy();
		}
	}
}