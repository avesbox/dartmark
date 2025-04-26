abstract class Pacakge {

  void parseFlatObject(Map<String, dynamic> json);

  void parseNestedObject(Map<String, dynamic> json);

  void parseDeeplyNestedObject(Map<String, dynamic> json);

  void parseFlatArray(List<Map<String, dynamic>> json);

  void parseNestedArray(List<Map<String, dynamic>> json);

  void parseDeeplyNestedArray(List<Map<String, dynamic>> json);

  Future<void> run();

}