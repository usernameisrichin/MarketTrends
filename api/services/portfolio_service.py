# ============================================================
# services/portfolio_service.py — Business Logic Layer
# ============================================================
#
# What is a "service"?
#   A service contains the LOGIC of your application.
#   It sits between the route (which handles HTTP) and the
#   data (models / database).
#
#   This separation means:
#     - Routes stay thin — they just call services
#     - Logic is in one place — easy to test and change
#     - Later, you can swap mock data for a real stock API
#       without touching any route code
#
# Right now this returns mock (hardcoded) data.
# In the future, you'd call a real API like:
#   - NSE/BSE API for Indian stocks
#   - CoinGecko or Binance API for Bitcoin
# ============================================================

from models.portfolio import Asset, PortfolioSummary


# Mock data — hardcoded portfolio holdings
# In a real app, this would be fetched from a database or external API
_MOCK_ASSETS = [
    Asset(
        type="stock",
        name="Reliance Industries",
        symbol="RELIANCE",
        value=500000,
        change="+1.2%",
    ),
    Asset(
        type="stock",
        name="Tata Consultancy Services",
        symbol="TCS",
        value=300000,
        change="-0.5%",
    ),
    Asset(
        type="stock",
        name="Infosys",
        symbol="INFY",
        value=200000,
        change="+0.8%",
    ),
    Asset(
        type="stock",
        name="HDFC Bank",
        symbol="HDFCBANK",
        value=150000,
        change="+0.3%",
    ),
    Asset(
        type="crypto",
        name="Bitcoin",
        symbol="BTC",
        value=450000,
        change="+3.8%",
    ),
]


def get_portfolio() -> PortfolioSummary:
    """
    Returns the full portfolio summary.

    Calculates totalValue by summing all asset values.
    Returns a hardcoded dailyChange for now.

    Returns:
        PortfolioSummary: The complete portfolio object.
    """
    total = sum(asset.value for asset in _MOCK_ASSETS)

    return PortfolioSummary(
        totalValue=total,
        dailyChange="+2.3%",
        assets=_MOCK_ASSETS,
    )
