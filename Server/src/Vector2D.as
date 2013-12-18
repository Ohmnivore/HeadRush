package {
	
	/**
	 * A basic 2-dimensional vector class.
	 */
	public class Vector2D {
		public var x:Number;
		public var y:Number;
		
		public function Vector2D(_x:Number = 0, _y:Number = 0) {
			x = _x;
			y = _y;
		}
		
		/**
		 * Generates a copy of this vector.
		 * @return Vector2D A copy of this vector.
		 */
		public function clone():Vector2D {
			return new Vector2D(x, y);
		}
		
		/**
		 * Whether or not this vector is equal to zero, i.e. its x, y, and length are zero.
		 * @return Boolean True if vector is zero, otherwise false.
		 */
		public function isZero():Boolean {
			return x == 0 && y == 0;
		}
		
		public function set length(value:Number):void {
			var a:Number = angle;
			x = Math.cos(a) * value;
			y = Math.sin(a) * value;
		}
		
		public function get length():Number {
			return Math.sqrt(x * x + y * y);
		}
		
		public function set angle(value:Number):void {
			var len:Number = length;
			x = Math.cos(value) * len;
			y = Math.sin(value) * len;
		}
		
		public function get angle():Number {
			return Math.atan2(y, x);
		}
		
		/**
		 * Calculates the dot product of this vector and another given vector.
		 * @param v2 Another Vector2D instance.
		 * @return Number The dot product of this vector and the one passed in as a parameter.
		 */
		public function dotProd(v2:Vector2D):Number {
			return x * v2.x + y * v2.y;
		}
		
		/**
		 * Calculates the cross product of this vector and another given vector.
		 * @param v2 Another Vector2D instance.
		 * @return Number The cross product of this vector and the one passed in as a parameter.
		 */
		public function crossProd(v2:Vector2D):Number
		{
			return x * v2.y - y * v2.x;
		}
		
		/**
		 * Calculates the angle between two vectors.
		 * @param v1 The first Vector2D instance.
		 * @param v2 The second Vector2D instance.
		 * @return Number the angle between the two given vectors.
		 */
		public static function angleBetween(v1:Vector2D, v2:Vector2D):Number
		{
			//if(!v1.isNormalized()) v1 = v1.clone().normalize();
			//if(!v2.isNormalized()) v2 = v2.clone().normalize();
			//return Math.acos(v1.dotProd(v2));
			return 1;
		}
		
		/**
		 * Determines if a given vector is to the right or left of this vector.
		 * @return int If to the left, returns -1. If to the right, +1.
		 */
		public function sign(v2:Vector2D):int
		{
			return perp.dotProd(v2) < 0 ? -1 : 1;
		}
		
		/**
		 * Finds a vector that is perpendicular to this vector.
		 * @return Vector2D A vector that is perpendicular to this vector.
		 */
		public function get perp():Vector2D
		{
			return new Vector2D(-y, x);
		}
		
		/**
		 * Calculates the distance from this vector to another given vector.
		 * @param v2 A Vector2D instance.
		 * @return Number The distance from this vector to the vector passed as a parameter.
		 */
		public function dist(v2:Vector2D):Number {
			return Math.sqrt(distSQ(v2));
		}
		
		/**
		 * Calculates the distance squared from this vector to another given vector.
		 * @param v2 A Vector2D instance.
		 * @return Number The distance squared from this vector to the vector passed as a parameter.
		 */
		public function distSQ(v2:Vector2D):Number
		{
			var dx:Number = v2.x - x;
			var dy:Number = v2.y - y;
			return dx * dx + dy * dy;
		}
		
	}
}