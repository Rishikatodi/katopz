package {	import com.squidder.flar.FLARMarkerObj;	import com.squidder.flar.PVFLARBaseApplication;	import com.squidder.flar.events.FLARDetectorEvent;		import flash.events.Event;		import org.papervision3d.lights.PointLight3D;	import org.papervision3d.materials.shadematerials.FlatShadeMaterial;	import org.papervision3d.materials.utils.MaterialsList;	import org.papervision3d.objects.DisplayObject3D;	import org.papervision3d.objects.primitives.Cube;			/**	 * @author Jon Reiling	 */	[SWF(backgroundColor="#000000", frameRate="30", quality="MEDIUM", width="640", height="480")]	public class MultiFLARExample extends PVFLARBaseApplication {				private var _cubes : Array;		private var _lightPoint : PointLight3D;		public function MultiFLARExample() {						_cubes = new Array();						_markers = new Array();						/*			_markers.push( new FLARMarkerObj( "assets/flar/crash.pat" , 16 , 50 , 80 ) );			_markers.push( new FLARMarkerObj( "assets/flar/kickdrum.pat" , 16 , 50 , 80 ) );			_markers.push( new FLARMarkerObj( "assets/flar/ride.pat" , 16 , 50 , 80 ) );			_markers.push( new FLARMarkerObj( "assets/flar/snare.pat" , 16 , 50 , 80 ) );			*/						var _percentW:uint = 80;			var _percentH:uint = 80;						_markers.push( new FLARMarkerObj( "marker/000.pat" , 32 , _percentW , _percentH ) );			_markers.push( new FLARMarkerObj( "marker/001.pat" , 32 , _percentW , _percentH ) );			_markers.push( new FLARMarkerObj( "marker/002.pat" , 32 , _percentW , _percentH ) );			_markers.push( new FLARMarkerObj( "marker/003.pat" , 32 , _percentW , _percentH ) );			_markers.push( new FLARMarkerObj( "marker/004.pat" , 32 , _percentW , _percentH ) );						/*			_markers.push( new FLARMarkerObj( "marker/005.pat" , 32 , _percentW , _percentH ) );			_markers.push( new FLARMarkerObj( "marker/006.pat" , 32 , _percentW , _percentH ) );			_markers.push( new FLARMarkerObj( "marker/007.pat" , 32 , _percentW , _percentH ) );			_markers.push( new FLARMarkerObj( "marker/008.pat" , 32 , _percentW , _percentH ) );			_markers.push( new FLARMarkerObj( "marker/009.pat" , 32 , _percentW , _percentH ) );			*/			super();		}				override protected function _init( event : Event ) : void {			super._init( event );							_lightPoint = new PointLight3D( );			_lightPoint.y = 1000;			_lightPoint.z = -1000;					}				override protected function _detectMarkers() : void {						_resultsArray = _flarDetector.updateMarkerPosition( _flarRaster , 80 , .5 );						for ( var i : int = 0 ; i < _resultsArray.length ; i ++ ) {								var subResults : Array = _resultsArray[ i ];								for ( var j : * in subResults ) {										_flarDetector.getTransmationMatrix( subResults[ j ], _resultMat );					if ( _cubes[ i ][ j ] != null ) transformMatrix( _cubes[ i ][ j ] , _resultMat );				}							}									}						override protected function _handleMarkerAdded( event : FLARDetectorEvent ) : void {						_addCube( event.codeId , event.codeIndex );		}		override protected function _handleMarkerRemove( event : FLARDetectorEvent ) : void {				_removeCube( event.codeId , event.codeIndex );			}				private function _addCube( id:int , index:int ) : void {						if ( _cubes[ id ] == null ) _cubes[ id ] = new Array();						if ( _cubes[ id ][ index ] == null ) {				var fmat:FlatShadeMaterial = _getFlatMaterial( id );				var dispObj : DisplayObject3D = new DisplayObject3D();								var cube : Cube = new Cube( new MaterialsList( {all: fmat} ) , 40 , 40 , 40 ); 				cube.z = 20; 				dispObj.addChild( cube );					_baseNode.addChild( dispObj );								_cubes[ id ][ index ] = dispObj;							} 							_baseNode.addChild( _cubes[ id ][ index ] );					}				private function _removeCube( id:int , index:int ) : void {			if ( _cubes[ id ] == null ) _cubes[ id ] = new Array();			if ( _cubes[ id ][ index ] != null ) {								_baseNode.removeChild( _cubes[ id ][ index ] );			}		}				private function _getFlatMaterial( id:int ) : FlatShadeMaterial {						if ( id%5 == 0 ) {				return new FlatShadeMaterial( _lightPoint , 0xff22aa , 0x75104e ); 								} else if ( id == 1 ){				return new FlatShadeMaterial( _lightPoint , 0x00ff00 , 0x113311 ); 								} else if ( id == 2 ){				return new FlatShadeMaterial( _lightPoint , 0x0000ff , 0x111133 ); 								} else if ( id == 3 ){				return new FlatShadeMaterial( _lightPoint , 0x00ffff , 0x113311 ); 								} else if ( id == 4 ){				return new FlatShadeMaterial( _lightPoint , 0xffff00 , 0x333311 ); 								}else {				return new FlatShadeMaterial( _lightPoint , 0xffffff*Math.random() , 0x333311 ); 								}		}	}}