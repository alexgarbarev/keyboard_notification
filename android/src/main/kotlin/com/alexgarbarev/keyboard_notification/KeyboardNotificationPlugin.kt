package com.alexgarbarev.keyboard_notification

import android.annotation.SuppressLint
import android.app.Activity
import android.content.res.Resources
import android.graphics.Rect
import android.os.Build
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import android.view.WindowInsets
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsAnimationCompat
import androidx.core.view.WindowInsetsCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** KeyboardNotificationPlugin */
class KeyboardNotificationPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  private lateinit var view: View
  private var legacyKeyboardObserver: LegacyKeyboardNotificationObserver? = null
  private var keyboardObserver: KeyboardNotificationObserver? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "keyboard_notification")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    result.notImplemented()
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    setupView(binding.activity)
    setupListener()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    disposeListener()
    setupView(binding.activity)
    setupListener()
  }

  override fun onDetachedFromActivityForConfigChanges() {
    disposeListener()
  }

  override fun onDetachedFromActivity() {
    disposeListener()
  }

  private fun setupView(activity: Activity) {
    view = activity.findViewById<ViewGroup>(android.R.id.content)
  }

  @SuppressLint("ObsoleteSdkInt")
  private fun setupListener() {
    val density = Resources.getSystem().displayMetrics.density;
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
      keyboardObserver = KeyboardNotificationObserver(view, density, channel)
      ViewCompat.setWindowInsetsAnimationCallback(view, keyboardObserver)
      view.requestApplyInsets()
    } else {
      legacyKeyboardObserver = LegacyKeyboardNotificationObserver(view, density, channel)
      view.viewTreeObserver.addOnGlobalLayoutListener(legacyKeyboardObserver)
    }
  }

  private fun disposeListener() {
    if (legacyKeyboardObserver != null) {
      view.viewTreeObserver.removeOnGlobalLayoutListener(legacyKeyboardObserver)
    } else {
      ViewCompat.setWindowInsetsAnimationCallback(view, null)
    }
    legacyKeyboardObserver = null
    keyboardObserver = null
  }


}

class LegacyKeyboardNotificationObserver(private val view: View, private val density: Float, private val channel: MethodChannel): ViewTreeObserver.OnGlobalLayoutListener {
  private var isVisible = false

  override fun onGlobalLayout() {
    val rect = Rect()
    view.getWindowVisibleDisplayFrame(rect)
    val screenHeight = view.rootView.height

    val keyboardHeight = screenHeight - rect.bottom

    val isVisibleNow = rect.height() / screenHeight.toDouble() < 0.85;
    if (isVisibleNow != isVisible) {
      isVisible = isVisibleNow
      channel.invokeMethod("keyboard_notification_toggle", mapOf(
        "height" to keyboardHeight.toFloat() / density,
        "visible" to isVisible)
      )
    }
  }
}

class KeyboardNotificationObserver(private val view: View, private val density: Float, private val channel: MethodChannel): WindowInsetsAnimationCompat.Callback(DISPATCH_MODE_CONTINUE_ON_SUBTREE) {

  private var lastKeyboardHeight = 0.0f;

  override fun onStart(
    animation: WindowInsetsAnimationCompat,
    bounds: WindowInsetsAnimationCompat.BoundsCompat
  ): WindowInsetsAnimationCompat.BoundsCompat {
    if (animation.typeMask != WindowInsets.Type.ime()) {
      return super.onStart(animation, bounds)
    }

    val bottomBars = view.rootWindowInsets.getInsets(WindowInsets.Type.systemBars()).bottom

    val isKeyboardVisible = view.rootWindowInsets.isVisible(WindowInsets.Type.ime())
    val keyboardHeight = (bounds.upperBound.bottom.toFloat() - bottomBars) / density


    channel.invokeMethod("keyboard_notification_animation_start", mapOf(
      "height" to keyboardHeight,
      "visible" to isKeyboardVisible)
    )
    lastKeyboardHeight = keyboardHeight

    return super.onStart(animation, bounds)
  }

  override fun onEnd(animation: WindowInsetsAnimationCompat) {
    if (animation.typeMask != WindowInsets.Type.ime()) {
      super.onEnd(animation)
      return
    }
    val isKeyboardVisible = view.rootWindowInsets.isVisible(WindowInsets.Type.ime())
    channel.invokeMethod("keyboard_notification_animation_end", mapOf(
      "height" to lastKeyboardHeight,
      "visible" to isKeyboardVisible)
    )
    super.onEnd(animation)
  }

  override fun onProgress(
    insets: WindowInsetsCompat,
    runningAnimations: MutableList<WindowInsetsAnimationCompat>
  ): WindowInsetsCompat {
    return insets
  }
}
