import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/response_state.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mr_fix_it/components/form_text_input.dart';
import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';
import 'package:mr_fix_it/util/constants.dart';

class SharePreviousWork extends StatefulWidget {
  final List<dynamic> previousWorks;
  const SharePreviousWork({super.key, required this.previousWorks});

  @override
  State<SharePreviousWork> createState() => _SharePreviousWorkState();
}

class _SharePreviousWorkState extends State<SharePreviousWork> {
  String? description = '';
  List<XFile> images = [];

  final GlobalKey<FormState> formState = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'New Previous Work ',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
              WidgetSpan(
                child: Icon(
                  Icons.history,
                  size: 45,
                  color: Color(0xff118ab2),
                ),
              ),
            ],
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(
              key: formState,
              child: formTextInput(
                label: 'Description',
                hint: "Description...",
                icon: Icons.description,
                maxLines: 5,
                validator: (value) {
                  if (value!.trim().isEmpty) {
                    return 'Description is empty';
                  }

                  if (value.length > 500) {
                    return 'Description exceeds 500 character';
                  }

                  return null;
                },
                onSaved: (value) {
                  description = value;
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: 270,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: primaryColor,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              child: InkWell(
                child: images.isEmpty
                    ? const Icon(
                        Icons.add_a_photo,
                        size: 45,
                        color: Color(0xff118ab2),
                      )
                    : Image.file(
                        File(images.last.path),
                        fit: BoxFit.cover,
                        width: 270,
                        height: 250,
                      ),
                onTap: () async {
                  final List<XFile> selectedImages = await ImagePicker().pickMultiImage();

                  if (selectedImages.isNotEmpty) {
                    images.clear();
                    images.addAll(selectedImages);

                    setState(() {});
                  }
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: InkWell(
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 22,
                      ),
                      SizedBox(width: 5.0),
                      Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  if (!formState.currentState!.validate() || images.isEmpty) {
                    return;
                  }

                  formState.currentState!.save();
                  _addPreviousWork();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addPreviousWork() {
    if (context.mounted) {
      apiCall(
        context,
        () async {
          final response = await Api.formData(
            'add-previous-work',
            {
              'description': description,
            },
            (request) async {
              for (int i = 0; i < images.length; i++) {
                request.files.add(
                  await http.MultipartFile.fromPath(
                    'workImgs',
                    images[i].path,
                    filename: images[i].name,
                    contentType: MediaType('image', path.extension(images[i].name).replaceAll('.', '')),
                  ),
                );
              }
            },
          );

          if (context.mounted) {
            if (response['responseState'] == ResponseState.success) {
              widget.previousWorks.add(response['body']['previousWork']);
              setState(() {});
              showAwsomeDialog(
                context: context,
                dialogType: DialogType.info,
                title: 'Success',
                description: 'Previous work added successfully',
                btnOkOnPress: () {
                  Navigator.pop(context);
                },
              );
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
}
