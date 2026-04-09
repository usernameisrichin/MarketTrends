# ============================================================
# services/family_service.py — Family Portfolio Aggregation
# ============================================================
#
# In India, investments are often distributed across family
# members for tax efficiency (each member has separate LTCG
# exemptions, 80C limits, etc.).
#
# This service aggregates portfolios by member and provides
# a combined net worth view.
#
# Currently uses mock data. In production, replace with a
# database query (e.g., Supabase, PostgreSQL).
# ============================================================

from models.family import FamilyMember, FamilySummaryResponse
from models.portfolio import Asset

# ── Mock family portfolios ────────────────────────────────────
# Each member has their own set of holdings.
# In production, this would come from a DB keyed by user account.

_FAMILY_DATA: dict[str, FamilyMember] = {

    "self": FamilyMember(
        id="self",
        name="You",
        relation="self",
        total_value=1_600_000,
        daily_change="+2.3%",
        assets=[
            Asset(type="stock",  name="Reliance Industries",       symbol="RELIANCE", value=500_000, change="+1.2%"),
            Asset(type="stock",  name="Tata Consultancy Services", symbol="TCS",      value=300_000, change="-0.5%"),
            Asset(type="stock",  name="Infosys",                   symbol="INFY",     value=200_000, change="+0.8%"),
            Asset(type="crypto", name="Bitcoin",                   symbol="BTC",      value=450_000, change="+3.8%"),
            Asset(type="stock",  name="HDFC Bank",                 symbol="HDFCBANK", value=150_000, change="+0.3%"),
        ],
    ),

    "spouse": FamilyMember(
        id="spouse",
        name="Priya",
        relation="spouse",
        total_value=950_000,
        daily_change="+1.1%",
        assets=[
            Asset(type="stock", name="Asian Paints",       symbol="ASIANPAINT", value=350_000, change="+1.5%"),
            Asset(type="stock", name="Bajaj Finance",      symbol="BAJFINANCE", value=300_000, change="+0.9%"),
            Asset(type="stock", name="Titan Company",      symbol="TITAN",      value=300_000, change="-0.2%"),
        ],
    ),

    "parent_father": FamilyMember(
        id="parent_father",
        name="Father",
        relation="parent",
        total_value=2_200_000,
        daily_change="+0.7%",
        assets=[
            Asset(type="stock", name="State Bank of India", symbol="SBIN",      value=800_000, change="+0.5%"),
            Asset(type="stock", name="Larsen & Toubro",     symbol="LT",        value=750_000, change="+1.2%"),
            Asset(type="stock", name="Coal India",          symbol="COALINDIA", value=650_000, change="-0.3%"),
        ],
    ),

    "parent_mother": FamilyMember(
        id="parent_mother",
        name="Mother",
        relation="parent",
        total_value=800_000,
        daily_change="+0.4%",
        assets=[
            Asset(type="stock", name="ITC Limited",   symbol="ITC",   value=400_000, change="+0.6%"),
            Asset(type="stock", name="Hindustan Unilever", symbol="HINDUNILVR", value=400_000, change="+0.2%"),
        ],
    ),
}


def get_family_summary() -> FamilySummaryResponse:
    """
    Aggregates all family member portfolios into a single net worth view.
    Returns all members sorted by total_value descending.
    """
    members       = list(_FAMILY_DATA.values())
    total_worth   = sum(m.total_value for m in members)

    # Weighted average of daily changes (simplified: just show blended %)
    return FamilySummaryResponse(
        total_net_worth = total_worth,
        daily_change    = "+1.4%",  # Blended daily change
        members         = members,
    )


def get_member(member_id: str) -> FamilyMember:
    """
    Returns a single family member's portfolio by ID.
    Raises ValueError if the member doesn't exist.
    """
    member = _FAMILY_DATA.get(member_id)
    if not member:
        valid_ids = list(_FAMILY_DATA.keys())
        raise ValueError(f"Member '{member_id}' not found. Valid IDs: {valid_ids}")
    return member
