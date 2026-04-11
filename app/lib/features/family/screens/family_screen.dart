// features/family/screens/family_screen.dart

import 'package:flutter/material.dart';
import '../models/family_model.dart';
import '../services/family_service.dart';
import '../../dashboard/widgets/asset_card.dart';
import '../../../shared/widgets/balance_visibility_wrapper.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});
  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _service = FamilyService();

  bool          _isLoading  = false;
  String?       _error;
  FamilySummary? _summary;
  int           _selectedIdx = 0;   // Which member tab is active

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _service.fetchFamilySummary();
      setState(() { _summary = data; _isLoading = false; });
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
        title: const Text('Family Portfolio', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(message: _error!)
              : _summary == null
                  ? const Center(child: Text('No data'))
                  : _Body(
                      summary:     _summary!,
                      selectedIdx: _selectedIdx,
                      onSelect:    (i) => setState(() => _selectedIdx = i),
                    ),
    );
  }
}


class _Body extends StatelessWidget {
  final FamilySummary summary;
  final int           selectedIdx;
  final ValueChanged<int> onSelect;

  const _Body({required this.summary, required this.selectedIdx, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final member = summary.members[selectedIdx];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── Net Worth Card ──────────────────────────────
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Family Net Worth',
                    style: TextStyle(fontSize: 14,
                        color: Theme.of(context).colorScheme.onPrimaryContainer
                            .withOpacity(0.7))),
                const SizedBox(height: 6),
                // Wrap the total in the balance visibility widget
                BalanceVisibilityWrapper(
                  child: Text(
                    '₹${_fmt(summary.totalNetWorth)}',
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
                Text('Today: ${summary.dailyChange}',
                    style: TextStyle(
                      color: summary.dailyChange.startsWith('+')
                          ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 12),
                // Member breakdown chips
                Wrap(spacing: 8, children: summary.members.asMap().entries.map((e) {
                  final m = e.value;
                  return ActionChip(
                    avatar: CircleAvatar(
                      radius: 10,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(m.name[0],
                          style: const TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                    label: Text('${m.name} ₹${_fmtShort(m.totalValue)}'),
                    onPressed: () => onSelect(e.key),
                  );
                }).toList()),
              ]),
            ),
          ),

          const SizedBox(height: 20),

          // ── Profile Switcher tabs ───────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: summary.members.asMap().entries.map((e) {
                final m       = e.value;
                final isActive = e.key == selectedIdx;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected:    isActive,
                    label:       Text(m.name),
                    avatar:      Icon(_relationIcon(m.relation), size: 16),
                    onSelected:  (_) => onSelect(e.key),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // ── Selected member header ──────────────────────
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(member.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('₹${_fmt(member.totalValue)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 4),
          Text(member.dailyChange,
              style: TextStyle(
                color: member.dailyChange.startsWith('+')
                    ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w600,
              )),

          const SizedBox(height: 12),

          // ── Holdings list ───────────────────────────────
          ...member.assets.map((a) => AssetCard(asset: a)),
        ],
      ),
    );
  }

  IconData _relationIcon(String relation) => switch (relation) {
    'spouse' => Icons.favorite,
    'parent' => Icons.elderly,
    'child'  => Icons.child_care,
    _        => Icons.person,
  };

  String _fmt(double v) => v.toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  String _fmtShort(double v) {
    if (v >= 1_00_000) return '${(v / 1_00_000).toStringAsFixed(1)}L';
    if (v >= 1_000)    return '${(v / 1_000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red)),
      ]),
    ),
  );
}
