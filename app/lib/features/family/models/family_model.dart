// features/family/models/family_model.dart

import '../../dashboard/models/portfolio_model.dart';

class FamilyMember {
  final String id;
  final String name;
  final String relation;
  final double totalValue;
  final String dailyChange;
  final List<Asset> assets;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.totalValue,
    required this.dailyChange,
    required this.assets,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
    id           = json['id']           as String,
    name         = json['name']         as String,
    relation     = json['relation']     as String,
    totalValue   = (json['total_value'] as num).toDouble(),
    dailyChange  = json['daily_change'] as String,
    assets       = (json['assets'] as List)
        .map((e) => Asset.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class FamilySummary {
  final double           totalNetWorth;
  final String           dailyChange;
  final List<FamilyMember> members;

  const FamilySummary({
    required this.totalNetWorth,
    required this.dailyChange,
    required this.members,
  });

  factory FamilySummary.fromJson(Map<String, dynamic> json) => FamilySummary(
    totalNetWorth = (json['total_net_worth'] as num).toDouble(),
    dailyChange   = json['daily_change']     as String,
    members       = (json['members'] as List)
        .map((e) => FamilyMember.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
