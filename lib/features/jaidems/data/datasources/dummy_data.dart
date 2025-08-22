// Dummy data for JaidemEntity list
import 'package:jaidem/features/jaidems/domain/entities/jaidem_entity.dart';

final List<JaidemEntity> jaidemList = [
  JaidemEntity(
    id: 1,
    fullname: 'Асель Асанова',
    avatar:
        'https://images.unsplash.com/photo-1494790108755-2616b332c2ef?w=400&h=400&fit=crop&crop=face',
    dateCreated: DateTime.now().subtract(const Duration(days: 30)),
    phone: '+996 556 678 890',
    age: 20,
    university: 'Манас университет',
    login: 'asel_asanova',
    password: 'hashed_password_1',
    courseYear: 2,
    speciality: 'Информационные технологии',
    email: 'asel.asanova@gmail.com',
    socialMedias: {
      'instagram': '@asel_asanova',
      'telegram': '@aselasanova',
      'whatsapp': '+996556678890'
    },
    interest: 'Теннис, книги, программирование',
    skills: 'Flutter, Dart, UI/UX дизайн',
    flow: 1,
    generation: '2023',
    state: 1,
  ),
  JaidemEntity(
    id: 2,
    fullname: 'Бекжан Токтосунов',
    avatar:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face',
    dateCreated: DateTime.now().subtract(const Duration(days: 45)),
    phone: '+996 700 123 456',
    age: 22,
    university: 'Кыргызский национальный университет',
    login: 'bekzhan_t',
    password: 'hashed_password_2',
    courseYear: 3,
    speciality: 'Компьютерная инженерия',
    email: 'bekzhan.toktosunov@mail.ru',
    socialMedias: {
      'instagram': '@bekzhan_tok',
      'telegram': '@bekzhantok',
      'github': 'https://github.com/bekzhan-tok',
      'linkedin': 'https://linkedin.com/in/bekzhan-toktosunov'
    },
    interest: 'Футбол, технологии, путешествия, фотография',
    skills: 'Python, Django, Machine Learning, React',
    flow: 2,
    generation: '2021',
    state: 1,
  ),
  JaidemEntity(
    id: 3,
    fullname: 'Айгуль Максатова',
    avatar:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop&crop=face',
    dateCreated: DateTime.now().subtract(const Duration(days: 15)),
    phone: '+996 777 555 333',
    age: 21,
    university: 'Американский университет в Центральной Азии',
    login: 'aigul_max',
    password: 'hashed_password_3',
    courseYear: 3,
    speciality: 'Бизнес администрирование',
    email: 'aigul.maksatova@auca.kg',
    socialMedias: {
      'instagram': '@aigul_maksatova',
      'telegram': '@aigulmaks',
      'facebook': 'https://facebook.com/aigul.maksatova',
      'linkedin': 'https://linkedin.com/in/aigul-maksatova'
    },
    interest: 'Маркетинг, йога, кулинария, чтение',
    skills: 'Marketing, Project Management, Adobe Creative Suite, Excel',
    flow: 1,
    generation: '2022',
    state: 2,
  ),
  JaidemEntity(
    id: 4,
    fullname: 'Данияр Кенжебаев',
    avatar:
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face',
    dateCreated: DateTime.now().subtract(const Duration(days: 60)),
    phone: '+996 550 987 654',
    age: 23,
    university: 'Кыргызско-Турецкий университет Манас',
    login: 'daniyar_kenz',
    password: 'hashed_password_4',
    courseYear: 4,
    speciality: 'Машиностроение',
    email: 'daniyar.kenzhebaev@student.manas.edu.kg',
    socialMedias: {
      'telegram': '@daniyarkenz',
      'instagram': '@danya_kenz',
      'youtube': 'https://youtube.com/@daniyar_engineering'
    },
    interest: 'Инженерия, автомобили, спорт, музыка',
    skills: 'AutoCAD, SolidWorks, 3D моделирование, Welding',
    flow: 3,
    generation: '2020',
    state: 1,
  ),
  JaidemEntity(
    id: 5,
    fullname: 'Нургуль Бакытова',
    avatar:
        'https://images.unsplash.com/photo-1489424731084-a5d8b219a5bb?w=400&h=400&fit=crop&crop=face',
    dateCreated: DateTime.now().subtract(const Duration(days: 20)),
    phone: '+996 312 456 789',
    age: 19,
    university: 'Кыргызский экономический университет',
    login: 'nurgul_b',
    password: 'hashed_password_5',
    courseYear: 1,
    speciality: 'Международная экономика',
    email: 'nurgul.bakytova@keu.kg',
    socialMedias: {
      'instagram': '@nurgul_bakyt',
      'telegram': '@nurgulbakyt',
      'tiktok': '@nurgul_b_official'
    },
    interest: 'Экономика, танцы, изучение языков, путешествия',
    skills: 'English, Turkish, Economics, Data Analysis',
    flow: 1,
    generation: '2024',
    state: 1,
  ),
  JaidemEntity(
    id: 6,
    fullname: 'Алмаз Сапаров',
    avatar:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop&crop=face',
    dateCreated: DateTime.now().subtract(const Duration(days: 90)),
    phone: '+996 708 111 222',
    age: 24,
    university: 'Кыргызский государственный технический университет',
    login: 'almaz_sap',
    password: 'hashed_password_6',
    courseYear: 4,
    speciality: 'Электроэнергетика',
    email: 'almaz.saparov@kstu.kg',
    socialMedias: {
      'telegram': '@almazsap',
      'instagram': '@almaz_electrical',
      'github': 'https://github.com/almaz-saparov'
    },
    interest: 'Электроника, горные лыжи, шахматы, Arduino проекты',
    skills: 'Electrical Engineering, Arduino, C++, MATLAB',
    flow: 2,
    generation: '2020',
    state: 3,
  ),
  JaidemEntity(
    id: 7,
    fullname: 'Жамиля Осмонова',
    avatar:
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=400&fit=crop&crop=face',
    dateCreated: DateTime.now().subtract(const Duration(days: 8)),
    phone: '+996 995 333 444',
    age: 20,
    university: 'Кыргызско-Российский славянский университет',
    login: 'zhamila_os',
    password: 'hashed_password_7',
    courseYear: 2,
    speciality: 'Журналистика',
    email: 'zhamila.osmonova@krsu.edu.kg',
    socialMedias: {
      'instagram': '@zhamila_journalist',
      'telegram': '@zhamilaos',
      'facebook': 'https://facebook.com/zhamila.osmonova',
      'youtube': 'https://youtube.com/@zhamilanews'
    },
    interest: 'Журналистика, фотография, литература, социальные медиа',
    skills: 'Content Creation, Photography, Video Editing, Writing',
    flow: 1,
    generation: '2023',
    state: 1,
  ),
  JaidemEntity(
    id: 8,
    fullname: 'Эркин Маматов',
    avatar:
        'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=400&h=400&fit=crop&crop=face',
    dateCreated: DateTime.now().subtract(const Duration(days: 120)),
    phone: '+996 553 777 888',
    age: 25,
    university: 'Кыргызская медицинская академия',
    login: 'erkin_mamat',
    password: 'hashed_password_8',
    courseYear: 5,
    speciality: 'Общая медицина',
    email: 'erkin.mamatov@kma.kg',
    socialMedias: {
      'telegram': '@erkinmamat',
      'instagram': '@dr_erkin_m',
      'linkedin': 'https://linkedin.com/in/erkin-mamatov'
    },
    interest: 'Медицина, волейбол, научные исследования, здоровый образ жизни',
    skills: 'Medical Knowledge, Research, First Aid, Patient Care',
    flow: 3,
    generation: '2019',
    state: 2,
  ),
  JaidemEntity(
    id: 9,
    fullname: 'Айжан Тургунова',
    avatar:
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&h=400&fit=crop&crop=face',
    dateCreated: DateTime.now().subtract(const Duration(days: 5)),
    phone: '+996 772 666 555',
    age: 22,
    university: 'Кыргызский аграрный университет',
    login: 'aizhan_tur',
    password: 'hashed_password_9',
    courseYear: 3,
    speciality: 'Ветеринария',
    email: 'aizhan.turgunova@kau.edu.kg',
    socialMedias: {
      'instagram': '@aizhan_vet',
      'telegram': '@aizhanturg',
      'tiktok': '@vet_aizhan'
    },
    interest: 'Ветеринария, животные, природа, экология',
    skills: 'Animal Care, Veterinary Medicine, Biology, Environment Protection',
    flow: 2,
    generation: '2022',
    state: 4,
  ),
  JaidemEntity(
    id: 10,
    fullname: 'Канат Жусупов',
    avatar:
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop&crop=face',
    dateCreated: DateTime.now().subtract(const Duration(days: 75)),
    phone: '+996 709 444 333',
    age: 21,
    university: 'Иссык-Кульский государственный университет',
    login: 'kanat_zhus',
    password: 'hashed_password_10',
    courseYear: 3,
    speciality: 'Туризм и гостиничное дело',
    email: 'kanat.zhusupov@iksu.edu.kg',
    socialMedias: {
      'instagram': '@kanat_tourism',
      'telegram': '@kanatzhus',
      'youtube': 'https://youtube.com/@kanat_travel_kg'
    },
    interest: 'Туризм, горы, фотография, культура Кыргызстана',
    skills: 'Tourism Management, Photography, Hospitality, Cultural Guide',
    flow: 1,
    generation: '2022',
    state: 5,
  ),
  JaidemEntity(
    id: 11,
    fullname: 'Гульмира Абдыкадырова',
    avatar:
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop&crop=face',
    dateCreated: DateTime.now().subtract(const Duration(days: 40)),
    phone: '+996 555 222 111',
    age: 23,
    university: 'Кыргызский государственный университет культуры',
    login: 'gulmira_ab',
    password: 'hashed_password_11',
    courseYear: 4,
    speciality: 'Музыкальное искусство',
    email: 'gulmira.abdykadyrova@kguk.kg',
    socialMedias: {
      'instagram': '@gulmira_music',
      'telegram': '@gulmiraab',
      'youtube': 'https://youtube.com/@gulmira_official',
      'tiktok': '@gulmira_singer'
    },
    interest: 'Музыка, пение, традиционное искусство, концерты',
    skills: 'Singing, Traditional Music, Performance, Music Theory',
    flow: 2,
    generation: '2021',
    state: 1,
  ),
  JaidemEntity(
    id: 12,
    fullname: 'Тимур Калматов',
    avatar:
        'https://images.unsplash.com/photo-1507591064344-4c6ce005b128?w=400&h=400&fit=crop&crop=face',
    dateCreated: DateTime.now().subtract(const Duration(days: 100)),
    phone: '+996 773 888 999',
    age: 24,
    university: 'Кыргызский архитектурно-строительный институт',
    login: 'timur_kalm',
    password: 'hashed_password_12',
    courseYear: 4,
    speciality: 'Архитектура',
    email: 'timur.kalmatov@kasi.edu.kg',
    socialMedias: {
      'instagram': '@timur_architect',
      'telegram': '@timurkalm',
      'behance': 'https://behance.net/timurkalmatov'
    },
    interest: 'Архитектура, дизайн, искусство, современные здания',
    skills: 'AutoCAD, SketchUp, Photoshop, Architectural Design',
    flow: 3,
    generation: '2020',
    state: 1,
  ),
];

// Helper function to get random subset of the list
List<JaidemEntity> getRandomJaidemList(int count) {
  final shuffledList = List<JaidemEntity>.from(jaidemList);
  shuffledList.shuffle();
  return shuffledList.take(count).toList();
}

// Helper function to get jaidems by university
List<JaidemEntity> getJaidemsByUniversity(String university) {
  return jaidemList
      .where((jaidem) =>
          jaidem.university.toLowerCase().contains(university.toLowerCase()))
      .toList();
}

// Helper function to get jaidems by speciality
List<JaidemEntity> getJaidemsBySpeciality(String speciality) {
  return jaidemList
      .where((jaidem) =>
          jaidem.speciality.toLowerCase().contains(speciality.toLowerCase()))
      .toList();
}

// Helper function to get jaidems by course year
List<JaidemEntity> getJaidemsByCourse(int courseYear) {
  return jaidemList.where((jaidem) => jaidem.courseYear == courseYear).toList();
}

// Helper function to get jaidems by age range
List<JaidemEntity> getJaidemsByAgeRange(int minAge, int maxAge) {
  return jaidemList
      .where((jaidem) => jaidem.age >= minAge && jaidem.age <= maxAge)
      .toList();
}

// Helper function to search jaidems by name
List<JaidemEntity> searchJaidemsByName(String query) {
  return jaidemList
      .where((jaidem) =>
          jaidem.fullname?.toLowerCase().contains(query.toLowerCase()) ?? false)
      .toList();
}

// Statistics helper functions
class JaidemStats {
  static int get totalCount => jaidemList.length;

  static Map<String, int> get universitiesCount {
    final Map<String, int> count = {};
    for (final jaidem in jaidemList) {
      count[jaidem.university] = (count[jaidem.university] ?? 0) + 1;
    }
    return count;
  }

  static Map<int, int> get courseYearsCount {
    final Map<int, int> count = {};
    for (final jaidem in jaidemList) {
      count[jaidem.courseYear] = (count[jaidem.courseYear] ?? 0) + 1;
    }
    return count;
  }

  static double get averageAge {
    if (jaidemList.isEmpty) return 0;
    return jaidemList.map((j) => j.age).reduce((a, b) => a + b) /
        jaidemList.length;
  }

  static List<String> get topSkills {
    final Map<String, int> skillsCount = {};

    for (final jaidem in jaidemList) {
      final skills = jaidem.skills.split(',').map((s) => s.trim()).toList();
      for (final skill in skills) {
        skillsCount[skill] = (skillsCount[skill] ?? 0) + 1;
      }
    }

    final sortedSkills = skillsCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedSkills.take(10).map((e) => e.key).toList();
  }
}
