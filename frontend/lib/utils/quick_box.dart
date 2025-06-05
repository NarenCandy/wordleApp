import 'package:flutter/material.dart';

runQuickBox({required BuildContext context, required String message}) {
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    showDialog(
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        context: context,
        builder: (context) {
          Future.delayed(Duration(milliseconds: 1000), () {
            // ignore: use_build_context_synchronously
            Navigator.maybePop(context);
          });
          return AlertDialog(
            title: Text(
              message,
              textAlign: TextAlign.center,
            ),
          );
        });
  });
}
