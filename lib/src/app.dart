import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  Appstate createState() => Appstate();
}

class Appstate extends State<MyApp> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful: ${response.paymentId}")),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  void _openRazorpay(int amount) {
    var options = {
      'key': 'rzp_test_pi2fEEfhC66GKs',
      'amount': amount * 100, 
      'name': 'Pratik Bagul',
      'description': 'Membership Payment',
      'prefill': {
        'contact': '8888888888',
        'email': 'test@example.com',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF3F7FB),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Membership Plans",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const Center(
                child: Text(
                  "Choose the best featured plans",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 60),

              // Horizontal Scroll
              SizedBox(
                height: 400,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    planCard(
                      title: "Basic",
                      subtitle: "Startup Plan",
                      price: "Free",
                      currency: "",
                      appEntitlement: 1,
                      coaches: 0,
                      color: Colors.blue,
                      isCurrent: true,
                      onTap: null, 
                       topRightIcon: Icons.star,
                       boxcolor: Color(0xFF3B82F6),

                    ),
                    planCard(
                      title: "Plus",
                      subtitle: "Enhanced Access",
                      price: "50",
                      currency: " ₹",
                      appEntitlement: 6,
                      coaches: 2,
                      color: Colors.green,
                      onTap: () => _openRazorpay(50),
                       topRightIcon: Icons.auto_awesome,
                       boxcolor: const Color.fromARGB(255, 238, 244, 249),
                    ),
                    planCard(
                      title: "Premium",
                      subtitle: "Professional Suite",
                      price: "100",
                      currency: " ₹",
                      appEntitlement: 16,
                      coaches: 5,
                      color: Colors.purple,
                      onTap: () => _openRazorpay(100),
                       topRightIcon: Icons.workspace_premium,
                       boxcolor: const Color.fromARGB(255, 238, 244, 249),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Plan Card Widget
  Widget planCard({
  required String title,
  required String subtitle,
  required String price,
  required String currency,
  required int appEntitlement,
  required int coaches,
  required Color color,
  required Color boxcolor,
  bool isCurrent = false,
  VoidCallback? onTap,
  IconData? topRightIcon, 
}) {
  return Container(
    width: 350,
    height: 400, 
    margin: const EdgeInsets.only(right: 16),
    child: Card(
      color: isCurrent ? color : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: isCurrent ? Colors.white : Colors.black)),
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 20,
                              color: isCurrent ? Colors.white : Colors.grey)),
                    ],
                  ),
                ),
                if (topRightIcon != null)
                  Icon(
                    topRightIcon,
                    size: 40,
                    color: isCurrent ? Colors.white : color,
                  ),
              ],
            ),

            const SizedBox(height: 40),
            Text(
              "$currency$price ${price != "Free" ? "Monthly" : ""}",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: isCurrent ? Colors.white : color),
            ),
            const SizedBox(height: 20),

         Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: boxcolor,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.check_circle,
              color: isCurrent ? Colors.white : color),
          const SizedBox(width: 6),
          Text("App Entitlement: $appEntitlement",
              style: TextStyle(
                  fontSize: 20,
                  color: isCurrent ? Colors.white : Colors.black)),
        ],
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          Icon(
              coaches > 0 ? Icons.check_circle : Icons.cancel,
              color: coaches > 0
                  ? (isCurrent ? Colors.white : color)
                  : Colors.red,
              ),
          const SizedBox(width: 6),
          Text("Coaches: $coaches",
              style: TextStyle(
                  fontSize: 20,
                  color: isCurrent ? Colors.white : Colors.black)),
        ],
      ),
    ],
  ),
),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrent ? Colors.white : color,
                  foregroundColor: isCurrent ? color : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isCurrent ? "✓  Current Plan" : "Choose Plan",
                style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}
