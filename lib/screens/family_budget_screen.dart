import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/family_user.dart';
import '../theme/app_theme.dart';
import '../widgets/connection_status.dart';

enum TransactionType { income, expense, savings, allowance, gift }
enum TransactionCategory { food, utility, transport, education, entertainment, healthcare, clothing, other }

class FamilyTransaction {
  final String id;
  final String familyId;
  final String title;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final String? paidById;
  final String? paidForId;
  final bool isShared;
  final String? notes;
  final DateTime date;
  final DateTime createdAt;

  FamilyTransaction({
    required this.id,
    required this.familyId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    this.paidById,
    this.paidForId,
    this.isShared = false,
    this.notes,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'title': title,
      'amount': amount,
      'type': type.name,
      'category': category.name,
      'paidById': paidById,
      'paidForId': paidForId,
      'isShared': isShared,
      'notes': notes,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FamilyTransaction.fromMap(Map<String, dynamic> map) {
    return FamilyTransaction(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      category: TransactionCategory.values.firstWhere((e) => e.name == map['category']),
      paidById: map['paidById'] as String?,
      paidForId: map['paidForId'] as String?,
      isShared: map['isShared'] as bool? ?? false,
      notes: map['notes'] as String?,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class FamilyBudgetScreen extends StatefulWidget {
  final FamilyUser currentUser;
  
  const FamilyBudgetScreen({super.key, required this.currentUser});

  @override
  State<FamilyBudgetScreen> createState() => _FamilyBudgetScreenState();
}

class _FamilyBudgetScreenState extends State<FamilyBudgetScreen> {
  List<FamilyTransaction> _transactions = [];
  final _uuid = const Uuid();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadSampleTransactions();
  }

  void _loadSampleTransactions() {
    final now = DateTime.now();
    _transactions = [
      FamilyTransaction(id: '1', familyId: widget.currentUser.familyId, title: 'Salary', amount: 5000, type: TransactionType.income, category: TransactionCategory.other, date: now, createdAt: now),
      FamilyTransaction(id: '2', familyId: widget.currentUser.familyId, title: 'Grocery shopping', amount: 150, type: TransactionType.expense, category: TransactionCategory.food, paidById: widget.currentUser.id, isShared: true, date: now.subtract(const Duration(days: 2)), createdAt: now),
      FamilyTransaction(id: '3', familyId: widget.currentUser.familyId, title: 'Electric bill', amount: 120, type: TransactionType.expense, category: TransactionCategory.utility, isShared: true, date: now.subtract(const Duration(days: 5)), createdAt: now),
      FamilyTransaction(id: '4', familyId: widget.currentUser.familyId, title: 'Gas for car', amount: 60, type: TransactionType.expense, category: TransactionCategory.transport, paidById: widget.currentUser.id, date: now.subtract(const Duration(days: 3)), createdAt: now),
      FamilyTransaction(id: '5', familyId: widget.currentUser.familyId, title: 'Internet', amount: 80, type: TransactionType.expense, category: TransactionCategory.utility, isShared: true, date: now.subtract(const Duration(days: 10)), createdAt: now),
      FamilyTransaction(id: '6', familyId: widget.currentUser.familyId, title: 'Emergency fund', amount: 500, type: TransactionType.savings, category: TransactionCategory.other, isShared: true, date: now.subtract(const Duration(days: 1)), createdAt: now),
      FamilyTransaction(id: '7', familyId: widget.currentUser.familyId, title: 'Allowance for kids', amount: 50, type: TransactionType.allowance, category: TransactionCategory.other, paidForId: 'child1', isShared: true, date: now, createdAt: now),
      FamilyTransaction(id: '8', familyId: widget.currentUser.familyId, title: 'Netflix subscription', amount: 15, type: TransactionType.expense, category: TransactionCategory.entertainment, isShared: true, date: now.subtract(const Duration(days: 15)), createdAt: now),
      FamilyTransaction(id: '9', familyId: widget.currentUser.familyId, title: 'Doctor visit copay', amount: 30, type: TransactionType.expense, category: TransactionCategory.healthcare, paidById: widget.currentUser.id, date: now.subtract(const Duration(days: 7)), createdAt: now),
      FamilyTransaction(id: '10', familyId: widget.currentUser.familyId, title: 'Birthday gift from grandma', amount: 100, type: TransactionType.gift, category: TransactionCategory.other, date: now.subtract(const Duration(days: 4)), createdAt: now),
    ];
  }

  double get _totalIncome => _transactions
      .where((t) => t.type == TransactionType.income && _isInMonth(t.date))
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _totalExpenses => _transactions
      .where((t) => t.type == TransactionType.expense && _isInMonth(t.date))
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _totalSavings => _transactions
      .where((t) => t.type == TransactionType.savings && _isInMonth(t.date))
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _balance => _totalIncome - _totalExpenses - _totalSavings;

  bool _isInMonth(DateTime date) => date.month == _selectedMonth && date.year == _selectedYear;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Budget'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: ConnectionStatusIndicator()),
        ],
      ),
      body: Column(
        children: [
          _buildMonthSelector(),
          _buildSummaryCard(),
          Expanded(child: _buildTransactionList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() {
              if (_selectedMonth == 1) {
                _selectedMonth = 12;
                _selectedYear--;
              } else {
                _selectedMonth--;
              }
            }),
          ),
          Text(
            '${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][_selectedMonth - 1]} $_selectedYear',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() {
              if (_selectedMonth == 12) {
                _selectedMonth = 1;
                _selectedYear++;
              } else {
                _selectedMonth++;
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.all(8),
      color: AppTheme.primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Income:'),
                Text('\$${_totalIncome.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Expenses:'),
                Text('\$${_totalExpenses.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Savings:'),
                Text('\$${_totalSavings.toStringAsFixed(2)}', style: const TextStyle(color: Colors.blue)),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Balance:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '\$${_balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _balance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    final monthlyTransactions = _transactions.where((t) => _isInMonth(t.date)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    
    if (monthlyTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No transactions this month', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: monthlyTransactions.length,
      itemBuilder: (ctx, i) => _buildTransactionTile(monthlyTransactions[i]),
    );
  }

  Widget _buildTransactionTile(FamilyTransaction t) {
    final isIncome = t.type == TransactionType.income || t.type == TransactionType.savings;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getCategoryColor(t.category).withOpacity(0.2),
        child: Icon(_getCategoryIcon(t.category), color: _getCategoryColor(t.category)),
      ),
      title: Text(t.title),
      subtitle: Text('${t.category.name} | ${_formatDate(t.date)}'),
      trailing: Text(
        '${isIncome ? '+' : '-'}\$${t.amount.toStringAsFixed(2)}',
        style: TextStyle(
          color: isIncome ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      onLongPress: () => _deleteTransaction(t),
    );
  }

  Color _getCategoryColor(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food: return Colors.orange;
      case TransactionCategory.utility: return Colors.blue;
      case TransactionCategory.transport: return Colors.purple;
      case TransactionCategory.education: return Colors.teal;
      case TransactionCategory.entertainment: return Colors.pink;
      case TransactionCategory.healthcare: return Colors.red;
      case TransactionCategory.clothing: return Colors.indigo;
      case TransactionCategory.other: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food: return Icons.restaurant;
      case TransactionCategory.utility: return Icons.electrical_services;
      case TransactionCategory.transport: return Icons.directions_car;
      case TransactionCategory.education: return Icons.school;
      case TransactionCategory.entertainment: return Icons.movie;
      case TransactionCategory.healthcare: return Icons.local_hospital;
      case TransactionCategory.clothing: return Icons.checkroom;
      case TransactionCategory.other: return Icons.more_horiz;
    }
  }

  void _deleteTransaction(FamilyTransaction t) {
    setState(() => _transactions.removeWhere((tr) => tr.id == t.id));
  }

  void _showAddTransactionDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    TransactionType selectedType = TransactionType.expense;
    TransactionCategory selectedCategory = TransactionCategory.other;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Transaction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$ '),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<TransactionType>(
                  value: selectedType,
                  items: TransactionType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<TransactionCategory>(
                  value: selectedCategory,
                  items: TransactionCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                  onChanged: (v) => setDialogState(() => selectedCategory = v!),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 8),
                TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (titleController.text.isNotEmpty && amount != null) {
                  final transaction = FamilyTransaction(
                    id: _uuid.v4(),
                    familyId: widget.currentUser.familyId,
                    title: titleController.text,
                    amount: amount,
                    type: selectedType,
                    category: selectedCategory,
                    paidById: widget.currentUser.id,
                    notes: notesController.text.isEmpty ? null : notesController.text,
                    date: DateTime.now(),
                    createdAt: DateTime.now(),
                  );
                  setState(() => _transactions.add(transaction));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}