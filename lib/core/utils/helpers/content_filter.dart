class ContentFilter {
  static final ContentFilter _instance = ContentFilter._internal();
  factory ContentFilter() => _instance;
  ContentFilter._internal();

  // Russian mat (comprehensive)
  static const List<String> _russianWords = [
    'хуй', 'хуя', 'хуе', 'хуё', 'хуи', 'хую',
    'пизд', 'пизда', 'пизде', 'пизду', 'пиздец',
    'блять', 'бляд', 'блядь', 'бляди',
    'ебать', 'ебат', 'ебан', 'ебну', 'ебал', 'ебло', 'ебуч', 'ёбан',
    'сука', 'суки', 'сучка', 'сучар',
    'мудак', 'мудил', 'мудач',
    'залуп', 'залупа',
    'шлюх', 'шлюха',
    'дерьмо',
    'говно', 'говна', 'говне', 'говну',
    'жопа', 'жопу', 'жопе',
    'срать', 'срань',
    'засранец', 'засран',
    'выблядок',
    'долбоёб', 'долбоеб',
    'заебал', 'заебис', 'заёб',
    'отъебись', 'отъеб',
    'уёбок', 'уебок', 'уёбищ',
    'пидор', 'пидар', 'пидр',
    'гандон', 'гондон',
    'манда',
    'елда',
    'член',
    'нахуй', 'нахуя', 'нахер',
    'похуй', 'похер',
    'охуел', 'охуе',
    'ахуел', 'ахуе',
  ];

  // English profanity
  static const List<String> _englishWords = [
    'fuck', 'fucker', 'fucking', 'fucked',
    'shit', 'shitty', 'bullshit',
    'bitch', 'bitches',
    'asshole', 'arsehole',
    'bastard',
    'damn', 'damned',
    'dick', 'dickhead',
    'cock', 'cocksucker',
    'cunt',
    'motherfucker', 'mofo',
    'nigger', 'nigga',
    'whore',
    'slut',
    'retard', 'retarded',
    'faggot', 'fag',
  ];

  // Kyrgyz inappropriate terms
  static const List<String> _kyrgyzWords = [
    'сатылган',
    'канчык',
    'итбай',
    'чочко',
    'эшек',
    'сокур',
    'акмак',
    'жинди',
    'наадан',
  ];

  late final Set<String> _allBlockedWords;
  bool _initialized = false;

  void _ensureInitialized() {
    if (_initialized) return;
    _allBlockedWords = {
      ..._russianWords,
      ..._englishWords,
      ..._kyrgyzWords,
    };
    _initialized = true;
  }

  /// Returns true if the text contains objectionable content
  bool containsObjectionableContent(String text) {
    _ensureInitialized();
    final normalized = _normalize(text);
    final words = normalized.split(RegExp(r'\s+'));

    for (final word in words) {
      for (final blocked in _allBlockedWords) {
        if (word.contains(blocked)) return true;
      }
    }
    return false;
  }

  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll('ё', 'е')
        .replaceAll(RegExp(r'[^\w\sа-яА-Яөүңёa-zA-Z]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
