class User {
  final int? id;
  final String? name;
  final String? password;

  User({this.id, this.name, this.password});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (id != null) {
      json['id'] = id;
    }
    if (name != null) {
      json['name'] = name;
    }
    if (password != null) {
      json['password'] = password;
    }
    return json;
  }
}
