import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaidem/core/data/models/jaidem/details/flow_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/region_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/speciality_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/university_model.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/network/dio_network.dart';
import 'package:jaidem/core/utils/constants/api_const.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

mixin JaidemFilters<T extends StatefulWidget> on State<T> {
  FlowModel? selectedFlow;
  int? selectedAge;
  RegionModel? selectedRegion;
  UniversityModel? selectedUniversity;
  SpecialityModel? selectedSpeciality;

  List<FlowModel> _flows = [];
  List<RegionModel> _regions = [];
  List<UniversityModel> _universities = [];
  List<SpecialityModel> _specialities = [];

  bool _isLoadingFlows = false;
  bool _isLoadingRegions = false;
  bool _isLoadingUniversities = false;
  bool _isLoadingSpecialities = false;

  bool hasActiveFilters() {
    return selectedFlow != null ||
        selectedAge != null ||
        selectedRegion != null ||
        selectedUniversity != null ||
        selectedSpeciality != null;
  }

  int getActiveFilterCount() {
    int count = 0;
    if (selectedFlow != null) count++;
    if (selectedAge != null) count++;
    if (selectedRegion != null) count++;
    if (selectedUniversity != null) count++;
    if (selectedSpeciality != null) count++;
    return count;
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

  Future<void> _loadRegions() async {
    if (_regions.isNotEmpty) return;

    try {
      final response = await DioNetwork.appAPI
          .get('${ApiConst.baseUrl}${ApiConst.regions}');
      if (response.statusCode == 200) {
        final data = response.data;
        final List results = data is List ? data : (data['results'] as List? ?? []);
        _regions = results.map((e) => RegionModel.fromJson(e)).toList();
      }
    } on DioException catch (_) {
      // Handle error silently
    }
  }

  Future<List<UniversityModel>> _loadUniversities({String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      final response = await DioNetwork.appAPI.get(
        '${ApiConst.baseUrl}${ApiConst.universities}',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final List results = data is List ? data : (data['results'] as List? ?? []);
        _universities = results.map((e) => UniversityModel.fromJson(e)).toList();
        return _universities;
      }
    } on DioException catch (_) {
      // Handle error silently
    }
    return [];
  }

  Future<void> _loadSpecialities() async {
    if (_specialities.isNotEmpty) return;

    try {
      final response = await DioNetwork.appAPI
          .get('${ApiConst.baseUrl}${ApiConst.specialities}');
      if (response.statusCode == 200) {
        final data = response.data;
        final List results = data is List ? data : (data['results'] as List? ?? []);
        _specialities =
            results.map((e) => SpecialityModel.fromJson(e)).toList();
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
    final locale = Localizations.localeOf(context).languageCode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _FilterSheet(
          locale: locale,
          flows: _flows,
          regions: _regions,
          universities: _universities,
          specialities: _specialities,
          isLoadingFlows: _isLoadingFlows,
          isLoadingRegions: _isLoadingRegions,
          isLoadingUniversities: _isLoadingUniversities,
          isLoadingSpecialities: _isLoadingSpecialities,
          selectedFlow: selectedFlow,
          selectedAge: selectedAge,
          selectedRegion: selectedRegion,
          selectedUniversity: selectedUniversity,
          selectedSpeciality: selectedSpeciality,
          onLoadFlows: () async {
            if (_flows.isEmpty && !_isLoadingFlows) {
              _isLoadingFlows = true;
              await _loadFlows();
              _isLoadingFlows = false;
            }
            return _flows;
          },
          onLoadRegions: () async {
            if (_regions.isEmpty && !_isLoadingRegions) {
              _isLoadingRegions = true;
              await _loadRegions();
              _isLoadingRegions = false;
            }
            return _regions;
          },
          onLoadUniversities: (String? search) async {
            if (!_isLoadingUniversities) {
              _isLoadingUniversities = true;
              final result = await _loadUniversities(search: search);
              _isLoadingUniversities = false;
              return result;
            }
            return _universities;
          },
          onLoadSpecialities: () async {
            if (_specialities.isEmpty && !_isLoadingSpecialities) {
              _isLoadingSpecialities = true;
              await _loadSpecialities();
              _isLoadingSpecialities = false;
            }
            return _specialities;
          },
          onApply: (flow, age, region, university, speciality) {
            selectedFlow = flow;
            selectedAge = age;
            selectedRegion = region;
            selectedUniversity = university;
            selectedSpeciality = speciality;
            final filters = <String, String?>{
              'flow': flow?.id.toString(),
              'age': age?.toString(),
              'region': region?.id.toString(),
              'university': university?.id.toString(),
              'speciality': speciality?.id.toString(),
            };
            onApply(filters);
          },
          onReset: () {
            selectedFlow = null;
            selectedAge = null;
            selectedRegion = null;
            selectedUniversity = null;
            selectedSpeciality = null;
            onReset();
          },
        );
      },
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.locale,
    required this.flows,
    required this.regions,
    required this.universities,
    required this.specialities,
    required this.isLoadingFlows,
    required this.isLoadingRegions,
    required this.isLoadingUniversities,
    required this.isLoadingSpecialities,
    required this.selectedFlow,
    required this.selectedAge,
    required this.selectedRegion,
    required this.selectedUniversity,
    required this.selectedSpeciality,
    required this.onLoadFlows,
    required this.onLoadRegions,
    required this.onLoadUniversities,
    required this.onLoadSpecialities,
    required this.onApply,
    required this.onReset,
  });

  final String locale;
  final List<FlowModel> flows;
  final List<RegionModel> regions;
  final List<UniversityModel> universities;
  final List<SpecialityModel> specialities;
  final bool isLoadingFlows;
  final bool isLoadingRegions;
  final bool isLoadingUniversities;
  final bool isLoadingSpecialities;
  final FlowModel? selectedFlow;
  final int? selectedAge;
  final RegionModel? selectedRegion;
  final UniversityModel? selectedUniversity;
  final SpecialityModel? selectedSpeciality;
  final Future<List<FlowModel>> Function() onLoadFlows;
  final Future<List<RegionModel>> Function() onLoadRegions;
  final Future<List<UniversityModel>> Function(String? search) onLoadUniversities;
  final Future<List<SpecialityModel>> Function() onLoadSpecialities;
  final void Function(
    FlowModel? flow,
    int? age,
    RegionModel? region,
    UniversityModel? university,
    SpecialityModel? speciality,
  ) onApply;
  final VoidCallback onReset;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  List<FlowModel> _flows = [];
  List<RegionModel> _regions = [];
  List<SpecialityModel> _specialities = [];

  bool _isLoadingFlows = true;
  bool _isLoadingRegions = true;
  bool _isLoadingSpecialities = true;

  FlowModel? _selectedFlow;
  double _selectedAge = 20;
  bool _ageFilterEnabled = false;
  RegionModel? _selectedRegion;
  UniversityModel? _selectedUniversity;
  SpecialityModel? _selectedSpeciality;

  @override
  void initState() {
    super.initState();
    _selectedFlow = widget.selectedFlow;
    _selectedRegion = widget.selectedRegion;
    _selectedUniversity = widget.selectedUniversity;
    _selectedSpeciality = widget.selectedSpeciality;
    if (widget.selectedAge != null) {
      _selectedAge = widget.selectedAge!.toDouble();
      _ageFilterEnabled = true;
    }
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadFlows(),
      _loadRegions(),
      _loadSpecialities(),
    ]);
  }

  Future<void> _loadFlows() async {
    final flows = await widget.onLoadFlows();
    if (mounted) {
      setState(() {
        _flows = flows;
        _isLoadingFlows = false;
      });
    }
  }

  Future<void> _loadRegions() async {
    final regions = await widget.onLoadRegions();
    if (mounted) {
      setState(() {
        _regions = regions;
        _isLoadingRegions = false;
      });
    }
  }

  Future<void> _loadSpecialities() async {
    final specialities = await widget.onLoadSpecialities();
    if (mounted) {
      setState(() {
        _specialities = specialities;
        _isLoadingSpecialities = false;
      });
    }
  }

  bool _hasActiveFilters() {
    return _selectedFlow != null ||
        _ageFilterEnabled ||
        _selectedRegion != null ||
        _selectedUniversity != null ||
        _selectedSpeciality != null;
  }

  void _clearAllFilters() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedFlow = null;
      _ageFilterEnabled = false;
      _selectedAge = 20;
      _selectedRegion = null;
      _selectedUniversity = null;
      _selectedSpeciality = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
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
                Text(
                  context.tr('filter'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (_hasActiveFilters())
                  GestureDetector(
                    onTap: _clearAllFilters,
                    child: Text(
                      context.tr('clear'),
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

          // Content - Scrollable
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flow Filter
                  _buildSectionTitle(context.tr('flow')),
                  const SizedBox(height: 12),
                  _buildFlowSelector(),

                  const SizedBox(height: 24),

                  // Region Filter
                  _buildSectionTitle(context.tr('region')),
                  const SizedBox(height: 12),
                  _buildRegionSelector(),

                  const SizedBox(height: 24),

                  // University Filter
                  _buildSectionTitle(context.tr('university')),
                  const SizedBox(height: 12),
                  _buildUniversitySelector(),

                  const SizedBox(height: 24),

                  // Speciality Filter
                  _buildSectionTitle(context.tr('speciality')),
                  const SizedBox(height: 12),
                  _buildSpecialitySelector(),

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
                          _selectedRegion,
                          _selectedUniversity,
                          _selectedSpeciality,
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
                      child: Text(
                        context.tr('apply'),
                        style: const TextStyle(
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
                        context.tr('reset'),
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
    if (_isLoadingFlows) {
      return _buildLoadingContainer();
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildFlowChip(null, context.tr('all')),
        ..._flows.map((flow) => _buildFlowChip(flow, '${context.tr('flow')} ${flow.name}')),
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
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
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

  Widget _buildRegionSelector() {
    if (_isLoadingRegions) {
      return _buildLoadingContainer();
    }

    return _buildSearchableSelector<RegionModel>(
      selectedValue: _selectedRegion,
      hint: context.tr('select_region'),
      selectedLabel: _selectedRegion?.getLocalizedName(widget.locale),
      onTap: () => _showRegionSearchDialog(),
      onClear: () {
        setState(() {
          _selectedRegion = null;
        });
      },
    );
  }

  Widget _buildUniversitySelector() {
    return _buildSearchableSelector<UniversityModel>(
      selectedValue: _selectedUniversity,
      hint: context.tr('select_university'),
      selectedLabel: _selectedUniversity?.getLocalizedName(widget.locale),
      onTap: () => _showUniversitySearchDialog(),
      onClear: () {
        setState(() {
          _selectedUniversity = null;
        });
      },
    );
  }

  Widget _buildSpecialitySelector() {
    if (_isLoadingSpecialities) {
      return _buildLoadingContainer();
    }

    return _buildSearchableSelector<SpecialityModel>(
      selectedValue: _selectedSpeciality,
      hint: context.tr('select_speciality'),
      selectedLabel: _selectedSpeciality?.getLocalizedName(widget.locale),
      onTap: () => _showSpecialitySearchDialog(),
      onClear: () {
        setState(() {
          _selectedSpeciality = null;
        });
      },
    );
  }

  Widget _buildSearchableSelector<T>({
    required T? selectedValue,
    required String hint,
    required String? selectedLabel,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedValue != null
                ? AppColors.primary.withValues(alpha: 0.5)
                : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: Colors.grey.shade500,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedLabel ?? hint,
                style: TextStyle(
                  color: selectedValue != null
                      ? Colors.grey.shade800
                      : Colors.grey.shade500,
                  fontSize: 14,
                  fontWeight:
                      selectedValue != null ? FontWeight.w500 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (selectedValue != null)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onClear();
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    color: Colors.grey.shade500,
                    size: 18,
                  ),
                ),
              )
            else
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade500,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showRegionSearchDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _SearchableDialog<RegionModel>(
        title: context.tr('select_region'),
        searchHint: context.tr('search'),
        clearLabel: context.tr('clear'),
        emptyText: context.tr('nothing_found'),
        items: _regions,
        selectedItem: _selectedRegion,
        itemLabel: (item) => item.getLocalizedName(widget.locale),
        searchFilter: (item, query) {
          final lowerQuery = query.toLowerCase();
          return item.nameEn.toLowerCase().contains(lowerQuery) ||
              (item.nameRu?.toLowerCase().contains(lowerQuery) ?? false) ||
              (item.nameKg?.toLowerCase().contains(lowerQuery) ?? false);
        },
        onSelected: (item) {
          setState(() {
            _selectedRegion = item;
          });
        },
      ),
    );
  }

  void _showUniversitySearchDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _UniversitySearchDialog(
        locale: widget.locale,
        title: context.tr('select_university'),
        searchHint: context.tr('search_university'),
        clearLabel: context.tr('clear'),
        emptyText: context.tr('universities_not_found'),
        selectedUniversity: _selectedUniversity,
        onLoadUniversities: widget.onLoadUniversities,
        onSelected: (item) {
          setState(() {
            _selectedUniversity = item;
          });
        },
      ),
    );
  }

  void _showSpecialitySearchDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _SearchableDialog<SpecialityModel>(
        title: context.tr('select_speciality'),
        searchHint: context.tr('search'),
        clearLabel: context.tr('clear'),
        emptyText: context.tr('nothing_found'),
        items: _specialities,
        selectedItem: _selectedSpeciality,
        itemLabel: (item) => item.getLocalizedName(widget.locale),
        searchFilter: (item, query) {
          final lowerQuery = query.toLowerCase();
          return item.nameRu.toLowerCase().contains(lowerQuery) ||
              (item.nameEn?.toLowerCase().contains(lowerQuery) ?? false) ||
              (item.nameKg?.toLowerCase().contains(lowerQuery) ?? false);
        },
        onSelected: (item) {
          setState(() {
            _selectedSpeciality = item;
          });
        },
      ),
    );
  }

  Widget _buildLoadingContainer() {
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

  Widget _buildAgeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(context.tr('age')),
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
                        '${_selectedAge.round()} ${context.tr('years_old')}',
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

class _SearchableDialog<T> extends StatefulWidget {
  const _SearchableDialog({
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.itemLabel,
    required this.searchFilter,
    required this.onSelected,
    required this.searchHint,
    required this.clearLabel,
    required this.emptyText,
  });

  final String title;
  final String searchHint;
  final String clearLabel;
  final String emptyText;
  final List<T> items;
  final T? selectedItem;
  final String Function(T) itemLabel;
  final bool Function(T item, String query) searchFilter;
  final void Function(T?) onSelected;

  @override
  State<_SearchableDialog<T>> createState() => _SearchableDialogState<T>();
}

class _SearchableDialogState<T> extends State<_SearchableDialog<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => widget.searchFilter(item, query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '${widget.searchHint}...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _filterItems('');
                          },
                          icon: const Icon(Icons.close, size: 18),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: _filterItems,
              ),
            ),

            // Clear selection option
            if (widget.selectedItem != null)
              ListTile(
                leading: Icon(Icons.clear, color: AppColors.primary),
                title: Text(
                  widget.clearLabel,
                  style: TextStyle(color: AppColors.primary),
                ),
                onTap: () {
                  widget.onSelected(null);
                  Navigator.of(context).pop();
                },
              ),

            const Divider(height: 1),

            // List
            Flexible(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          widget.emptyText,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = widget.selectedItem == item;

                        return ListTile(
                          title: Text(
                            widget.itemLabel(item),
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade800,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check, color: AppColors.primary)
                              : null,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.onSelected(item);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UniversitySearchDialog extends StatefulWidget {
  const _UniversitySearchDialog({
    required this.locale,
    required this.selectedUniversity,
    required this.onLoadUniversities,
    required this.onSelected,
    required this.title,
    required this.searchHint,
    required this.clearLabel,
    required this.emptyText,
  });

  final String locale;
  final String title;
  final String searchHint;
  final String clearLabel;
  final String emptyText;
  final UniversityModel? selectedUniversity;
  final Future<List<UniversityModel>> Function(String? search) onLoadUniversities;
  final void Function(UniversityModel?) onSelected;

  @override
  State<_UniversitySearchDialog> createState() => _UniversitySearchDialogState();
}

class _UniversitySearchDialogState extends State<_UniversitySearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<UniversityModel> _universities = [];
  bool _isLoading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadUniversities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadUniversities({String? search}) async {
    setState(() {
      _isLoading = true;
    });

    final universities = await widget.onLoadUniversities(search);

    if (mounted) {
      setState(() {
        _universities = universities;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadUniversities(search: query.isEmpty ? null : query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '${widget.searchHint}...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _loadUniversities();
                          },
                          icon: const Icon(Icons.close, size: 18),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            // Clear selection option
            if (widget.selectedUniversity != null)
              ListTile(
                leading: Icon(Icons.clear, color: AppColors.primary),
                title: Text(
                  widget.clearLabel,
                  style: TextStyle(color: AppColors.primary),
                ),
                onTap: () {
                  widget.onSelected(null);
                  Navigator.of(context).pop();
                },
              ),

            const Divider(height: 1),

            // List
            Flexible(
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _universities.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              widget.emptyText,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _universities.length,
                          itemBuilder: (context, index) {
                            final item = _universities[index];
                            final isSelected =
                                widget.selectedUniversity?.id == item.id;

                            return ListTile(
                              title: Text(
                                item.getLocalizedName(widget.locale),
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey.shade800,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(Icons.check, color: AppColors.primary)
                                  : null,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                widget.onSelected(item);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
