﻿package com.cutecoma.playground.core
{
	import com.cutecoma.game.core.Position;
	import com.cutecoma.playground.events.GroundEvent;
	import com.sleepydesign.events.SDMouseEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.math.Plane3D;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.WireColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.TilePlane;
	
	public class Ground extends EventDispatcher
	{
		private var plane3D		:Plane3D;
		private var engine3D	:Engine3D;
		
		// tile
		private var _debug			: Boolean = false;
		private var _tileInstance	: TilePlane;
		private var _tileMaterials	:MaterialsList;
		
		public function Ground(engine3D:Engine3D, map:Map, mouseEnable:Boolean=true, debug:Boolean=false)
		{
			this.engine3D = engine3D;
			plane3D = new Plane3D(new Number3D(0, 1, 0), Number3D.ZERO);
			
			if(mouseEnable)
				engine3D.viewport.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseIsDown);
				
			this.debug = debug;
		}
		
		//____________________________________________________________ CLICK
		
		private function onMouseIsDown(event:MouseEvent):void
		{
			//if(!(event.target is Stage))return;
			var camera:Camera3D = engine3D.camera;
			var ray:Number3D = Number3D.add(camera.unproject(engine3D.viewport.containerSprite.mouseX, engine3D.viewport.containerSprite.mouseY), camera.position);
			
			var cameraVertex3D	:Vertex3D = new Vertex3D(camera.x, camera.y, camera.z);
			var rayVertex3D		:Vertex3D = new Vertex3D(ray.x, ray.y, ray.z);
			var intersectPoint	:Vertex3D = plane3D.getIntersectionLine(cameraVertex3D, rayVertex3D);
			
			dispatchEvent(new SDMouseEvent(SDMouseEvent.MOUSE_DOWN, {position:Position.parse(intersectPoint)}, event));
		}
		
		//____________________________________________________________ TilePlane
		
		public function get debug():Boolean
		{
			return _debug;
		}
		
		public function set debug(value:Boolean):void
		{
			_debug = value; 
			if(_debug)
			{
				engine3D.viewport.interactive = true;
				create();
			}else{
				engine3D.viewport.interactive = false;
				destroy();
			}
		}
		
		public function update():void
		{
			if(_debug)
			{
				destroy();
				create();
			}
		}
		
		public function create():void
		{
			var map:Map = Map.getInstance();
				
			var w:uint=map.data.bitmapData.width;
			var h:uint=map.data.bitmapData.height;
			
			_tileMaterials = new MaterialsList();
			var _getPixel:Function = map.data.bitmapData.getPixel;
			for(var k :uint= 0; k < w*h; k++)
			{
				var i:int 			= int(k%w);
				var j:int 			= int(k/w);
				var color:Number 	= _getPixel(i,j);
				
				//if(color!=0x000000)
				var _wireColorMaterial:WireColorMaterial = new WireColorMaterial(color, .5, true);
				_wireColorMaterial.name = i + "_" + j;
				_tileMaterials.addMaterial(_wireColorMaterial);
			}
			
			if(_tileInstance)
				_tileInstance.destroy();
				
			_tileInstance = new TilePlane(_tileMaterials, w*Map.factorX, h*Map.factorZ, w,h);
			//_tileInstance.useOwnContainer = true;
			//_tileInstance.blendMode = BlendMode.MULTIPLY;
			engine3D.addChild(_tileInstance);
			
			_tileInstance.removeEventListener(InteractiveScene3DEvent.OBJECT_CLICK, onClick);
			_tileInstance.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, onClick);
			
			_tileInstance.removeEventListener(InteractiveScene3DEvent.OBJECT_MOVE, onMouseMove);
			_tileInstance.addEventListener(InteractiveScene3DEvent.OBJECT_MOVE, onMouseMove);
		}
		
		public function onClick(event:InteractiveScene3DEvent):void
		{
			var _x_y:Array = event.renderHitData.material.name.split("_");
			dispatchEvent(new GroundEvent(GroundEvent.MOUSE_DOWN, _x_y[0], _x_y[1], event.renderHitData.material.fillColor));
		}
		
		public function onMouseMove(event:InteractiveScene3DEvent):void
		{
			var _x_y:Array = event.renderHitData.material.name.split("_");
			dispatchEvent(new GroundEvent(GroundEvent.MOUSE_MOVE, _x_y[0], _x_y[1], event.renderHitData.material.fillColor));
		}
		
		public function destroy():void
		{
			// event
			if(_tileInstance)
			{
				_tileInstance.removeEventListener(InteractiveScene3DEvent.OBJECT_CLICK, onClick);
				_tileInstance.removeEventListener(InteractiveScene3DEvent.OBJECT_MOVE, onMouseMove);
			}
			
			// self
			if(_tileMaterials)
			{
				_tileMaterials.destroy();
				_tileMaterials = null;
			}
			
			// parent
			if(_tileInstance)
				engine3D.removeChild(_tileInstance);
			_tileInstance = null;
		}
	}
}