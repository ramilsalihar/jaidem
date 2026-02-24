import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaidem/core/data/models/jaidem/details/speciality_model.dart';
import 'package:jaidem/core/data/models/jaidem/details/university_model.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/network/dio_network.dart';
import 'package:jaidem/core/utils/constants/api_const.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/profile/presentation/cubit/profile_cubit.dart';

@RoutePage()
class ProfileEditFormPage extends StatefulWidget {
  const ProfileEditFormPage({super.key});

  @override
  State<ProfileEditFormPage> createState() => _ProfileEditFormPageState();
}

class _ProfileEditFormPageState extends State<ProfileEditFormPage> {
  late final TextEditingController aboutMeController;
  late final TextEditingController courseYearController;
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

  // Selected university and speciality
  UniversityModel? _selectedUniversity;
  SpecialityModel? _selectedSpeciality;
  List<UniversityModel> _universities = [];
  List<SpecialityModel> _specialities = [];
  bool _isLoadingSpecialities = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().getUser();
    aboutMeController = TextEditingController();
    courseYearController = TextEditingController();
    interestController = TextEditingController();
    skillsController = TextEditingController();
    phoneController = TextEditingController();
    instagramController = TextEditingController();
    whatsappController = TextEditingController();
    _loadSpecialities();
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

  void _fillControllers(PersonModel user) {
    aboutMeController.text = user.aboutMe ?? '';
    courseYearController.text = user.courseYear.toString();
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
  }

  @override
  void dispose() {
    aboutMeController.dispose();
    courseYearController.dispose();
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
              content: const Text('Сүрөт ийгиликтүү жүктөлдү'),
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
            content: Text('Сүрөт жүктөөдө ката: $e'),
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

      final updatedUser = user.copyWith(
        avatar: _avatarUrl,
        aboutMe: aboutMeController.text,
        courseYear: int.tryParse(courseYearController.text) ?? user.courseYear,
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
      );

      await context.read<ProfileCubit>().updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Профиль ийгиликтүү сакталды'),
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
            content: Text('Сактоодо ката: $e'),
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
            'Жүктөлүүдө...',
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
              'Ката кетти',
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
                _buildSectionTitle('Мен жөнүндө', Icons.person_outline_rounded),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: aboutMeController,
                  hint: 'Өзүңүз тууралуу маалымат жазыңыз...',
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                _buildBirthdayPicker(),

                const SizedBox(height: 24),

                // Education section
                _buildSectionTitle('Билим', Icons.school_outlined),
                const SizedBox(height: 12),
                _buildUniversitySelector(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: courseYearController,
                        hint: 'Окуу жылы',
                        icon: Icons.calendar_today_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _buildSpecialitySelector(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Interests & Skills
                _buildSectionTitle('Кызыкчылыктар жана көндүмдөр', Icons.favorite_outline_rounded),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: interestController,
                  hint: 'Кызыкчылыктар (мис: Футбол, Китеп окуу...)',
                  icon: Icons.interests_outlined,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: skillsController,
                  hint: 'Көндүмдөр (мис: Программирование, Дизайн...)',
                  icon: Icons.psychology_outlined,
                ),

                const SizedBox(height: 24),

                // Contact info
                _buildSectionTitle('Байланыш маалыматы', Icons.contact_phone_outlined),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: phoneController,
                  hint: 'Телефон номери',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: whatsappController,
                  hint: 'WhatsApp номери',
                  icon: Icons.chat_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: instagramController,
                  hint: 'Instagram колдонуучу аты',
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
                  const Text(
                    'Профилди түзөтүү',
                    style: TextStyle(
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
              'Сүрөттү өзгөртүү үчүн басыңыз',
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
    TextInputType keyboardType = TextInputType.text,
  }) {
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

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedBirthday ?? DateTime(2000, 1, 1),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => _selectedBirthday = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: displayText != null
                ? AppColors.primary.withValues(alpha: 0.5)
                : Colors.grey.shade200,
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
                displayText ?? 'Туулган күнүңүздү тандаңыз',
                style: TextStyle(
                  color: displayText != null
                      ? Colors.grey.shade800
                      : Colors.grey.shade400,
                  fontSize: 14,
                  fontWeight: displayText != null ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            Icon(Icons.calendar_month_outlined, color: Colors.grey.shade500, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUniversitySelector() {
    return GestureDetector(
      onTap: () => _showUniversitySearchDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedUniversity != null
                ? AppColors.primary.withValues(alpha: 0.5)
                : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.account_balance_outlined,
              color: Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedUniversity?.name ?? 'Университет тандаңыз',
                style: TextStyle(
                  color: _selectedUniversity != null
                      ? Colors.grey.shade800
                      : Colors.grey.shade400,
                  fontSize: 14,
                  fontWeight: _selectedUniversity != null ? FontWeight.w500 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_selectedUniversity != null)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedUniversity = null;
                  });
                },
                child: Icon(Icons.close, color: Colors.grey.shade500, size: 18),
              )
            else
              Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialitySelector() {
    return GestureDetector(
      onTap: () => _showSpecialitySearchDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedSpeciality != null
                ? AppColors.primary.withValues(alpha: 0.5)
                : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.work_outline_rounded,
              color: Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedSpeciality?.name ?? 'Адистик',
                style: TextStyle(
                  color: _selectedSpeciality != null
                      ? Colors.grey.shade800
                      : Colors.grey.shade400,
                  fontSize: 14,
                  fontWeight: _selectedSpeciality != null ? FontWeight.w500 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_selectedSpeciality != null)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedSpeciality = null;
                  });
                },
                child: Icon(Icons.close, color: Colors.grey.shade500, size: 18),
              )
            else
              Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500, size: 20),
          ],
        ),
      ),
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
                  _isSaving ? 'Сакталууда...' : 'Сактоо',
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
                  'Жокко чыгаруу',
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Университет тандаңыз',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Издөө...',
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            if (widget.selectedUniversity != null)
              ListTile(
                leading: Icon(Icons.clear, color: AppColors.primary),
                title: Text('Тазалоо', style: TextStyle(color: AppColors.primary)),
                onTap: () {
                  widget.onSelected(null);
                  Navigator.of(context).pop();
                },
              ),
            const Divider(height: 1),
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
                              'Университеттер табылган жок',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _universities.length,
                          itemBuilder: (context, index) {
                            final item = _universities[index];
                            final isSelected = widget.selectedUniversity?.id == item.id;

                            return ListTile(
                              dense: true,
                              title: Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected ? AppColors.primary : Colors.grey.shade800,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(Icons.check, color: AppColors.primary, size: 20)
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Адистик тандаңыз',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Издөө...',
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: _filterItems,
              ),
            ),
            if (widget.selectedSpeciality != null)
              ListTile(
                leading: Icon(Icons.clear, color: AppColors.primary),
                title: Text('Тазалоо', style: TextStyle(color: AppColors.primary)),
                onTap: () {
                  widget.onSelected(null);
                  Navigator.of(context).pop();
                },
              ),
            const Divider(height: 1),
            Flexible(
              child: widget.isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _filteredItems.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'Адистиктер табылган жок',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            final isSelected = widget.selectedSpeciality?.id == item.id;

                            return ListTile(
                              dense: true,
                              title: Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected ? AppColors.primary : Colors.grey.shade800,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(Icons.check, color: AppColors.primary, size: 20)
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
