class ChatModel {
  final String text;
  String kind;
  String image;
  String audio;
  final String sender_name;
  bool show_time;
  Duration position;  // Ajout pour gérer la position de l'audio
  Duration duration;  // Ajout pour gérer la durée de l'audio

  ChatModel(
      this.text,
      this.sender_name,
      this.kind,
      this.image,
      this.audio,
      this.show_time,
      {this.position = const Duration(), this.duration = const Duration()}  // Initialiser avec 0
      );
}
