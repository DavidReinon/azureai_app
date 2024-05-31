class User {
  User({this.id, this.name, this.password});
  
  User.fromMap(Map<String, dynamic> map)
    : id = map['id'],
      name = map['name'],
      password = map['password'];

  final int? id;
  final String? name;
  final String? password;

  int? get getId => id;
  String? get getName => name;
  String? get getPassword => password;


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
