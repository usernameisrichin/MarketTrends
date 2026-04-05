# ============================================================
# models/portfolio.py — Data Blueprints (Pydantic Models)
# ============================================================
#
# What are models?
#   Models define the SHAPE of data — what fields exist,
#   what type each field is, and what the JSON will look like.
#
#   FastAPI uses Pydantic models to:
#     1. Validate incoming data (correct types, required fields)
#     2. Serialize outgoing data (Python objects → JSON)
#     3. Auto-generate API documentation at /docs
#
# Think of models as contracts: "this is exactly what the API
# will return, no surprises."
# ============================================================

from pydantic import BaseModel
from typing import List


class Asset(BaseModel):
    """
    Represents a single holding in the portfolio.
    Could be an Indian stock or Bitcoin.
    """
    type: str     # "stock" or "crypto"
    name: str     # Full name, e.g. "Reliance Industries"
    symbol: str   # Ticker symbol, e.g. "RELIANCE" or "BTC"
    value: float  # Current value in INR
    change: str   # Daily change as a formatted string, e.g. "+1.2%"


class PortfolioSummary(BaseModel):
    """
    The top-level portfolio response.
    Contains the summary + list of individual assets.
    """
    totalValue: float       # Total portfolio value in INR
    dailyChange: str        # Overall daily change, e.g. "+2.3%"
    assets: List[Asset]     # All holdings
