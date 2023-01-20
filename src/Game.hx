import openfl.net.SharedObject;
import starling.assets.AssetManager;
import starling.core.Starling;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.BitmapFont;
import starling.text.TextField;
import starling.text.TextFormat;
import starling.utils.Align;
import starling.utils.Color;

class Game extends Sprite {
	private var score(get, set):Int;
	private var topScore(get, set):Int;

	public static var assets(get, never):AssetManager;

	private static var sAssets:AssetManager;
	private static var sDefaultTextFormat:TextFormat = new TextFormat("bradybunch", BitmapFont.NATIVE_SIZE, Color.WHITE);

	private var _world:World;
	private var _score:Int;
	private var _scoreLabel:TextField;
	private var _title:TitleOverlay;
	private var _sharedObject:SharedObject;

	public function new() {
		super();
		_sharedObject = SharedObject.getLocal("flappy-data");
	}

	public function start(assets:AssetManager):Void {
		trace("start game!");
		sAssets = assets;

		_world = new World(stage.stageWidth, stage.stageHeight);
		_world.addEventListener(World.BIRD_CRASHED, onBirdCollided);
		_world.addEventListener(World.OBSTACLE_PASSED, onObstaclePassed);
		addChild(_world);

		_scoreLabel = new TextField(100, 80, "", sDefaultTextFormat);
		_scoreLabel.visible = false;
		addChild(_scoreLabel);

		_title = new TitleOverlay(stage.stageWidth, stage.stageHeight);
		addChild(_title);

		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		stage.addEventListener(TouchEvent.TOUCH, onTouch);

		showTitle();
	}

	private function restart():Void {
		_scoreLabel.visible = false;
		_world.reset();
		showTitle();
	}

	private function showTitle():Void {
		_title.alpha = 0;
		_title.topScore = topScore;

		Starling.currentJuggler.tween(_title, 1.0, {
			alpha: 1.0
		});
	}

	private function hideTitle():Void {
		Starling.currentJuggler.removeTweens(_title);
		Starling.currentJuggler.tween(_title, 0.5, {
			alpha: 0.0
		});
	}

	private function onEnterFrame(event:Event, passedTime:Float):Void {
		_world.advanceTime(passedTime);
	}

	private function onBirdCollided():Void {
		if (_score > topScore) {
			topScore = _score;
		}

		Starling.currentJuggler.delayCall(restart, 1.5);
		assets.playSound("crash");
	}

	private function onObstaclePassed():Void {
		this.score += 1;
		assets.playSound("pass");
	}

	private function onTouch(event:TouchEvent):Void {
		var touch:Touch = event.getTouch(stage, TouchPhase.BEGAN);
		if (touch != null) {
			if (_world.phase == World.PHASE_IDLE) {
				hideTitle();
				this.score = 0;
				_scoreLabel.visible = true;
				_world.start();
			}

			if (_world.phase == World.PHASE_PLAYING) {
				_world.flapBird();
				assets.playSound("flap");
			}
		}
	}

	private function get_score():Int {
		return _score;
	}

	private function set_score(value:Int):Int {
		_score = value;
		_scoreLabel.text = Std.string(value);
		return value;
	}

	private function get_topScore():Int {
		// return (_sharedObject.data["topScore"]);
		if (_sharedObject.data.topScore == null) {
			return 0;
		}

		return Std.int(_sharedObject.data.topScore);
	}

	private function set_topScore(value:Int):Int {
		// _sharedObject.data["topScore"] = value;
		_sharedObject.setProperty("topScore", value);
		return value;
	}

	private static function get_assets():AssetManager {
		return sAssets;
	}
}
