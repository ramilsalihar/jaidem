import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/widgets/buttons/app_button.dart';
import 'package:jaidem/core/widgets/fields/app_text_form_field.dart';
import 'package:jaidem/features/profile/presentation/cubit/profile_cubit.dart';

@RoutePage()
class ProfileEditFormPage extends StatefulWidget {
  const ProfileEditFormPage({super.key});

  @override
  State<ProfileEditFormPage> createState() => _ProfileEditFormPageState();
}

class _ProfileEditFormPageState extends State<ProfileEditFormPage> {
  late final TextEditingController dateController;
  late final TextEditingController universityController;
  late final TextEditingController courseYearController;
  late final TextEditingController specialityController;
  late final TextEditingController regionController;
  late final TextEditingController villageController;
  late final TextEditingController interestController;
  late final TextEditingController phoneController;
  late final TextEditingController socialMediaController;

  @override
  void initState() {
    super.initState();

    context.read<ProfileCubit>().getUser();
    dateController = TextEditingController();
    universityController = TextEditingController();
    courseYearController = TextEditingController();
    specialityController = TextEditingController();
    regionController = TextEditingController();
    villageController = TextEditingController();
    interestController = TextEditingController();
    phoneController = TextEditingController();
    socialMediaController = TextEditingController();
  }

  void _fillControllers(PersonModel user) {
    dateController.text = user.dateCreated.toIso8601String();
    universityController.text = user.university ?? "";
    courseYearController.text = user.courseYear.toString();
    specialityController.text = user.speciality ?? "";
    regionController.text = user.region.name;
    villageController.text = user.village.name;
    interestController.text = user.interest ?? "";
    phoneController.text = user.phone ?? "";
    socialMediaController.text = user.socialMedias?['instagram'] ?? "";
  }

  @override
  void dispose() {
    dateController.dispose();
    universityController.dispose();
    courseYearController.dispose();
    specialityController.dispose();
    regionController.dispose();
    villageController.dispose();
    interestController.dispose();
    phoneController.dispose();
    socialMediaController.dispose();
    super.dispose();
  }

  void _onSave(PersonModel user) {
    final updatedUser = user.copyWith(
      dateCreated: DateTime.tryParse(dateController.text) ?? user.dateCreated,
      university: universityController.text,
      courseYear: int.tryParse(courseYearController.text),
      speciality: specialityController.text,
      region: user.region.copyWith(name: regionController.text),
      village: user.village.copyWith(name: villageController.text),
      interest: interestController.text,
      phone: phoneController.text,
      socialMedias: {
        ...?user.socialMedias,
        'instagram': socialMediaController.text,
      },
    );

    context.read<ProfileCubit>().updateUser(updatedUser);

    context.router.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text('Редактировать профиль',
            style: context.textTheme.headlineLarge),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 1,
            color: AppColors.grey,
          ),
        ),
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _fillControllers(state.user);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileError) {
            return Text('Error ${state.message}');
          }
          if (state is ProfileLoaded) {
            final user = state.user;

            return SingleChildScrollView(
              padding:
                  const EdgeInsets.all(16).copyWith(bottom: kToolbarHeight),
              child: Column(
                children: [
                  AppTextFormField(
                      label: 'Дата рождения',
                      hintText: 'Введите дату рождения',
                      controller: dateController),
                  const SizedBox(height: 16),
                  AppTextFormField(
                      label: 'Университет',
                      hintText: 'Манас',
                      controller: universityController),
                  const SizedBox(height: 16),
                  AppTextFormField(
                      label: 'Год обучения',
                      hintText: '2',
                      controller: courseYearController),
                  const SizedBox(height: 16),
                  AppTextFormField(
                      label: 'Специальность',
                      hintText: 'Экономика и менеджмент',
                      controller: specialityController),
                  const SizedBox(height: 16),
                  AppTextFormField(
                      label: 'Регион',
                      hintText: 'Нарын',
                      controller: regionController),
                  const SizedBox(height: 16),
                  AppTextFormField(
                      label: 'Село/город',
                      hintText: 'Кайырма',
                      controller: villageController),
                  const SizedBox(height: 16),
                  AppTextFormField(
                      label: 'Интересы',
                      hintText: 'Футбол, Чтение...',
                      controller: interestController),
                  const SizedBox(height: 16),
                  AppTextFormField(
                      label: 'Телефон',
                      hintText: 'Введите номер телефона',
                      controller: phoneController),
                  const SizedBox(height: 16),
                  AppTextFormField(
                      label: 'Соц сети',
                      hintText: 'Инстаграм',
                      controller: socialMediaController),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Сохранить',
                          borderRadius: 6,
                          backgroundColor: AppColors.primary.shade300,
                          onPressed: () => _onSave(user),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppButton(
                          text: 'Отменить',
                          borderRadius: 6,
                          isOutlined: true,
                          textColor: AppColors.primary.shade300,
                          onPressed: () => context.router.pop(),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
