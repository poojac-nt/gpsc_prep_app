import 'package:flutter/material.dart';

class CustomAlertdialog extends StatelessWidget {
  const CustomAlertdialog({
    super.key,
    required this.title,
    required this.mainContent,
    required this.content,
    required this.actions,
  });
  final String title;
  final String mainContent;
  final String content;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mainContent,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Text(content, style: TextStyle(fontSize: 15, color: Colors.black54)),
        ],
      ),
      actions: actions,
    );
  }
}
