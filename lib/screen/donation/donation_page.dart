import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';

import 'package:mr_fix_it/components/app_bar.dart';

import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/constants.dart';

// ignore: must_be_immutable
class DonationPage extends StatefulWidget {
  late int _userID;

  DonationPage({super.key, required int userID}) {
    _userID = userID;
  }

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  int _selectedOption = 0;
  final List<dynamic> _donationOptions = [1, 3, 5, 10, 20, 25, 50, 100];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: mainAppBar(
        0,
        const BackButton(),
        null,
        primaryColor,
        transparent,
      ),
      body: Center(
        child: Container(
          height: height * 0.8,
          width: width * 0.8,
          padding: const EdgeInsets.all(defultpadding),
          decoration: BoxDecoration(
            border: Border.all(color: primaryColor),
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Donate to Mr.Fix It",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'If you like Mr.fix it, show your support with a donation.\nEvery little matters.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Image(
                image: AssetImage('asset/images/donation.gif'),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: SizedBox(
                  height: 60,
                  width: width * 0.6,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _donationOptions.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedOption = index;
                          });
                        },
                        child: Container(
                          width: 50,
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: grayBackgorund,
                            border: index == _selectedOption ? Border.all(color: primaryColor) : null,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${_donationOptions[index]}\$',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                width: 130,
                height: 40,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: TextButton.icon(
                  onPressed: () {
                    _checkout();
                  },
                  icon: const Icon(
                    color: primaryBackgroundTextColor,
                    Icons.attach_money,
                  ),
                  label: const Text(
                    'Donate',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: primaryBackgroundTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => PaypalCheckout(
          sandboxMode: true,
          clientId: "AWz_dayO4ukyMoxuwKTH-446GbKu7Gy5Tef4ErXDLHHMWo8QaWW3t9qjYMWOuKoBs9XD8n1Ke0iV4fnL",
          secretKey: "EGsyuW3X_CdkqEaG5bwEMvafW3AuEjV4-rQ9DXu4GvEkf2-PwWAzCk4Oc8-zosr_vGBZPxlqdi9kqVSF",
          returnURL:
              "http://13.60.3.70/api/client/client-donation?donationStatus=success&clientID=${widget._userID}&amount=${_donationOptions[_selectedOption]}",
          cancelURL: "http://13.60.3.70/api/client/client-donation?donationStatus=cancel&clientID=${widget._userID}&amount=0",
          transactions: [
            {
              "amount": {
                "total": '${_donationOptions[_selectedOption]}',
                "currency": "USD",
                "details": {"subtotal": '${_donationOptions[_selectedOption]}', "shipping": '0', "shipping_discount": 0}
              },
              "description": "The payment transaction description.",
              "item_list": {
                "items": [
                  {"name": "Donation", "quantity": 1, "price": '${_donationOptions[_selectedOption]}', "currency": "USD"},
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
    );
  }
}
