import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

showMessage({
  required BuildContext context,
  required String title,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      elevation: 6,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      padding: const EdgeInsets.all(10),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5))),
      content: Row(
        children: [
          SizedBox(
            width: ScreenUtil().setWidth(5),
          ),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              style: const TextStyle(overflow: TextOverflow.ellipsis),
            ),
          )
        ],
      ),
    ),
  );
}
