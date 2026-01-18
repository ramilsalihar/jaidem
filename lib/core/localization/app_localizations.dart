import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'ky': _kyStrings,
    'ru': _ruStrings,
    'en': _enStrings,
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
           _localizedValues['ky']?[key] ??
           key;
  }

  // Kyrgyz strings
  static const Map<String, String> _kyStrings = {
    // General
    'app_name': 'Jaidem',
    'loading': 'Жүктөлүүдө...',
    'error': 'Ката',
    'success': 'Ийгилик',
    'cancel': 'Жокко чыгаруу',
    'save': 'Сактоо',
    'delete': 'Өчүрүү',
    'edit': 'Өзгөртүү',
    'confirm': 'Ырастоо',
    'yes': 'Ооба',
    'no': 'Жок',
    'ok': 'Макул',
    'back': 'Артка',
    'next': 'Кийинки',
    'done': 'Даяр',
    'search': 'Издөө',
    'retry': 'Кайра аракет',
    'all': 'Баары',
    'clear': 'Тазалоо',
    'apply': 'Колдонуу',
    'reset': 'Баштапкы абалга келтирүү',
    'nothing_found': 'Эч нерсе табылган жок',
    'reload': 'Кайра жүктөө',
    'close': 'Жабуу',

    // Auth
    'login': 'Кирүү',
    'logout': 'Чыгуу',
    'email': 'Email',
    'password': 'Сырсөз',
    'forgot_password': 'Сырсөздү унуттуңузбу?',
    'login_error': 'Кирүү ишке ашкан жок',
    'welcome_message': 'Кош келиңиз',
    'login_to_account': 'Аккаунтка кирүү',
    'enter_credentials': 'Кирүү үчүн маалыматтарыңызды жазыңыз',
    'email_or_phone': 'Email же телефон',
    'enter_email_or_phone': 'Email же телефон жазыңыз',
    'enter_password': 'Сырсөз жазыңыз',
    'password_recovery': 'Сырсөздү калыбына келтирүү',
    'password_recovery_message': 'Сырсөздү калыбына келтирүү үчүн насаатчыңызга кайрылыңыз. Ал сизге сырсөздү кайра орнотууга жардам берет.',
    'understood': 'Түшүндүм',
    'sign_in': 'Кирүү',

    // Menu
    'menu': 'Меню',
    'profile': 'Профиль',
    'settings': 'Жөндөөлөр',
    'language': 'Тил',
    'change_language': 'Тилди өзгөртүү',
    'select_language': 'Тилди тандаңыз',
    'change_password': 'Сырсөздү өзгөртүү',
    'chats': 'Чаттар',
    'files': 'Файлдар',
    'about': 'Колдонмо жөнүндө',

    // Jaidems
    'jaidems': 'Жайдемчилер',
    'search_jaidems': 'Жайдемчилерди издөө...',
    'jaidems_not_found': 'Жайдемчилер табылган жок',
    'change_search_criteria': 'Издөө критерийлерин өзгөртүп көрүңүз',

    // Filters
    'filter': 'Чыпкалоо',
    'flow': 'Агым',
    'flow_number': 'Агым',
    'region': 'Аймак',
    'select_region': 'Аймак тандоо',
    'university': 'Университет',
    'select_university': 'Университет тандоо',
    'search_university': 'Университет издөө...',
    'universities_not_found': 'Университеттер табылган жок',
    'speciality': 'Адистик',
    'select_speciality': 'Адистик тандоо',
    'age': 'Жашы',
    'years_old': 'жаш',

    // Events
    'events': 'Иш-чаралар',
    'required_events': 'Милдеттүү иш-чаралар',
    'optional_events': 'Каалоочуларга',
    'event_details': 'Толук маалымат',
    'event_date': 'Датасы жана убактысы',
    'event_location': 'Жайгашкан жери',
    'event_generation': 'Муун',
    'event_description': 'Сүрөттөмө',
    'event_conditions': 'Шарттар',
    'event_contact': 'Байланыш',
    'event_video': 'Видео',
    'event_passed': 'Иш-чара өттү',
    'event_not_happened': 'Иш-чара али болгон жок',
    'reviews_after_event': 'Иш-чара өткөндөн кийин пикир калтыра аласыз',
    'required': 'Милдеттүү',
    'loading_events': 'Иш-чаралар жүктөлүүдө...',
    'events_load_error': 'Иш-чараларды жүктөөдө ката кетти',

    // Attendance
    'will_go': 'Барам',
    'will_not_go': 'Барбайм',
    'maybe': 'Ойлоном',
    'i_want_to_participate': 'Мен катышкым келет',
    'your_answer': 'Сиздин жообуңуз:',
    'change_answer': 'Жообуңузду өзгөртүү',
    'attendance_success': 'Сурам ийгиликтүү жөнөтүлдү!',
    'attendance_error': 'Жөнөтүү ишке ашкан жок, кийинчерээк кайра аракет кылыңыз.',
    'decline_reason': 'Барбай турган себебиңизди жазыңыз',
    'decline_reason_hint': 'Себебиңизди жазыңыз...',
    'send': 'Жөнөтүү',

    // Reviews
    'reviews': 'Пикирлер',
    'no_reviews': 'Пикирлер жок',
    'be_first_to_review': 'Биринчи болуп пикир калтырыңыз!',
    'write_review': 'Пикир жазуу',
    'edit_review': 'Пикирди түзөтүү',
    'new_review': 'Жаңы пикир',
    'your_review': 'Сиз',
    'write_your_review': 'Пикириңизди жазыңыз...',
    'delete_review': 'Пикирди өчүрүү',
    'delete_review_confirm': 'Сиз чындап эле пикириңизди өчүргүңүз келеби?',
    'review_save_error': 'Пикирди сактоо ишке ашкан жок',
    'review_delete_error': 'Пикирди өчүрүү ишке ашкан жок',

    // Likes
    'likes': 'Жактыруулар',

    // Goals
    'goals': 'Максаттар',
    'my_goals': 'Менин максаттарым',
    'manage_goals': 'Өзүңүздүн максаттарыңызды башкарыңыз',
    'add_goal': 'Максат кошуу',
    'add_task': 'Тапшырма кошуу',
    'add_indicator': 'Индикатор кошуу',
    'no_goals': 'Максаттар жок',
    'start_adding_goal': 'Биринчи максатыңызды кошуп баштаңыз!',
    'press_button_below': 'Төмөндөгү баскычты басыңыз',
    'progress': 'Прогресс',
    'deadline': 'Мөөнөт',
    'remaining': 'Калды',
    'days': 'күн',
    'no_deadline': 'Мөөнөт жок',
    'status_active': 'Активдүү',
    'status_in_progress': 'Аткарылууда',
    'status_completed': 'Аяктаган',
    'status_paused': 'Токтотулган',
    'edit_goal': 'Максатты өзгөртүү',
    'new_goal': 'Жаңы максат',
    'update_goal_info': 'Максатыңыздын маалыматтарын жаңыртыңыз',
    'set_goal_for_success': 'Ийгиликке жетүү үчүн максат коюңуз',
    'basic_info': 'Негизги маалымат',
    'goal_name': 'Максаттын аты',
    'goal_name_hint': 'Англис тилин үйрөнүү',
    'description_optional': 'Сүрөттөмө (милдеттүү эмес)',
    'description_hint': 'Максатыңыз жөнүндө кыскача...',
    'deadline_and_frequency': 'Мөөнөт жана жыштык',
    'end_date': 'Аяктоо күнү',
    'select_date': 'Күндү тандаңыз',
    'frequency': 'Жыштыгы',
    'daily': 'Күн сайын',
    'weekly': 'Жума сайын',
    'monthly': 'Ай сайын',
    'indicators': 'Индикаторлор',
    'reminder': 'Эскертме',
    'reminder_time': 'Эскертме убактысы',
    'select_time': 'Убакытты тандаңыз',
    'goal_name_required': 'Максаттын аты талап кылынат.',
    'name_min_length': 'Аталыш кеминде 3 символдон турушу керек',
    'deadline_required': 'Максаттуу дата милдеттүү түрдө көрсөтүлөт',
    'deadline_past_error': 'Максаттын аткарылуу күнү өткөн чакта болушу мүмкүн эмес.',
    'frequency_required': 'Жыштыгы милдеттүү',
    'reminder_time_required': 'Эскертүү убактысы милдеттүү түрдө көрсөтүлүшү керек',
    'goal_updated_success': 'Максат ийгиликтүү жаңыртылды!',
    'goal_created_success': 'Максат ийгиликтүү түзүлдү!',
    'goal_and_indicators_created': 'Максат жана индикаторлор ийгиликтүү түзүлдү!',
    'indicator_create_error': 'Индикаторду түзүүдө ката кетти',
    'max_indicators': 'Максимум 3 индикатор кошууга болот',

    // Profile
    'edit_profile': 'Профилди түзөтүү',
    'about_me': 'Мен жөнүндө',
    'skills': 'Көндүмдөр',
    'interests': 'Кызыкчылыктар',
    'course_year': 'Курс',
    'village': 'Айыл/Шаар',
    'district': 'Район',
    'information': 'Маалымат',
    'unknown': 'Белгисиз',
    'call': 'Чалуу',
    'contact': 'Байланыш',
    'phone': 'Телефон',

    // Forum
    'forum': 'Форум',
    'feed': 'Лента',
    'posts': 'Посттор',
    'comments': 'Комментарийлер',
    'write_comment': 'Комментарий жазыңыз...',
    'no_posts': 'Посттор жок',
    'no_posts_yet': 'Азырынча эч кандай пост жок',
    'search_hint': 'Издөө...',

    // Video
    'video_load_error': 'Видеону жүктөө ишке ашкан жок',
    'open_in_youtube': 'YouTube\'да ачуу',

    // Languages
    'kyrgyz': 'Кыргызча',
    'russian': 'Орусча',
    'english': 'Англисче',

    // Errors
    'error_occurred': 'Ката кетти',
    'try_again': 'Кайра аракет кылыңыз',
    'no_internet': 'Интернет байланышы жок',

    // Menu / Drawer
    'main_section': 'Негизги',
    'knowledge_base': 'База знаний',
    'chat_list': 'Чаттардын тизмеси',
    'chat_with_admin': 'Администратор менен баарлашуу',
    'chat_with_mentor': 'Насаатчы менен баарлашуу',
    'settings_section': 'Орнотуулар',
    'notifications': 'Эскертмелер',
    'welcome': 'Кош келиңиз!',
    'select_menu_item': 'Менюдан керектүү бөлүмдү тандаңыз',
    'signing_out': 'Чыгууда...',
    'sign_out': 'Аккаунттан чыгуу',
    'sign_out_confirm': 'Чыгууну каалайсызбы?',
    'sign_out_description': 'Аккаунтуңуздан чыгуудан кийин кайра кирүү керек болот',
    'yes_sign_out': 'Ооба, чыгуу',
    'sign_out_failed': 'Чыгуу ишке ашпады',

    // Bottom Navigation
    'nav_home': 'Башкы',
    'nav_jaidem': 'Жайдем',
    'nav_events': 'Иш-чара',
    'nav_profile': 'Профиль',
  };

  // Russian strings
  static const Map<String, String> _ruStrings = {
    // General
    'app_name': 'Jaidem',
    'loading': 'Загрузка...',
    'error': 'Ошибка',
    'success': 'Успех',
    'cancel': 'Отмена',
    'save': 'Сохранить',
    'delete': 'Удалить',
    'edit': 'Изменить',
    'confirm': 'Подтвердить',
    'yes': 'Да',
    'no': 'Нет',
    'ok': 'ОК',
    'back': 'Назад',
    'next': 'Далее',
    'done': 'Готово',
    'search': 'Поиск',
    'retry': 'Повторить',
    'all': 'Все',
    'clear': 'Очистить',
    'apply': 'Применить',
    'reset': 'Сбросить',
    'nothing_found': 'Ничего не найдено',
    'reload': 'Перезагрузить',
    'close': 'Закрыть',

    // Auth
    'login': 'Вход',
    'logout': 'Выход',
    'email': 'Email',
    'password': 'Пароль',
    'forgot_password': 'Забыли пароль?',
    'login_error': 'Ошибка входа',
    'welcome_message': 'Добро пожаловать',
    'login_to_account': 'Войти в аккаунт',
    'enter_credentials': 'Введите данные для входа',
    'email_or_phone': 'Email или телефон',
    'enter_email_or_phone': 'Введите email или телефон',
    'enter_password': 'Введите пароль',
    'password_recovery': 'Восстановление пароля',
    'password_recovery_message': 'Для восстановления пароля обратитесь к вашему ментору. Он поможет вам сбросить пароль и восстановить доступ к аккаунту.',
    'understood': 'Понятно',
    'sign_in': 'Войти',

    // Menu
    'menu': 'Меню',
    'profile': 'Профиль',
    'settings': 'Настройки',
    'language': 'Язык',
    'change_language': 'Изменить язык',
    'select_language': 'Выберите язык',
    'change_password': 'Изменить пароль',
    'chats': 'Чаты',
    'files': 'Файлы',
    'about': 'О приложении',

    // Jaidems
    'jaidems': 'Джайдемчилер',
    'search_jaidems': 'Поиск джайдемчилер...',
    'jaidems_not_found': 'Джайдемчилер не найдены',
    'change_search_criteria': 'Попробуйте изменить критерии поиска',

    // Filters
    'filter': 'Фильтр',
    'flow': 'Поток',
    'flow_number': 'Поток',
    'region': 'Регион',
    'select_region': 'Выберите регион',
    'university': 'Университет',
    'select_university': 'Выберите университет',
    'search_university': 'Поиск университета...',
    'universities_not_found': 'Университеты не найдены',
    'speciality': 'Специальность',
    'select_speciality': 'Выберите специальность',
    'age': 'Возраст',
    'years_old': 'лет',

    // Events
    'events': 'Мероприятия',
    'required_events': 'Обязательные мероприятия',
    'optional_events': 'Для желающих',
    'event_details': 'Подробнее',
    'event_date': 'Дата и время',
    'event_location': 'Местоположение',
    'event_generation': 'Поколение',
    'event_description': 'Описание',
    'event_conditions': 'Условия',
    'event_contact': 'Контакты',
    'event_video': 'Видео',
    'event_passed': 'Мероприятие прошло',
    'event_not_happened': 'Мероприятие еще не состоялось',
    'reviews_after_event': 'Вы сможете оставить отзыв после мероприятия',
    'required': 'Обязательно',
    'loading_events': 'Загрузка мероприятий...',
    'events_load_error': 'Ошибка загрузки мероприятий',

    // Attendance
    'will_go': 'Пойду',
    'will_not_go': 'Не пойду',
    'maybe': 'Думаю',
    'i_want_to_participate': 'Хочу участвовать',
    'your_answer': 'Ваш ответ:',
    'change_answer': 'Изменить ответ',
    'attendance_success': 'Заявка успешно отправлена!',
    'attendance_error': 'Не удалось отправить, попробуйте позже.',
    'decline_reason': 'Укажите причину отказа',
    'decline_reason_hint': 'Напишите причину...',
    'send': 'Отправить',

    // Reviews
    'reviews': 'Отзывы',
    'no_reviews': 'Отзывов нет',
    'be_first_to_review': 'Будьте первым, кто оставит отзыв!',
    'write_review': 'Написать отзыв',
    'edit_review': 'Редактировать отзыв',
    'new_review': 'Новый отзыв',
    'your_review': 'Вы',
    'write_your_review': 'Напишите ваш отзыв...',
    'delete_review': 'Удалить отзыв',
    'delete_review_confirm': 'Вы действительно хотите удалить свой отзыв?',
    'review_save_error': 'Не удалось сохранить отзыв',
    'review_delete_error': 'Не удалось удалить отзыв',

    // Likes
    'likes': 'Лайки',

    // Goals
    'goals': 'Цели',
    'my_goals': 'Мои цели',
    'manage_goals': 'Управляйте своими целями',
    'add_goal': 'Добавить цель',
    'add_task': 'Добавить задачу',
    'add_indicator': 'Добавить индикатор',
    'no_goals': 'Нет целей',
    'start_adding_goal': 'Начните добавлять свою первую цель!',
    'press_button_below': 'Нажмите кнопку внизу',
    'progress': 'Прогресс',
    'deadline': 'Срок',
    'remaining': 'Осталось',
    'days': 'дн.',
    'no_deadline': 'Без срока',
    'status_active': 'Активная',
    'status_in_progress': 'В процессе',
    'status_completed': 'Завершена',
    'status_paused': 'Приостановлена',
    'edit_goal': 'Редактировать цель',
    'new_goal': 'Новая цель',
    'update_goal_info': 'Обновите информацию о вашей цели',
    'set_goal_for_success': 'Поставьте цель для достижения успеха',
    'basic_info': 'Основная информация',
    'goal_name': 'Название цели',
    'goal_name_hint': 'Выучить английский язык',
    'description_optional': 'Описание (необязательно)',
    'description_hint': 'Кратко о вашей цели...',
    'deadline_and_frequency': 'Срок и периодичность',
    'end_date': 'Дата окончания',
    'select_date': 'Выберите дату',
    'frequency': 'Периодичность',
    'daily': 'Ежедневно',
    'weekly': 'Еженедельно',
    'monthly': 'Ежемесячно',
    'indicators': 'Индикаторы',
    'reminder': 'Напоминание',
    'reminder_time': 'Время напоминания',
    'select_time': 'Выберите время',
    'goal_name_required': 'Название цели обязательно.',
    'name_min_length': 'Название должно содержать минимум 3 символа',
    'deadline_required': 'Дата цели обязательна',
    'deadline_past_error': 'Дата цели не может быть в прошлом.',
    'frequency_required': 'Периодичность обязательна',
    'reminder_time_required': 'Время напоминания обязательно',
    'goal_updated_success': 'Цель успешно обновлена!',
    'goal_created_success': 'Цель успешно создана!',
    'goal_and_indicators_created': 'Цель и индикаторы успешно созданы!',
    'indicator_create_error': 'Ошибка при создании индикатора',
    'max_indicators': 'Максимум можно добавить 3 индикатора',

    // Profile
    'edit_profile': 'Редактировать профиль',
    'about_me': 'Обо мне',
    'skills': 'Навыки',
    'interests': 'Интересы',
    'course_year': 'Курс',
    'village': 'Город/село',
    'district': 'Район',
    'information': 'Информация',
    'unknown': 'Неизвестно',
    'call': 'Позвонить',
    'contact': 'Контакты',
    'phone': 'Телефон',

    // Forum
    'forum': 'Форум',
    'feed': 'Лента',
    'posts': 'Посты',
    'comments': 'Комментарии',
    'write_comment': 'Напишите комментарий...',
    'no_posts': 'Нет постов',
    'no_posts_yet': 'Пока нет ни одного поста',
    'search_hint': 'Поиск...',

    // Video
    'video_load_error': 'Не удалось загрузить видео',
    'open_in_youtube': 'Открыть в YouTube',

    // Languages
    'kyrgyz': 'Кыргызский',
    'russian': 'Русский',
    'english': 'Английский',

    // Errors
    'error_occurred': 'Произошла ошибка',
    'try_again': 'Попробуйте снова',
    'no_internet': 'Нет подключения к интернету',

    // Menu / Drawer
    'main_section': 'Основное',
    'knowledge_base': 'База знаний',
    'chat_list': 'Список чатов',
    'chat_with_admin': 'Чат с администратором',
    'chat_with_mentor': 'Чат с наставником',
    'settings_section': 'Настройки',
    'notifications': 'Уведомления',
    'welcome': 'Добро пожаловать!',
    'select_menu_item': 'Выберите нужный раздел в меню',
    'signing_out': 'Выход...',
    'sign_out': 'Выйти из аккаунта',
    'sign_out_confirm': 'Вы хотите выйти?',
    'sign_out_description': 'После выхода из аккаунта потребуется повторный вход',
    'yes_sign_out': 'Да, выйти',
    'sign_out_failed': 'Не удалось выйти',

    // Bottom Navigation
    'nav_home': 'Главная',
    'nav_jaidem': 'Жайдем',
    'nav_events': 'События',
    'nav_profile': 'Профиль',
  };

  // English strings
  static const Map<String, String> _enStrings = {
    // General
    'app_name': 'Jaidem',
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'cancel': 'Cancel',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'confirm': 'Confirm',
    'yes': 'Yes',
    'no': 'No',
    'ok': 'OK',
    'back': 'Back',
    'next': 'Next',
    'done': 'Done',
    'search': 'Search',
    'retry': 'Retry',
    'all': 'All',
    'clear': 'Clear',
    'apply': 'Apply',
    'reset': 'Reset',
    'nothing_found': 'Nothing found',
    'reload': 'Reload',
    'close': 'Close',

    // Auth
    'login': 'Login',
    'logout': 'Logout',
    'email': 'Email',
    'password': 'Password',
    'forgot_password': 'Forgot password?',
    'login_error': 'Login failed',
    'welcome_message': 'Welcome',
    'login_to_account': 'Sign in to your account',
    'enter_credentials': 'Enter your credentials to sign in',
    'email_or_phone': 'Email or phone',
    'enter_email_or_phone': 'Enter email or phone',
    'enter_password': 'Enter password',
    'password_recovery': 'Password Recovery',
    'password_recovery_message': 'To recover your password, please contact your mentor. They will help you reset your password and restore access to your account.',
    'understood': 'Understood',
    'sign_in': 'Sign In',

    // Menu
    'menu': 'Menu',
    'profile': 'Profile',
    'settings': 'Settings',
    'language': 'Language',
    'change_language': 'Change language',
    'select_language': 'Select language',
    'change_password': 'Change password',
    'chats': 'Chats',
    'files': 'Files',
    'about': 'About app',

    // Jaidems
    'jaidems': 'Jaidemchiler',
    'search_jaidems': 'Search jaidemchiler...',
    'jaidems_not_found': 'Jaidemchiler not found',
    'change_search_criteria': 'Try changing search criteria',

    // Filters
    'filter': 'Filter',
    'flow': 'Flow',
    'flow_number': 'Flow',
    'region': 'Region',
    'select_region': 'Select region',
    'university': 'University',
    'select_university': 'Select university',
    'search_university': 'Search university...',
    'universities_not_found': 'Universities not found',
    'speciality': 'Speciality',
    'select_speciality': 'Select speciality',
    'age': 'Age',
    'years_old': 'years old',

    // Events
    'events': 'Events',
    'required_events': 'Required events',
    'optional_events': 'Optional',
    'event_details': 'Details',
    'event_date': 'Date and time',
    'event_location': 'Location',
    'event_generation': 'Generation',
    'event_description': 'Description',
    'event_conditions': 'Conditions',
    'event_contact': 'Contact',
    'event_video': 'Video',
    'event_passed': 'Event has passed',
    'event_not_happened': 'Event has not happened yet',
    'reviews_after_event': 'You can leave a review after the event',
    'required': 'Required',
    'loading_events': 'Loading events...',
    'events_load_error': 'Failed to load events',

    // Attendance
    'will_go': 'Will go',
    'will_not_go': 'Won\'t go',
    'maybe': 'Maybe',
    'i_want_to_participate': 'I want to participate',
    'your_answer': 'Your answer:',
    'change_answer': 'Change answer',
    'attendance_success': 'Request sent successfully!',
    'attendance_error': 'Failed to send, please try again later.',
    'decline_reason': 'Please specify the reason',
    'decline_reason_hint': 'Write your reason...',
    'send': 'Send',

    // Reviews
    'reviews': 'Reviews',
    'no_reviews': 'No reviews',
    'be_first_to_review': 'Be the first to leave a review!',
    'write_review': 'Write a review',
    'edit_review': 'Edit review',
    'new_review': 'New review',
    'your_review': 'You',
    'write_your_review': 'Write your review...',
    'delete_review': 'Delete review',
    'delete_review_confirm': 'Are you sure you want to delete your review?',
    'review_save_error': 'Failed to save review',
    'review_delete_error': 'Failed to delete review',

    // Likes
    'likes': 'Likes',

    // Goals
    'goals': 'Goals',
    'my_goals': 'My Goals',
    'manage_goals': 'Manage your goals',
    'add_goal': 'Add goal',
    'add_task': 'Add task',
    'add_indicator': 'Add indicator',
    'no_goals': 'No goals',
    'start_adding_goal': 'Start adding your first goal!',
    'press_button_below': 'Press the button below',
    'progress': 'Progress',
    'deadline': 'Deadline',
    'remaining': 'Remaining',
    'days': 'days',
    'no_deadline': 'No deadline',
    'status_active': 'Active',
    'status_in_progress': 'In Progress',
    'status_completed': 'Completed',
    'status_paused': 'Paused',
    'edit_goal': 'Edit Goal',
    'new_goal': 'New Goal',
    'update_goal_info': 'Update your goal information',
    'set_goal_for_success': 'Set a goal to achieve success',
    'basic_info': 'Basic Information',
    'goal_name': 'Goal Name',
    'goal_name_hint': 'Learn English',
    'description_optional': 'Description (optional)',
    'description_hint': 'Briefly about your goal...',
    'deadline_and_frequency': 'Deadline and Frequency',
    'end_date': 'End Date',
    'select_date': 'Select date',
    'frequency': 'Frequency',
    'daily': 'Daily',
    'weekly': 'Weekly',
    'monthly': 'Monthly',
    'indicators': 'Indicators',
    'reminder': 'Reminder',
    'reminder_time': 'Reminder Time',
    'select_time': 'Select time',
    'goal_name_required': 'Goal name is required.',
    'name_min_length': 'Name must be at least 3 characters',
    'deadline_required': 'Target date is required',
    'deadline_past_error': 'Goal date cannot be in the past.',
    'frequency_required': 'Frequency is required',
    'reminder_time_required': 'Reminder time is required',
    'goal_updated_success': 'Goal updated successfully!',
    'goal_created_success': 'Goal created successfully!',
    'goal_and_indicators_created': 'Goal and indicators created successfully!',
    'indicator_create_error': 'Error creating indicator',
    'max_indicators': 'Maximum 3 indicators can be added',

    // Profile
    'edit_profile': 'Edit profile',
    'about_me': 'About me',
    'skills': 'Skills',
    'interests': 'Interests',
    'course_year': 'Course',
    'village': 'City/village',
    'district': 'District',
    'information': 'Information',
    'unknown': 'Unknown',
    'call': 'Call',
    'contact': 'Contact',
    'phone': 'Phone',

    // Forum
    'forum': 'Forum',
    'feed': 'Feed',
    'posts': 'Posts',
    'comments': 'Comments',
    'write_comment': 'Write a comment...',
    'no_posts': 'No posts',
    'no_posts_yet': 'No posts yet',
    'search_hint': 'Search...',

    // Video
    'video_load_error': 'Failed to load video',
    'open_in_youtube': 'Open in YouTube',

    // Languages
    'kyrgyz': 'Kyrgyz',
    'russian': 'Russian',
    'english': 'English',

    // Errors
    'error_occurred': 'An error occurred',
    'try_again': 'Try again',
    'no_internet': 'No internet connection',

    // Menu / Drawer
    'main_section': 'Main',
    'knowledge_base': 'Knowledge Base',
    'chat_list': 'Chat List',
    'chat_with_admin': 'Chat with Admin',
    'chat_with_mentor': 'Chat with Mentor',
    'settings_section': 'Settings',
    'notifications': 'Notifications',
    'welcome': 'Welcome!',
    'select_menu_item': 'Select a section from the menu',
    'signing_out': 'Signing out...',
    'sign_out': 'Sign out',
    'sign_out_confirm': 'Do you want to sign out?',
    'sign_out_description': 'You will need to sign in again after signing out',
    'yes_sign_out': 'Yes, sign out',
    'sign_out_failed': 'Failed to sign out',

    // Bottom Navigation
    'nav_home': 'Home',
    'nav_jaidem': 'Jaidem',
    'nav_events': 'Events',
    'nav_profile': 'Profile',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ky', 'ru', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => true;
}

// Extension for easy access
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  String tr(String key) => AppLocalizations.of(this)?.translate(key) ?? key;
}
