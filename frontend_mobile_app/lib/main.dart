import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// --- App Configuration ---
const String backendBaseUrl = 'http://10.0.2.2:8000'; // Local dev, change for prod
const Map<String, Color> appColors = {
  'primary': Color(0xFF1D3557),
  'secondary': Color(0xFF457B9D),
  'accent': Color(0xFFE63946),
};
const bool isDemoMode = true; // If true, random/sample/mock data and OCR

// --- Data Models ---

// PUBLIC_INTERFACE
class User {
  final String id;
  final String email;
  User({required this.id, required this.email});

  factory User.fromJson(Map<String, dynamic> json) =>
      User(id: json['id'], email: json['email']);
}

// PUBLIC_INTERFACE
class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String date;
  final String category;
  final String? note;
  final String? receiptUrl;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.note,
    this.receiptUrl,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'],
        title: json['title'],
        amount: (json['amount'] as num).toDouble(),
        date: json['date'],
        category: json['category'],
        note: json['note'],
        receiptUrl: json['receipt_url'],
      );
}

// PUBLIC_INTERFACE
class Budget {
  final String id;
  final String category;
  final double amountAllocated;
  final double amountSpent;
  Budget({
    required this.id,
    required this.category,
    required this.amountAllocated,
    required this.amountSpent,
  });

  double get percentUsed =>
      amountAllocated == 0 ? 0 : (amountSpent / amountAllocated).clamp(0, 1);
  bool get isExceeded => amountSpent > amountAllocated;

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        id: json['id'],
        category: json['category'],
        amountAllocated:
            (json['amount_allocated'] as num).toDouble(),
        amountSpent: (json['amount_spent'] as num).toDouble(),
      );
}

// --- Backend Service ---

class BackendService {
  // Static singleton usage
  static Future<User?> login(String email, String password) async {
    if (isDemoMode) {
      return User(id: "u1", email: email);
    }
    final resp = await http.post(
      Uri.parse('$backendBaseUrl/login'),
      body: {"email": email, "password": password},
    );
    if (resp.statusCode == 200) {
      return User.fromJson(jsonDecode(resp.body));
    }
    return null;
  }

  static Future<User?> signup(
      String email, String password) async {
    if (isDemoMode) {
      return User(id: "u2", email: email);
    }
    final resp = await http.post(
      Uri.parse('$backendBaseUrl/signup'),
      body: {"email": email, "password": password},
    );
    if (resp.statusCode == 201) {
      return User.fromJson(jsonDecode(resp.body));
    }
    return null;
  }

  static Future<List<TransactionModel>> fetchTransactions(
      String userId) async {
    if (isDemoMode) {
      return mockTransactions;
    }
    final resp = await http.get(
        Uri.parse('$backendBaseUrl/transactions?user_id=$userId'));
    if (resp.statusCode == 200) {
      return (jsonDecode(resp.body) as List)
          .map((e) => TransactionModel.fromJson(e))
          .toList();
    }
    return [];
  }

  static Future<List<Budget>> fetchBudgets(String userId) async {
    if (isDemoMode) {
      return mockBudgets;
    }
    final resp = await http
        .get(Uri.parse('$backendBaseUrl/budgets?user_id=$userId'));
    if (resp.statusCode == 200) {
      return (jsonDecode(resp.body) as List)
          .map((e) => Budget.fromJson(e))
          .toList();
    }
    return [];
  }

  static Future<void> addTransaction(
      String userId, TransactionModel tx) async {
    // Omitted: call backend endpoint or simulate
  }

  static Future<void> updateTransaction(
      String userId, TransactionModel tx) async {}

  static Future<void> deleteTransaction(
      String userId, String txId) async {}

  static Future<String> processReceiptImage(String path) async {
    // Simulate OCR for demo mode; would actually send to backend
    await Future.delayed(const Duration(seconds: 1));
    return "Simulated: \$27.50 at Grocery Mart";
  }
}

// --- Demo Data ---
final List<TransactionModel> mockTransactions = [
  TransactionModel(
      id: "t1",
      title: "Coffee",
      amount: 3.20,
      date: "2024-06-02",
      category: "Food",
      note: "Morning coffee"),
  TransactionModel(
      id: "t2",
      title: "Groceries",
      amount: 52.68,
      date: "2024-06-01",
      category: "Food",
      receiptUrl: null),
  TransactionModel(
    id: "t3",
    title: "Gym",
    amount: 31.00,
    date: "2024-05-29",
    category: "Health",
  ),
];

final List<Budget> mockBudgets = [
  Budget(
      id: "b1",
      category: "Food",
      amountAllocated: 250.0,
      amountSpent: 180.3),
  Budget(
      id: "b2",
      category: "Entertainment",
      amountAllocated: 100.0,
      amountSpent: 120.8),
];

// --- Main App ---

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Simulate light theme system bar
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(const PersonalFinanceApp());
}

// PUBLIC_INTERFACE
class PersonalFinanceApp extends StatelessWidget {
  const PersonalFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.light(
        primary: appColors['primary']!,
        secondary: appColors['secondary']!,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        error: appColors['accent']!,
      ),
      useMaterial3: true,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: appColors['accent'],
        foregroundColor: Colors.white,
        iconSize: 26,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: appColors['primary'],
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: appColors['primary'],
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: appColors['secondary']!),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appColors['primary'],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );

    return MaterialApp(
      title: 'Personal Finance Tracker',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const AuthFlow(),
    );
  }
}

// --- Auth Flow (Login/Signup) ---

class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key});
  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  bool showLogin = true;
  User? user;
  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return HomeTabs(user: user!);
    }
    return showLogin
        ? LoginScreen(
            onLogin: (u) => setState(() => user = u),
            onSwitch: () => setState(() => showLogin = false),
          )
        : SignupScreen(
            onSignup: (u) => setState(() => user = u),
            onSwitch: () => setState(() => showLogin = true),
          );
  }
}

// PUBLIC_INTERFACE
class LoginScreen extends StatefulWidget {
  final void Function(User user) onLogin;
  final VoidCallback onSwitch;
  const LoginScreen({
    required this.onLogin,
    required this.onSwitch,
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  String? errorMsg;

  void doLogin() async {
    setState(() => loading = true);
    var user = await BackendService.login(emailCtrl.text, passCtrl.text);
    setState(() => loading = false);
    if (user != null) {
      widget.onLogin(user);
    } else {
      setState(() => errorMsg = "Login failed.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                  labelText: "Email", prefixIcon: Icon(Icons.mail)),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(
                  labelText: "Password", prefixIcon: Icon(Icons.lock)),
              obscureText: true,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
                onPressed: loading ? null : doLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColors['primary'],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                ),
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Login")),
            if (errorMsg != null)
              Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(errorMsg!,
                      style: TextStyle(color: appColors['accent']))),
            TextButton(
                onPressed: widget.onSwitch,
                child: const Text("Don’t have an account? Sign up"))
          ],
        ),
      ),
    );
  }
}

// PUBLIC_INTERFACE
class SignupScreen extends StatefulWidget {
  final void Function(User user) onSignup;
  final VoidCallback onSwitch;
  const SignupScreen({
    required this.onSignup,
    required this.onSwitch,
    super.key,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final pass2Ctrl = TextEditingController();
  bool loading = false;
  String? errorMsg;

  void doSignup() async {
    if (passCtrl.text != pass2Ctrl.text) {
      setState(() => errorMsg = "Passwords do not match.");
      return;
    }
    setState(() => loading = true);
    var user =
        await BackendService.signup(emailCtrl.text, passCtrl.text);
    setState(() => loading = false);
    if (user != null) {
      widget.onSignup(user);
    } else {
      setState(() => errorMsg = "Signup failed.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                  labelText: "Email", prefixIcon: Icon(Icons.mail)),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(
                  labelText: "Password", prefixIcon: Icon(Icons.lock)),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pass2Ctrl,
              decoration: const InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: Icon(Icons.lock_outline)),
              obscureText: true,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
                onPressed: loading ? null : doSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColors['primary'],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                ),
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Sign Up")),
            if (errorMsg != null)
              Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(errorMsg!,
                      style: TextStyle(color: appColors['accent']))),
            TextButton(
                onPressed: widget.onSwitch,
                child: const Text("Already have an account? Sign in"))
          ],
        ),
      ),
    );
  }
}

// --- Home Tabs Navigation ---
// Dashboard, Transactions, Budgets

class HomeTabs extends StatefulWidget {
  final User user;
  const HomeTabs({required this.user, Key? key}) : super(key: key);

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int _tabIdx = 0;
  List<TransactionModel> transactions = [];
  List<Budget> budgets = [];
  String? txFilterCategory;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    // Fetch data from backend (or load demo)
    final tx = await BackendService.fetchTransactions(widget.user.id);
    final bd = await BackendService.fetchBudgets(widget.user.id);
    setState(() {
      transactions = tx;
      budgets = bd;
    });
  }

  void addTx(TransactionModel t) async {
    setState(() => transactions.add(t));
    await BackendService.addTransaction(widget.user.id, t);
    loadData();
  }

  void editTx(TransactionModel updated) async {
    setState(() {
      final idx =
          transactions.indexWhere((tx) => tx.id == updated.id);
      if (idx != -1) transactions[idx] = updated;
    });
    await BackendService.updateTransaction(widget.user.id, updated);
    loadData();
  }

  void removeTx(String txId) async {
    setState(() =>
        transactions.removeWhere((element) => element.id == txId));
    await BackendService.deleteTransaction(widget.user.id, txId);
    loadData();
  }

  // Tab Widgets
  Widget getTab({required int idx}) {
    switch (idx) {
      case 0:
        return DashboardScreen(
          user: widget.user,
          transactions: transactions,
          budgets: budgets,
          onRefresh: loadData,
        );
      case 1:
        return TransactionsScreen(
          transactions: txFilterCategory == null
              ? transactions
              : transactions
                  .where(
                      (t) => t.category == txFilterCategory)
                  .toList(),
          allCategories:
              transactions.map((tx) => tx.category).toSet().toList(),
          onAdd: addTx,
          onEdit: editTx,
          onDelete: removeTx,
          onFilter: (cat) =>
              setState(() => txFilterCategory = cat),
          currentFilter: txFilterCategory,
        );
      case 2:
        return BudgetsScreen(
          budgets: budgets,
          transactions: transactions,
          onRefresh: loadData,
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getTab(idx: _tabIdx),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIdx,
        selectedItemColor: appColors['primary'],
        unselectedItemColor: appColors['secondary'],
        onTap: (i) => setState(() => _tabIdx = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.auto_graph), label: "Dashboard"),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: "Transactions"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: "Budgets"),
        ],
      ),
      floatingActionButton: _tabIdx == 1
          ? FloatingActionButton(
              onPressed: () async {
                // Add transaction screen/prompt
                final t = await showDialog<TransactionModel>(
                  context: context,
                  builder: (ctx) => Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16)),
                      child: TransactionForm()),
                );
                if (t != null) addTx(t);
              },
              tooltip: "Add Transaction",
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

// --- Dashboard Screen ---

// PUBLIC_INTERFACE
class DashboardScreen extends StatelessWidget {
  final User user;
  final List<TransactionModel> transactions;
  final List<Budget> budgets;
  final VoidCallback onRefresh;

  const DashboardScreen({
    required this.user,
    required this.transactions,
    required this.budgets,
    required this.onRefresh,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final balance = transactions.fold<double>(
        0, (sum, item) => sum - (item.amount));
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: appColors['primary'],
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            "Welcome, ${user.email.split('@')[0]}",
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(color: appColors['primary']),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            color: appColors['secondary']!.withAlpha((0.08 * 255).toInt()),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text("Current Balance",
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    "\$${balance.toStringAsFixed(2)}",
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: appColors['primary']),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Recent Transactions",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          ...transactions
              .take(3)
              .map((t) => ListTile(
                    title: Text(t.title),
                    subtitle: Text('${t.category} • ${t.date}'),
                    trailing: Text(
                      "- \$${t.amount.toStringAsFixed(2)}",
                      style: TextStyle(color: appColors['accent']),
                    ),
                  )),
          const SizedBox(height: 20),
          Text(
            "Budgets Overview",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          ...budgets
              .map((b) => BudgetProgressBar(budget: b))
              .toList(),
        ],
      ),
    );
  }
}

class BudgetProgressBar extends StatelessWidget {
  final Budget budget;
  const BudgetProgressBar({required this.budget, super.key});
  @override
  Widget build(BuildContext context) {
    final percent = budget.percentUsed;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(budget.category,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            if (budget.isExceeded)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(Icons.warning_amber_rounded,
                    color: appColors['accent'], size: 20),
              ),
          ]),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percent,
            color: percent < 1
                ? appColors['secondary']
                : appColors['accent'],
            backgroundColor:
                appColors['secondary']!.withAlpha((0.2 * 255).toInt()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  "\$${budget.amountSpent.toStringAsFixed(2)} spent",
                  style: const TextStyle(fontSize: 12)),
              Text(
                  "\$${budget.amountAllocated.toStringAsFixed(2)} target",
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Transactions Screen ---

// PUBLIC_INTERFACE
class TransactionsScreen extends StatelessWidget {
  final List<TransactionModel> transactions;
  final List<String> allCategories;
  final void Function(TransactionModel) onAdd;
  final void Function(TransactionModel) onEdit;
  final void Function(String) onDelete;
  final void Function(String?) onFilter;
  final String? currentFilter;

  const TransactionsScreen({
    required this.transactions,
    required this.allCategories,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onFilter,
    required this.currentFilter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transactions"),
        actions: [
          currentFilter != null
              ? IconButton(
                  icon: const Icon(Icons.cancel),
                  tooltip: "Clear filter",
                  onPressed: () => onFilter(null),
                )
              : PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_alt),
                  tooltip: "Filter by category",
                  onSelected: (cat) => onFilter(cat),
                  itemBuilder: (ctx) => allCategories
                      .map((c) => PopupMenuItem<String>(
                            value: c,
                            child: Text(c),
                          ))
                      .toList(),
                ),
        ],
      ),
      body: transactions.isEmpty
          ? const Center(
              child: Text("No transactions found."),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: transactions.length,
              itemBuilder: (ctx, i) {
                final t = transactions[i];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 4),
                  child: ListTile(
                    leading: Icon(Icons.receipt_long,
                        color: appColors['primary']),
                    title: Text(t.title),
                    subtitle:
                        Text('${t.category} • ${t.date}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "- \$${t.amount.toStringAsFixed(2)}",
                          style: TextStyle(
                              color: appColors['accent'],
                              fontWeight: FontWeight.bold),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (s) {
                            if (s == 'edit') {
                              showDialog<TransactionModel>(
                                  context: context,
                                  builder: (ctx) => Dialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    16)),
                                        child: TransactionForm(
                                          existing: t,
                                        ),
                                      )).then((updated) {
                                if (updated != null) onEdit(updated);
                              });
                            }
                            if (s == 'delete') {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text(
                                      "Delete Transaction?"),
                                  content: Text(
                                      "Are you sure you want to delete '${t.title}'?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        onDelete(t.id);
                                        Navigator.of(ctx).pop();
                                      },
                                      style: TextButton.styleFrom(
                                          foregroundColor:
                                              appColors['accent']),
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// --- Add/Edit Transaction Form with Receipt OCR "Simulated" ---

class TransactionForm extends StatefulWidget {
  final TransactionModel? existing;
  const TransactionForm({this.existing, super.key});
  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  String? receiptInfo;
  bool ocrLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final t = widget.existing!;
      titleCtrl.text = t.title;
      amountCtrl.text = t.amount.toString();
      dateCtrl.text = t.date;
      categoryCtrl.text = t.category;
      noteCtrl.text = t.note ?? "";
    }
  }

  void simulateOCR() async {
    setState(() => ocrLoading = true);
    final result = await BackendService.processReceiptImage("fake-path");
    setState(() {
      ocrLoading = false;
      receiptInfo = result;
      // Try to parse an amount from result
      final reg = RegExp(r'\$(\d+(\.\d+)?)');
      final m = reg.firstMatch(result);
      if (m != null) amountCtrl.text = m.group(1)!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(widget.existing == null
              ? "Add Transaction"
              : "Edit Transaction"),
          const SizedBox(height: 8),
          TextField(
            controller: titleCtrl,
            decoration: const InputDecoration(labelText: "Title"),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: amountCtrl,
            decoration: const InputDecoration(
                labelText: "Amount", prefixText: "\$"),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: dateCtrl,
            decoration: const InputDecoration(labelText: "Date (YYYY-MM-DD)"),
            keyboardType: TextInputType.datetime,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: categoryCtrl,
            decoration: const InputDecoration(labelText: "Category"),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: noteCtrl,
            decoration: const InputDecoration(labelText: "Note (optional)"),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                  onPressed: ocrLoading ? null : simulateOCR,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: ocrLoading
                      ? const Text("Processing...")
                      : const Text("Scan Receipt (Sim)")),
              if (receiptInfo != null)
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(receiptInfo!,
                        style: const TextStyle(fontSize: 12),
                        softWrap: true),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(TransactionModel(
                  id: widget.existing?.id ?? UniqueKey().toString(),
                  title: titleCtrl.text,
                  amount: double.tryParse(amountCtrl.text) ?? 0,
                  date: dateCtrl.text,
                  category: categoryCtrl.text,
                  note: noteCtrl.text.isNotEmpty ? noteCtrl.text : null,
                  receiptUrl: null));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors['primary'],
              foregroundColor: Colors.white,
            ),
            child: Text(widget.existing == null ? "Add" : "Save"),
          )
        ]),
      ),
    );
  }
}

// --- Budgets Screen with Progress, Alerts, Transactions Summary ---

// PUBLIC_INTERFACE
class BudgetsScreen extends StatelessWidget {
  final List<Budget> budgets;
  final List<TransactionModel> transactions;
  final VoidCallback onRefresh;
  const BudgetsScreen({
    required this.budgets,
    required this.transactions,
    required this.onRefresh,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Budgets"),
      ),
      body: RefreshIndicator(
        color: appColors['primary'],
        onRefresh: () async => onRefresh(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ...budgets.map((b) => Card(
                  color: b.isExceeded
                      ? appColors['accent']!.withAlpha((0.09 * 255).toInt())
                      : appColors['secondary']!.withAlpha((0.08 * 255).toInt()),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.category,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: b.percentUsed,
                          color: b.isExceeded
                              ? appColors['accent']
                              : appColors['secondary'],
                          backgroundColor:
                              appColors['secondary']!.withAlpha((0.1 * 255).toInt()),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                "\$${b.amountSpent.toStringAsFixed(2)} spent",
                                style: const TextStyle(fontSize: 13)),
                            Text(
                                "\$${b.amountAllocated.toStringAsFixed(2)} allowed",
                                style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                        if (b.isExceeded)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: appColors['accent']),
                              const SizedBox(width: 5),
                              const Text(
                                  "Budget exceeded.",
                                  style: TextStyle(
                                      color: Colors.redAccent, fontSize: 13)),
                            ]),
                          ),
                        const SizedBox(height: 8),
                        Text(
                            "Latest: ${_findLatestTxDesc(transactions, b.category)}",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String _findLatestTxDesc(
      List<TransactionModel> txs, String category) {
    final tx = txs
        .where((t) => t.category == category)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    if (tx.isEmpty) return "No transactions";
    final t = tx.first;
    return "${t.title} • \$${t.amount.toStringAsFixed(2)} on ${t.date}";
  }
}

// --- Push Notifications (Simulated) ---

// In real app: Use firebase_messaging or similar
void showBudgetAlert(BuildContext context, Budget budget) {
  // Show snackbar for now
  if (budget.isExceeded) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "Alert: Budget for ${budget.category} exceeded!"),
        backgroundColor: appColors['accent'],
      ),
    );
  }
}

