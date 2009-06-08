package open3d.objects
{
	import __AS3__.vec.Vector;
	
	import flash.display.*;
	import flash.geom.*;
	
	import open3d.geom.Face;
	import open3d.materials.Material;
	
	/**
	 * Mesh
	 * @author katopz
	 */	
	public class Mesh extends Object3D
	{
		public var screenZ:Number = 0;
		
		// public var faster than get/set
		public var faces:Vector.<Face>;
		protected var _faces:Vector.<Face>;
		
		// still need Array for sortOn(faster than Vector sort)
		private var _faceIndexes:Array;
		
		public function get numFaces():int
		{
			return _faceIndexes?_faceIndexes.length:0;
		}
		
		protected var _culling:String = TriangleCulling.NEGATIVE;
		public function set culling(value:String):void
		{
			_culling = value;
			_triangles.culling = _culling;
		}
		
		public function get culling():String
		{
			return _culling;
		}
		
		private var _isFaceDebug:Boolean = true;
		public function set isFaceDebug(value:Boolean):void
		{
			_isFaceDebug = value;
		}
		
		public function get isFaceDebug():Boolean
		{
			return _isFaceDebug;
		}
		
		private var _isFaceZSort:Boolean = true;
		public function set isFaceZSort(value:Boolean):void
		{
			_isFaceZSort = value;
		}
		
		public function get isFaceZSort():Boolean
		{
			return _isFaceZSort;
		}
		
		private var _isTransfromDirty:Boolean = false;
		public function set isTransfromDirty(value:Boolean):void
		{
			_isTransfromDirty = value;
		}
		
		public function get isTransfromDirty():Boolean
		{
			return _isTransfromDirty;
		}
		
		private var _commands:Vector.<int>=Vector.<int>([1, 2, 2]); // commands to draw triangle
		private var _data:Vector.<Number> = new Vector.<Number>(6, true); // data to draw shape

		public function Mesh()
		{
			_triangles = new GraphicsTrianglePath(new Vector.<Number>(), new Vector.<int>(), new Vector.<Number>(), culling);
		}

		protected function buildFaces(material:Material):void
		{
			var _indices:Vector.<int> = _triangles.indices;
			
			// numfaces
			var _indices_length:int = _indices.length / 3;
			
			_faces = new Vector.<Face>(_indices_length, true);
			_faceIndexes = [];
			
			var i0:Number, i1:Number, i2:Number;
			for (var i:int = 0; i < _indices_length; ++i)
			{
				// 3 point of face 
				var ix3:int = int(i*3);
				i0 = _indices[int(ix3 + 0)];
				i1 = _indices[int(ix3 + 1)];
				i2 = _indices[int(ix3 + 2)];
				
				// Vector3D faster than Vector
				var index:Vector3D = new Vector3D(i0, i1, i2);
				var _face:Face = _faces[i] = new Face(index, 3 * i0 + 2, 3 * i1 + 2, 3 * i2 + 2);
				
				// register face index for z-sort
				_faceIndexes[i] = index;
			}
			
			this.material = material;
			
			isTransfromDirty = true;
			
			// for public call fadter than get/set
			faces = _faces;
			
			update();
		}
		
		override public function project(projectionMatrix3D:Matrix3D, matrix3D:Matrix3D):void
		{
			super.project(projectionMatrix3D, matrix3D);
			
			var _faceIndexes_length:int = _faceIndexes.length;
			if(_faceIndexes_length<=0)return;
			
			// z-sort, TODO : only sort when transfrom is dirty
			if (_isFaceZSort && _isTransfromDirty)
			{
				// get last depth after projected
				for each (var _face:Face in _faces)
					_face.calculateScreenZ(_vout);
				
				// sortOn (faster than Vector.sort)
				_faceIndexes.sortOn("w", 18);
				
				// push back (faster than Vector concat)
				var _triangles_indices:Vector.<int> = _triangles.indices = new Vector.<int>(_faceIndexes_length * 3, true);
				var i:int = -1;
				for each(var face:Vector3D in _faceIndexes)
				{
					_triangles_indices[++i] = face.x;
					_triangles_indices[++i] = face.y;
					_triangles_indices[++i] = face.z;
				}
			}
			
			// faster than getRelativeMatrix3D, also support current render method
			screenZ = _faceIndexes[int(_faceIndexes_length*.5)].w;
		}
		
		public function debugFace(x:Number, y:Number, _view_graphics:Graphics):void
		{
        	var _vertices:Vector.<Number> = _triangles.vertices;

			// TODO : promote this to face class somehow
        	var isHit:Boolean;
			_view_graphics.beginFill(0xCCFF0000);
        	
        	for each (var face:Face in _faces)
        	{
				// get path data grom face
				var _data:Vector.<Number> = face.getPathData(_vertices);
				
				// chk point in triangle
				if(insideTriangle(x, y, _data[0], _data[1], _data[2], _data[3], _data[4], _data[5]))
				{
					// DRAW TYPE #3 drawPath for ColorMaterial = faster than BitmapData-Color
					_view_graphics.drawPath(_commands, _data);
					
					/* TODO : remove this face normal debug
					
					_view_graphics.lineStyle(1,0xFF0000);
					var normal:Vector3D = face.getNormal(_vout);
					
					_view_graphics.moveTo(x,y);
					_view_graphics.lineTo(normal.x, normal.y);
					
					_view_graphics.lineStyle();
					
					*/
				}
        	}
        	_view_graphics.endFill();
		}
		
        /**
         * see if p is inside triangle abc
         * http://actionsnippet.com/?p=1462
         * 
         *      a 
         *     /\
         *    /p \
         *  b/____\c
         * 
         */        
        private function insideTriangle(px:Number, py:Number, ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number):Boolean
        {
			var aX:Number, aY:Number, bX:Number, bY:Number
			var cX:Number, cY:Number, apx:Number, apy:Number;
			var bpx:Number, bpy:Number, cpx:Number, cpy:Number;
			var cCROSSap:Number, bCROSScp:Number, aCROSSbp:Number;

			aX = cx - bx;
			aY = cy - by;
			bX = ax - cx;
			bY = ay - cy;
			cX = bx - ax;
			cY = by - ay;
			
			apx = px - ax;
			apy = py - ay;
			bpx = px - bx;
			bpy = py - by;
			cpx = px - cx;
			cpy = py - cy;

			aCROSSbp = aX * bpy - aY * bpx;
			cCROSSap = cX * apy - cY * apx;
			bCROSScp = bX * cpy - bY * cpx;

			return (aCROSSbp >= 0.0) && (bCROSScp >= 0.0) && (cCROSSap >= 0.0);
        }
	}
}
