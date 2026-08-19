package com.nakudin.malamazainabmuhadara2

import android.util.Log
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.RequestConfiguration
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : AudioServiceActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("zainab2_banner_ad", BannerAdFactory(flutterEngine.dartExecutor.binaryMessenger))

        MobileAds.setRequestConfiguration(
            RequestConfiguration.Builder()
                .setTestDeviceIds(listOf())
                .build()
        )

        MobileAds.initialize(this) { Log.d("ZainabAds", "AdMob initialized") }
    }
}
