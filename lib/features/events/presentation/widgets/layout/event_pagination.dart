import 'package:flutter/material.dart';
import 'package:jaidem/features/events/domain/entities/event_entity.dart';
import 'package:jaidem/features/events/presentation/widgets/buttons/event_pagination_bar.dart';
import 'package:jaidem/features/events/presentation/widgets/cards/event_card.dart';

class EventPagination extends StatefulWidget {
  const EventPagination({
    super.key,
    required this.events,
    required this.label,
  });

  final List<EventEntity> events;
  final String label;

  @override
  State<EventPagination> createState() => _EventPaginationState();
}

class _EventPaginationState extends State<EventPagination> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EventPaginationBar(
          label: widget.label,
          controller: _pageController,
        ),
        SizedBox(
          height: 260,
          width: size.width,
          child: PageView(
            controller: _pageController,
            children: widget.events
                .map(
                  (event) => EventCard(event: event),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
