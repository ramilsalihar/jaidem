import 'package:flutter/material.dart';

const int maxCounter = 3;

class RatingField extends StatelessWidget {
  const RatingField({
    super.key,
    required this.rating,
    this.iconSize = 20.0,
  });

  final int rating;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 1; i <= maxCounter; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Image.asset(
              i <= rating
                  ? 'assets/icons/star_filled.png'
                  : 'assets/icons/star_outlined.png',
              color: const Color(0xFFFF9500),
              width: iconSize,
              height: iconSize,
            ),
          ),
      ],
    );
  }
}
