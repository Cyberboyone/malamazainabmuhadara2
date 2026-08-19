package com.nakudin.malamazainabmuhadara2

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView

class BannerAdView(context: Context, messenger: BinaryMessenger, id: Int, params: Map<String, Any?>) : PlatformView {

    private val container = FrameLayout(context)

    init {
        val adView = AdView(context)
        adView.adUnitId = "ca-app-pub-9529770421530115/9868251691"
        adView.setAdSize(AdSize.BANNER)
        container.addView(adView)
        adView.loadAd(AdRequest.Builder().build())
    }

    override fun getView(): View = container

    override fun dispose() {
        val adView = container.getChildAt(0) as? AdView
        adView?.destroy()
    }
}
