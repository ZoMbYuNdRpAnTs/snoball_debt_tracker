import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/debt.dart';
import 'models/payment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(DebtAdapter());
  Hive.registerAdapter(PaymentAdapter());

  await Hive.openBox<Debt>('debts');

  runApp(const SnowballDebtTrackerApp());
}

class SnowballDebtTrackerApp extends StatelessWidget {
  const SnowballDebtTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snoball Debt Tracker',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xFF003366), // Light gray
        primaryColor: Color(0xFF003366), // Deep Blue
        colorScheme: ColorScheme.light(
          primary: Color(0xFF001F3F),
          secondary: Color(0xFF00A676), // Emerald Green
          tertiary: Color(0xFFFFD700), // Golden Yellow
        ),
        fontFamily: 'OpenSans',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 44), // Full width, 44px height
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            backgroundColor: Color(0xFF001F3F), // Deep Blue
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF001F3F), // Deep Blue
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            // fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF001F3F), // Deep Navy
        primaryColor: Color(0xFFFFD700), // Golden Yellow for highlights
        fontFamily: 'OpenSans',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 44),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            backgroundColor: Color(0xFFFFD700), // Accent color
            foregroundColor: Color(0xFF001F3F),
          ),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
      ),
      themeMode: ThemeMode.system,
      home: DebtListScreen(),
    );
  }
}

class DebtListScreen extends StatefulWidget {
  @override
  _DebtListScreenState createState() => _DebtListScreenState();
}

class _DebtListScreenState extends State<DebtListScreen> {
  late Box<Debt> debtsBox;

  void _addDebt(Debt debt) {
    setState(() {
      debtsBox.add(debt);
    });
  }

  void _navigateToAddDebt() async {
    final newDebt = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddDebtScreen(onSave: _addDebt)),
    );
  }

  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Debt'),
            content: const Text('Are you sure you want to delete this debt?'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  setState(() {
                    debtsBox.deleteAt(index);
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    debtsBox = Hive.box<Debt>('debts');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Debts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insert_chart),
            tooltip: 'View Report',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          ReportsScreen(debts: debtsBox.values.toList()),
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: debtsBox.listenable(),
        builder: (context, Box<Debt> box, _) {
          if (box.values.isEmpty) {
            return const Center(
              child: Text(
                'No debts tracked yet.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final debts = box.values.toList();

          return ListView.builder(
            itemCount: debts.length,
            itemBuilder: (context, index) {
              final debt = debtsBox.getAt(index)!;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Starting: \$${debt.startingBalance.toStringAsFixed(2)}\n'
                        'Current: \$${debt.balance.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Interest: ${debt.interestRate.toStringAsFixed(2)}% | '
                        'Min Payment: \$${debt.minPayment}',
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(
                              Icons.payment,
                              color: Colors.green,
                            ),
                            label: const Text(
                              'Pay',
                              style: TextStyle(color: Colors.green),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => PaymentScreen(
                                        debt: debtsBox.getAt(index)!,
                                        onPaymentMade: (payment) {
                                          debt.balance -= payment.amount;
                                          debt.payments.add(payment);
                                          debt.save(); // save change
                                        },
                                      ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          TextButton.icon(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () => _confirmDelete(context, index),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddDebt,
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class AddDebtScreen extends StatefulWidget {
  final Debt? existingDebt;
  final void Function(Debt)? onSave;

  const AddDebtScreen({this.existingDebt, this.onSave, super.key});

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController startingBalanceController;
  late TextEditingController balanceController;
  late TextEditingController interestController;
  late TextEditingController paymentController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.existingDebt?.name ?? '',
    );
    startingBalanceController = TextEditingController(
      text: widget.existingDebt?.startingBalance.toString() ?? '',
    );
    balanceController = TextEditingController(
      text: widget.existingDebt?.balance.toString() ?? '',
    );
    interestController = TextEditingController(
      text: widget.existingDebt?.interestRate.toString() ?? '',
    );
    paymentController = TextEditingController(
      text: widget.existingDebt?.minPayment.toString() ?? '',
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.amber), // accent color on focus
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingDebt != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Debt' : 'Add New Debt'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Debt Name'),
                validator:
                    (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: startingBalanceController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Starting Balance'),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value!.isEmpty
                            ? 'Please enter a starting balance'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: balanceController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Balance'),
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? 'Please enter a balance' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: interestController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Interest Rate (%)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: paymentController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Minimum Payment'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final updatedDebt = Debt(
                      name: nameController.text,
                      startingBalance:
                          double.tryParse(startingBalanceController.text) ?? 0,
                      balance: double.tryParse(balanceController.text) ?? 0,
                      interestRate:
                          double.tryParse(interestController.text) ?? 0,
                      minPayment: double.tryParse(paymentController.text) ?? 0,
                    );

                    if (widget.onSave != null) {
                      widget.onSave!(updatedDebt);
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text(isEditing ? 'Update' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    interestController.dispose();
    paymentController.dispose();
    startingBalanceController.dispose();
    super.dispose();
  }
}

class ReportsScreen extends StatelessWidget {
  final List<Debt> debts;

  const ReportsScreen({required this.debts, super.key});

  @override
  Widget build(BuildContext context) {
    final totalStartingBalance = debts.fold(
      0.0,
      (sum, debt) => sum + debt.startingBalance,
    );
    final totalCurrentBalance = debts.fold(
      0.0,
      (sum, debt) => sum + debt.balance,
    );
    final totalPaid = totalStartingBalance - totalCurrentBalance;
    final percentPaid =
        totalStartingBalance == 0
            ? 0
            : ((totalPaid / totalStartingBalance) * 100).clamp(0, 100);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt Report'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Starting Balance: \$${totalStartingBalance.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Current Balance: \$${totalCurrentBalance.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Paid: \$${totalPaid.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Percent Paid Off: ${percentPaid.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: percentPaid / 100,
              minHeight: 12,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  final Debt debt;
  final void Function(Payment) onPaymentMade;

  const PaymentScreen({
    required this.debt,
    required this.onPaymentMade,
    super.key,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    amountController.text = widget.debt.minPayment.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final payments = widget.debt.payments;

    return Scaffold(
      appBar: AppBar(
        title: Text('Make Payment – ${widget.debt.name}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Minimum Payment: \$${widget.debt.minPayment.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Payment Amount',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount <= 0 || amount > widget.debt.balance) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid payment amount')),
                  );
                  return;
                }

                final payment = Payment(amount: amount, date: DateTime.now());
                widget.onPaymentMade(payment);
                Navigator.pop(context);
              },
              child: const Text('Submit Payment'),
            ),
            const SizedBox(height: 32),
            const Text(
              'Payment History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child:
                  payments.isEmpty
                      ? const Text(
                        'No payments yet.',
                        style: TextStyle(color: Colors.white),
                      )
                      : ListView.builder(
                        itemCount: payments.length,
                        itemBuilder: (context, index) {
                          final p = payments[index];
                          return ListTile(
                            title: Text(
                              '\$${p.amount.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              '${p.date.toLocal()}'.split(' ')[0],
                              style: const TextStyle(color: Colors.white70),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
