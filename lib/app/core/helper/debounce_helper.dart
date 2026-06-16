import 'package:easy_debounce/easy_debounce.dart';

class DebounceHelper {
  static const String searchTextTag = "support_search_debounce";
  static const String buttonTag = "booking_search_debounce";

  debounce({tag, onMethod, time = 500}) {
    EasyDebounce.debounce(tag, Duration(milliseconds: time), () => onMethod());
  }

  killDebounce({tag}) {
    EasyDebounce.cancel(tag);
  }

  killAllDebounce() {
    EasyDebounce.cancelAll();
  }
}
