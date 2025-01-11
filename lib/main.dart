
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      home: CurrencyConverterScreen(),
    );
  }
}

class CurrencyConverterScreen extends StatefulWidget {
  @override
  _CurrencyConverterScreenState createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  double _conversionRate = 0.0;
  TextEditingController _amountController = TextEditingController();
  String _result = '';

  final String _apiUrl =
      'https://v6.exchangerate-api.com/v6/31788b2363b451d0e735a7c1/latest/USD';

  List<String> _currencies = [];

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  Future<void> _fetchCurrencies() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _currencies = (data['conversion_rates'] as Map<String, dynamic>).keys.toList();
          _conversionRate = data['conversion_rates'][_toCurrency];
        });
      } else {
        _showError('Failed to fetch currency data.');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    }
  }

  Future<void> _convertCurrency() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['conversion_rates'];
        setState(() {
          _conversionRate = rates[_toCurrency] / rates[_fromCurrency];
          final amount = double.tryParse(_amountController.text) ?? 0.0;
          _result = (amount * _conversionRate).toStringAsFixed(2);
        });
      } else {
        _showError('Failed to fetch conversion rates.');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Currency Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Amount'
                ),
            ),
            SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _fromCurrency,
                    isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        _fromCurrency = value!;
                      });
                    },
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(
                        child: Text(currency),
                        value: currency,
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: _toCurrency,
                    isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        _toCurrency = value!;
                      });
                    },
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(
                        child: Text(currency),
                        value: currency,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _convertCurrency,
              child: Text('Convert'),
            ),
            SizedBox(height: 16),
            Text(
              
              'Result: $_result $_toCurrency',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
