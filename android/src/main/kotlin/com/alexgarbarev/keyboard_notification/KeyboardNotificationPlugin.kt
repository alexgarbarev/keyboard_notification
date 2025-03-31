package com.alexgarbarev.keyboard_notification

import android.annotation.SuppressLint
import android.app.Activity
import android.content.res.Resources
import android.graphics.Rect
import android.os.Build
import android.util.Log
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
  private var curvePrecision: Float = 0.03f

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "keyboard_notification")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "setCurvePrecision") {
      val value = call.argument<Double>("value")
      if (value != null) {
        curvePrecision = value.toFloat()
        keyboardObserver?.curvePrecision = value.toFloat()
        result.success(true)
      } else {
        result.error("Parse error", "Unable to parse 'value' as Float", null)
      }
    } else {
      result.notImplemented()
    }
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
      keyboardObserver = KeyboardNotificationObserver(view, density, channel, curvePrecision)
      ViewCompat.setWindowInsetsAnimationCallback(view, keyboardObserver)
      view.requestApplyInsets()
      Log.i("KEYBOARD_NOTIFICATION_LOG", "Setup modern listener")

    } else {
      legacyKeyboardObserver = LegacyKeyboardNotificationObserver(view, density, channel)
      view.viewTreeObserver.addOnGlobalLayoutListener(legacyKeyboardObserver)
      Log.i("KEYBOARD_NOTIFICATION_LOG", "Setup legacy listener")
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

    // If visible screen height is less than 85% of screen, then
    // keyboard is opened
    val isVisibleNow = rect.height() / screenHeight.toDouble() < 0.85;
    if (isVisibleNow != isVisible) {
      isVisible = isVisibleNow
      channel.invokeMethod("keyboard_notification_toggle", mapOf("height" to keyboardHeight.toFloat() / density, "visible" to isVisible))
      Log.i("KEYBOARD_NOTIFICATION_LOG", "Sent 'keyboard_notification_toggle'")
    }
  }
}

class KeyboardNotificationObserver(private val view: View, private val density: Float, private val channel: MethodChannel, public var curvePrecision: Float): WindowInsetsAnimationCompat.Callback(DISPATCH_MODE_CONTINUE_ON_SUBTREE) {

  private var lastKeyboardHeight = 0.0f;

  override fun onStart(
    animation: WindowInsetsAnimationCompat,
    bounds: WindowInsetsAnimationCompat.BoundsCompat
  ): WindowInsetsAnimationCompat.BoundsCompat {
    if (animation.typeMask != WindowInsets.Type.ime()) {
      return super.onStart(animation, bounds)
    }

    val isKeyboardVisible = view.rootWindowInsets.isVisible(WindowInsets.Type.ime())
    val keyboardHeight = bounds.upperBound.bottom.toFloat() / density

//    Log.i("KEYBOARD_NOTIFICATION_LOG", "bounds = ${bounds}, = ${view.rootWindowInsets}")

    val interpolator = animation.interpolator

    val precision = curvePrecision
    var points: List<Float>? = null
    if (interpolator != null) {
      points = buildList {
        var i = 0.0f
        while (i <= 1.0f) {
          add(interpolator.getInterpolation(i))
          i += precision
        }
      }
    }

    channel.invokeMethod("keyboard_notification_animation_start", mapOf(
      "height" to keyboardHeight,
      "visible" to isKeyboardVisible,
      "duration" to animation.durationMillis,
      "precision" to precision,
      "curvePoints" to points)
    )
    Log.i("KEYBOARD_NOTIFICATION_LOG", "Sent 'keyboard_notification_animation_start' with height: $keyboardHeight")


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
    Log.i("KEYBOARD_NOTIFICATION_LOG", "Sent 'keyboard_notification_animation_end'")
    super.onEnd(animation)
  }

  override fun onProgress(
    insets: WindowInsetsCompat,
    runningAnimations: MutableList<WindowInsetsAnimationCompat>
  ): WindowInsetsCompat {
    return insets
  }
}
