import 'dart:math';

import 'package:flutter/material.dart';

int generateRandomInt32() {
  Random random = Random();
  int min = 0;
  int max = 2147483647;
  return min + random.nextInt(max - min + 1);
}

DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
}