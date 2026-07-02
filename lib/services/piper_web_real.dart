import 'dart:js_util' as js_util;

Future<bool> speakPiperInBrowser(String text) async {
  try {
    if (js_util.hasProperty(js_util.globalThis, 'piperSpeakWeb')) {
      final promise = js_util.callMethod(js_util.globalThis, 'piperSpeakWeb', [text]);
      final result = await js_util.promiseToFuture(promise);
      return result == true;
    }
  } catch (e) {
    // ignore
  }
  return false;
}
