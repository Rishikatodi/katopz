package open3d.objects
{
	import __AS3__.vec.Vector;
	
	import flash.display.*;
	import flash.geom.*;
	
	import open3d.materials.Material;

	/**
	 * Object3D
	 * @author katopz
	 */
	public class Object3D extends Sprite
	{
		public var triangles:GraphicsTrianglePath;
		protected var _triangles:GraphicsTrianglePath;

		// public var faster than get/set view
		public var vin:Vector.<Number>;
		protected var _vin:Vector.<Number>;

		public var vout:Vector.<Number>;
		protected var _vout:Vector.<Number>;

		protected var _material:Material;
		
		// internal
		private var _transform_matrix3D:Matrix3D;
		private var _vertices:Vector.<Number>;
		private var _uvtData:Vector.<Number>;
		
		public function Object3D():void
		{
			vin = _vin = new Vector.<Number>();
			_transform_matrix3D = transform.matrix3D = new Matrix3D();
			_material = new Material();
		}

		/**
		 * must update once before project loop
		 */
		public function update():void
		{
			// speed up
			_vin.fixed = true;
			_triangles.uvtData.fixed = true;
			_triangles.indices.fixed = true;
			
			// private use
			_vertices = _triangles.vertices;
			_uvtData = _triangles.uvtData;
			
			// public use
			triangles = _triangles;
			
			// dispose vout 
			vout = _vout = new Vector.<Number>(_vin.length, true);
		}

		public function project(projectionMatrix3D:Matrix3D, matrix3D:Matrix3D):void
		{
			// local
			_transform_matrix3D.transformVectors(_vin, _vout);
			
			// global
			matrix3D.transformVectors(_vout, _vout);
			
			// project
			Utils3D.projectVectors(projectionMatrix3D, _vout, _vertices, _uvtData);
		}

		public function set material(value:Material):void
		{
			_material = value ? value : new Material();
			_material.triangles = _triangles;
			_material.update();
		}

		public function get material():Material
		{
			return _material;
		}

		public function get graphicsData():Vector.<IGraphicsData>
		{
			return _material.graphicsData;
		}

		// TODO : more friendly use
		public function getVertices(index:int):Vector3D
		{
			return new Vector3D
				(
				_vin[3 * index + 0],
				_vin[3 * index + 1],
				_vin[3 * index + 2]
				);
		}

		// TODO : more friendly use
		public function setVertices(index:int, axis:String, value:Number):void
		{
			if (axis == "x")
			{
				_vin[3 * index + 0] = value;
			}
			else if (axis == "y")
			{
				_vin[3 * index + 1] = value;
			}
			else if (axis == "z")
			{
				_vin[3 * index + 2] = value;
			}
		}
	}
}