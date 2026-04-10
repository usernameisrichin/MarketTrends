// features/sip/screens/sip_screen.dart

import 'package:flutter/material.dart';
import '../models/sip_model.dart';
import '../services/sip_service.dart';
import '../widgets/sip_chart.dart';

class SipScreen extends StatefulWidget {
  const SipScreen({super.key});
  @override
  State<SipScreen> createState() => _SipScreenState();
}

class _SipScreenState extends State<SipScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _sipService   = SipService();
  final _amountCtrl   = TextEditingController();
  final _assetCtrl    = TextEditingController(text: 'BTC');

  String   _duration  = '3y';
  bool     _isLoading = false;
  String?  _error;
  SipResult? _result;

  static const _durations = ['1y', '3y', '5y'];
  static const _presets   = ['BTC', 'ETH', 'RELIANCE.NS', 'TCS.NS', 'INFY.NS'];

  Future<void> _runBacktest() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; _result = null; });
    try {
      final result = await _sipService.backtest(SipRequest(
        monthlyAmount: double.parse(_amountCtrl.text),
        asset:         _assetCtrl.text.trim().toUpperCase(),
        duration:      _duration,
      ));
      setState(() { _result = result; _isLoading = false; });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('SIP Backtester', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Monthly amount ──────────────────────────
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monthly Investment (₹)',
                  hintText:  '5000',
                  prefixText: '₹ ',
                  border:    OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // ── Asset input + preset chips ───────────────
              TextFormField(
                controller: _assetCtrl,
                decoration: const InputDecoration(
                  labelText: 'Asset Ticker',
                  hintText:  'BTC, RELIANCE.NS, TCS.NS …',
                  border:    OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: _presets.map((p) => ActionChip(
                  label: Text(p, style: const TextStyle(fontSize: 12)),
                  onPressed: () => _assetCtrl.text = p,
                )).toList(),
              ),

              const SizedBox(height: 16),

              // ── Duration selector ────────────────────────
              Row(
                children: [
                  const Text('Duration:', style: TextStyle(fontSize: 15)),
                  const SizedBox(width: 12),
                  ..._durations.map((d) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(d),
                      selected: _duration == d,
                      onSelected: (_) => setState(() => _duration = d),
                    ),
                  )),
                ],
              ),

              const SizedBox(height: 20),

              // ── Run button ───────────────────────────────
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _runBacktest,
                icon: _isLoading
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.play_arrow),
                label: Text(_isLoading ? 'Running...' : 'Run Backtest',
                    style: const TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                ),
              ],

              if (_result != null) ...[
                const SizedBox(height: 24),
                _SummaryCards(result: _result!),
                const SizedBox(height: 20),
                _ChartSection(result: _result!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


class _SummaryCards extends StatelessWidget {
  final SipResult result;
  const _SummaryCards({required this.result});

  @override
  Widget build(BuildContext context) {
    final isGain = result.returnsAmount >= 0;
    final color  = isGain ? Colors.green.shade700 : Colors.red.shade700;

    return Column(
      children: [
        Row(children: [
          Expanded(child: _Card(
            label: 'Total Invested',
            value: '₹${_fmt(result.totalInvested)}',
            icon: Icons.savings,
            iconColor: Colors.blue,
          )),
          const SizedBox(width: 12),
          Expanded(child: _Card(
            label: 'Current Value',
            value: '₹${_fmt(result.currentValue)}',
            icon: Icons.account_balance_wallet,
            iconColor: Colors.indigo,
          )),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _Card(
            label: 'Returns',
            value: '${isGain ? "+" : ""}₹${_fmt(result.returnsAmount)}',
            icon: isGain ? Icons.trending_up : Icons.trending_down,
            iconColor: color,
            valueColor: color,
          )),
          const SizedBox(width: 12),
          Expanded(child: _Card(
            label: 'Returns %',
            value: '${isGain ? "+" : ""}${result.returnsPct.toStringAsFixed(2)}%',
            icon: Icons.percent,
            iconColor: color,
            valueColor: color,
          )),
        ]),
      ],
    );
  }

  String _fmt(double v) => v.toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}


class _Card extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? valueColor;
  const _Card({required this.label, required this.value, required this.icon,
    required this.iconColor, this.valueColor});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
            color: valueColor)),
      ]),
    ),
  );
}


class _ChartSection extends StatelessWidget {
  final SipResult result;
  const _ChartSection({required this.result});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Portfolio Growth — ${result.asset} (${result.duration})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Row(children: [
        _Legend(color: Colors.indigo,         label: 'Portfolio Value'),
        const SizedBox(width: 16),
        _Legend(color: Colors.orange.shade600, label: 'Invested Amount', dashed: true),
      ]),
      const SizedBox(height: 12),
      SipChart(timeSeries: result.timeSeries),
    ],
  );
}

class _Legend extends StatelessWidget {
  final Color  color;
  final String label;
  final bool   dashed;
  const _Legend({required this.color, required this.label, this.dashed = false});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 20, height: 3,
      decoration: BoxDecoration(
        color: dashed ? Colors.transparent : color,
        border: dashed ? Border(bottom: BorderSide(color: color, width: 2)) : null,
      ),
    ),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 12)),
  ]);
}
