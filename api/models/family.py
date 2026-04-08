# ============================================================
# models/family.py — Family Portfolio Aggregation Models
# ============================================================
#
# Indian families often manage investments across members.
# This feature aggregates holdings by family member and
# shows a combined "Net Worth" view.
# ============================================================

from pydantic import BaseModel
from typing import List
from models.portfolio import Asset


class FamilyMember(BaseModel):
    """Represents one family member's portfolio."""
    id: str           # Unique ID: "self", "spouse", "parent_father", etc.
    name: str         # Display name: "You", "Priya", "Father"
    relation: str     # "self", "spouse", "parent", "child"
    total_value: float
    daily_change: str  # e.g. "+1.2%"
    assets: List[Asset]


class FamilySummaryResponse(BaseModel):
    """
    Combined family net worth view.
    total_net_worth = sum of all member total_values.
    """
    total_net_worth: float
    daily_change: str
    members: List[FamilyMember]
