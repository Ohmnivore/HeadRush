package {
	/**
	 * Static class that has some of the vector math functions for behaviors.
	 */
	public class VMath {
		/**
		 * Calculates the distance squared from first vector to second vector.
		 * @param	v1	The Vector2D in question
		 * @param	v2	The Vector2D to be added to v1
		 */
		static public function add(v1:Vector2D, v2:Vector2D):void {
			v1.x += v2.x;
			v1.y += v2.y;
		}
		/**
		 * Calculates the distance squared from first vector to second vector.
		 */
		static public function subtract(v1:Vector2D, v2:Vector2D):void {
			v1.x -= v2.x;
			v1.y -= v2.y;
		}
		/**
		 * Multiplies the two vectors by a value, creating a new Vector2D instance to hold the result.
		 * @param v2 		A Vector2D instance.
		 * @param value 	The value to multiply the vector instance by.
		 */
		static public function multiply(v1:Vector2D, value:Number):void {
			v1.x * value;
			v1.y * value;
		}
		
		/**
		 * Divides this vector by a value, creating a new Vector2D instance to hold the result.
		 * @param v2 A Vector2D instance.
		 * @param value 	The value to multiply the vector instance by.
		 */
		static public function divide(v1:Vector2D, value:Number):void {
			v1.x / value;
			v1.y / value;
		}
		/**
		 * Brings the given vector's magnitude down to a 0-1 value so it can be used to constrain other vectors.
		 * @param	v	A Vector2D instance.
		 */
		static public function normalize(v:Vector2D):void {
			var vx:Number = v.x;
			var vy:Number = v.y;
			var len:Number = Math.sqrt((vx * vx) + (vy * vy));
			if (len) {
				v.x /= len;
				v.y /= len;
			}
		}
		/**
		 * Ensures the length of the vector is no longer than the given value.
		 * @param	v	A Vector2D instance to truncate.
		 * @param	max	The maximum value this vector should be. If length is larger than max, it will be truncated to this value.
		 */
		static public function truncate(v:Vector2D, max:Number):void {
			var vx:Number = v.x;
			var vy:Number = v.y;
			var cl:Number = Math.sqrt((vx * vx) + (vy * vy));
			var nl:Number = Math.min(max, cl);
			var a:Number = Math.atan2(vy, vx);
			v.x = Math.cos(a) * nl;
			v.y = Math.sin(a) * nl;
		}
		
		static public function reverse(v:Vector2D):void {
			v.x = -v.x;
			v.y = -v.y;
		}
		
	} // end class
}