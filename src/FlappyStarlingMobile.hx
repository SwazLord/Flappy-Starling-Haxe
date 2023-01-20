import openfl.display.StageAlign;
import starling.display.Stage;
import openfl.display.StageScaleMode;
import starling.utils.Max;
import openfl.errors.Error;
import openfl.geom.Rectangle;
import starling.utils.RectangleUtil;
import starling.utils.StringUtil;
import utils.ScreenSetup;
import openfl.system.Capabilities;
import openfl.Assets;
import openfl.display.Sprite;
import starling.assets.AssetManager;
import starling.core.Starling;
import starling.events.Event;
#if air
import flash.desktop.NativeApplication;
#end

class FlappyStarlingMobile extends Sprite {
	private var _starling:Starling;
	private var _assets:AssetManager;

	public function new() {
		super();

		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	private function onAddedToStage(event:Dynamic):Void {
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

		start();
	}

	private function start():Void {
		trace("stage.fullScreenWidth = " + stage.fullScreenWidth + " stage.fullScreenHeight = " + stage.fullScreenHeight);
		var screen:ScreenSetup = new ScreenSetup(stage.fullScreenWidth, stage.fullScreenHeight, [1, 2, 3]);
		_starling = new Starling(Game, stage, screen.viewPort);
		_starling.stage.stageWidth = Std.int(screen.stageWidth);
		_starling.stage.stageHeight = Std.int(screen.stageHeight);
		_starling.addEventListener(Event.ROOT_CREATED, function():Void {
			trace("screen.assetScale = ", screen.assetScale);
			loadAssets(screen.assetScale, startGame);
		});
		this.stage.addEventListener(Event.RESIZE, onResize, false, Max.INT_MAX_VALUE, true);
		_starling.start();

		#if air
		NativeApplication.nativeApplication.addEventListener(flash.events.Event.ACTIVATE, function(e:Dynamic):Void {
			_starling.start();
		});
		NativeApplication.nativeApplication.addEventListener(flash.events.Event.DEACTIVATE, function(e:Dynamic):Void {
			_starling.stop(true);
		});
		#end
	}

	private function loadAssets(scale:Float, onComplete:Void->Void):Void {
		trace(StringUtil.format("assets/textures/{0}x/atlas.png", [scale]));
		_assets = new AssetManager(scale);
		_assets.verbose = Capabilities.isDebugger;
		_assets.enqueue([
			Assets.getPath(StringUtil.format("assets/textures/{0}x/atlas.png", [scale])),
			Assets.getPath(StringUtil.format("assets/textures/{0}x/atlas.xml", [scale])),
			Assets.getPath(StringUtil.format("assets/fonts/{0}x/bradybunch.png", [scale])),
			Assets.getPath(StringUtil.format("assets/fonts/{0}x/bradybunch.fnt", [scale])),
			Assets.getPath("assets/sounds/crash.mp3"),
			Assets.getPath("assets/sounds/flap.mp3"),
			Assets.getPath("assets/sounds/pass.mp3")
		]);
		_assets.loadQueue(onComplete);
	}

	private function startGame():Void {
		var game:Game = cast(_starling.root, Game);
		trace("Assets Done Loading");
		game.start(_assets);
	}

	private function onResize(e:openfl.events.Event):Void {
		var viewPort:Rectangle = RectangleUtil.fit(new Rectangle(0, 0, Constants.GameWidth, Constants.GameHeight),
			new Rectangle(0, 0, stage.stageWidth, stage.stageHeight));
		try {
			this._starling.viewPort = viewPort;
		} catch (error:Error) {}
	}
}
