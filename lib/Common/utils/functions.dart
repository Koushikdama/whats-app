import 'package:intl/intl.dart';

String getDate(dynamic date) {
  String mDY = "";
  if (date.runtimeType == String) {
    DateTime dateTime = DateTime.parse(date);

    // Format the DateTime to "MMM dd yy"
    mDY = DateFormat('MMM dd yy').format(dateTime);
  } else {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(date);

    // Format the DateTime to a human-readable format
    mDY = DateFormat('MMM dd yy').format(dateTime);
  }
  return mDY;
}

String convertTimestampToDateString(dynamic timestamp) {
  // Convert milliseconds to DateTime
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

  // Format the date into YYYY_MM_DD
  String formattedDate =
      "${dateTime.year}_${dateTime.month.toString().padLeft(2, '0')}_${dateTime.day.toString().padLeft(2, '0')}";

  return formattedDate;
}
