import 'package:hive/hive.dart';
import 'payment.dart';

part 'debt.g.dart';

@HiveType(typeId: 0)
class Debt extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double startingBalance;

  @HiveField(2)
  double balance;

  @HiveField(3)
  final double interestRate;

  @HiveField(4)
  final double minPayment;

  @HiveField(5)
  List<Payment> payments;

  Debt({
    required this.name,
    required this.startingBalance,
    required this.balance,
    required this.interestRate,
    required this.minPayment,
    this.payments = const [],
  });
}
