extension DateFormatting on DateTime {
  DateTime toMidnightDate() {
    return toLocal().subtract(
      Duration(
        hours: hour,
        minutes: minute,
        seconds: second,
        milliseconds: millisecond,
        microseconds: microsecond,
      ),
    );
  }
}
