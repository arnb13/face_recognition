import 'package:intl/intl.dart';

class DateTimeHelper {
  static String getFormattedDate(int time) {
    DateFormat newFormat = DateFormat("yyyy-MM-dd");
    return newFormat.format(DateTime.fromMillisecondsSinceEpoch(time));
  }

  static String getFormattedDateTime(int time) {
    DateFormat newFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    return newFormat.format(DateTime.fromMillisecondsSinceEpoch(time));
  }

  static String formatDate(String inputDate) {
    DateTime dateTime = DateTime.parse(inputDate);
    return DateFormat('dd-MMM').format(dateTime);
  }

  static String formatYear(String inputDate) {
    DateTime dateTime = DateTime.parse(inputDate);
    return DateFormat('MMM-yy').format(dateTime);
  }
}
