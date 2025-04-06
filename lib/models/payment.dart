import 'package:hive/hive.dart';

part 'payment.g.dart';

@HiveType(typeId: 1)
class Payment extends HiveObject {
  @HiveField(0)
  final double amount;

  @HiveField(1)
  final DateTime date;

  Payment({required this.amount, required this.date});
}
