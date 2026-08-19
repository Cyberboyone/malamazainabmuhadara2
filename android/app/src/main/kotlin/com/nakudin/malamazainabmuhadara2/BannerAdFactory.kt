package com.nakudin.malamazainabmuhadara2

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class BannerAdFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, params: Any?): PlatformView {
        val args = params as? Map<String, Any?> ?: emptyMap()
        return BannerAdView(context, messenger, viewId, args)
    }
}
