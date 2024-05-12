import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moodeatsai/constants/constants.dart';

class DateOfReminder {
  static void openDatePicker(BuildContext context,
      {TextEditingController? ageController,
      ValueNotifier<DateTime>? timeNotifier}) {
    BottomPicker.date(
      backgroundColor: AppColors.backgroundColor,
      pickerTitle: const Text(
        'Select date',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      dateOrder: DatePickerDateOrder.dmy,
      initialDateTime: DateTime.now(),
      minDateTime: DateTime(1900),
      pickerTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 1,
      ),
      onChange: (index) {
        // print(index);
      },
      buttonSingleColor: AppColors.darkYellow,
      onSubmit: (selectedDate) {
        if (ageController != null) {
          ageController.text = selectedDate.toLocal().toString().split(' ')[0];
        }
        if (timeNotifier != null) {
          timeNotifier.value = selectedDate;
        }
      },
    ).show(context);
  }
}
