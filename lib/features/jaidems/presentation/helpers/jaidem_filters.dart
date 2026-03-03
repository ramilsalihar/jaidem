import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaidem/core/data/models/jaidem/details/flow_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/region_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/speciality_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/state_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/university_model.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/network/dio_network.dart';
import 'package:jaidem/core/utils/constants/api_const.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

mixin JaidemFilters<T extends StatefulWidget> on State<T> {
  int? selectedGeneration;
  FlowModel? selectedFlow;
  int? selectedAgeMin;
  int? selectedAgeMax;
  StateModel? selectedState;
  RegionModel? selectedRegion;
  UniversityModel? selectedUniversity;
  SpecialityModel? selectedSpeciality;

  List<FlowModel> _flows = [];
  List<StateModel> _states = [];
  List<RegionModel> _regions = [];
  List<UniversityModel> _universities = [];
  List<SpecialityModel> _specialities = [];

  bool _isLoadingFlows = false;
  bool _isLoadingStates = false;
  bool _isLoadingRegions = false;
  bool _isLoadingUniversities = false;
  bool _isLoadingSpecialities = false;

  bool hasActiveFilters() {
    return selectedGeneration != null ||
        selectedFlow != null ||
        selectedAgeMin != null ||
        selectedAgeMax != null ||
        selectedState != null ||
        selectedRegion != null ||
        selectedUniversity != null ||
        selectedSpeciality != null;
  }

  int getActiveFilterCount() {
    int count = 0;
    if (selectedGeneration != null) count++;
    if (selectedFlow != null) count++;
    if (selectedAgeMin != null || selectedAgeMax != null) count++;
    if (selectedState != null) count++;
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

  Future<void> _loadStates() async {
    if (_states.isNotEmpty) return;

    try {
      final response = await DioNetwork.appAPI
          .get('${ApiConst.baseUrl}${ApiConst.states}');
      if (response.statusCode == 200) {
        final data = response.data;
        final List results = data is List ? data : (data['results'] as List? ?? []);
        _states = results.map((e) => StateModel.fromJson(e)).toList();
      }
    } on DioException catch (_) {
      // Handle error silently
    }
  }

  Future<List<RegionModel>> _loadRegions({int? stateId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (stateId != null) {
        queryParams['state'] = stateId;
      }
      final response = await DioNetwork.appAPI.get(
        '${ApiConst.baseUrl}${ApiConst.regions}',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final List results = data is List ? data : (data['results'] as List? ?? []);
        _regions = results.map((e) => RegionModel.fromJson(e)).toList();
        return _regions;
      }
    } on DioException catch (_) {
      // Handle error silently
    }
    return [];
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
          states: _states,
          regions: _regions,
          universities: _universities,
          specialities: _specialities,
          isLoadingFlows: _isLoadingFlows,
          isLoadingStates: _isLoadingStates,
          isLoadingRegions: _isLoadingRegions,
          isLoadingUniversities: _isLoadingUniversities,
          isLoadingSpecialities: _isLoadingSpecialities,
          selectedGeneration: selectedGeneration,
          selectedFlow: selectedFlow,
          selectedAgeMin: selectedAgeMin,
          selectedAgeMax: selectedAgeMax,
          selectedState: selectedState,
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
          onLoadStates: () async {
            if (_states.isEmpty && !_isLoadingStates) {
              _isLoadingStates = true;
              await _loadStates();
              _isLoadingStates = false;
            }
            return _states;
          },
          onLoadRegions: ({int? stateId}) async {
            _isLoadingRegions = true;
            final result = await _loadRegions(stateId: stateId);
            _isLoadingRegions = false;
            return result;
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
          onApply: (generation, flow, ageMin, ageMax, stateModel, region, university, speciality) {
            selectedGeneration = generation;
            selectedFlow = flow;
            selectedAgeMin = ageMin;
            selectedAgeMax = ageMax;
            selectedState = stateModel;
            selectedRegion = region;
            selectedUniversity = university;
            selectedSpeciality = speciality;
            final filters = <String, String?>{
              'generation': generation?.toString(),
              'flow': flow?.id.toString(),
              'age_min': ageMin?.toString(),
              'age_max': ageMax?.toString(),
              'state': stateModel?.id.toString(),
              'region': region?.id.toString(),
              'university': university?.id.toString(),
              'speciality': speciality?.id.toString(),
            };
            onApply(filters);
          },
          onReset: () {
            selectedGeneration = null;
            selectedFlow = null;
            selectedAgeMin = null;
            selectedAgeMax = null;
            selectedState = null;
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
    required this.states,
    required this.regions,
    required this.universities,
    required this.specialities,
    required this.isLoadingFlows,
    required this.isLoadingStates,
    required this.isLoadingRegions,
    required this.isLoadingUniversities,
    required this.isLoadingSpecialities,
    required this.selectedGeneration,
    required this.selectedFlow,
    required this.selectedAgeMin,
    required this.selectedAgeMax,
    required this.selectedState,
    required this.selectedRegion,
    required this.selectedUniversity,
    required this.selectedSpeciality,
    required this.onLoadFlows,
    required this.onLoadStates,
    required this.onLoadRegions,
    required this.onLoadUniversities,
    required this.onLoadSpecialities,
    required this.onApply,
    required this.onReset,
  });

  final String locale;
  final List<FlowModel> flows;
  final List<StateModel> states;
  final List<RegionModel> regions;
  final List<UniversityModel> universities;
  final List<SpecialityModel> specialities;
  final bool isLoadingFlows;
  final bool isLoadingStates;
  final bool isLoadingRegions;
  final bool isLoadingUniversities;
  final bool isLoadingSpecialities;
  final int? selectedGeneration;
  final FlowModel? selectedFlow;
  final int? selectedAgeMin;
  final int? selectedAgeMax;
  final StateModel? selectedState;
  final RegionModel? selectedRegion;
  final UniversityModel? selectedUniversity;
  final SpecialityModel? selectedSpeciality;
  final Future<List<FlowModel>> Function() onLoadFlows;
  final Future<List<StateModel>> Function() onLoadStates;
  final Future<List<RegionModel>> Function({int? stateId}) onLoadRegions;
  final Future<List<UniversityModel>> Function(String? search) onLoadUniversities;
  final Future<List<SpecialityModel>> Function() onLoadSpecialities;
  final void Function(
    int? generation,
    FlowModel? flow,
    int? ageMin,
    int? ageMax,
    StateModel? stateModel,
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
  List<StateModel> _statesList = [];
  List<RegionModel> _regions = [];
  List<SpecialityModel> _specialities = [];

  bool _isLoadingFlows = true;
  bool _isLoadingStates = true;
  bool _isLoadingRegions = false;
  bool _isLoadingSpecialities = true;

  int? _selectedGeneration;
  FlowModel? _selectedFlow;
  RangeValues _ageRange = const RangeValues(18, 25);
  bool _ageFilterEnabled = false;
  StateModel? _selectedState;
  RegionModel? _selectedRegion;
  UniversityModel? _selectedUniversity;
  SpecialityModel? _selectedSpeciality;

  @override
  void initState() {
    super.initState();
    _selectedGeneration = widget.selectedGeneration;
    _selectedFlow = widget.selectedFlow;
    _selectedState = widget.selectedState;
    _selectedRegion = widget.selectedRegion;
    _selectedUniversity = widget.selectedUniversity;
    _selectedSpeciality = widget.selectedSpeciality;
    if (widget.selectedAgeMin != null || widget.selectedAgeMax != null) {
      _ageRange = RangeValues(
        (widget.selectedAgeMin ?? 15).toDouble(),
        (widget.selectedAgeMax ?? 35).toDouble(),
      );
      _ageFilterEnabled = true;
    }
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadFlows(),
      _loadStates(),
      _loadSpecialities(),
    ]);
    if (_selectedState != null) {
      await _loadRegionsByState(_selectedState!.id);
    }
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

  Future<void> _loadStates() async {
    final states = await widget.onLoadStates();
    if (mounted) {
      setState(() {
        _statesList = states;
        _isLoadingStates = false;
      });
    }
  }

  Future<void> _loadRegionsByState(int stateId) async {
    setState(() {
      _isLoadingRegions = true;
    });
    final regions = await widget.onLoadRegions(stateId: stateId);
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
    return _selectedGeneration != null ||
        _selectedFlow != null ||
        _ageFilterEnabled ||
        _selectedState != null ||
        _selectedRegion != null ||
        _selectedUniversity != null ||
        _selectedSpeciality != null;
  }

  void _clearAllFilters() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedGeneration = null;
      _selectedFlow = null;
      _ageFilterEnabled = false;
      _ageRange = const RangeValues(18, 25);
      _selectedState = null;
      _selectedRegion = null;
      _regions = [];
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
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.12),
                            AppColors.primary.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.tr('filter'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1D26),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                if (_hasActiveFilters())
                  GestureDetector(
                    onTap: _clearAllFilters,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.tr('clear'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Content - Scrollable
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context.tr('generation'), Icons.groups_rounded),
                  const SizedBox(height: 10),
                  _buildGenerationSelector(),

                  const SizedBox(height: 20),

                  _buildSectionTitle(context.tr('flow'), Icons.account_tree_rounded),
                  const SizedBox(height: 10),
                  _buildFlowSelector(),

                  const SizedBox(height: 20),

                  _buildSectionTitle(context.tr('state'), Icons.map_rounded),
                  const SizedBox(height: 10),
                  _buildStateSelector(),

                  const SizedBox(height: 20),

                  _buildSectionTitle(context.tr('region'), Icons.location_on_rounded),
                  const SizedBox(height: 10),
                  _buildRegionSelector(),

                  const SizedBox(height: 20),

                  _buildSectionTitle(context.tr('university'), Icons.school_rounded),
                  const SizedBox(height: 10),
                  _buildUniversitySelector(),

                  const SizedBox(height: 20),

                  _buildSectionTitle(context.tr('speciality'), Icons.work_rounded),
                  const SizedBox(height: 10),
                  _buildSpecialitySelector(),

                  const SizedBox(height: 20),

                  _buildAgeSection(),

                  const SizedBox(height: 28),

                  // Apply Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onApply(
                        _selectedGeneration,
                        _selectedFlow,
                        _ageFilterEnabled ? _ageRange.start.round() : null,
                        _ageFilterEnabled ? _ageRange.end.round() : null,
                        _selectedState,
                        _selectedRegion,
                        _selectedUniversity,
                        _selectedSpeciality,
                      );
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.85),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          context.tr('apply'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Reset Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onReset();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Center(
                        child: Text(
                          context.tr('reset'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                          ),
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primary.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildGenerationSelector() {
    return _buildSearchableSelector<int?>(
      selectedValue: _selectedGeneration,
      hint: context.tr('select_generation'),
      selectedLabel: _selectedGeneration != null
          ? '${context.tr('generation')} $_selectedGeneration'
          : null,
      onTap: () => _showGenerationSelectDialog(),
      onClear: () {
        setState(() {
          _selectedGeneration = null;
          _selectedFlow = null;
        });
      },
    );
  }

  void _showGenerationSelectDialog() {
    final generations = [1, 2, 3, 4, 5];
    showDialog(
      context: context,
      builder: (dialogContext) => _SearchableDialog<int>(
        title: context.tr('select_generation'),
        searchHint: context.tr('search'),
        clearLabel: context.tr('clear'),
        emptyText: context.tr('nothing_found'),
        items: generations,
        selectedItem: _selectedGeneration,
        itemLabel: (item) => '${context.tr('generation')} $item',
        searchFilter: (item, query) => item.toString().contains(query),
        onSelected: (item) {
          setState(() {
            if (_selectedGeneration != item &&
                _selectedFlow != null &&
                item != null &&
                _selectedFlow!.generation != item) {
              _selectedFlow = null;
            }
            _selectedGeneration = item;
          });
        },
      ),
    );
  }

  Widget _buildFlowSelector() {
    if (_isLoadingFlows) {
      return _buildLoadingContainer();
    }

    if (_selectedGeneration == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.grey.shade100.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey.shade200.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.info_outline_rounded, color: Colors.amber.shade600, size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.tr('select_generation_first'),
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _buildSearchableSelector<FlowModel>(
      selectedValue: _selectedFlow,
      hint: context.tr('select_flow'),
      selectedLabel: _selectedFlow != null
          ? '${context.tr('flow')} ${_selectedFlow!.name}'
          : null,
      onTap: () => _showFlowSearchDialog(),
      onClear: () {
        setState(() {
          _selectedFlow = null;
        });
      },
    );
  }

  List<FlowModel> _getFilteredFlows() {
    if (_selectedGeneration == null) return _flows;
    return _flows.where((f) => f.generation == _selectedGeneration).toList();
  }

  void _showFlowSearchDialog() {
    final filteredFlows = _getFilteredFlows();
    showDialog(
      context: context,
      builder: (dialogContext) => _SearchableDialog<FlowModel>(
        title: context.tr('select_flow'),
        searchHint: context.tr('search'),
        clearLabel: context.tr('clear'),
        emptyText: context.tr('nothing_found'),
        items: filteredFlows,
        selectedItem: _selectedFlow,
        itemLabel: (item) => '${context.tr('flow')} ${item.name} - ${item.description}',
        searchFilter: (item, query) {
          final lowerQuery = query.toLowerCase();
          return item.name.toLowerCase().contains(lowerQuery) ||
              item.description.toLowerCase().contains(lowerQuery);
        },
        onSelected: (item) {
          setState(() {
            _selectedFlow = item;
          });
        },
      ),
    );
  }

  Widget _buildStateSelector() {
    if (_isLoadingStates) {
      return _buildLoadingContainer();
    }

    return _buildSearchableSelector<StateModel>(
      selectedValue: _selectedState,
      hint: context.tr('select_state'),
      selectedLabel: _selectedState?.getLocalizedName(widget.locale),
      onTap: () => _showStateSearchDialog(),
      onClear: () {
        setState(() {
          _selectedState = null;
          _selectedRegion = null;
          _regions = [];
        });
      },
    );
  }

  void _showStateSearchDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _SearchableDialog<StateModel>(
        title: context.tr('select_state'),
        searchHint: context.tr('search'),
        clearLabel: context.tr('clear'),
        emptyText: context.tr('nothing_found'),
        items: _statesList,
        selectedItem: _selectedState,
        itemLabel: (item) => item.getLocalizedName(widget.locale),
        searchFilter: (item, query) {
          final lowerQuery = query.toLowerCase();
          return item.name.toLowerCase().contains(lowerQuery) ||
              (item.nameRu?.toLowerCase().contains(lowerQuery) ?? false) ||
              (item.nameKg?.toLowerCase().contains(lowerQuery) ?? false);
        },
        onSelected: (item) {
          setState(() {
            if (_selectedState?.id != item?.id) {
              _selectedRegion = null;
              _regions = [];
            }
            _selectedState = item;
          });
          if (item != null) {
            _loadRegionsByState(item.id);
          }
        },
      ),
    );
  }

  Widget _buildRegionSelector() {
    if (_isLoadingRegions) {
      return _buildLoadingContainer();
    }

    if (_selectedState == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.grey.shade100.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey.shade200.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.info_outline_rounded, color: Colors.amber.shade600, size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.tr('select_state_first'),
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
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
    final isSelected = selectedValue != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.35)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isSelected ? Icons.check_circle_rounded : Icons.search_rounded,
                color: isSelected ? AppColors.primary : Colors.grey.shade400,
                size: 14,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedLabel ?? hint,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF1A1D26)
                      : Colors.grey.shade400,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onClear();
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.grey.shade500,
                    size: 13,
                  ),
                ),
              )
            else
              Icon(
                Icons.unfold_more_rounded,
                color: Colors.grey.shade400,
                size: 18,
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
          return item.name.toLowerCase().contains(lowerQuery) ||
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
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withValues(alpha: 0.5)),
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
            _buildSectionTitle(context.tr('age'), Icons.cake_rounded),
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
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_ageRange.start.round()} - ${_ageRange.end.round()} ${context.tr('years_old')}',
                        style: TextStyle(
                          fontSize: 16,
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
                    overlayColor: AppColors.primary.withValues(alpha: 0.2),
                    trackHeight: 6,
                    rangeThumbShape: const RoundRangeSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                  ),
                  child: RangeSlider(
                    values: _ageRange,
                    min: 15,
                    max: 35,
                    divisions: 20,
                    onChanged: (values) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _ageRange = values;
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
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 10, 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade100),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      Icons.list_alt_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1D26),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.close_rounded, size: 16, color: Colors.grey.shade500),
                    ),
                  ),
                ],
              ),
            ),

            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: '${widget.searchHint}...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 6),
                    child: Icon(Icons.search_rounded, size: 18, color: Colors.grey.shade400),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 34),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            _filterItems('');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(Icons.close_rounded, size: 15, color: Colors.grey.shade400),
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  isDense: true,
                ),
                onChanged: _filterItems,
              ),
            ),

            // Clear selection option
            if (widget.selectedItem != null)
              GestureDetector(
                onTap: () {
                  widget.onSelected(null);
                  Navigator.of(context).pop();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.remove_circle_outline_rounded, color: AppColors.primary, size: 15),
                      const SizedBox(width: 8),
                      Text(
                        widget.clearLabel,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Divider(height: 1, color: Colors.grey.shade100),

            // List
            Flexible(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 36,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.emptyText,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      itemCount: _filteredItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 2),
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = widget.selectedItem == item;

                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.onSelected(item);
                            Navigator.of(context).pop();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.08)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.itemLabel(item),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? AppColors.primary
                                          : const Color(0xFF2D3142),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
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
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 10, 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade100),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1D26),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.close_rounded, size: 16, color: Colors.grey.shade500),
                    ),
                  ),
                ],
              ),
            ),

            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: '${widget.searchHint}...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 6),
                    child: Icon(Icons.search_rounded, size: 18, color: Colors.grey.shade400),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 34),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            _loadUniversities();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(Icons.close_rounded, size: 15, color: Colors.grey.shade400),
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  isDense: true,
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            // Clear selection option
            if (widget.selectedUniversity != null)
              GestureDetector(
                onTap: () {
                  widget.onSelected(null);
                  Navigator.of(context).pop();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.remove_circle_outline_rounded, color: AppColors.primary, size: 15),
                      const SizedBox(width: 8),
                      Text(
                        widget.clearLabel,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Divider(height: 1, color: Colors.grey.shade100),

            // List
            Flexible(
              child: _isLoading
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ),
                    )
                  : _universities.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 36,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  widget.emptyText,
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          itemCount: _universities.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 2),
                          itemBuilder: (context, index) {
                            final item = _universities[index];
                            final isSelected =
                                widget.selectedUniversity?.id == item.id;

                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                widget.onSelected(item);
                                Navigator.of(context).pop();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.08)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.getLocalizedName(widget.locale),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: isSelected
                                              ? AppColors.primary
                                              : const Color(0xFF2D3142),
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
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
