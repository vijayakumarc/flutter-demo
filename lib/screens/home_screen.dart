import 'package:expense_tracker/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final expenseBox = Hive.box<ExpenseModel>("expenses");
  List<ExpenseModel> get expenses => expenseBox.values.toList();

  final double totalBudget = 5000;
  double get totalExpense =>
      expenses.fold(0.0, (sum, item) => sum + item.amount);
  double get balance => totalBudget - totalExpense;

  confirmDelete(index) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Expense"),
        content: const Text("Are you sure want to delete?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              final expenseBox = Hive.box<ExpenseModel>("expenses");
              await expenseBox.deleteAt(index);
              Navigator.pop(context);
              setState(() {});
            },
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newExpense =
              await Navigator.pushNamed(context, "/add-expense")
                  as ExpenseModel;
          setState(() {
            expenseBox.add(newExpense);
          });
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(title: const Text("Expense Tracker")),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            color: cs.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryItem(
                      label: "Spent",
                      value: totalExpense.toStringAsFixed(2),
                      color: cs.error,
                      icon: Icons.arrow_upward,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: cs.onPrimaryContainer.withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: _SummaryItem(
                      label: "Balance",
                      value: balance.toStringAsFixed(2),
                      color: Colors.green.shade700,
                      icon: Icons.account_balance_wallet,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Expenses",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          Expanded(
            child: expenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long,
                            size: 64, color: cs.outline),
                        const SizedBox(height: 12),
                        Text("No expenses yet",
                            style: TextStyle(color: cs.outline)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return ExpenseCard(
                        title: expense.title,
                        date: expense.date,
                        amount: expense.amount,
                        onDelete: () => confirmDelete(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

class ExpenseCard extends StatelessWidget {
  final String title;
  final DateTime? date;
  final double amount;
  final VoidCallback onDelete;

  const ExpenseCard({
    required this.title,
    required this.date,
    required this.amount,
    required this.onDelete,
    super.key,
  });

  String get formattedDate {
    return date == null ? "No Date" : DateFormat("MMM d, y").format(date!);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: cs.secondaryContainer,
          child: Icon(Icons.receipt, color: cs.onSecondaryContainer, size: 20),
        ),
        title: Text(
          title.length > 20 ? '${title.substring(0, 20)}...' : title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(formattedDate,
            style: TextStyle(color: cs.outline, fontSize: 13)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "\$${amount.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: cs.error),
              tooltip: "Delete",
            ),
          ],
        ),
      ),
    );
  }
}
