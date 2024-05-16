import 'package:flutter/material.dart';

//fonts
const mainFont = 'Questrial';

//colors
const primaryColor = Color(0xFF0C9869);
const gradientPrimaryColor = Color.fromARGB(255, 7, 93, 63);
const whiteBackgroundTextColor = Color(0xFF3C4046);
const primaryBackgroundTextColor = Color.fromRGBO(255, 255, 255, 1);
const backgroundColor = Color(0xFFF9F8FD);
const creamBackground = Color.fromARGB(255, 230, 228, 226);
const transparent = Colors.transparent;
const grayBackgorund = Color.fromARGB(255, 225, 224, 230);

//paddings
const defultpadding = 20.0;

//regex
const emailRegex =
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
const birthdayRegex = r"^\d{4}-\d{1,2}-\d{1,2}$";
const passwordRegex = r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,16}$";
const phoneRegex = r"^(?:\+972|\+970)?[0-9]{9}$|^[0-9]{10}$";
