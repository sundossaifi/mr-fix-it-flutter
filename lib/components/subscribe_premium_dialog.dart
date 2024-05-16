import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';
import 'package:mr_fix_it/util/constants.dart';
import 'package:mr_fix_it/util/dialog.dart';

class SubscribePremiumDialog extends StatefulWidget {
  final int workerID;
  final featured;
  const SubscribePremiumDialog({super.key, required this.workerID, this.featured});

  @override
  State<SubscribePremiumDialog> createState() => _SubscribePremiumDialogState();
}

class _SubscribePremiumDialogState extends State<SubscribePremiumDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Image.asset(
            'asset/images/handymen.jpeg',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
          const SizedBox(
            height: 10,
          ),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Premium Membership',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                WidgetSpan(
                  child: Icon(
                    Icons.workspace_premium,
                    size: 45,
                    color: Color(0xff118ab2),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      content: SizedBox(
        height: 130,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    child: Icon(
                      Icons.verified,
                      size: 25,
                      color: primaryColor,
                    ),
                  ),
                  TextSpan(
                    text: ' Appear at main page',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    child: Icon(
                      Icons.verified,
                      size: 25,
                      color: primaryColor,
                    ),
                  ),
                  TextSpan(
                    text: ' Search suggestion',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            if (widget.featured == null)
              Center(
                child: InkWell(
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5.0),
                        Text(
                          '15',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5.0),
                        Text(
                          '\$/ Month',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
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
            if (widget.featured != null)
              Text.rich(
                TextSpan(
                  children: [
                    const WidgetSpan(
                      child: Icon(
                        Icons.calendar_month,
                        size: 25,
                        color: primaryColor,
                      ),
                    ),
                    TextSpan(
                      text:
                          '${widget.featured['startDate'].toString().substring(0, widget.featured['startDate'].toString().indexOf("T"))} - ${widget.featured['expiryDate'].toString().substring(0, widget.featured['startDate'].toString().indexOf("T"))}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _checkout() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (BuildContext context) => PaypalCheckout(
              sandboxMode: true,
              clientId: "AWz_dayO4ukyMoxuwKTH-446GbKu7Gy5Tef4ErXDLHHMWo8QaWW3t9qjYMWOuKoBs9XD8n1Ke0iV4fnL",
              secretKey: "EGsyuW3X_CdkqEaG5bwEMvafW3AuEjV4-rQ9DXu4GvEkf2-PwWAzCk4Oc8-zosr_vGBZPxlqdi9kqVSF",
              returnURL: "http://13.60.3.70/api/worker/subscribe-featured?subscriptionStatus=success&workerID=${widget.workerID}",
              cancelURL: "http://13.60.3.70/api/worker/subscribe-featured?subscriptionStatus=cancel&workerID=${widget.workerID}",
              transactions: const [
                {
                  "amount": {
                    "total": '15',
                    "currency": "USD",
                    "details": {"subtotal": '15', "shipping": '0', "shipping_discount": 0}
                  },
                  "description": "The payment transaction description.",
                  "item_list": {
                    "items": [
                      {"name": "Featured Plan", "quantity": 1, "price": '15', "currency": "USD"},
                    ],
                  }
                }
              ],
              note: "PAYMENT_NOTE",
              onError: (error) {
                Navigator.pop(context);
                showAwsomeDialog(
                  context: context,
                  dialogType: DialogType.error,
                  title: 'Failed',
                  description: 'Something went wrong, try again later',
                  btnOkOnPress: () {},
                );
              },
            ),
          ),
        )
        .then((value) => Navigator.pop(context));
  }
}
