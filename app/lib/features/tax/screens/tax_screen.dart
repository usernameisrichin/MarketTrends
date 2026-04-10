// ============================================================
// features/tax/screens/tax_screen.dart
// ============================================================
//
// UI flow:
//   1. User fills in: buy date, sell date, buy price, sell price,
//      quantity, asset type (equity or crypto)
//   2. Taps "Calculate Tax"
//   3. POST /tax/calculate → TaxResult
//   4. Result shown in TaxResultCard below the form
// ============================================================

import 'package:flutter/material.dart';
import '../models/tax_model.dart';
import '../services/tax_service.dart';
import '../widgets/tax_result_card.dart';

class TaxScreen extends StatefulWidget {
  const TaxScreen({super.key});

  @override
  State<TaxScreen> createState() => _TaxScreenState();
}

class _TaxScreenState extends State<TaxScreen> {

  final _formKey          = GlobalKey<FormState>();
  final _taxService       = TaxService();

  // ── Form controllers ──────────────────────────────────────
  final _buyPriceCtrl   = TextEditingController();
  final _sellPriceCtrl  = TextEditingController();
  final _quantityCtrl   = TextEditingController();

  DateTime? _buyDate;
  DateTime? _sellDate;
  String    _assetType = 'equity';   // "equity" or "crypto"

  // ── UI state ──────────────────────────────────────────────
  bool        _isLoading = false;
  String?     _error;
  TaxResult?  _result;

  @override
  void dispose() {
    _buyPriceCtrl.dispose();
    _sellPriceCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  // ── Date picker ───────────────────────────────────────────
  Future<void> _pickDate(bool isBuy) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
          isBuy ? const Duration(days: 400) : const Duration(days: 5)),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isBuy) _buyDate = picked; else _sellDate = picked;
      });
    }
  }

  // ── Submission ────────────────────────────────────────────
  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_buyDate == null || _sellDate == null) {
      setState(() => _error = 'Please select both buy and sell dates.');
      return;
    }

    setState(() { _isLoading = true; _error = null; _result = null; });

    try {
      final request = TaxRequest(
        buyDate:    '${_buyDate!.year}-${_pad(_buyDate!.month)}-${_pad(_buyDate!.day)}',
        sellDate:   '${_sellDate!.year}-${_pad(_sellDate!.month)}-${_pad(_sellDate!.day)}',
        buyPrice:   double.parse(_buyPriceCtrl.text),
        sellPrice:  double.parse(_sellPriceCtrl.text),
        quantity:   double.parse(_quantityCtrl.text),
        assetType:  _assetType,
      );
      final result = await _taxService.calculate(request);
      setState(() { _result = result; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); _isLoading = false; });
    }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Tax Estimator', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Asset type selector ─────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Text('Asset Type', style: TextStyle(fontSize: 15)),
                      const Spacer(),
                      ChoiceChip(
                        label: const Text('Equity'),
                        selected: _assetType == 'equity',
                        onSelected: (_) => setState(() => _assetType = 'equity'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Crypto'),
                        selected: _assetType == 'crypto',
                        selectedColor: Colors.purple.shade100,
                        onSelected: (_) => setState(() => _assetType = 'crypto'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Date pickers ────────────────────────────
              Row(
                children: [
                  Expanded(child: _DateTile(
                    label: 'Buy Date',
                    date: _buyDate,
                    onTap: () => _pickDate(true),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _DateTile(
                    label: 'Sell Date',
                    date: _sellDate,
                    onTap: () => _pickDate(false),
                  )),
                ],
              ),

              const SizedBox(height: 12),

              // ── Price + quantity inputs ──────────────────
              Row(
                children: [
                  Expanded(child: _NumberField(
                    controller: _buyPriceCtrl,
                    label: 'Buy Price (₹)',
                    hint: '2400.00',
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _NumberField(
                    controller: _sellPriceCtrl,
                    label: 'Sell Price (₹)',
                    hint: '2875.50',
                  )),
                ],
              ),

              const SizedBox(height: 12),

              _NumberField(
                controller: _quantityCtrl,
                label: 'Quantity (shares / coins)',
                hint: '10',
              ),

              const SizedBox(height: 20),

              // ── Calculate button ─────────────────────────
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _calculate,
                icon: _isLoading
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.calculate),
                label: Text(_isLoading ? 'Calculating...' : 'Calculate Tax',
                    style: const TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),

              // ── Error ────────────────────────────────────
              if (_error != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!,
                          style: const TextStyle(color: Colors.red))),
                    ]),
                  ),
                ),
              ],

              // ── Result ───────────────────────────────────
              if (_result != null) ...[
                const SizedBox(height: 20),
                TaxResultCard(result: _result!),
              ],

              // ── Info box ─────────────────────────────────
              const SizedBox(height: 24),
              _InfoBox(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small private sub-widgets ─────────────────────────────────

class _DateTile extends StatelessWidget {
  final String    label;
  final DateTime? date;
  final VoidCallback onTap;
  const _DateTile({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = date != null
        ? '${date!.day}/${date!.month}/${date!.year}'
        : 'Pick date';
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(text, style: TextStyle(
          color: date == null ? Colors.grey.shade500 : null,
        )),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  const _NumberField({required this.controller, required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Required';
        if (double.tryParse(v) == null)    return 'Enter a valid number';
        if (double.parse(v) <= 0)          return 'Must be > 0';
        return null;
      },
    );
  }
}

class _InfoBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
              const SizedBox(width: 6),
              Text('Indian Tax Rules (FY 2024-25)',
                  style: TextStyle(fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700)),
            ]),
            const SizedBox(height: 8),
            const Text('• Equity STCG (< 1 year): 20%\n'
                       '• Equity LTCG (≥ 1 year): 12.5% above ₹1.25L\n'
                       '• Crypto: 30% flat + 1% TDS on sell value',
                style: TextStyle(fontSize: 13, height: 1.6)),
          ],
        ),
      ),
    );
  }
}
