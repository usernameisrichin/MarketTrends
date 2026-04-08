# ============================================================
# models/tax.py — Tax Calculation Data Models
# ============================================================
#
# Indian Capital Gains Tax Rules (FY 2024-25, post-Budget 2024):
#
#   EQUITY STCG  → holding < 12 months  → 20% on gains
#   EQUITY LTCG  → holding ≥ 12 months  → 12.5% on gains above ₹1.25L
#   CRYPTO       → any duration         → 30% flat + 1% TDS on sell value
#
# These models define what the API expects (request) and returns (response).
# ============================================================

from pydantic import BaseModel, field_validator
from datetime import date
from typing import Optional


class TaxCalculationRequest(BaseModel):
    """
    Input fields needed to calculate capital gains tax.
    The frontend sends this as a JSON POST body.
    """
    buy_date: date          # Date of purchase  (format: YYYY-MM-DD)
    sell_date: date         # Date of sale       (format: YYYY-MM-DD)
    buy_price: float        # Price per unit at purchase (INR)
    sell_price: float       # Price per unit at sale     (INR)
    quantity: float         # Number of shares / coins
    asset_type: str         # "equity" or "crypto"

    @field_validator("asset_type")
    @classmethod
    def validate_asset_type(cls, v: str) -> str:
        allowed = {"equity", "crypto"}
        if v.lower() not in allowed:
            raise ValueError(f"asset_type must be one of {allowed}")
        return v.lower()

    @field_validator("sell_date")
    @classmethod
    def sell_after_buy(cls, v: date, info) -> date:
        # Access buy_date from previously validated fields
        buy = info.data.get("buy_date")
        if buy and v <= buy:
            raise ValueError("sell_date must be after buy_date")
        return v


class TaxCalculationResponse(BaseModel):
    """
    Structured tax breakdown returned by the API.
    Frontend uses this to display the result card.
    """
    gain: float                      # Absolute gain/loss in INR
    tax_amount: float                # Tax payable in INR
    tax_type: str                    # "STCG", "LTCG", or "CRYPTO"
    tax_rate: float                  # Applicable rate as percentage (e.g. 20.0)
    net_profit: float                # gain − tax_amount
    holding_days: int                # Number of days between buy and sell
    tds_amount: Optional[float] = None  # 1% TDS deducted at source (crypto only)
    exemption_applied: Optional[float] = None  # LTCG ₹1.25L exemption applied
