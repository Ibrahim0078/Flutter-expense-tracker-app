import 'package:intl/intl.dart';

// convert String to a Double
double convertStringToDouble(String string){
  double? amount = double.tryParse(string);
  return amount ?? 0;
}

// format double amount into dollars & cents
String formatAmount(double amount){
  final format = NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);
  return format.format(amount);
}

int calculateMonthCount (int startYear, startMonth, currentYear, currentMonth){
  int monthCount = (currentYear - startYear) * 12 + currentMonth - startMonth + 1;
  return monthCount;
}

String getCurrentMonthName(){
  DateTime now = DateTime.now();
  List<String> months = [
    'JAN',
    'FAB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC'
  ];
  return months[now.month - 1];
}