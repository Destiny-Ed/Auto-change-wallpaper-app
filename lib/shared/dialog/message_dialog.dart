import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:wallpaper_app/styles/color.dart';

void showMessage(BuildContext context, String message, {bool isError = true, VoidCallback? onConfirmTapped}) {
  QuickAlert.show(
    context: context,
    type: isError ? QuickAlertType.error : QuickAlertType.success,
    title: isError ? 'Oops...' : null,
    confirmBtnColor: primaryColor,
    onConfirmBtnTap: onConfirmTapped,
    text: message,
  );
}
