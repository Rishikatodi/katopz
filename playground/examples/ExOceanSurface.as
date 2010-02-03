package examples{	//import fl.events.*;		import flash.display.*;	import flash.events.*;	import flash.geom.*;	import flash.net.URLRequest;	import flash.text.*;	import flash.utils.Timer;		import com.greensock.TweenLite;		import org.papervision3d.cameras.Camera3D;	import org.papervision3d.core.culling.RectangleTriangleCuller;	import org.papervision3d.materials.BitmapMaterial;	import org.papervision3d.materials.WireframeMaterial;	import org.papervision3d.objects.primitives.Plane;	import org.papervision3d.objects.primitives.Sphere;	import org.papervision3d.render.BasicRenderEngine;	import org.papervision3d.scenes.Scene3D;	import org.papervision3d.view.Viewport3D;		public class ExOceanSurface extends Sprite	{		private var mouseRotationEnabled:Boolean = true;				private var outputRendering		:BitmapData;		private var tmpRendering		:BitmapData;				private var container 			: Sprite;		public var scene 				: Scene3D;		//private var camera 			: FreeCamera3D;		private var camera 				: Camera3D;		private var terrain3D 			: Plane;		private var viewport			:Viewport3D;		private var renderer			:BasicRenderEngine;				private var textureBitmap 		: BitmapData;		private var heightMap 			: BitmapData;		private var perlinNoiseFallOff	: BitmapData;		private var gradBmp				: BitmapData;				private var perlinNoiseOffset	: Array = new Array(2);		private var paletteArray 		: Array = new Array();		private var nw					: Number ;		private var nh					: Number ;				private var numOctaves			: Number;		private var randSeed			: Number;		private var mapUrl 				: String = "seaGradAlpha.png";		//private var sphere				: Ase;		private var sphere			: Sphere;				private var loader				: Loader;		private var t					: TextField		private var ofy					: Number = 0;				//use to test speed		private var tCount				: Number = 0;		private var tExecTime 			: Number= 0;		private var tUnitTest			: Boolean = true;		private var tf					: TextFormat;		private var _outStr				: String = "";		private var origin				: Point = new Point();				private var cullRect			: Sprite = new Sprite();		private var rect				: Rectangle = new Rectangle();		//private var ism					: InteractiveSceneManager;						//----------------------------------		// Curve objects		public var p1					:Object;		public var p2					:Object;		// Generic stuff		private var selectedPoint				:Number;		private var controlPoints				:Array;		private var curvePoints					:Array;		private var targetTravel				:Boolean;		//--------------------------------				public var md:Boolean = false;		public var lastmx:Number;		public var lastmy:Number;				public var updateTimer:Timer = new Timer(50);				public function ExOceanSurface()		{			//stage.displayState = StageDisplayState.FULL_SCREEN			t= new TextField()			addChild(t);						this.mouseChildren = false			this.mouseEnabled = false						t.width 	= 300;			t.height 	= 200;			t.x 		= t.y = 10;			t.multiline = true;			tf = new TextFormat("Verdana", 10, 0xFFFFFF, true);						t.mouseEnabled = false			t.mouseWheelEnabled = false						t.y+=20			outStr += "OceanSurface::OceanSurface BETA 1.0\n";						stage.quality = "HIGH";			stage.scaleMode = "noScale";			stage.align="TL";						loadMedia()			//sld1.addEventListener(SliderEvent.THUMB_DRAG, onSliderChange);			//bt_gen.addEventListener(MouseEvent.CLICK , regenSeed)					}		private var rSeed_txt:Number;				private function regenSeed(e:* = null):void		{			randSeed = Math.random()*1000;			rSeed_txt = randSeed;		}		/*		private function onSliderChange(e:SliderEvent):void		{			trace(e.value)		}		*/		public function set outStr(new_value:String):void		{			_outStr = new_value;			t.text = outStr;			t.setTextFormat(tf);					}		public function get outStr():String		{			return _outStr;		}				private function loadMedia():void		{			outStr +=  "OceanSurface::loadMedia[ "+mapUrl+" ]\n";						loader = new Loader();			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, mediaLoaded);			loader.load(new URLRequest(mapUrl));		}				private function mediaLoaded(e:* = null):void		{			var bt:Bitmap = Bitmap(loader.content);			trace("bt.smoothing : "+bt.smoothing)			bt.smoothing = true;			gradBmp = bt.bitmapData;			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, mediaLoaded);						init3D();		}				public function resetStage(...rest):void		{			cullRect.graphics.clear();			cullRect.graphics.beginFill(0xE9E9E9,.5);			cullRect.graphics.drawRect((stage.stageWidth*.5)-(320*.5),(stage.stageHeight*.5)-(240*.5),320, 240)			cullRect.graphics.endFill();			rect.x = -(320*.5)			rect.y = -(240*.5)			rect.width = 320;			rect.height = 240;						createCuller();		}				private function createCuller():void		{			viewport.triangleCuller = new RectangleTriangleCuller(rect);		}				private function init3D():void		{			this.cacheAsBitmap = true;						outStr += "OceanSurface::init3D\n";			cullRect = new Sprite();						addChild( cullRect)			cullRect.x = stage.stageWidth/2;			cullRect.y = stage.stageHeight/2;						this.container = new Sprite();			container.mouseEnabled = container.mouseChildren = false;						addChild( this.container );			//var rect:Rectangle = this.container.getBounds(this);			outputRendering = new BitmapData(945, 600, true, 0x00);			tmpRendering 	= outputRendering.clone();						//flt = new FisheyeFilter(tmpRendering, outputRendering);			//flt.setActive(true);						//addChild(new Bitmap(outputRendering) );									//this.swapChildren(container, t);			this.container.x = stage.stageWidth/2;			this.container.y = stage.stageHeight/2;			//this.container.cacheAsBitmap = true;			// Create scene 			this.scene = new Scene3D( );			this.viewport = new Viewport3D(0,0,true,false);			this.renderer = new BasicRenderEngine();						addChild(viewport);						/*			// Create camera			camera = new FreeCamera3D();			camera.x = 0;			camera.z = -480;			camera.y = 300;			camera.zoom = 10;			camera.focus = 100;			*/			//-----------------------------------------			// Creates cameras			camera = new Camera3D();			camera.x = 335// 600;			camera.z = 500//1.5;			camera.y = 385//750;			camera.zoom = 10;			camera.focus = 100;			targetTravel = true;			p1 = {x:335, y:385, z:500};			p2 = {x:250, y:75, z:50};						controlPoints = [];			curvePoints = [];						// Sample control points			//addControlPoint(830, 430, -281);			//addControlPoint(200, 120, 200);									//----------------------------------------			// create heighMaps			var heightMapWidth:Number = 100;						heightMap = new BitmapData(heightMapWidth,heightMapWidth,true,0);			var milkBitmap:BitmapData = new BitmapData(100,100,true,0xffffff);			milkBitmap.fillRect(milkBitmap.rect,0xB0FFFFFF)						textureBitmap = heightMap.clone();			for (var ra:uint = 0;ra<256;ra++)			{				paletteArray[ra] = gradBmp.getPixel32(10, 256-ra);			}						var materialBottle :BitmapMaterial = new BitmapMaterial(milkBitmap);									// create textures						var textureMaterial:BitmapMaterial = new BitmapMaterial(textureBitmap);			textureMaterial.doubleSided = false;			//textureMaterial.lineAlpha = .1;						// create terrain			terrain3D = new Plane(textureMaterial,512,512,32,32);			var c:BitmapMaterial = new BitmapMaterial(milkBitmap);			var wf:WireframeMaterial = new WireframeMaterial(0xFF0000, 1, 0.4);			wf.doubleSided = true;			terrain3D.rotationZ = 180						//c.doubleSided = true;			sphere = new Sphere(c,16);			//sphere = new Ase( wf, "tri.ase", .025);//			//sphere.rotationX += 15			outStr +=  "Segments W : " + String(32) +"\n";			outStr +=  "Segments H : " + String(32) +"\n";			outStr +=  "Verticies : " + String(terrain3D.geometry.vertices.length) +"\n";			scene.addChild(terrain3D,"Terrain");			scene.addChild(sphere,"sphere3D");			//sphere = new Ase( c, "NEW_bottle_2.ASE", .008);						//scene.addChild(sphere,"sphere23D");			//scene.getChildByName('sphere3D').container.filters =[new DropShadowFilter(4, 45, 0xcc0000, 1, 4, 4, 1, 1,false, false)];			terrain3D.rotationX = -90;			sphere.rotationY = 90;			generateTerrain();			camera.lookAt(terrain3D);			//camera.lookAt(sphere);			outStr +=  "OceanSurface::StartRender\nnumOctave : " + numOctaves + "\nrandSeed : " + randSeed;			/*			var fps = new FPS();			fps.x = 10			fps.y = 5;			addChild(fps);			*/			//t.text = outStr;				//resetStage()						renderer.renderScene(scene, camera, viewport);						stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);						stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);						updateTimer.addEventListener(TimerEvent.TIMER, loop3D);			updateTimer.start();									//this.addEventListener( Event.ENTER_FRAME, loop3D );		}				//---------------------------------		public function mouseDown(evt:*=null):void		{			md = true;		}				public function mouseUp(evt:*=null):void		{			md = false;		}						public function setPointAlpha(p:Number, p_alpha:Number):void {			if (isNaN(p)) return;					}				public function stopTravel(): void		{			TweenLite.killTweensOf(camera);			TweenLite.killTweensOf(camera.target);			camera.x = p1.x;			camera.y = p1.y;			camera.z = p1.z;			camera.target.x = 0;			camera.target.y = 100;			camera.target.z = 0;		}		public function startTravel():void 		{			// Plays the ball using the bezier values			stopTravel();			var i:uint;			var animTime	:Number = Number(10);			var animDelay	:Number = targetTravel ? animTime/20 : 0;					// Creates list of control points			var bezierList:Array = [];			for (i = 0; i < controlPoints.length; i++)			{				bezierList.push({x:controlPoints[i].x, y:controlPoints[i].y, z:controlPoints[i].z});			}						TweenLite.to(camera, animTime, {x:p2.x, y:p2.y, z:p2.z, bezier:bezierList, delay:animDelay, transition:"linear", onComplete:tweenEnd});			if (targetTravel) {				// Algo tweens the target				camera.target.x = p1.x;				camera.target.y = p1.y;				camera.target.z = p1.z;				TweenLite.to(camera.target, animTime, {x:p2.x, y:p2.y, z:p2.z, bezier:bezierList, transition:"linear"});			}								}				private function tweenEnd():void		{			//isInTweeen = false;			mouseRotationEnabled = true;			trace('tweenEnd')					}		//-----------------------------------------		private function keyDownHandler(e:KeyboardEvent):void		{			mouseRotationEnabled = false;						switch(e.keyCode)			{												case 32:					isInTween = true;					//p1 = {x:camera.x, y:camera.y, z:camera.z}					//startTravel();					trace(camera.x +"|"+ camera.y +"|"+ camera.z)					break;				case 38:					//camera.moveForward(5);									break;				case 40:					//camera.moveBackward(5);				break;			}			//scene.renderCamera( camera );		}				private function createMapMask(): void		{						perlinNoiseFallOff = new BitmapData( heightMap.width , heightMap.height, true, 0 );						var holder: Sprite =  new Sprite();						var gradientBox: Matrix = new Matrix();						gradientBox.createGradientBox( heightMap.width, heightMap.height, 0, 0, 0 );			var g:Graphics = holder.graphics;			g.beginGradientFill( 'linear', [ 0x8ab5d5, 0x8ab5d5, 0x8ab5d5, 0x8ab5d5 ], [ 90, 90,60, 0 ], [ 0x00, 0x80,0xB0  ,0XFF], gradientBox );			g.moveTo( 0, 0 );			g.lineTo( heightMap.width, 0 );			g.lineTo( heightMap.width, heightMap.height );			g.lineTo( 0, heightMap.height );			g.lineTo( 0, 0 );			g.endFill();						perlinNoiseFallOff.draw( holder );					}						private function generateTerrain(e:Event = null):void		{			//nw 			= heightMap.width/(1+Math.random()*5);			//nh 			= heightMap.width/(1+Math.random()*5);			outStr +=  "OceanSurface::generateTerrain\n";						nw 					= heightMap.width * .66			nh 					= heightMap.height * .66			numOctaves 			= 3//Math.round(Math.random()*5);			randSeed			= Math.random()*1000; //928.34274810180068/			rSeed_txt		= randSeed;			perlinNoiseOffset 	= [ new Point(), new Point() ];						//createMapMask();			updateLevels();		}				private var sld1_value:Number=0.2;		private var sld2_value:Number=0.2;				private function updateLevels():void		{			//if(tUnitTest)				//var t1 = getTimer();						perlinNoiseOffset[0].x -= 2 * sld1_value;			perlinNoiseOffset[1].x -= 1.5 * sld1_value;									nw 					= heightMap.width * sld2_value;			nh 					= heightMap.height * sld2_value;			randSeed			= rSeed_txt;			// TODO : cached perlin			heightMap.perlinNoise(nw, nh, numOctaves, randSeed, true, false , 4, false, perlinNoiseOffset);			//heightMap.copyPixels(heightMap,heightMap.rect,new Point(),perlinNoiseFallOff,new Point(),false)			textureBitmap.paletteMap(heightMap,heightMap.rect,origin, paletteArray ,paletteArray , paletteArray);			textureBitmap.copyPixels(textureBitmap,textureBitmap.rect,origin,perlinNoiseFallOff,origin,false)						var vertices	:Array  = terrain3D.geometry.vertices;			var gridX		:Number = 1+terrain3D.segmentsW;			var gridY		:Number = 1+terrain3D.segmentsH;			var vertexIndex	:Number = 0;			var iW       	:Number = heightMap.width / gridX;			var iH       	:Number = heightMap.height / gridY;						ofy += 1			for( var ix:int = 0; ix < gridX ; ix++ )			{				for( var iy:int = 0; iy < gridY; iy++ )				{					var elevation :Number = Number( heightMap.getPixel(ix*iW,heightMap.height-iy*iH));										vertices[vertexIndex].z = -Math.min(0xFF,Math.max(1,elevation))/5;					//trace(vertices[vertexIndex].z )					//vertices[vertexIndex].z = -16;										sphere.x = vertices[480].x //+ ofy					sphere.z = vertices[480].y 					sphere.y = -vertices[480].z-10//-5										vertexIndex++;				}			}						/*if(tUnitTest)			{				var t2 = getTimer();								if(tCount<100)				{					tExecTime += (t2-t1);					tCount++;				}								if(tCount==100)				{					t.text = outStr  + "\nexecuted 100 times in : " +String(tExecTime)+ " ms.";					t.setTextFormat(tf);					//trace("camera.x : " + camera.x)					//trace("camera.x : " + camera.y)					//trace("camera.x : " + camera.z)					tCount = tExecTime = 0;				}			}*/					}				private var isInTween	:Boolean = false;				private function loop3D( event :Event ):void		{						updateLevels()						var axeAngle:Number = stage.mouseX/50;						if(md == true)			{								camera.x += (600*Math.cos(axeAngle)-camera.x)*.1;				camera.z += (-600*Math.sin(axeAngle)-camera.z)*.1;				camera.y = stage.stageHeight - stage.mouseY;								camera.lookAt(terrain3D);			}						renderer.renderScene(scene, camera, viewport);		}				}}