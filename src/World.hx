import openfl.Vector;
import openfl.geom.Rectangle;
import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.textures.Texture;

class World extends Sprite {
	public var phase(get, never):String;

	private static inline var SCROLL_VELOCITY:Float = 130;
	private static var FLAP_VELOCITY:Float = -300;
	private static inline var GRAVITY:Float = 800;
	private static inline var BIRD_RADIUS:Float = 18;
	private static inline var OBSTACLE_DISTANCE:Float = 180;
	private static inline var OBSTACLE_GAP_HEIGHT:Float = 170;
	private static inline var OBSTACLE_Y_RANGE:Float = 270;

	public static inline var BIRD_CRASHED:String = "birdCrashed";
	public static inline var OBSTACLE_PASSED:String = "obstaclePassed";

	public static inline var PHASE_IDLE:String = "phaseIdle";
	public static inline var PHASE_PLAYING:String = "phasePlaying";
	public static inline var PHASE_CRASHED:String = "phaseCrashed";

	private var _phase:String;
	private var _width:Float;
	private var _height:Float;
	private var _ground:Image;
	private var _obstacles:Sprite;
	private var _bird:MovieClip;
	private var _birdVelocity:Float = 0.0;

	private var _currentX:Float;
	private var _lastObstacleX:Float;

	public function new(width:Float, height:Float) {
		super();
		_phase = PHASE_IDLE;
		_width = width;
		_height = height;

		addBackground();
		addObstacleSprite();
		addGround();
		addBird();
	}

	// setup methods

	private function addBackground():Void {
		var sky:Image = new Image(Game.assets.getTexture("sky"));
		sky.y = _height - sky.height;
		addChild(sky);

		var cloud1:Image = new Image(Game.assets.getTexture("cloud-1"));
		cloud1.x = _width * 0.5;
		cloud1.y = _height * 0.1;
		addChild(cloud1);

		var cloud2:Image = new Image(Game.assets.getTexture("cloud-2"));
		cloud2.x = _width * 0.1;
		cloud2.y = _height * 0.2;
		addChild(cloud2);
	}

	private function addBird():Void {
		var birdTextures:Vector<Texture> = Game.assets.getTextures("bird-");
		birdTextures.push(birdTextures[1]);

		_bird = new MovieClip(birdTextures);
		_bird.pivotX = 46;
		_bird.pivotY = 45;
		_bird.pixelSnapping = true;

		addChild(_bird);
		resetBird();
	}

	private function addGround():Void {
		_ground = new Image(Game.assets.getTexture("ground"));
		_ground.y = _height - _ground.height;
		_ground.width = _width;
		_ground.tileGrid = new Rectangle(0, 0, _ground.width, _ground.height);
		addChild(_ground);
	}

	private function addObstacleSprite():Void {
		_obstacles = new Sprite();
		addChild(_obstacles);
	}

	private function addObstacle():Void // On a very "high" screen, we don't want the gaps to spread to far from each other
	{
		// (which would make the game really hard), so we limit the range of y-coordinates.

		var yRange:Int = Std.int(Math.min(OBSTACLE_Y_RANGE, _ground.y - OBSTACLE_GAP_HEIGHT));
		var minY:Float = (_ground.y - yRange) / 2;
		var maxY:Float = _ground.y - minY;
		var obstacle:Obstacle = new Obstacle(OBSTACLE_GAP_HEIGHT);
		obstacle.y = minY + Math.random() * (maxY - minY);
		obstacle.x = _width + obstacle.width / 2;
		_obstacles.addChild(obstacle);
	}

	// game control

	public function start():Void {
		_phase = PHASE_PLAYING;
		_currentX = _lastObstacleX = 0;
	}

	public function reset():Void {
		_phase = PHASE_IDLE;
		_obstacles.removeChildren(0, -1, true);
		resetBird();
	}

	// helper methods

	private function resetBird():Void {
		_bird.x = _width / 3;
		_bird.y = _height / 2;
	}

	private function checkForCollisions():Void {
		var bottom:Float = _ground.y - BIRD_RADIUS;
		var collision:Bool = false;

		if (_bird.y > bottom) {
			_bird.y = bottom;
			_birdVelocity = 0;
			collision = true;
		} else {
			for (i in 0..._obstacles.numChildren) {
				var obstacle:Obstacle = try cast(_obstacles.getChildAt(i), Obstacle) catch (e:Dynamic) null;

				if (!obstacle.passed && _bird.x > obstacle.x) {
					obstacle.passed = true;
					dispatchEventWith(OBSTACLE_PASSED, true);
				}

				if (obstacle.collidesWithBird(_bird.x, _bird.y, BIRD_RADIUS)) {
					collision = true;
					break;
				}
			}
		}

		if (collision) {
			_phase = PHASE_CRASHED;
			dispatchEventWith(BIRD_CRASHED);
		}
	}

	public function flapBird():Void {
		_birdVelocity = FLAP_VELOCITY;
	}

	// time-related methods

	public function advanceTime(passedTime:Float):Void {
		if (_phase == PHASE_IDLE || _phase == PHASE_PLAYING) {
			_bird.advanceTime(passedTime);
			advanceGround(passedTime);
		}

		if (_phase == PHASE_PLAYING) {
			_currentX += SCROLL_VELOCITY * passedTime;
			advanceObstacles(passedTime);
			advancePhysics(passedTime);
			checkForCollisions();
		}
	}

	private function advanceGround(passedTime:Float):Void {
		var distance:Float = SCROLL_VELOCITY * passedTime;

		_ground.tileGrid.x -= distance;
		_ground.tileGrid = _ground.tileGrid;
	}

	private function advancePhysics(passedTime:Float):Void {
		_bird.y += _birdVelocity * passedTime;
		_birdVelocity += GRAVITY * passedTime;
	}

	private function advanceObstacles(passedTime:Float):Void {
		if (_currentX >= _lastObstacleX + OBSTACLE_DISTANCE) {
			_lastObstacleX = _currentX;
			addObstacle();
		}

		var obstacle:Obstacle;
		var numObstacles:Int = _obstacles.numChildren;
		var i:Int = 0;
		while (i < numObstacles) {
			// obstacle = try cast(_obstacles.getChildAt(i), Obstacle) catch (e:Dynamic) null;

			obstacle = cast(_obstacles.getChildAt(i), Obstacle);

			if (obstacle.x < -obstacle.width) {
				i--;
				numObstacles--;
				obstacle.removeFromParent(true);
			} else {
				obstacle.x -= passedTime * SCROLL_VELOCITY;
			}

			i++;
		}
	}

	// properties

	private function get_phase():String {
		return _phase;
	}
}
