
class EmbeddedAssets
{
    /** ATTENTION: Naming conventions!
     *
     *  - Classes for embedded IMAGES should have the exact same name as the file,
     *    without extension. This is required so that references from XMLs (atlas, bitmap font)
     *    won't break.
     *
     *  - Atlas and font XML files can have an arbitrary name, since they are never
     *    referenced by file name.
     *
     */
    
    // Texture Atlas
    
    @:meta(Embed(source="../assets/textures/1x/atlas.xml",mimeType="application/octet-stream"))

    public static var atlas_xml : Class<Dynamic>;
    
    @:meta(Embed(source="../assets/textures/1x/atlas.png"))

    public static var atlas : Class<Dynamic>;
    
    // Bitmap Fonts
    
    @:meta(Embed(source="../assets/fonts/1x/bradybunch.fnt",mimeType="application/octet-stream"))

    public static var bradybunch_fnt : Class<Dynamic>;
    
    @:meta(Embed(source="../assets/fonts/1x/bradybunch.png"))

    public static var bradybunch : Class<Dynamic>;
    
    // Sounds
    
    @:meta(Embed(source="../assets/sounds/flap.mp3"))

    public static var flap : Class<Dynamic>;
    
    @:meta(Embed(source="../assets/sounds/pass.mp3"))

    public static var pass : Class<Dynamic>;
    
    @:meta(Embed(source="../assets/sounds/crash.mp3"))

    public static var crash : Class<Dynamic>;

    public function new()
    {
    }
}

