import 'package:flutter/material.dart';
import '../src/app.dart';
import '../src/transaction_screen.dart';

void main() {
  
 runApp(
    MaterialApp(
      home: TransactionDetailScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

