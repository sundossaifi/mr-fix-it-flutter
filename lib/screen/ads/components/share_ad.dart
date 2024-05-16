import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mr_fix_it/util/response_state.dart';
import 'package:path/path.dart' as path;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';
import 'package:mr_fix_it/util/constants.dart';
import 'package:mr_fix_it/util/dialog.dart';

class ShareNewAd extends StatefulWidget {
  final List<dynamic> ads;
  const ShareNewAd({
    super.key,
    required this.ads,
  });

  @override
  State<ShareNewAd> createState() => _ShareNewAdState();
}

class _ShareNewAdState extends State<ShareNewAd> {
  XFile? ad;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'New Ad ',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
              WidgetSpan(
                child: Icon(
                  Icons.post_add,
                  size: 45,
                  color: Color(0xff118ab2),
                ),
              ),
            ],
          ),
        ),
      ),
      content: SizedBox(
        height: 320,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 250,
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
                child: ad == null
                    ? const Icon(
                        Icons.add_a_photo,
                        size: 45,
                        color: Color(0xff118ab2),
                      )
                    : Image.file(
                        File(ad!.path),
                        fit: BoxFit.cover,
                        width: 250,
                        height: 250,
                      ),
                onTap: () async {
                  final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

                  if (returnedImage != null) {
                    setState(() {
                      ad = returnedImage;
                    });
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
                        '5\$',
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
                  _checkout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkout() {
    int state = 0;

    if (ad != null) {
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (BuildContext context) => PaypalCheckout(
            sandboxMode: true,
            clientId: "AWz_dayO4ukyMoxuwKTH-446GbKu7Gy5Tef4ErXDLHHMWo8QaWW3t9qjYMWOuKoBs9XD8n1Ke0iV4fnL",
            secretKey: "EGsyuW3X_CdkqEaG5bwEMvafW3AuEjV4-rQ9DXu4GvEkf2-PwWAzCk4Oc8-zosr_vGBZPxlqdi9kqVSF",
            returnURL: "success.snippetcoder.com",
            cancelURL: "cancel.snippetcoder.com",
            transactions: const [
              {
                "amount": {
                  "total": '5',
                  "currency": "USD",
                  "details": {"subtotal": '5', "shipping": '0', "shipping_discount": 0}
                },
                "description": "The payment transaction description.",
                "item_list": {
                  "items": [
                    {"name": "Featured Plan", "quantity": 1, "price": '5', "currency": "USD"},
                  ],
                }
              }
            ],
            note: "PAYMENT_NOTE",
            onSuccess: (Map params) {
              state = 1;
            },
            onCancel: () {
              state = 2;
            },
            onError: (error) {
              state = 3;
            },
          ),
        ),
      )
          .then(
        (value) {
          if (state == 1) {
            apiCall(
              context,
              () async {
                final response = await Api.formData(
                  'share-ad',
                  {},
                  (request) async {
                    request.files.add(
                      await http.MultipartFile.fromPath(
                        'img',
                        ad!.path,
                        filename: ad!.name,
                        contentType: MediaType('image', path.extension(ad!.name).replaceAll('.', '')),
                      ),
                    );
                  },
                );

                if (context.mounted) {
                  if (response['responseState'] == ResponseState.success) {
                    widget.ads.add(response['body']['ad']);
                    setState(() {});
                    showAwsomeDialog(
                      context: context,
                      dialogType: DialogType.info,
                      title: 'Success',
                      description: 'Ad shared successfully',
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
          } else if (state == 2) {
            showAwsomeDialog(
              context: context,
              dialogType: DialogType.info,
              title: 'Canceled',
              description: 'Your request canceled',
              btnOkOnPress: () {},
            );
          } else if (state == 3) {
            showAwsomeDialog(
              context: context,
              dialogType: DialogType.error,
              title: 'Failed',
              description: 'Something went wrong, try again later',
              btnOkOnPress: () {},
            );
          }
        },
      );
    }
  }
}
