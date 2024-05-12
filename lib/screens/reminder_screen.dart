import 'package:flutter/material.dart';
import 'package:moodeatsai/constants/constants.dart';
import 'package:moodeatsai/db_services/reminder_service.dart';
import 'package:moodeatsai/utils/utils.dart';
import 'dart:developer';
import 'package:moodeatsai/widgets/widgets.dart';

class DateReminderScreen extends StatefulWidget {
  final int? channelId;
  final String? documentId;

  const DateReminderScreen({super.key, this.channelId, this.documentId});

  @override
  State<DateReminderScreen> createState() => _DateReminderScreenState();
}

class _DateReminderScreenState extends State<DateReminderScreen> {
  ValueNotifier<bool> isSnoozeSwitchNotifier = ValueNotifier(false);
  ValueNotifier<bool> isNotificationNotifier = ValueNotifier(false);
  final ValueNotifier<TimeOfDay> timeNotifier = ValueNotifier(TimeOfDay.now());
  DateTime reminderDate = DateTime.now();
  TimeOfDay reminderTime = TimeOfDay.now();
  String? remiderTimeFormat;
  TextEditingController titleController = TextEditingController();
  final ValueNotifier<DateTime> timeDateNotifier =
      ValueNotifier(DateTime.now());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios , color: Colors.black,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          ' Set Reminder',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SingleChildScrollView(
            child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Schedule reminder to try recipe later.",
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              const Text(
                "Set title",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(
                height: 10,
              ),
              CustomTextField(
                controller: titleController,
                keyboardType: TextInputType.name,
                hintText: 'Enter title for reminder ',
                validator: (input) {
                  if (input == null || input.isEmpty) {
                    return 'Please Enter title';
                  }
                  return null;
                },
                obscureText: false,
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                "Select Date",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ValueListenableBuilder<DateTime>(
                        valueListenable: timeDateNotifier,
                        builder: (context, selectedDate, _) {
                          reminderDate = selectedDate;
                          log('.........date $reminderDate');

                          return Text(
                            selectedDate.toLocal().toString().split(' ')[0],
                            style: const TextStyle(fontSize: 14),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.calendar_today,
                          size: 20,
                        ),
                        color: Colors.black,
                        onPressed: () {
                          DateOfReminder.openDatePicker(
                            context,
                            timeNotifier: timeDateNotifier,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                "Select Time",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: timeNotifier.value,
                    builder: (BuildContext context, Widget? child) {
                      final ThemeData timePickerTheme = ThemeData(
                        useMaterial3: false,
                        primaryColor: AppColors.darkYellow,
                        colorScheme: ColorScheme.fromSwatch().copyWith(
                          primary: AppColors.darkYellow,
                          secondary: AppColors.darkYellow,
                          surface: AppColors.backgroundColor,
                        ),
                        dialogBackgroundColor: AppColors.backgroundColor,
                      );

                      // Return the TimePicker with the custom theme
                      return Theme(
                        data: timePickerTheme,
                        child: child!,
                      );
                    },
                  );
                  if (pickedTime != null) {
                    timeNotifier.value = pickedTime;
                  }
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, // Black border color
                      width: 1.0,
                    ),
                    borderRadius:
                        BorderRadius.circular(10), // Optional: rounded corners
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder<TimeOfDay>(
                          valueListenable: timeNotifier,
                          builder: (context, selectedTime, _) {
                            log('.........time ${selectedTime.format(context)}');
                            reminderTime = selectedTime;
                            remiderTimeFormat = selectedTime.format(context);
                            return Text(
                              selectedTime.format(context),
                              style: const TextStyle(fontSize: 16),
                            );
                          },
                        ),
                        const Icon(
                          Icons.access_time_rounded,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Center(
                child: SizedBox(
                  width: 250,
                  child: CustomButton(
                    text: 'Save',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        FocusScope.of(context).unfocus();

                        try {
                          //  NotificationService().simpleNotification(
                          //   id: generateRandomInt32(),
                          //   title: 'Sample title', body: 'It works!');
                          final combinedDateTime =
                              combineDateAndTime(reminderDate, reminderTime);
                          log('date for reminder $combinedDateTime');

                          await NotificationService().scheduleNotification(
                            id: generateRandomInt32(),
                            title: titleController.text,
                            body: "It's time to take meal",
                            scheduledNotificationDateTime: combinedDateTime,
                          );
                          log('scheduled notification');
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.greenAccent,
                              content: Text(
                                'Scheduled notification successfully',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          );
                        } catch (error) {
                          log('Error scheduling notification: $error');
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Text(
                                  'Failed to schedule notification date must be in future'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        )),
      ),
    );
  }
}
// NotificationService().showNotification(
                          //     title: 'Sample title', body: 'It works!');