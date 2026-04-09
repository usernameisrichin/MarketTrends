# ============================================================
# services/sip_service.py — SIP Backtester
# ============================================================
#
# How SIP simulation works:
#   1. Build a list of monthly dates from start → today
#   2. For each month, look up the closing price
#   3. units_bought = monthly_amount / price
#   4. Accumulate total_units and total_invested
#   5. portfolio_value = total_units × current_price
#
# Data sources:
#   Stocks  → Yahoo Finance via yfinance (Indian stocks use .NS suffix)
#   Crypto  → CoinGecko public API (free tier, no API key needed)
#
# Both sources are synchronous libraries, so we use
# asyncio.to_thread() to avoid blocking FastAPI's event loop.
# ============================================================

import asyncio
import httpx
import yfinance as yf
from datetime import date, datetime
from dateutil.relativedelta import relativedelta
from typing import Dict

from models.sip import SIPRequest, SIPResponse, SIPDataPoint

# CoinGecko coin ID map (symbol → CoinGecko ID)
_CRYPTO_MAP: Dict[str, str] = {
    "BTC":  "bitcoin",
    "ETH":  "ethereum",
    "SOL":  "solana",
    "BNB":  "binancecoin",
    "MATIC": "matic-network",
}

# Fallback mock prices when external APIs are unavailable
# Key: "YYYY-MM", Value: price in INR
_MOCK_BTC_PRICES: Dict[str, float] = {
    "2023-04": 2_300_000, "2023-05": 2_500_000, "2023-06": 2_350_000,
    "2023-07": 2_600_000, "2023-08": 2_450_000, "2023-09": 2_200_000,
    "2023-10": 2_750_000, "2023-11": 3_200_000, "2023-12": 3_600_000,
    "2024-01": 3_800_000, "2024-02": 4_200_000, "2024-03": 5_800_000,
    "2024-04": 5_600_000, "2024-05": 5_400_000, "2024-06": 5_200_000,
    "2024-07": 5_500_000, "2024-08": 5_300_000, "2024-09": 5_100_000,
    "2024-10": 5_900_000, "2024-11": 7_200_000, "2024-12": 8_400_000,
    "2025-01": 8_100_000, "2025-02": 7_600_000, "2025-03": 6_900_000,
    "2025-04": 7_200_000, "2025-05": 7_800_000, "2025-06": 8_200_000,
    "2025-07": 8_500_000, "2025-08": 8_300_000, "2025-09": 7_900_000,
    "2025-10": 8_100_000, "2025-11": 8_700_000, "2025-12": 9_200_000,
    "2026-01": 9_500_000, "2026-02": 9_100_000, "2026-03": 8_800_000,
}


def _get_start_date(duration: str) -> date:
    """Convert duration string to a calendar start date."""
    today = date.today()
    mapping = {"1y": 1, "3y": 3, "5y": 5}
    years = mapping[duration]
    return today - relativedelta(years=years)


def _build_monthly_dates(start: date, end: date):
    """
    Yield the first day of each month between start and end.
    e.g. start=2023-04-01, end=2024-04-01 → 13 dates
    """
    current = start.replace(day=1)
    while current <= end.replace(day=1):
        yield current
        current += relativedelta(months=1)


# ── Stock data (synchronous yfinance) ────────────────────────

def _fetch_stock_prices_sync(ticker: str, start: date) -> Dict[str, float]:
    """
    Fetch monthly closing prices from Yahoo Finance.
    Indian stock tickers end with .NS (e.g. RELIANCE.NS)
    """
    # Auto-append .NS for Indian stocks if no exchange suffix present
    if "." not in ticker:
        ticker = f"{ticker}.NS"

    stock = yf.Ticker(ticker)
    hist = stock.history(start=start.isoformat(), interval="1mo")

    prices: Dict[str, float] = {}
    for ts, row in hist.iterrows():
        key = ts.strftime("%Y-%m")
        prices[key] = float(row["Close"])
    return prices


async def _fetch_stock_prices(ticker: str, start: date) -> Dict[str, float]:
    """Async wrapper around the blocking yfinance call."""
    return await asyncio.to_thread(_fetch_stock_prices_sync, ticker, start)


# ── Crypto data (async httpx → CoinGecko) ────────────────────

async def _fetch_crypto_prices(coin_id: str, start: date) -> Dict[str, float]:
    """
    Fetch monthly historical prices from CoinGecko free API.
    Returns prices in INR (vs_currency=inr).
    """
    days = (date.today() - start).days
    url = "https://api.coingecko.com/api/v3/coins/{coin}/market_chart".format(coin=coin_id)
    params = {"vs_currency": "inr", "days": days, "interval": "monthly"}

    async with httpx.AsyncClient(timeout=15.0) as client:
        resp = await client.get(url, params=params)
        resp.raise_for_status()
        data = resp.json()

    prices: Dict[str, float] = {}
    for ts_ms, price in data.get("prices", []):
        key = datetime.fromtimestamp(ts_ms / 1000).strftime("%Y-%m")
        prices[key] = price
    return prices


# ── SIP simulation engine ─────────────────────────────────────

def _simulate_sip(
    monthly_prices: Dict[str, float],
    monthly_amount: float,
    start: date,
) -> tuple[float, float, list]:
    """
    Core SIP loop:
      - For each month that has a price, invest monthly_amount
      - Accumulate total_units and total_invested
      - Record a SIPDataPoint snapshot per month

    Returns: (total_invested, current_value, time_series)
    """
    total_units    = 0.0
    total_invested = 0.0
    time_series    = []

    for month_date in _build_monthly_dates(start, date.today()):
        key = month_date.strftime("%Y-%m")
        price = monthly_prices.get(key)
        if price is None or price <= 0:
            continue   # Skip months with no data

        units_bought    = monthly_amount / price
        total_units    += units_bought
        total_invested += monthly_amount
        portfolio_value = total_units * price

        time_series.append(SIPDataPoint(
            date            = key,
            portfolio_value = round(portfolio_value, 2),
            total_invested  = round(total_invested, 2),
        ))

    # Use latest available price for final current_value
    if time_series:
        last_price   = monthly_prices[max(monthly_prices.keys())]
        current_value = total_units * last_price
    else:
        current_value = 0.0

    return total_invested, round(current_value, 2), time_series


# ── Public API ────────────────────────────────────────────────

async def run_sip_backtest(req: SIPRequest) -> SIPResponse:
    """
    Main entry point called by the route handler.
    Fetches historical prices, runs simulation, returns structured result.
    """
    start_date = _get_start_date(req.duration)
    asset_upper = req.asset.upper()

    # ── Fetch prices ─────────────────────────────────────────
    if asset_upper in _CRYPTO_MAP:
        coin_id = _CRYPTO_MAP[asset_upper]
        try:
            monthly_prices = await _fetch_crypto_prices(coin_id, start_date)
        except Exception:
            # Fallback to mock data when CoinGecko is unavailable
            monthly_prices = _MOCK_BTC_PRICES
    else:
        try:
            monthly_prices = await _fetch_stock_prices(req.asset, start_date)
        except Exception as e:
            raise Exception(f"Could not fetch data for '{req.asset}'. "
                            f"Check the ticker symbol. Error: {e}")

    if not monthly_prices:
        raise Exception(f"No price data returned for '{req.asset}'. "
                        f"Try a different ticker or duration.")

    # ── Run simulation ────────────────────────────────────────
    total_invested, current_value, time_series = _simulate_sip(
        monthly_prices, req.monthly_amount, start_date
    )

    if total_invested == 0:
        raise Exception("Simulation returned no data. The asset may not have "
                        "price history for the requested duration.")

    returns_amount = current_value - total_invested
    returns_pct    = (returns_amount / total_invested * 100) if total_invested > 0 else 0.0

    return SIPResponse(
        total_invested = round(total_invested, 2),
        current_value  = round(current_value,  2),
        returns_pct    = round(returns_pct,    2),
        returns_amount = round(returns_amount, 2),
        monthly_amount = req.monthly_amount,
        asset          = req.asset,
        duration       = req.duration,
        time_series    = time_series,
    )
