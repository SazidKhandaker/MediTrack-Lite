class DateHelper {

  static String formatBanglaDate(String date) {
    try {
      DateTime d = DateTime.parse(date);

      List<String> monthsBn = [
        "জানুয়ারি", "ফেব্রুয়ারি", "মার্চ", "এপ্রিল",
        "মে", "জুন", "জুলাই", "আগস্ট",
        "সেপ্টেম্বর", "অক্টোবর", "নভেম্বর", "ডিসেম্বর"
      ];

      String toBanglaNumber(String input) {
        const en = ['0','1','2','3','4','5','6','7','8','9'];
        const bn = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];

        for (int i = 0; i < 10; i++) {
          input = input.replaceAll(en[i], bn[i]);
        }
        return input;
      }

      String day = toBanglaNumber(d.day.toString());
      String year = toBanglaNumber(d.year.toString());

      return "$day ${monthsBn[d.month - 1]} $year";
    } catch (e) {
      return date;
    }
  }
}