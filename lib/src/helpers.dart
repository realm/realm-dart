class Helpers {
  static DateTime createDateTime(int miliseconds) {
    return DateTime.fromMillisecondsSinceEpoch(miliseconds, isUtc: true);
  }

  static dynamic invokeStatic(Type type, String name) native "Helpers_invokeStatic";
}

extension SymbolHelper on Symbol {
   String get name {
      String name = this.toString();
      name = name.substring(8, name.length - 2);
      return name;
   }
} 
