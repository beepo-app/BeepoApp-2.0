import 'package:flutter/material.dart';

class ActivityButton extends StatelessWidget {
  const ActivityButton({
    super.key,
    required this.mytext,
    required this.buttontext,
    this.press,
    required this.icon,
    this.subtitle,
    required this.checkStatus,
  });

  final String mytext;
  final String buttontext;
  final IconData icon;
  final bool checkStatus;
  final String? subtitle;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(241, 240, 240, 1),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 15, right: 20, top: 15, bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  mytext,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff0E014C),
                  ),
                ),
              ],
            ),
            checkStatus
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: const Color(0xffD9D9D9),
                      foregroundColor: const Color(0xff263238),
                      fixedSize: const Size(120, 1),
                    ),
                    onPressed: press,
                    child: const Text('Claim'),
                  )
                : Text(
                    buttontext,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(250, 145, 8, 1),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}


//  Text(
//             'Time Spent: ${timeBasedPointsProvider.timeSpent} seconds',
//             style: TextStyle(fontSize: 16),
//           ),