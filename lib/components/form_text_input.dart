import 'package:flutter/material.dart';
import 'package:mr_fix_it/util/constants.dart';

Widget formTextInput(
    {Key? key,
    String label = '',
    TextEditingController? controller,
    bool readOnly = false,
    bool obscureText = false,
    String hint = "",
    IconData? icon,
    int? maxLines = 1,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    void Function()? onTap,
    void Function(String?)? onChanged,
    keyboardType = TextInputType.text}) {
  return Padding(
    padding: const EdgeInsets.only(
      top: 10,
    ),
    child: TextFormField(
      keyboardType: keyboardType,
      key: key,
      controller: controller,
      readOnly: readOnly,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        label: Text(
          label,
          style: const TextStyle(
            color: primaryColor,
            fontSize: 17,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(20),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(20),
        ),
        hintText: hint,
        prefixIcon: Icon(icon),
        errorStyle: const TextStyle(
          color: Colors.red,
          fontSize: 13,
        ),
      ),
      validator: validator,
      onSaved: onSaved,
      onTap: onTap,
      onChanged: onChanged,
    ),
  );
}
