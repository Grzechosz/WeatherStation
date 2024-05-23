class Sensor{
  final String id;
  final bool isOccupied;
  final String name;

  Sensor({required this.id, required this.isOccupied, required this.name});

  factory Sensor.fromFirebase(Map<String, dynamic> map){
    final String id;
    final String name;
    final bool isOccupied;

    id = map['id'];
    isOccupied = map['isOccupied'];
    name = map['name'];

    return Sensor(id: id, isOccupied: isOccupied, name: name);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isOccupied': isOccupied,
    };
  }

}