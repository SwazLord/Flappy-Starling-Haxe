import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class Obstacle extends Sprite
{
    public var passed(get, set) : Bool;

    private var _passed : Bool;
    
    private var _radius : Float;
    private var _gapHeight : Float;
    
    public function new(gapHeight : Float)
    {
        super();
        var topTexture : Texture = Game.assets.getTexture("obstacle-top");
        var bottomTexture : Texture = Game.assets.getTexture("obstacle-bottom");
        
        _radius = topTexture.width / 2;
        _gapHeight = gapHeight;
        
        var top : Image = new Image(topTexture);
        top.pixelSnapping = true;
        top.pivotX = _radius;
        top.pivotY = topTexture.height - _radius;
        top.y = gapHeight / -2;
        
        var bottom : Image = new Image(bottomTexture);
        bottom.pixelSnapping = true;
        bottom.pivotX = _radius;
        bottom.pivotY = _radius;
        bottom.y = gapHeight / 2;
        
        addChild(top);
        addChild(bottom);
    }
    
    public function collidesWithBird(birdX : Float, birdY : Float, birdRadius : Float) : Bool
    // check if bird is completely left or right of the obstacle
    {
        
        if (birdX + birdRadius < x - _radius || birdX - birdRadius > x + _radius)
        {
            return false;
        }
        
        var bottomY : Float = y + _gapHeight / 2;
        var topY : Float = y - _gapHeight / 2;
        
        // check if bird is within gap
        if (birdY < topY || birdY > bottomY)
        {
            return true;
        }
        
        // check for collision with circular end pieces
        var distX : Float = x - birdX;
        var distY : Float;
        
        // top trunk
        distY = topY - birdY;
        if (Math.sqrt(distX * distX + distY * distY) < _radius + birdRadius)
        {
            return true;
        }
        
        // bottom trunk
        distY = bottomY - birdY;
        if (Math.sqrt(distX * distX + distY * distY) < _radius + birdRadius)
        {
            return true;
        }
        
        // bird flies through in-between the circles
        return false;
    }
    
    private function get_passed() : Bool
    {
        return _passed;
    }
    private function set_passed(value : Bool) : Bool
    {
        _passed = value;
        return value;
    }
}

