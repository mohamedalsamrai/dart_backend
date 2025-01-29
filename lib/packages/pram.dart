class Pram {
  Pram(this.name) : value = name;
  String name;
  String value;
  Pram type(String type) {
    value = "$value $type";
    return this;
  }

  Pram key() {
    value = "$value AUTO_INCREMENT PRIMARY KEY";
    return this;
  }
}