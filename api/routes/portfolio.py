# ============================================================
# routes/portfolio.py — Portfolio API Routes
# ============================================================
#
# What is a "route"?
#   A route maps a URL + HTTP method to a function.
#   e.g. GET /portfolio → calls get_portfolio_handler()
#
# Why separate routes from main.py?
#   Keeping routes in their own files makes the code modular.
#   As the app grows, you might add:
#     - routes/watchlist.py
#     - routes/transactions.py
#     - routes/auth.py
#   Each stays in its own file. main.py stays clean.
#
# APIRouter is like a mini FastAPI app — you define routes on it,
# then "include" it in the main app in main.py.
# ============================================================

from fastapi import APIRouter, HTTPException, status
from models.portfolio import PortfolioSummary
from services.portfolio_service import get_portfolio


# Create a router with a URL prefix.
# All routes in this file will start with /portfolio.
router = APIRouter(
    prefix="/portfolio",
    tags=["Portfolio"],   # Groups endpoints in the /docs UI
)


@router.get(
    "",
    response_model=PortfolioSummary,
    status_code=status.HTTP_200_OK,
    summary="Get portfolio summary",
    response_description="Total value, daily change, and list of holdings",
)
def get_portfolio_handler():
    """
    **GET /portfolio**

    Returns the full portfolio summary:
    - `totalValue` — combined value of all holdings in INR
    - `dailyChange` — today's change as a percentage string (e.g. "+2.3%")
    - `assets` — list of stocks and crypto holdings
    """
    try:
        return get_portfolio()
    except Exception as e:
        # If the service layer ever raises, return a clean 500 error
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Could not load portfolio data: {str(e)}",
        )
