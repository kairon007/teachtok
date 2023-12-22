import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NumberedIconButton extends StatefulWidget {
  final IconData icon;
  final String number;

  NumberedIconButton({required this.icon, required this.number});

  @override
  _NumberedIconButtonState createState() => _NumberedIconButtonState();
}

class _NumberedIconButtonState extends State<NumberedIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _isPressed = !_isPressed;
        });
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            bottomLeft: Radius.circular(16.0),
          ),
        ),
        child: Column(
          children: [
            Icon(
              widget.icon,
              color: _isPressed ? Colors.red : Colors.white,
            ),
            SizedBox(height: 4.0),
            Text(
              widget.number,
              style: TextStyle(
                color: Colors.white ,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}