import 'package:flutter/material.dart';

class MenuField extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MenuField({
    super.key,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Изменить')),
        const PopupMenuItem(value: 'delete', child: Text('Удалить')),
      ],
    );
  }
}
