# ============================================================
# services/market_data_service.py — Hybrid Real-Time Data
# ============================================================
#
# Architecture:
#
#   CRYPTO   → Stream from CoinGecko every 5s via WebSocket
#   STOCKS   → Poll Yahoo Finance every 5 min during market hours
#              Cache results after market close (in-memory here,
#              use Redis in production for persistence + TTL)
#
# Indian market hours: 09:15 – 15:30 IST (Mon–Fri)
#
# In production:
#   - Replace in-memory _cache with Redis:
#       import redis.asyncio as redis
#       cache = redis.from_url("redis://localhost")
#       await cache.setex(key, ttl, json.dumps(data))
# ============================================================

import asyncio
import httpx
from datetime import datetime, time as dtime
from typing import Optional
import pytz

# ── Timezone + market hours ───────────────────────────────────
IST          = pytz.timezone("Asia/Kolkata")
MARKET_OPEN  = dtime(9, 15)
MARKET_CLOSE = dtime(15, 30)

# ── In-memory cache ───────────────────────────────────────────
# dict: cache_key → {"data": ..., "cached_at": datetime}
_cache: dict = {}
CACHE_TTL_SECONDS = 300  # 5 minutes (during market hours)


def _is_market_open() -> bool:
    """Returns True if the current IST time is within NSE trading hours."""
    now_ist = datetime.now(IST).time()
    return MARKET_OPEN <= now_ist <= MARKET_CLOSE


def _get_from_cache(key: str) -> Optional[dict]:
    """Return cached value if it exists and hasn't expired."""
    entry = _cache.get(key)
    if not entry:
        return None
    age = (datetime.now() - entry["cached_at"]).seconds
    if age < CACHE_TTL_SECONDS:
        return entry["data"]
    return None


def _set_cache(key: str, data: dict) -> None:
    _cache[key] = {"data": data, "cached_at": datetime.now()}


# ── Crypto price fetch ────────────────────────────────────────

async def get_crypto_price(coin_id: str = "bitcoin", currency: str = "inr") -> dict:
    """
    Fetch live crypto price from CoinGecko.
    Cached for 5 minutes to respect rate limits.

    Args:
        coin_id:  CoinGecko coin ID (e.g. "bitcoin", "ethereum")
        currency: Target currency (default "inr")

    Returns:
        dict with price, 24h change, market cap, and timestamp
    """
    cache_key = f"crypto_{coin_id}_{currency}"
    cached = _get_from_cache(cache_key)
    if cached:
        return cached

    url = "https://api.coingecko.com/api/v3/simple/price"
    params = {
        "ids":                coin_id,
        "vs_currencies":      currency,
        "include_24hr_change": "true",
        "include_market_cap":  "true",
    }

    async with httpx.AsyncClient(timeout=10.0) as client:
        resp = await client.get(url, params=params)
        resp.raise_for_status()
        raw = resp.json()

    result = {
        "coin":        coin_id,
        "price":       raw[coin_id][currency],
        "change_24h":  raw[coin_id].get(f"{currency}_24h_change", 0.0),
        "market_cap":  raw[coin_id].get(f"{currency}_market_cap", 0),
        "currency":    currency.upper(),
        "timestamp":   datetime.now().isoformat(),
        "is_live":     True,
    }

    _set_cache(cache_key, result)
    return result


# ── WebSocket stream generator ────────────────────────────────

async def stream_prices():
    """
    Async generator for the WebSocket endpoint.
    Yields one price update per coin every 5 seconds.

    Usage in route:
        async for tick in stream_prices():
            await websocket.send_json(tick)
    """
    coins = ["bitcoin", "ethereum"]
    while True:
        for coin in coins:
            try:
                data = await get_crypto_price(coin)
                yield data
            except Exception as e:
                yield {"error": str(e), "coin": coin}
        await asyncio.sleep(5)


# ── Stock price (poll-based) ──────────────────────────────────

async def get_stock_price(symbol: str) -> dict:
    """
    Fetch latest stock price.
    During market hours → live fetch.
    After market close → return cached value if available.

    Uses Yahoo Finance API directly (no library dependency here,
    just a simple HTTP call to the query endpoint).
    """
    cache_key = f"stock_{symbol}"

    if not _is_market_open():
        # Market is closed — serve cached data
        cached = _get_from_cache(cache_key)
        if cached:
            return {**cached, "is_live": False, "note": "Market closed. Showing cached price."}

    # Live fetch from Yahoo Finance chart API
    url = f"https://query1.finance.yahoo.com/v8/finance/chart/{symbol}.NS"
    params = {"interval": "1m", "range": "1d"}

    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            resp = await client.get(url, params=params, headers={"User-Agent": "Mozilla/5.0"})
            resp.raise_for_status()
            data = resp.json()

        meta = data["chart"]["result"][0]["meta"]
        result = {
            "symbol":         symbol,
            "price":          meta.get("regularMarketPrice", 0),
            "prev_close":     meta.get("previousClose", 0),
            "change_pct":     round(
                (meta.get("regularMarketPrice", 0) - meta.get("previousClose", 1))
                / meta.get("previousClose", 1) * 100, 2
            ),
            "currency":       meta.get("currency", "INR"),
            "market_state":   meta.get("marketState", "UNKNOWN"),
            "timestamp":      datetime.now().isoformat(),
            "is_live":        True,
        }
        _set_cache(cache_key, result)
        return result

    except Exception as e:
        # Return error with last known price if available
        cached = _get_from_cache(cache_key)
        if cached:
            return {**cached, "is_live": False, "error": str(e)}
        raise
