import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/features/forum/presentation/widgets/utils/forum_details.dart';

class ForumCard extends StatelessWidget {
  const ForumCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '15 июня прошел турнир между потоками 5-6-7-8-9-10',
            style: context.textTheme.headlineMedium,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 180,
            width: size.width,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                'https://cdn.britannica.com/99/128399-050-EB6E336F/Temple-of-Saturn-Roman-Forum-Rome.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ForumDetails()
        ],
      ),
    );
  }
}
