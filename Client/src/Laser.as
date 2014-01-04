package 
{
	import flash.geom.Point;
    import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;

    public class Laser extends FlxSprite
    {
		public var state:PlayState;
		public var startingp:FlxPoint = new FlxPoint(0,0);
		public var heading:FlxPoint = new FlxPoint(0,0);
		public var endpoint:FlxPoint = new FlxPoint(0,0);
		public var endpoint_t:FlxPoint = new FlxPoint(0, 0);
		public var firstendpoint:FlxPoint = new FlxPoint(0, 0);
		public var lastintersect:FlxPoint = new FlxPoint(0, 0);
		public var dist:Number;
		public var emitter:FlxEmitter;
		
        public function Laser(Origin:FlxPoint, Heading:FlxPoint, State:PlayState):void
        {
			startingp = Origin;
			state = State;
			endpoint = new FlxPoint(startingp.x, startingp.y);
			heading = new FlxPoint(0,0);
			heading.x =  Heading.x - startingp.x;
			heading.y =  Heading.y - startingp.y;
			
			state.map.rayCast(startingp, heading, endpoint);
			
			super(startingp.x, startingp.y);
			//height = Math.abs(startingp.y - endpoint.y);
			//width = Math.abs(startingp.x - endpoint.x);
			x = startingp.x;
			y = startingp.y;
			
			var target:FlxPoint = endpoint;
			var startPoint:FlxPoint = startingp;
			
			var tempWidth:int = Math.abs(this.x - target.x);
			var tempHeight:int = Math.abs(this.y - target.y);
			this.makeGraphic(tempWidth, tempHeight, 0x00000000);
			this.x = Math.min(this.x, target.x);
			this.y = Math.min(this.y, target.y);
	
			this.drawLine(startPoint.x < target.x ? 0 : tempWidth, 
			startPoint.y < target.y ? 0 : tempHeight, 
			startPoint.x > target.x ? 0 : tempWidth,
			startPoint.y > target.y ? 0 : tempHeight, 0xffff0000, 1);
			//makeGraphic(Math.abs(startingp.x-endpoint.x), Math.abs(startingp.y-endpoint.y), 0x00000000);
			//drawLine(0, 0, endpoint.x-startingp.x, endpoint.y-startingp.y, 0xffff0000, 1);
			//x = startingp.x;
			//y = startingp.y;
			
			//firstendpoint = endpoint.;
			firstendpoint.copyFrom(endpoint);
			dist = PtoPdist2(firstendpoint, startingp);
			
			
			var deg_to_rad=0.0174532925;
			var emittervect:Vector2D = new Vector2D(startingp.x - endpoint.x, startingp.y - endpoint.y);
			VMath.normalize(emittervect);
			
			
			emitter = new FlxEmitter(0, 0);
			state.emitters.add(emitter);
			
			var particles:int = 20;
			
			for(var i:int = 0; i < particles; i++)
			{
				var particle:FlxParticle = new FlxParticle();
				particle.makeGraphic(2, 2, 0xffff0000);
				particle.exists = false;
				emitter.add(particle);
			}
			
			//emitter.setRotation(-10, 10);
			emitter.setXSpeed(emittervect.x*10,emittervect.x*10);
			emitter.setYSpeed(emittervect.y*10, emittervect.y*10);
			//emitter.setXSpeed(-30,30);
			//emitter.setYSpeed(-40,-50);
			emitter.setSize(0, 0);
			emitter.start(false,0.25,0.1);
        }
		
		public override function update():void
        {
			var found:Boolean = false;
			var bigarray:Array = new Array();
			
			for each (var p:OutPlatform in state.platforms.members)
			{
				var intersect:Array = rayBoxIntersect2(startingp, firstendpoint, new Point(p.x, p.y), new Point(p.x + p.width, p.y + p.height));
				
				if (intersect.length > 0)
				{
					found = true;
					
					for each (var fp:FlxPoint in intersect)
					{
						bigarray.push(fp);
					}
				}
			}
			
			if (found && (endpoint.x!=lastintersect.x || endpoint.y!=lastintersect.y))
			{
				var tempdist:Number = dist;
				var closestintersect:FlxPoint = new FlxPoint(0,0);
				
				for each (var fp:FlxPoint in bigarray)
				{
					var distcontainer:Number = PtoPdist2(startingp, fp);
					if (distcontainer < tempdist)
					{
						tempdist = distcontainer;
						closestintersect = fp;
					}
				}
				fill(0x00000000);
				//drawLine(startingp.x, startingp.y, closestintersect.x, closestintersect.y, 0xffff0000, 1);
				this.drawLine(startingp.x < closestintersect.x ? 0 : closestintersect.x-x, 
				startingp.y < closestintersect.y ? 0 : closestintersect.y-y, 
				startingp.x > closestintersect.x ? 0 : closestintersect.x-x,
				startingp.y > closestintersect.y ? 0 : closestintersect.y-y, 0xffff0000, 1);
				endpoint.copyFrom(closestintersect);
				lastintersect.copyFrom(closestintersect);
			}
			
			if (!found && (endpoint.x != firstendpoint.x || endpoint.y != firstendpoint.y))
			{
				fill(0x00000000);
				//drawLine(startingp.x, startingp.y, firstendpoint.x, firstendpoint.y, 0xffff0000, 1);
				this.drawLine(startingp.x < firstendpoint.x ? 0 : width, 
				startingp.y < firstendpoint.y ? 0 : height, 
				startingp.x > firstendpoint.x ? 0 : width,
				startingp.y > firstendpoint.y ? 0 : height, 0xffff0000, 1);
				endpoint.copyFrom(firstendpoint);
			}
			
			emitter.x = endpoint.x;
			emitter.y = endpoint.y;
			super.update();
        }
		
		public static function rayBoxIntersect2(r1, r2, box1, box2):Array {
			
			var arr:Array = [];
			var intersection:FlxPoint;
							
			intersection = rayRayIntersect(r1, r2, box1, new FlxPoint(box2.x, box1.y));
			if (intersection) arr.push(intersection);
			
			intersection = rayRayIntersect(r1, r2, box1, new FlxPoint(box1.x, box2.y));
			if (intersection) arr.push(intersection);
			
			intersection = rayRayIntersect(r1, r2, box2, new FlxPoint(box2.x, box1.y));
			if (intersection) arr.push(intersection);
			
			intersection = rayRayIntersect(r1, r2, box2, new FlxPoint(box1.x, box2.y));
			if (intersection) arr.push(intersection);
			
			return arr;
		}
		
		public static function rayRayIntersect(p1, p2, p3, p4):FlxPoint {

			var denom:Number = ((p4.y - p3.y)*(p2.x - p1.x)) - ((p4.x - p3.x)*(p2.y - p1.y));
			var nume_a:Number = ((p4.x - p3.x)*(p1.y - p3.y)) - ((p4.y - p3.y)*(p1.x - p3.x));
			var nume_b:Number = ((p2.x - p1.x)*(p1.y - p3.y)) - ((p2.y - p1.y)*(p1.x - p3.x));
	
			if(denom == 0.0) {
				if(nume_a == 0.0 && nume_b == 0.0) {
					return null; //COINCIDENT;
				}
				return null; //PARALLEL;
			}
	
			var ua:Number = nume_a / denom;
			var ub:Number = nume_b / denom;
	
			if(ua >= 0.0 && ua <= 1.0 && ub >= 0.0 && ub <= 1.0) {	//INTERSECTING
				// Get the intersection point.
				return new FlxPoint(p1.x + ua*(p2.x - p1.x), p1.y + ua*(p2.y - p1.y));
			}
			
			return null;
		}
		
		static public function PtoPdist2(p1:FlxPoint, p2:FlxPoint):Number
		{
			return ((p2.x - p1.x) * (p2.x - p1.x) + (p2.y - p1.y) * (p2.y - p1.y));
		}
    }
}