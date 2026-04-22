class Medicine {
  String name;
  String note;
  String time;
  String date; // 🔥 IMPORTANT (yyyy-MM-dd)

  Medicine({
    required this.name,
    required this.note,
    required this.time,
    required this.date,
  });
}