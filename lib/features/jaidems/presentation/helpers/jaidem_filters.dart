import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaidem/core/data/models/jaidem/details/flow_model.dart';
import 'package:jaidem/core/network/dio_network.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

mixin JaidemFilters<T extends StatefulWidget> on State<T> {
  FlowModel? selectedFlow;
  int? selectedAge;
  List<FlowModel> _flows = [];
  bool _isLoadingFlows = false;

  bool hasActiveFilters() {
    return selectedFlow != null || selectedAge != null;
  }

  Future<void> _loadFlows() async {
    if (_flows.isNotEmpty) return;

    try {
      final response =
          await DioNetwork.appAPI.get('https://jaidem-back.ru/jaidem/api/core/flow/');
      if (response.statusCode == 200) {
        final results = response.data['results'] as List;
        _flows = results.map((e) => FlowModel.fromJson(e)).toList();
      }
    } on DioException catch (_) {
      // Handle error silently
    }
  }

  void showFilterModal({
    required void Function(Map<String, String?> filters) onApply,
    required VoidCallback onReset,
  }) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _FilterSheet(
          flows: _flows,
          isLoadingFlows: _isLoadingFlows,
          selectedFlow: selectedFlow,
          selectedAge: selectedAge,
          onLoadFlows: () async {
            if (_flows.isEmpty && !_isLoadingFlows) {
              _isLoadingFlows = true;
              await _loadFlows();
              _isLoadingFlows = false;
            }
            return _flows;
          },
          onApply: (flow, age) {
            selectedFlow = flow;
            selectedAge = age;
            final filters = <String, String?>{
              'flow': flow?.id.toString(),
              'age': age?.toString(),
            };
            onApply(filters);
          },
          onReset: () {
            selectedFlow = null;
            selectedAge = null;
            onReset();
          },
        );
      },
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.flows,
    required this.isLoadingFlows,
    required this.selectedFlow,
    required this.selectedAge,
    required this.onLoadFlows,
    required this.onApply,
    required this.onReset,
  });

  final List<FlowModel> flows;
  final bool isLoadingFlows;
  final FlowModel? selectedFlow;
  final int? selectedAge;
  final Future<List<FlowModel>> Function() onLoadFlows;
  final void Function(FlowModel? flow, int? age) onApply;
  final VoidCallback onReset;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  List<FlowModel> _flows = [];
  bool _isLoading = true;
  FlowModel? _selectedFlow;
  double _selectedAge = 20;
  bool _ageFilterEnabled = false;

  @override
  void initState() {
    super.initState();
    _selectedFlow = widget.selectedFlow;
    if (widget.selectedAge != null) {
      _selectedAge = widget.selectedAge!.toDouble();
      _ageFilterEnabled = true;
    }
    _loadFlows();
  }

  Future<void> _loadFlows() async {
    final flows = await widget.onLoadFlows();
    if (mounted) {
      setState(() {
        _flows = flows;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Чыпкалоо',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (_selectedFlow != null || _ageFilterEnabled)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedFlow = null;
                        _ageFilterEnabled = false;
                        _selectedAge = 20;
                      });
                    },
                    child: Text(
                      'Тазалоо',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flow Filter
                _buildSectionTitle('Агым'),
                const SizedBox(height: 12),
                _buildFlowSelector(),

                const SizedBox(height: 24),

                // Age Filter
                _buildAgeSection(),

                const SizedBox(height: 32),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.onApply(
                        _selectedFlow,
                        _ageFilterEnabled ? _selectedAge.round() : null,
                      );
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Колдонуу',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Reset Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.onReset();
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Баштапкы абалга келтирүү',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildFlowSelector() {
    if (_isLoading) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildFlowChip(null, 'Баары'),
        ..._flows.map((flow) => _buildFlowChip(flow, 'Агым ${flow.name}')),
      ],
    );
  }

  Widget _buildFlowChip(FlowModel? flow, String label) {
    final isSelected = _selectedFlow?.id == flow?.id;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedFlow = flow;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildAgeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Жашы'),
            Switch(
              value: _ageFilterEnabled,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                setState(() {
                  _ageFilterEnabled = value;
                });
              },
              activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
        if (_ageFilterEnabled) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_selectedAge.round()} жаш',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: Colors.grey.shade200,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withValues(alpha: 0.2),
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                  ),
                  child: Slider(
                    value: _selectedAge,
                    min: 15,
                    max: 35,
                    divisions: 20,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedAge = value;
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '15',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      '35',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
