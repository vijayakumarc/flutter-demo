import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;

  final _formKey = GlobalKey<FormState>();

  void showDatepicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: _selectedDate ?? DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }

    print("Selected Date $pickedDate");
  }

  void submitForm() {
    if ((_formKey.currentState?.validate() ?? false) && _selectedDate != null) {
      final title = _titleController.text;
      final amount = double.parse(_amountController.text);

      final newExpense = ExpenseModel(
        title: title,
        amount: amount,
        date: _selectedDate,
      );
      Navigator.pop(context, newExpense);
    }
  }

  void resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _amountController.clear();
    setState(() {
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Title is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Amount is required";
                  }
                  if (double.tryParse(value) == null) {
                    return "Enter a number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: showDatepicker,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Date",
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? "Choose a date"
                        : DateFormat("MMM d, y").format(_selectedDate!),
                    style: TextStyle(
                      color: _selectedDate == null ? cs.outline : null,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: submitForm,
                      icon: const Icon(Icons.check),
                      label: const Text("Add Expense"),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: resetForm,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.error,
                      side: BorderSide(color: cs.error),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Reset"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
