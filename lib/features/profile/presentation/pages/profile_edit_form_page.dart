import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaidem/core/data/models/jaidem/details/additional_education_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/other_school_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/success_history_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/region_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/speciality_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/state_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/university_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/village_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/work_place_model.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/network/dio_network.dart';
import 'package:jaidem/core/utils/constants/api_const.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/utils/helpers/time_picker_mixin.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/profile/presentation/cubit/profile_cubit.dart';

@RoutePage()
class ProfileEditFormPage extends StatefulWidget {
  const ProfileEditFormPage({super.key});

  @override
  State<ProfileEditFormPage> createState() => _ProfileEditFormPageState();
}

class _ProfileEditFormPageState extends State<ProfileEditFormPage> with TimePickerMixin {
  late final TextEditingController aboutMeController;
  late final TextEditingController interestController;
  late final TextEditingController skillsController;
  late final TextEditingController phoneController;
  late final TextEditingController instagramController;
  late final TextEditingController whatsappController;

  String? _avatarUrl;
  File? _selectedImage;
  bool _isUploadingImage = false;
  bool _isSaving = false;
  DateTime? _selectedBirthday;

  DateTime? _univerStartDate;
  DateTime? _univerEndDate;
  bool _noUniversity = false;
  List<OtherSchoolModel> _otherSchools = [];
  List<WorkPlaceModel> _workPlaces = [];
  List<SuccessHistoryModel> _successHistory = [];
  List<AdditionalEducationModel> _additionalEducations = [];

  // Selected university and speciality
  UniversityModel? _selectedUniversity;
  SpecialityModel? _selectedSpeciality;
  List<UniversityModel> _universities = [];
  List<SpecialityModel> _specialities = [];
  bool _isLoadingSpecialities = false;

  // Location fields
  StateModel? _selectedState;
  RegionModel? _selectedRegion;
  VillageModel? _selectedVillage;
  List<StateModel> _states = [];
  List<RegionModel> _regions = [];
  List<VillageModel> _villages = [];
  bool _isLoadingStates = false;
  bool _isLoadingRegions = false;
  bool _isLoadingVillages = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().getUser();
    aboutMeController = TextEditingController();
    interestController = TextEditingController();
    skillsController = TextEditingController();
    phoneController = TextEditingController();
    instagramController = TextEditingController();
    whatsappController = TextEditingController();
    _loadSpecialities();
    _loadStates();
    _loadOtherSchools();
    _loadWorkPlaces();
    _loadSuccessHistory();
    _loadAdditionalEducations();
  }

  Future<void> _loadOtherSchools() async {
    try {
      final response = await DioNetwork.appAPI.get(
        '${ApiConst.baseUrl}${ApiConst.otherSchools}',
      );
      if (response.statusCode == 200 && mounted) {
        final List results = response.data is List
            ? response.data
            : (response.data['results'] as List? ?? []);
        setState(() {
          _otherSchools = results
              .map((e) => OtherSchoolModel.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _loadWorkPlaces() async {
    try {
      final response = await DioNetwork.appAPI.get(
        '${ApiConst.baseUrl}${ApiConst.workPlaces}',
      );
      if (response.statusCode == 200 && mounted) {
        final List results = response.data is List
            ? response.data
            : (response.data['results'] as List? ?? []);
        setState(() {
          _workPlaces = results
              .map((e) => WorkPlaceModel.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _loadSuccessHistory() async {
    try {
      final response = await DioNetwork.appAPI.get(
        '${ApiConst.baseUrl}${ApiConst.successHistory}',
      );
      if (response.statusCode == 200 && mounted) {
        final List results = response.data is List
            ? response.data
            : (response.data['results'] as List? ?? []);
        setState(() {
          _successHistory = results
              .map((e) => SuccessHistoryModel.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _loadAdditionalEducations() async {
    try {
      final response = await DioNetwork.appAPI.get(
        '${ApiConst.baseUrl}${ApiConst.additionalEducation}',
      );
      if (response.statusCode == 200 && mounted) {
        final List results = response.data is List
            ? response.data
            : (response.data['results'] as List? ?? []);
        setState(() {
          _additionalEducations = results
              .map((e) => AdditionalEducationModel.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _loadSpecialities() async {
    setState(() {
      _isLoadingSpecialities = true;
    });
    try {
      final response = await DioNetwork.appAPI
          .get('${ApiConst.baseUrl}${ApiConst.specialities}');
      if (response.statusCode == 200) {
        final data = response.data;
        final List results = data is List ? data : (data['results'] as List? ?? []);
        _specialities = results.map((e) => SpecialityModel.fromJson(e)).toList();
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isLoadingSpecialities = false;
      });
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
    } catch (_) {}
    return [];
  }

  Future<void> _loadStates() async {
    setState(() => _isLoadingStates = true);
    try {
      final response = await DioNetwork.appAPI
          .get('${ApiConst.baseUrl}${ApiConst.states}');
      if (response.statusCode == 200) {
        final data = response.data;
        final List results = data is List ? data : (data['results'] as List? ?? []);
        _states = results.map((e) => StateModel.fromJson(e)).toList();
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoadingStates = false);
    }
  }

  Future<void> _loadRegions(int stateId) async {
    setState(() {
      _isLoadingRegions = true;
      _regions = [];
      _villages = [];
      _selectedRegion = null;
      _selectedVillage = null;
    });
    try {
      final response = await DioNetwork.appAPI.get(
        '${ApiConst.baseUrl}${ApiConst.regions}',
        queryParameters: {'state': stateId},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final List results = data is List ? data : (data['results'] as List? ?? []);
        _regions = results.map((e) => RegionModel.fromJson(e)).toList();
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoadingRegions = false);
    }
  }

  Future<void> _loadVillages(int regionId) async {
    setState(() {
      _isLoadingVillages = true;
      _villages = [];
      _selectedVillage = null;
    });
    try {
      final response = await DioNetwork.appAPI.get(
        '${ApiConst.baseUrl}${ApiConst.villages}',
        queryParameters: {'region': regionId},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final List results = data is List ? data : (data['results'] as List? ?? []);
        _villages = results.map((e) => VillageModel.fromJson(e)).toList();
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoadingVillages = false);
    }
  }

  void _fillControllers(PersonModel user) {
    aboutMeController.text = user.aboutMe ?? '';
    if (user.univerStartDate != null && user.univerStartDate!.isNotEmpty) {
      _univerStartDate = DateTime.tryParse(user.univerStartDate!);
    }
    if (user.univerEndDate != null && user.univerEndDate!.isNotEmpty) {
      _univerEndDate = DateTime.tryParse(user.univerEndDate!);
    }
    _noUniversity = user.noUniversity;
    interestController.text = user.interest ?? '';
    skillsController.text = user.skills ?? '';
    phoneController.text = user.phone ?? '';
    instagramController.text = user.socialMedias?['instagram'] ?? '';
    whatsappController.text = user.socialMedias?['whatsapp'] ?? '';
    _avatarUrl = user.avatar;
    _selectedUniversity = user.univer;
    _selectedSpeciality = user.spec;
    if (user.birthday != null && user.birthday!.isNotEmpty) {
      _selectedBirthday = DateTime.tryParse(user.birthday!);
    }
    // Location fields
    if (user.state.id != 0) {
      _selectedState = user.state;
      _loadRegions(user.state.id).then((_) {
        if (user.region != null) {
          setState(() => _selectedRegion = user.region);
          _loadVillages(user.region!.id).then((_) {
            if (user.village != null) {
              setState(() => _selectedVillage = user.village);
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    aboutMeController.dispose();
    interestController.dispose();
    skillsController.dispose();
    phoneController.dispose();
    instagramController.dispose();
    whatsappController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final dio = DioNetwork.appAPI;
      final formData = FormData.fromMap({
        'title': 'avatar_${DateTime.now().millisecondsSinceEpoch}',
        'image': await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: 'avatar.jpg',
        ),
      });

      final response = await dio.post(
        'https://jaidem-back.ru/jaidem/api/category/image/',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final imageUrl = response.data['image'] as String;
        setState(() {
          _avatarUrl = imageUrl;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('image_uploaded')),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.tr('image_upload_error')}: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _onSave(PersonModel user) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final birthdayStr = _selectedBirthday != null
          ? '${_selectedBirthday!.year.toString().padLeft(4, '0')}-${_selectedBirthday!.month.toString().padLeft(2, '0')}-${_selectedBirthday!.day.toString().padLeft(2, '0')}'
          : user.birthday;

      String? formatDate(DateTime? d) => d != null
          ? '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}'
          : null;

      final updatedUser = user.copyWith(
        avatar: _avatarUrl,
        aboutMe: aboutMeController.text,
        interest: interestController.text,
        skills: skillsController.text,
        phone: phoneController.text,
        socialMedias: {
          ...?user.socialMedias,
          'instagram': instagramController.text,
          'whatsapp': whatsappController.text,
        },
        univer: _selectedUniversity,
        spec: _selectedSpeciality,
        birthday: birthdayStr,
        state: _selectedState ?? user.state,
        region: _selectedRegion,
        village: _selectedVillage,
        noUniversity: _noUniversity,
        univerStartDate: formatDate(_univerStartDate) ?? user.univerStartDate,
        univerEndDate: formatDate(_univerEndDate) ?? user.univerEndDate,
      );

      await context.read<ProfileCubit>().updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('profile_saved')),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        context.router.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.tr('save_error')}: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _fillControllers(state.user);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return _buildLoadingState();
          }
          if (state is ProfileError) {
            return _buildErrorState(state.message);
          }
          if (state is ProfileLoaded) {
            return _buildContent(state.user);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('loading'),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('error_occurred'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(PersonModel user) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Header with avatar
          _buildHeader(user),

          // Form fields
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // About me
                _buildSectionTitle(context.tr('about_me'), Icons.person_outline_rounded),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: aboutMeController,
                  hint: context.tr('about_me_hint'),
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                _buildBirthdayPicker(),

                const SizedBox(height: 24),

                // Location section
                _buildSectionTitle(context.tr('location'), Icons.location_on_outlined),
                const SizedBox(height: 12),
                _buildStateSelector(),
                const SizedBox(height: 12),
                _buildRegionSelector(),
                const SizedBox(height: 12),
                _buildVillageSelector(),

                const SizedBox(height: 24),

                // Education section
                _buildSectionTitle(context.tr('education'), Icons.school_outlined),
                const SizedBox(height: 12),
                _buildNoUniversityToggle(),
                if (!_noUniversity) ...[
                  const SizedBox(height: 12),
                  _buildUniversitySelector(),
                  const SizedBox(height: 12),
                  _buildSpecialitySelector(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePickerField(
                          label: context.tr('start_date'),
                          date: _univerStartDate,
                          onTap: () => _pickDate(
                            initial: _univerStartDate,
                            onPicked: (d) => setState(() => _univerStartDate = d),
                          ),
                          onClear: () => setState(() => _univerStartDate = null),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDatePickerField(
                          label: context.tr('end_date'),
                          date: _univerEndDate,
                          onTap: () => _pickDate(
                            initial: _univerEndDate,
                            onPicked: (d) => setState(() => _univerEndDate = d),
                          ),
                          onClear: () => setState(() => _univerEndDate = null),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Other Education section
                _buildSectionTitle(context.tr('other_education'), Icons.menu_book_outlined),
                const SizedBox(height: 12),
                _buildOtherSchoolsList(),

                const SizedBox(height: 24),

                // Additional Education section
                _buildSectionTitle(context.tr('additional_education'), Icons.auto_stories_outlined),
                const SizedBox(height: 12),
                _buildAdditionalEducationList(),

                const SizedBox(height: 24),

                // Work Experience section
                _buildSectionTitle(context.tr('work_experience'), Icons.work_outline_rounded),
                const SizedBox(height: 12),
                _buildWorkPlacesList(),

                const SizedBox(height: 24),

                // Success History section
                _buildSectionTitle(context.tr('success_history'), Icons.emoji_events_outlined),
                const SizedBox(height: 12),
                _buildSuccessHistoryList(),

                const SizedBox(height: 24),

                // Interests & Skills
                _buildSectionTitle(context.tr('interests_and_skills'), Icons.favorite_outline_rounded),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: interestController,
                  hint: context.tr('interests_hint'),
                  icon: Icons.interests_outlined,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: skillsController,
                  hint: context.tr('skills_hint'),
                  icon: Icons.psychology_outlined,
                ),

                const SizedBox(height: 24),

                // Contact info
                _buildSectionTitle(context.tr('contact_info'), Icons.contact_phone_outlined),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: phoneController,
                  hint: context.tr('phone_hint'),
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: whatsappController,
                  hint: context.tr('whatsapp_hint'),
                  icon: Icons.chat_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: instagramController,
                  hint: context.tr('instagram_hint'),
                  icon: Icons.camera_alt_outlined,
                ),

                const SizedBox(height: 32),

                // Action buttons
                _buildActionButtons(user),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(PersonModel user) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.shade700,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.router.pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    context.tr('edit_profile'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Avatar with edit button
            GestureDetector(
              onTap: _isUploadingImage ? null : _pickImage,
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 3,
                      ),
                    ),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white24,
                      ),
                      child: ClipOval(
                        child: _isUploadingImage
                            ? Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : _selectedImage != null
                                ? Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  )
                                : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                    ? Image.network(
                                        _avatarUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _buildDefaultAvatar(user),
                                      )
                                    : _buildDefaultAvatar(user),
                      ),
                    ),
                  ),
                  // Camera icon overlay
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Tap to change text
            Text(
              context.tr('tap_to_change_photo'),
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(PersonModel user) {
    final initial = (user.fullname?.isNotEmpty ?? false) ? user.fullname![0].toUpperCase() : 'U';
    return Container(
      color: Colors.white24,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    keyboardType ??= maxLines > 1 ? TextInputType.multiline : TextInputType.text;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade800,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          prefixIcon: icon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: Icon(
                    icon,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                )
              : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: icon != null ? 0 : 16,
            vertical: maxLines > 1 ? 16 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBirthdayPicker() {
    final displayText = _selectedBirthday != null
        ? '${_selectedBirthday!.day.toString().padLeft(2, '0')}.${_selectedBirthday!.month.toString().padLeft(2, '0')}.${_selectedBirthday!.year}'
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cake_outlined,
            color: Colors.grey.shade400,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              displayText ?? context.tr('select_birthday'),
              style: TextStyle(
                color: displayText != null
                    ? Colors.grey.shade500
                    : Colors.grey.shade400,
                fontSize: 14,
                fontWeight: displayText != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 18),
        ],
      ),
    );
  }

  Widget _buildLocationLoadingContainer() {
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

  Widget _buildDisabledSelector(String hint) {
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
              hint,
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

  Widget _buildLocationSelector<T>({
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

  Widget _buildStateSelector() {
    if (_isLoadingStates) return _buildLocationLoadingContainer();
    final locale = Localizations.localeOf(context).languageCode;
    return _buildLocationSelector<StateModel>(
      selectedValue: _selectedState,
      hint: context.tr('select_state'),
      selectedLabel: _selectedState?.getLocalizedName(locale),
      onTap: () => _showStateSearchDialog(),
      onClear: () {
        setState(() {
          _selectedState = null;
          _selectedRegion = null;
          _selectedVillage = null;
          _regions = [];
          _villages = [];
        });
      },
    );
  }

  Widget _buildRegionSelector() {
    if (_isLoadingRegions) return _buildLocationLoadingContainer();
    if (_selectedState == null) return _buildDisabledSelector(context.tr('select_district_first'));
    final locale = Localizations.localeOf(context).languageCode;
    return _buildLocationSelector<RegionModel>(
      selectedValue: _selectedRegion,
      hint: context.tr('select_district'),
      selectedLabel: _selectedRegion?.getLocalizedName(locale),
      onTap: () => _showRegionSearchDialog(),
      onClear: () {
        setState(() {
          _selectedRegion = null;
          _selectedVillage = null;
          _villages = [];
        });
      },
    );
  }

  Widget _buildVillageSelector() {
    if (_isLoadingVillages) return _buildLocationLoadingContainer();
    if (_selectedRegion == null) return _buildDisabledSelector(context.tr('select_village_first'));
    final locale = Localizations.localeOf(context).languageCode;
    return _buildLocationSelector<VillageModel>(
      selectedValue: _selectedVillage,
      hint: context.tr('select_village'),
      selectedLabel: _selectedVillage?.getLocalizedName(locale),
      onTap: () => _showVillageSearchDialog(),
      onClear: () {
        setState(() => _selectedVillage = null);
      },
    );
  }

  void _showStateSearchDialog() {
    final locale = Localizations.localeOf(context).languageCode;
    showDialog(
      context: context,
      builder: (dialogContext) => _LocationSearchDialog<StateModel>(
        title: context.tr('select_state'),
        searchHint: context.tr('search_hint'),
        clearLabel: context.tr('clear'),
        emptyText: context.tr('select_state'),
        items: _states,
        selectedItem: _selectedState,
        itemLabel: (item) => item.getLocalizedName(locale),
        searchFilter: (item, query) {
          final lowerQuery = query.toLowerCase();
          return item.name.toLowerCase().contains(lowerQuery) ||
              (item.nameRu?.toLowerCase().contains(lowerQuery) ?? false) ||
              (item.nameKg?.toLowerCase().contains(lowerQuery) ?? false);
        },
        onSelected: (item) {
          setState(() {
            _selectedState = item;
            _selectedRegion = null;
            _selectedVillage = null;
            _regions = [];
            _villages = [];
          });
          if (item != null) {
            _loadRegions(item.id);
          }
        },
      ),
    );
  }

  void _showRegionSearchDialog() {
    final locale = Localizations.localeOf(context).languageCode;
    showDialog(
      context: context,
      builder: (dialogContext) => _LocationSearchDialog<RegionModel>(
        title: context.tr('select_district'),
        searchHint: context.tr('search_hint'),
        clearLabel: context.tr('clear'),
        emptyText: context.tr('no_districts_found'),
        items: _regions,
        selectedItem: _selectedRegion,
        itemLabel: (item) => item.getLocalizedName(locale),
        searchFilter: (item, query) {
          final lowerQuery = query.toLowerCase();
          return item.nameEn.toLowerCase().contains(lowerQuery) ||
              (item.nameRu?.toLowerCase().contains(lowerQuery) ?? false) ||
              (item.nameKg?.toLowerCase().contains(lowerQuery) ?? false);
        },
        onSelected: (item) {
          setState(() {
            _selectedRegion = item;
            _selectedVillage = null;
            _villages = [];
          });
          if (item != null) {
            _loadVillages(item.id);
          }
        },
      ),
    );
  }

  void _showVillageSearchDialog() {
    final locale = Localizations.localeOf(context).languageCode;
    showDialog(
      context: context,
      builder: (dialogContext) => _LocationSearchDialog<VillageModel>(
        title: context.tr('select_village'),
        searchHint: context.tr('search_hint'),
        clearLabel: context.tr('clear'),
        emptyText: context.tr('no_villages_found'),
        items: _villages,
        selectedItem: _selectedVillage,
        itemLabel: (item) => item.getLocalizedName(locale),
        searchFilter: (item, query) {
          final lowerQuery = query.toLowerCase();
          return item.name.toLowerCase().contains(lowerQuery) ||
              (item.nameRu?.toLowerCase().contains(lowerQuery) ?? false) ||
              (item.nameKg?.toLowerCase().contains(lowerQuery) ?? false);
        },
        onSelected: (item) {
          setState(() => _selectedVillage = item);
        },
      ),
    );
  }

  Widget _buildNoUniversityToggle() {
    return GestureDetector(
      onTap: () => setState(() => _noUniversity = !_noUniversity),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _noUniversity
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _noUniversity
                ? AppColors.primary.withValues(alpha: 0.35)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _noUniversity,
                onChanged: (v) => setState(() => _noUniversity = v ?? false),
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.tr('no_university'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: _noUniversity ? FontWeight.w600 : FontWeight.w400,
                  color: _noUniversity
                      ? const Color(0xFF1A1D26)
                      : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _buildDateRange(String? startDate, String? endDate) {
    final start = startDate != null ? DateTime.tryParse(startDate) : null;
    final end = endDate != null ? DateTime.tryParse(endDate) : null;
    if (start == null && end == null) return null;
    final s = start != null ? _formatDateShort(start) : '...';
    final e = end != null ? _formatDateShort(end) : '...';
    return '$s — $e';
  }

  Widget _buildOtherSchoolsList() {
    return Column(
      children: [
        ..._otherSchools.map((school) {
          final dateRange = _buildDateRange(school.startDate, school.endDate);
          final subtitle = [
            if (school.description.isNotEmpty) school.description,
            if (dateRange != null) dateRange,
          ].join(' · ');
          return _buildCrudItem(
            title: school.name,
            subtitle: subtitle.isNotEmpty ? subtitle : null,
            onEdit: () => _showOtherSchoolDialog(school: school),
            onDelete: () => _deleteOtherSchool(school.id),
          );
        }),
        _buildAddButton(
          context.tr('add_school'),
          onTap: () => _showOtherSchoolDialog(),
        ),
      ],
    );
  }

  Widget _buildWorkPlacesList() {
    return Column(
      children: [
        ..._workPlaces.map((wp) {
          final dateRange = _buildDateRange(wp.startDate, wp.endDate);
          final subtitle = [
            if (wp.position.isNotEmpty) wp.position,
            if (dateRange != null) dateRange,
          ].join(' · ');
          return _buildCrudItem(
            title: wp.name,
            subtitle: subtitle.isNotEmpty ? subtitle : null,
            onEdit: () => _showWorkPlaceDialog(workPlace: wp),
            onDelete: () => _deleteWorkPlace(wp.id),
          );
        }),
        _buildAddButton(
          context.tr('add_work_place'),
          onTap: () => _showWorkPlaceDialog(),
        ),
      ],
    );
  }

  Widget _buildCrudItem({
    required String title,
    String? subtitle,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1D26),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogDatePicker({
    required BuildContext ctx,
    required String label,
    DateTime? date,
    required ValueChanged<DateTime> onPicked,
    required VoidCallback onClear,
  }) {
    return GestureDetector(
      onTap: () async {
        await showCupertinoDatePicker(
          context: ctx,
          initialDate: date,
          minimumDate: DateTime(1990),
          maximumDate: DateTime(2040),
          onDateSelected: onPicked,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                date != null ? _formatDateShort(date) : label,
                style: TextStyle(
                  fontSize: 12,
                  color: date != null ? const Color(0xFF1A1D26) : Colors.grey.shade400,
                ),
              ),
            ),
            if (date != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded, size: 14, color: Colors.grey.shade400),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showOtherSchoolDialog({OtherSchoolModel? school}) async {
    final nameController = TextEditingController(text: school?.name ?? '');
    final descController = TextEditingController(text: school?.description ?? '');
    DateTime? startDate = school?.startDate != null ? DateTime.tryParse(school!.startDate!) : null;
    DateTime? endDate = school?.endDate != null ? DateTime.tryParse(school!.endDate!) : null;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            context.tr('add_school'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: context.tr('school_name'),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  hintText: context.tr('description'),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDialogDatePicker(
                      ctx: ctx,
                      label: context.tr('start_date'),
                      date: startDate,
                      onPicked: (d) => setDialogState(() => startDate = d),
                      onClear: () => setDialogState(() => startDate = null),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDialogDatePicker(
                      ctx: ctx,
                      label: context.tr('end_date'),
                      date: endDate,
                      onPicked: (d) => setDialogState(() => endDate = d),
                      onClear: () => setDialogState(() => endDate = null),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(context.tr('save')),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      try {
        String? fmtDate(DateTime? d) => d != null
            ? '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}'
            : null;
        final data = <String, dynamic>{
          'name': nameController.text.trim(),
          'description': descController.text.trim(),
          if (fmtDate(startDate) != null) 'dateStart': fmtDate(startDate),
          if (fmtDate(endDate) != null) 'dateEnd': fmtDate(endDate),
        };
        if (school != null) {
          await DioNetwork.appAPI.patch(
            '${ApiConst.baseUrl}${ApiConst.otherSchools}${school.id}/',
            data: data,
          );
        } else {
          await DioNetwork.appAPI.post(
            '${ApiConst.baseUrl}${ApiConst.otherSchools}',
            data: data,
          );
        }
        await _loadOtherSchools();
      } catch (_) {}
    }
    nameController.dispose();
    descController.dispose();
  }

  Future<void> _deleteOtherSchool(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.tr('delete'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(context.tr('delete_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.tr('cancel'))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await DioNetwork.appAPI.delete('${ApiConst.baseUrl}${ApiConst.otherSchools}$id/');
        await _loadOtherSchools();
      } catch (_) {}
    }
  }

  Future<void> _showWorkPlaceDialog({WorkPlaceModel? workPlace}) async {
    final nameController = TextEditingController(text: workPlace?.name ?? '');
    final positionController = TextEditingController(text: workPlace?.position ?? '');
    final descController = TextEditingController(text: workPlace?.description ?? '');
    DateTime? startDate = workPlace?.startDate != null ? DateTime.tryParse(workPlace!.startDate!) : null;
    DateTime? endDate = workPlace?.endDate != null ? DateTime.tryParse(workPlace!.endDate!) : null;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            context.tr('add_work_place'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: context.tr('work_place_name'),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: positionController,
                decoration: InputDecoration(
                  hintText: context.tr('position'),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  hintText: context.tr('description'),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDialogDatePicker(
                      ctx: ctx,
                      label: context.tr('start_date'),
                      date: startDate,
                      onPicked: (d) => setDialogState(() => startDate = d),
                      onClear: () => setDialogState(() => startDate = null),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDialogDatePicker(
                      ctx: ctx,
                      label: context.tr('end_date'),
                      date: endDate,
                      onPicked: (d) => setDialogState(() => endDate = d),
                      onClear: () => setDialogState(() => endDate = null),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(context.tr('save')),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      try {
        String? fmtDate(DateTime? d) => d != null
            ? '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}'
            : null;
        final data = <String, dynamic>{
          'name': nameController.text.trim(),
          'position': positionController.text.trim(),
          'description': descController.text.trim(),
          if (fmtDate(startDate) != null) 'dateStart': fmtDate(startDate),
          if (fmtDate(endDate) != null) 'dateEnd': fmtDate(endDate),
        };
        if (workPlace != null) {
          await DioNetwork.appAPI.patch(
            '${ApiConst.baseUrl}${ApiConst.workPlaces}${workPlace.id}/',
            data: data,
          );
        } else {
          await DioNetwork.appAPI.post(
            '${ApiConst.baseUrl}${ApiConst.workPlaces}',
            data: data,
          );
        }
        await _loadWorkPlaces();
      } catch (_) {}
    }
    nameController.dispose();
    positionController.dispose();
    descController.dispose();
  }

  Future<void> _deleteWorkPlace(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.tr('delete'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(context.tr('delete_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.tr('cancel'))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await DioNetwork.appAPI.delete('${ApiConst.baseUrl}${ApiConst.workPlaces}$id/');
        await _loadWorkPlaces();
      } catch (_) {}
    }
  }

  Widget _buildSuccessHistoryList() {
    return Column(
      children: [
        ..._successHistory.map((sh) => _buildCrudItem(
              title: sh.name,
              subtitle: sh.description.isNotEmpty ? sh.description : null,
              onEdit: () => _showSuccessHistoryDialog(successHistory: sh),
              onDelete: () => _deleteSuccessHistory(sh.id),
            )),
        _buildAddButton(
          context.tr('add_success'),
          onTap: () => _showSuccessHistoryDialog(),
        ),
      ],
    );
  }

  Future<void> _showSuccessHistoryDialog({SuccessHistoryModel? successHistory}) async {
    final nameController = TextEditingController(text: successHistory?.name ?? '');
    final descController = TextEditingController(text: successHistory?.description ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          context.tr('add_success'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: context.tr('success_name'),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                hintText: context.tr('description'),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      try {
        final data = {
          'name': nameController.text.trim(),
          'description': descController.text.trim(),
        };
        if (successHistory != null) {
          await DioNetwork.appAPI.patch(
            '${ApiConst.baseUrl}${ApiConst.successHistory}${successHistory.id}/',
            data: data,
          );
        } else {
          await DioNetwork.appAPI.post(
            '${ApiConst.baseUrl}${ApiConst.successHistory}',
            data: data,
          );
        }
        await _loadSuccessHistory();
      } catch (_) {}
    }
    nameController.dispose();
    descController.dispose();
  }

  Future<void> _deleteSuccessHistory(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.tr('delete'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(context.tr('delete_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.tr('cancel'))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await DioNetwork.appAPI.delete('${ApiConst.baseUrl}${ApiConst.successHistory}$id/');
        await _loadSuccessHistory();
      } catch (_) {}
    }
  }

  Widget _buildAdditionalEducationList() {
    return Column(
      children: [
        ..._additionalEducations.map((ae) => _buildCrudItem(
              title: ae.title,
              subtitle: ae.description.isNotEmpty ? ae.description : null,
              onEdit: () => _showAdditionalEducationDialog(education: ae),
              onDelete: () => _deleteAdditionalEducation(ae.id),
            )),
        _buildAddButton(
          context.tr('add_additional_education'),
          onTap: () => _showAdditionalEducationDialog(),
        ),
      ],
    );
  }

  Future<void> _showAdditionalEducationDialog({AdditionalEducationModel? education}) async {
    final titleController = TextEditingController(text: education?.title ?? '');
    final descController = TextEditingController(text: education?.description ?? '');
    DateTime? startDate = education?.dateStart != null ? DateTime.tryParse(education!.dateStart!) : null;
    DateTime? endDate = education?.dateEnd != null ? DateTime.tryParse(education!.dateEnd!) : null;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            context.tr('add_additional_education'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: context.tr('additional_education_title'),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  hintText: context.tr('description'),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDialogDatePicker(
                      ctx: ctx,
                      label: context.tr('start_date'),
                      date: startDate,
                      onPicked: (d) => setDialogState(() => startDate = d),
                      onClear: () => setDialogState(() => startDate = null),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDialogDatePicker(
                      ctx: ctx,
                      label: context.tr('end_date'),
                      date: endDate,
                      onPicked: (d) => setDialogState(() => endDate = d),
                      onClear: () => setDialogState(() => endDate = null),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(context.tr('save')),
            ),
          ],
        ),
      ),
    );

    if (result == true && titleController.text.trim().isNotEmpty) {
      try {
        String? fmtDate(DateTime? d) => d != null
            ? '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}'
            : null;
        final data = <String, dynamic>{
          'title': titleController.text.trim(),
          'description': descController.text.trim(),
          if (fmtDate(startDate) != null) 'dateStart': fmtDate(startDate),
          if (fmtDate(endDate) != null) 'dateEnd': fmtDate(endDate),
        };
        if (education != null) {
          await DioNetwork.appAPI.patch(
            '${ApiConst.baseUrl}${ApiConst.additionalEducation}${education.id}/',
            data: data,
          );
        } else {
          await DioNetwork.appAPI.post(
            '${ApiConst.baseUrl}${ApiConst.additionalEducation}',
            data: data,
          );
        }
        await _loadAdditionalEducations();
      } catch (_) {}
    }
    titleController.dispose();
    descController.dispose();
  }

  Future<void> _deleteAdditionalEducation(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.tr('delete'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(context.tr('delete_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.tr('cancel'))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await DioNetwork.appAPI.delete('${ApiConst.baseUrl}${ApiConst.additionalEducation}$id/');
        await _loadAdditionalEducations();
      } catch (_) {}
    }
  }

  Future<void> _pickDate({
    DateTime? initial,
    required ValueChanged<DateTime> onPicked,
  }) async {
    await showCupertinoDatePicker(
      context: context,
      initialDate: initial,
      minimumDate: DateTime(1990),
      maximumDate: DateTime(2040),
      onDateSelected: onPicked,
    );
  }

  String _formatDateShort(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  Widget _buildDatePickerField({
    required String label,
    DateTime? date,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey.shade500),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null ? _formatDateShort(date) : label,
                style: TextStyle(
                  fontSize: 13,
                  color: date != null ? const Color(0xFF1A1D26) : Colors.grey.shade400,
                  fontWeight: date != null ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            if (date != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded, size: 16, color: Colors.grey.shade400),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUniversitySelector() {
    return _buildLocationSelector<UniversityModel>(
      selectedValue: _selectedUniversity,
      hint: context.tr('select_university_hint'),
      selectedLabel: _selectedUniversity?.name,
      onTap: () => _showUniversitySearchDialog(),
      onClear: () => setState(() => _selectedUniversity = null),
    );
  }

  Widget _buildSpecialitySelector() {
    final locale = Localizations.localeOf(context).languageCode;
    return _buildLocationSelector<SpecialityModel>(
      selectedValue: _selectedSpeciality,
      hint: context.tr('specialty'),
      selectedLabel: _selectedSpeciality?.getLocalizedName(locale),
      onTap: () => _showSpecialitySearchDialog(),
      onClear: () => setState(() => _selectedSpeciality = null),
    );
  }

  void _showUniversitySearchDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _UniversitySearchDialog(
        selectedUniversity: _selectedUniversity,
        onLoadUniversities: _loadUniversities,
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
      builder: (dialogContext) => _SpecialitySearchDialog(
        specialities: _specialities,
        isLoading: _isLoadingSpecialities,
        selectedSpeciality: _selectedSpeciality,
        onSelected: (item) {
          setState(() {
            _selectedSpeciality = item;
          });
        },
      ),
    );
  }

  Widget _buildActionButtons(PersonModel user) {
    return Column(
      children: [
        // Save button
        GestureDetector(
          onTap: _isSaving ? null : () => _onSave(user),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isSaving
                    ? [Colors.grey.shade400, Colors.grey.shade500]
                    : [AppColors.primary, AppColors.primary.shade600],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _isSaving
                      ? Colors.grey.withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSaving)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  _isSaving ? context.tr('saving') : context.tr('save'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Cancel button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.router.pop();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.close_rounded, color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 10),
                Text(
                  context.tr('cancel'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _UniversitySearchDialog extends StatefulWidget {
  const _UniversitySearchDialog({
    required this.selectedUniversity,
    required this.onLoadUniversities,
    required this.onSelected,
  });

  final UniversityModel? selectedUniversity;
  final Future<List<UniversityModel>> Function({String? search}) onLoadUniversities;
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

    final universities = await widget.onLoadUniversities(search: search);

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
                      Icons.account_balance_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.tr('select_university_hint'),
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
                  hintText: '${context.tr('search_hint')}...',
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        context.tr('clear'),
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
                          width: 28,
                          height: 28,
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
                                  context.tr('no_universities_found'),
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
                            final isSelected = widget.selectedUniversity?.id == item.id;

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
                                        item.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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

class _SpecialitySearchDialog extends StatefulWidget {
  const _SpecialitySearchDialog({
    required this.specialities,
    required this.isLoading,
    required this.selectedSpeciality,
    required this.onSelected,
  });

  final List<SpecialityModel> specialities;
  final bool isLoading;
  final SpecialityModel? selectedSpeciality;
  final void Function(SpecialityModel?) onSelected;

  @override
  State<_SpecialitySearchDialog> createState() => _SpecialitySearchDialogState();
}

class _SpecialitySearchDialogState extends State<_SpecialitySearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<SpecialityModel> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.specialities;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getLocale() => Localizations.localeOf(context).languageCode;

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.specialities;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredItems = widget.specialities
            .where((item) =>
                item.name.toLowerCase().contains(lowerQuery) ||
                (item.nameEn?.toLowerCase().contains(lowerQuery) ?? false) ||
                (item.nameKg?.toLowerCase().contains(lowerQuery) ?? false))
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
                      Icons.work_outline_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.tr('select_speciality_hint'),
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
                  hintText: '${context.tr('search_hint')}...',
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  isDense: true,
                ),
                onChanged: _filterItems,
              ),
            ),

            // Clear selection option
            if (widget.selectedSpeciality != null)
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
                        context.tr('clear'),
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
              child: widget.isLoading
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ),
                    )
                  : _filteredItems.isEmpty
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
                                  context.tr('specialities_not_found'),
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
                            final isSelected = widget.selectedSpeciality?.id == item.id;
                            final locale = _getLocale();

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
                                        item.getLocalizedName(locale),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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

class _LocationSearchDialog<T> extends StatefulWidget {
  const _LocationSearchDialog({
    super.key,
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
  State<_LocationSearchDialog<T>> createState() => _LocationSearchDialogState<T>();
}

class _LocationSearchDialogState<T> extends State<_LocationSearchDialog<T>> {
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
