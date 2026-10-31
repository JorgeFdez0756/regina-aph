/// IDs estables de clips españoles empaquetados. Sustituir sus WAV no cambia el juego.
abstract final class VoiceCue {
  static const welcome = ['welcome'];
  static const map = ['map'];
  static const counting = ['counting'];
  static const album = ['album'];
  static List<String> letter(String target) => [
    'letters',
    'l_${target.toLowerCase()}',
  ];
  static List<String> hintLetter(String target) => [
    'hint_letters',
    'l_${target.toLowerCase()}',
  ];
  static List<String> number(int value) => ['n$value'];
  static List<String> prize(int id) => ['r$id'];
}
