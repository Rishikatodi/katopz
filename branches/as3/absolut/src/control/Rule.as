package control
{
	import flash.geom.Point;

	import org.osflash.signals.Signal;

	import view.Crystal;

	public class Rule
	{
		public static var checkSignal:Signal = new Signal(Boolean /*result*/, Vector.<Crystal>);

		/**
		 *
		 * Rule #1 : swap only nearby area.
		 *
		 * @param focusID
		 * @param swapID
		 * @param listener
		 *
		 */
		public static function isNearby(focusID:int, swapID:int):Boolean
		{
			var _a:Point = getPositionFromIndex(focusID, config.COL_SIZE);
			var _b:Point = getPositionFromIndex(swapID, config.COL_SIZE);

			return (Math.abs(_a.x - _b.x) + Math.abs(_a.y - _b.y) <= 1);
		}

		private static function getPositionFromIndex(index:uint, size:uint):Point
		{
			return new Point(int(index % size), int(index / size));
		}

		public static function check(boards:Vector.<Crystal>, listener:Function):void
		{
			checkSignal.addOnce(listener);

			var _result:Boolean = false;
			for (var j:int = 0; j < config.ROW_SIZE * config.COL_SIZE; j += config.COL_SIZE)
			{
				// check col
				var _sameCrystals:Vector.<Crystal> = new Vector.<Crystal>();
				var _isSame:Boolean = true;
				var k:int = j;
				var _count:int = 0;
				// all in col
				while (k < j + config.COL_SIZE - 1)
				{
					_count = 0;
					var _currentIndex:uint = k;
					var _skinIndex:uint = boards[k].skinIndex;

					// start skin index same as other skin index?
					while ((k < j + config.COL_SIZE - 2) && (_isSame = (_skinIndex == boards[k + 1].skinIndex)))
					{
						/*
						   same color more than 3 time
						   [a] [a] [a] [b] [c] [d] [e] [f]
						 */

						if (_isSame)
						{
							// more than 3?
							_count++;

							// same more than 3
							if (_count > 1)
							{
								// eliminate all in col
								for (var _index:int = _currentIndex; _index <= k + 1; _index++)
								{
									boards[_index].status = Crystal.STATUS_TOBE_REMOVE;
									trace(_index);
								}

								_result = _result || true;
							}
							else
							{
								_result = _result || false;
							}
						}
						k++;
					}
					k++;
				}
			}

			// result
			checkSignal.dispatch(_result, boards);
		}
	}
}