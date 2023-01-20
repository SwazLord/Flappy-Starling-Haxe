import starling.display.Image;
import starling.display.Sprite;
import starling.text.BitmapFont;
import starling.text.TextField;
import starling.utils.Color;

class TitleOverlay extends Sprite {
	public var topScore(get, set):Int;

	private var _topScoreLabel:TextField;
	private var _topScore:Int;

	public function new(width:Int, height:Int) {
		super();
		var title:TextField = new TextField(width, 200, "Flappy\nStarling");
		title.format.setTo("bradybunch", BitmapFont.NATIVE_SIZE, Color.WHITE);
		title.format.leading = -20;

		var tapIndicator:Image = new Image(Game.assets.getTexture("tap-indicator"));
		tapIndicator.x = width / 2;
		tapIndicator.y = (height - tapIndicator.height) / 2;

		_topScoreLabel = new TextField(width, 50, "");
		_topScoreLabel.format.setTo(BitmapFont.MINI, BitmapFont.NATIVE_SIZE * 2);
		_topScoreLabel.y = height * 0.80;

		addChild(title);
		addChild(tapIndicator);
		addChild(_topScoreLabel);
	}

	private function get_topScore():Int {
		return _topScore;
	}

	private function set_topScore(value:Int):Int {
		_topScore = value;
		_topScoreLabel.text = "Current Record: " + value;
		return value;
	}
}
