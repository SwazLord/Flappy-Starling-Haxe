// =================================================================================================
//
//	Starling Framework
//	Copyright Gamua GmbH. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================
package utils;

import openfl.system.Capabilities;
import openfl.geom.Rectangle;

class ScreenSetup {
	public var stageWidth(get, never):Float;
	public var stageHeight(get, never):Float;
	public var viewPort(get, never):Rectangle;
	public var scale(get, never):Float;
	public var assetScale(get, never):Float;

	private var _stageWidth:Float;
	private var _stageHeight:Float;
	private var _viewPort:Rectangle;
	private var _scale:Float;
	private var _assetScale:Float;

	public function new(fullScreenWidth:UInt, fullScreenHeight:UInt, assetScales:Array<UInt> = null, screenDPI:Float = -1) {
		if (screenDPI <= 0) {
			screenDPI = Capabilities.screenDPI;
		}
		if (assetScales == null || assetScales.length == 0) {
			assetScales = [1];
		}

		var iPad:Bool = Capabilities.os.indexOf("iPad") != -1;
		var baseDPI:Float = (iPad) ? 130 : 160;
		var exactScale:Float = screenDPI / baseDPI;

		if (exactScale < 1.25) {
			_scale = 1.0;
		} else if (exactScale < 1.75) {
			_scale = 1.5;
		} else {
			_scale = Math.round(exactScale);
		}

		_stageWidth = Std.int(fullScreenWidth / _scale);
		_stageHeight = Std.int(fullScreenHeight / _scale);

		// assetScales.sort(Array.NUMERIC | Array.DESCENDING);
		assetScales.sort((a, b) -> b - a);
		trace("assetScales = ", assetScales);
		_assetScale = assetScales[0];

		for (i in 0...assetScales.length) {
			if (assetScales[i] >= _scale) {
				_assetScale = assetScales[i];
			}
		}

		_viewPort = new Rectangle(0, 0, _stageWidth * _scale, _stageHeight * _scale);
	}

	/** The recommended stage width in points. */
	private function get_stageWidth():Float {
		return _stageWidth;
	}

	/** The recommended stage height in points. */
	private function get_stageHeight():Float {
		return _stageHeight;
	}

	/** The recommended viewPort rectangle. */
	private function get_viewPort():Rectangle {
		return _viewPort;
	}

	/** The scale factor resulting from the recommended viewPort and stage sizes. */
	private function get_scale():Float {
		return _scale;
	}

	/** From the available sets of assets, those with this scale factor will look best. */
	private function get_assetScale():Float {
		return _assetScale;
	}
}
