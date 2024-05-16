import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bottom_drawer/bottom_drawer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:mr_fix_it/components/btn_widget.dart';
import 'package:mr_fix_it/components/form_text_input.dart';
import 'package:mr_fix_it/components/title_with_custom_underline.dart';

import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';

import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/constants.dart';
import 'package:mr_fix_it/util/response_state.dart';

// ignore: must_be_immutable
class TaskRateDrawer extends StatefulWidget {
  late BottomDrawerController _bottomDrawerController;
  final task;
  final void Function(Map<String, dynamic> feedback) updateTaskRate;

  TaskRateDrawer({super.key, required BottomDrawerController bottomDrawerController, required this.task, required this.updateTaskRate}) {
    _bottomDrawerController = bottomDrawerController;
  }

  @override
  State<TaskRateDrawer> createState() => _TaskRateDrawerState();
}

class _TaskRateDrawerState extends State<TaskRateDrawer> {
  double perfection = 0.0;
  double treatment = 0.0;
  String additionalInfo = "";

  final GlobalKey<FormState> _formState = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BottomDrawer(
      header: const SizedBox(
        width: 0,
        height: 0,
      ),
      controller: widget._bottomDrawerController,
      body: _buildBottomDrawerBody(context),
      headerHeight: 0,
      drawerHeight: MediaQuery.of(context).size.height * 0.5,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 60,
          spreadRadius: 5,
          offset: const Offset(2, -6),
        ),
      ],
    );
  }

  Widget _buildBottomDrawerBody(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Task Rate",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Container(
                  width: 30,
                  alignment: AlignmentDirectional.topStart,
                  child: TitleWithCustomUnderline(
                    text: "Perfection",
                    fontSize: 30,
                    height: 30,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              RatingBar.builder(
                initialRating: 0,
                itemSize: (MediaQuery.of(context).size.width - 30) / 5,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: primaryColor,
                ),
                onRatingUpdate: (rating) {
                  perfection = rating;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Container(
                  width: 30,
                  alignment: AlignmentDirectional.topStart,
                  child: TitleWithCustomUnderline(
                    text: "Treatment",
                    fontSize: 30,
                    height: 30,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              RatingBar.builder(
                initialRating: 0,
                itemSize: (MediaQuery.of(context).size.width - 30) / 5,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: primaryColor,
                ),
                onRatingUpdate: (rating) {
                  treatment = rating;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Form(
                key: _formState,
                child: formTextInput(
                  label: 'Additional Info',
                  hint: "Additional Info...",
                  icon: Icons.description,
                  maxLines: 5,
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Additional info is empty';
                    }

                    return null;
                  },
                  onSaved: (value) {
                    additionalInfo = value!;
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 150,
                child: ButtonWidget(
                  btnText: "Rate",
                  backgroundColor: primaryColor,
                  onClick: () {
                    if (!_formState.currentState!.validate()) {
                      return;
                    }

                    _formState.currentState!.save();
                    _taskRateSubmission(widget.task['id'], perfection, treatment, additionalInfo);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _taskRateSubmission(int taskID, double perfection, double treatment, String additionalInfo) {
    apiCall(
      context,
      () async {
        final response = await Api.postData(
          'task-rate-submission',
          {
            'taskID': taskID.toString(),
            'perfection': perfection.toString(),
            'treatment': treatment.toString(),
            'additionalInfo': additionalInfo,
          },
        );

        if (context.mounted) {
          if (response['responseState'] == ResponseState.success) {
            await showAwsomeDialog(
              context: context,
              dialogType: DialogType.info,
              title: 'Success',
              description: 'Feedback submitted successfully',
              btnOkOnPress: () {},
            );

            setState(() {
              widget.updateTaskRate({
                'taskID': taskID,
                'perfectionRate': perfection,
                'treatmentRate': treatment,
                'additionalInfo': additionalInfo,
              });
              widget._bottomDrawerController.close();
            });
          } else {
            showAwsomeDialog(
              context: context,
              dialogType: DialogType.error,
              title: 'Failed',
              description: 'Something went wrong, please try again later',
              btnOkOnPress: () {},
            );
          }
        }
      },
    );
  }
}
