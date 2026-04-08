# ============================================================
# models/sip.py — SIP Backtester Data Models
# ============================================================
#
# SIP = Systematic Investment Plan
# Rupee-Cost Averaging: invest a fixed amount every month
# regardless of market price. Over time, this averages out
# the cost per unit and reduces timing risk.
#
# This backtester shows: "If I had invested ₹X/month in
# RELIANCE for 3 years, what would my portfolio be worth today?"
# ============================================================

from pydantic import BaseModel, field_validator
from typing import List


class SIPRequest(BaseModel):
    """
    Input: what asset, how much per month, for how long.
    """
    monthly_amount: float   # Fixed monthly investment in INR (e.g. 5000)
    asset: str              # Ticker: "RELIANCE.NS", "TCS.NS", "BTC", "ETH"
    duration: str           # "1y", "3y", or "5y"

    @field_validator("duration")
    @classmethod
    def validate_duration(cls, v: str) -> str:
        allowed = {"1y", "3y", "5y"}
        if v not in allowed:
            raise ValueError(f"duration must be one of {allowed}")
        return v

    @field_validator("monthly_amount")
    @classmethod
    def validate_amount(cls, v: float) -> float:
        if v <= 0:
            raise ValueError("monthly_amount must be positive")
        return v


class SIPDataPoint(BaseModel):
    """
    A single month's snapshot of the SIP portfolio.
    Used to draw the line chart on the frontend.
    """
    date: str               # "YYYY-MM" format
    portfolio_value: float  # What the portfolio is worth at this point
    total_invested: float   # Cumulative amount invested so far


class SIPResponse(BaseModel):
    """
    Full backtesting result returned by the API.
    """
    total_invested: float       # Total money put in over the period
    current_value: float        # Portfolio value at the latest price
    returns_pct: float          # (current_value - total_invested) / total_invested × 100
    returns_amount: float       # current_value - total_invested (absolute INR)
    monthly_amount: float       # Echo back the input
    asset: str                  # Echo back the ticker
    duration: str               # Echo back the duration
    time_series: List[SIPDataPoint]  # Monthly data for the chart
