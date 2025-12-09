import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TransactionDetailScreen  extends StatefulWidget {
  const TransactionDetailScreen ({super.key});

  @override
  _TransactionDetailScreen  createState() => _TransactionDetailScreen ();
}


class _TransactionDetailScreen extends State<TransactionDetailScreen > {
  List<dynamic> transactions = [];
  bool isLoading = true;
  double eWalletBalance = 0.0;
double availableCashBalance = 254.92; // keep fixed or fetch from another API
 String vendorName = "";

 @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

Future<void> fetchTransactions() async {
  final url = Uri.parse("http://10.0.2.2/android/config/get_transaction.php");
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse["success"] == true) {
        // Get vendor name from top-level
        final String fetchedVendorName = jsonResponse["vendor_name"] ?? "";

        // Get transactions from "data" array
        final List<dynamic> jsonData = jsonResponse["data"] ?? [];

        double walletTotal = 0.0;
        List<_TransactionData> mappedTransactions = [];

        for (var tx in jsonData) {
          if (tx['nature'] == "CREDIT" && tx['transact_from'] == "EWALLET") {
            walletTotal += double.tryParse(tx['amount'].toString()) ?? 0.0;
          }
          mappedTransactions.add(_TransactionData.fromJson(tx));
        }

        setState(() {
          vendorName = fetchedVendorName;
          transactions = mappedTransactions;
          eWalletBalance = walletTotal;
          isLoading = false;
        });
      } else {
        throw Exception("API returned failure");
      }
    } else {
      throw Exception("Failed to load transactions");
    }
  } catch (e) {
    print("Error: $e");
    setState(() {
      isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title:  Text(
 vendorName.isNotEmpty ? "$vendorName's Wallet" : "Loading Wallet...",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.share_outlined, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Text(
                  // Using current date for demonstration
                  DateFormat('EEEE, MMMM d, y, h:mm a').format(DateTime.now()),
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 110,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.shade800,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child:  Center(
                    child: Text(
                      vendorName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(icon: Icons.call_split_outlined, label: 'Split the bill'),
                  _ActionButton(icon: Icons.sync, label: 'Pay back'),
                  _ActionButton(icon: Icons.support_agent_outlined, label: 'Get support'),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.black, width: 2.5)),
                      ),
                      child: Center(
                        child: Text('Details', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
                      ),
                      child: Center(
                        child: Text('Analytics & tags', style: textTheme.titleSmall?.copyWith(color: Colors.grey.shade600)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'April Highlights',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // --- UNIQUE & ENHANCED HIGHLIGHTS SECTION (Unchanged) ---
              SizedBox(
                height: 170,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(bottom: 10), // Padding for shadow visibility
                  children: [
                    _EnhancedHighlightCard(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Total eWallet Balance',
                      amount: currencyFormat.format(eWalletBalance),
                      description: '25% less than last month',
                      gradientColors: [Colors.blue.shade300, Colors.blue.shade600],
                      shadowColor: Colors.blue.withOpacity(0.4),
                    ),
                    const SizedBox(width: 16),
                    _EnhancedHighlightCard(
                      icon: Icons.money_outlined,
                      title: 'Available eCash Balance',
                      amount: currencyFormat.format(254.92),
                      description: 'Ready to use',
                      gradientColors: [Colors.purple.shade200, Colors.purple.shade400],
                      shadowColor: Colors.purple.withOpacity(0.4),
                    ),
                    const SizedBox(width: 16),
                    _EnhancedHighlightCard(
                      icon: Icons.card_giftcard_rounded,
                      title: 'Available Vouchers',
                      amount: currencyFormat.format(644.92),
                      description: '5 new vouchers added',
                      gradientColors: [Colors.green.shade300, Colors.teal.shade500],
                      shadowColor: Colors.teal.withOpacity(0.4),
                    ),
                    const SizedBox(width: 16),
                    _EnhancedHighlightCard(
                      icon: Icons.hourglass_top_rounded,
                      title: 'Pending Payments',
                      amount: currencyFormat.format(14.92),
                      description: 'Due by Friday',
                      gradientColors: [Colors.grey.shade400, Colors.grey.shade600],
                      shadowColor: Colors.grey.withOpacity(0.4),
                    ),
                    const SizedBox(width: 16),
                    _EnhancedHighlightCard(
                      icon: Icons.local_mall_outlined,
                      title: 'Top spending',
                      amount: 'Groceries',
                      description: '10% higher than average',
                      gradientColors: [Colors.orange.shade300, Colors.deepOrange.shade500],
                      shadowColor: Colors.deepOrange.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- COMPLETELY REDESIGNED RECENT TRANSACTIONS LAYOUT ---
               _EnhancedTransactionList(
                title: 'Recent Transactions',
              transactions: transactions.cast<_TransactionData>(),
                
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Supporting Widgets (Unchanged) ---

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey.shade300)),
          child: Icon(icon, color: Colors.black87, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }
}

class _EnhancedHighlightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String amount;
  final String description;
  final List<Color> gradientColors;
  final Color shadowColor;

  const _EnhancedHighlightCard({
    required this.icon,
    required this.title,
    required this.amount,
    required this.description,
    required this.gradientColors,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 24),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Data Class (Unchanged) ---
class _TransactionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final double amount;
  final String nature;
    final String vendorName;

  const _TransactionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.nature,
    required this.vendorName,

  });

  // Factory method to create from JSON
  factory _TransactionData.fromJson(Map<String, dynamic> json) {
    final bool isCredit = json['nature'] == "CREDIT";
    return _TransactionData(
      icon: isCredit ? Icons.arrow_downward_rounded : Icons.storefront_outlined,
      title: json['description'] ?? 'No Title',
      subtitle: json['date'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
       nature: json['nature'] ?? '',
       vendorName: json['vendor_name']?.toString() ?? '',
    );
  }
}


// --- REFACTORED: Enhanced Transaction List Container ---

class _EnhancedTransactionList extends StatelessWidget {
  final String title;
  final List<_TransactionData> transactions;
  const _EnhancedTransactionList({required this.title, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Integrated Header ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // --- List of New Tiles ---
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _EnhancedTransactionTile(transaction: transaction);
            },
            separatorBuilder: (context, index) => Divider(
              height: 24, // More space between items
              thickness: 1,
              color: Colors.grey.shade100,
            ),
          ),
        ],
      ),
    );
  }
}

// --- REFACTORED: Enhanced Transaction Tile ---

class _EnhancedTransactionTile extends StatelessWidget {
  final _TransactionData transaction;

  const _EnhancedTransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final bool isCredit = transaction.nature.toUpperCase() == "CREDIT"; // <-- Check by nature
    final iconBgColor = isCredit ? Colors.green.shade50 : Colors.red.shade50;
    final iconColor = isCredit ? Colors.green.shade600 : Colors.red.shade600;
    final amountColor = isCredit ? Colors.green.shade700 : Colors.red.shade700;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(transaction.icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.vendorName.isNotEmpty
      ? transaction.vendorName
      : transaction.title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                transaction.subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ),
        Text(
'${isCredit ? "" : "-"}${currencyFormat.format(transaction.amount)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: amountColor,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

  final currencyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);