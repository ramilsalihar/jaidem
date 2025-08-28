import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/widgets/fields/details_text_field.dart';
import 'package:jaidem/features/events/presentation/widgets/buttons/event_action_buttons.dart';

class EventPagination extends StatefulWidget {
  const EventPagination({
    super.key,
    required this.events,
    required this.label,
  });

  final List<String> events;
  final String label;

  @override
  State<EventPagination> createState() => _EventPaginationState();
}

class _EventPaginationState extends State<EventPagination> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: 310,
      width: size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                widget.label,
                style: context.textTheme.headlineLarge,
              ),
              const Spacer(),
              IconButton.filled(
                iconSize: 20,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.primary.shade300,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                iconSize: 20,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primary.shade300,
                ),
              ),
            ],
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: widget.events
                  .map(
                    (event) => Container(
                      width: size.width,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              'https://cdn-cjhkj.nitrocdn.com/krXSsXVqwzhduXLVuGLToUwHLNnSxUxO/assets/images/optimized/rev-ff94111/spotme.com/wp-content/uploads/2020/07/Hero-1.jpg',
                              width: double.infinity,
                              fit: BoxFit.cover,
                              height: 100,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DetailsTextField(
                            label: 'Тема:',
                            value: 'Как развивать свой потенциал',
                            labelStyle: context.textTheme.bodyMedium?.copyWith(
                              color: AppColors.grey,
                            ),
                            valueStyle: context.textTheme.bodyMedium?.copyWith(
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          DetailsTextField(
                            label: 'Когда:',
                            value: '1 мая 2022 года',
                            labelStyle: context.textTheme.bodyMedium?.copyWith(
                              color: AppColors.grey,
                            ),
                            valueStyle: context.textTheme.bodyMedium?.copyWith(
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5),
                          DetailsTextField(
                            label: 'Где:',
                            value: 'г. Бишкек, Отель Туристан',
                            labelStyle: context.textTheme.bodyMedium?.copyWith(
                              color: AppColors.grey,
                            ),
                            valueStyle: context.textTheme.bodyMedium?.copyWith(
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          EventActionButtons(
                            status: EventCardState.decision,
                            primaryButtonAction: () {},
                          )
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          )
        ],
      ),
    );
  }
}
