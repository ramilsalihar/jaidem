import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import '../../utils/style/app_colors.dart';

class AppSearchField extends StatefulWidget {
  final SearchController? controller;
  final String? hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<Widget> Function(BuildContext, SearchController)?
      suggestionsBuilder;

  const AppSearchField({
    super.key,
    this.controller,
    this.hintText = 'Поиск...',
    this.onChanged,
    this.onSubmitted,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.keyboardType,
    this.suggestionsBuilder,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late SearchController _searchController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _searchController = widget.controller ?? SearchController();
    _focusNode = FocusNode();

    _searchController.addListener(() {
      if (widget.onChanged != null) {
        widget.onChanged!(_searchController.text);
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _searchController.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap with FocusScope to detect taps outside
    return FocusScope(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // Unfocus the field if tapping outside
          if (_focusNode.hasFocus) {
            _focusNode.unfocus();
          }
        },
        child: SizedBox(
          height: 45,
          child: SearchBar(
            controller: _searchController,
            focusNode: _focusNode,
            hintText: widget.hintText,
            enabled: widget.enabled,
            keyboardType: widget.keyboardType,
            leading: widget.leading ??
                const Icon(
                  Icons.search,
                  color: AppColors.grey,
                ),
            trailing: widget.trailing != null
                ? [widget.trailing!]
                : [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          if (widget.onChanged != null) {
                            widget.onChanged!('');
                          }
                        },
                      ),
                  ],
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            backgroundColor: WidgetStateProperty.all(AppColors.lightGrey),
            surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            shadowColor: WidgetStateProperty.all(Colors.transparent),
            elevation: WidgetStateProperty.all(0),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16),
            ),
            textStyle: WidgetStateProperty.all(
              context.textTheme.headlineLarge,
            ),
            hintStyle: WidgetStateProperty.all(
              context.textTheme.headlineSmall?.copyWith(
                fontSize: 16,
                color: AppColors.grey,
              ),
            ),
            side: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.focused)) {
                return BorderSide(color: AppColors.primary, width: 2);
              }
              return BorderSide(color: Colors.grey.shade300, width: 1);
            }),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
