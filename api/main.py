# ============================================================
# main.py — FastAPI Backend for Market Portfolio Dashboard
# ============================================================
#
# What is FastAPI?
#   FastAPI is a Python framework that makes it easy to build APIs.
#   An API (Application Programming Interface) is basically a way
#   for your Flutter app to ask the server: "Hey, give me the data!"
#   and the server responds with JSON (a structured text format).
#
# How to run this file:
#   uvicorn main:app --reload
#
#   "uvicorn" is the server that runs FastAPI apps.
#   "main:app" means: in the file `main.py`, use the variable `app`.
#   "--reload" means: auto-restart the server when you save changes.
# ============================================================

# "fastapi" gives us the tools to build the API
from fastapi import FastAPI

# "BaseModel" lets us define the shape of our data (like a blueprint)
from pydantic import BaseModel

# "List" is a Python type hint — it means "a list of items"
from typing import List

# "CORSMiddleware" allows our Flutter web app to talk to this server.
# By default, browsers block requests between different origins (domains/ports).
# CORS = Cross-Origin Resource Sharing
from fastapi.middleware.cors import CORSMiddleware


# ============================================================
# Create the FastAPI app
# Think of "app" as the main engine of your backend server.
# ============================================================
app = FastAPI(
    title="Market Portfolio API",
    description="Returns portfolio data for Indian stocks and Bitcoin",
    version="1.0.0",
)


# ============================================================
# Allow Flutter web (and any origin) to call this API.
# Without this, a browser would block the request.
# ============================================================
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],      # Allow ALL origins (fine for development)
    allow_methods=["*"],      # Allow GET, POST, etc.
    allow_headers=["*"],      # Allow any headers
)


# ============================================================
# Data Models (Blueprints for our JSON responses)
#
# BaseModel means: this class is a data blueprint.
# Each field has a name and a type (str = text, float = decimal number).
# ============================================================

class Asset(BaseModel):
    """Represents a single holding — either a stock or Bitcoin."""
    name: str           # e.g. "Reliance Industries" or "Bitcoin"
    symbol: str         # e.g. "RELIANCE" or "BTC"
    asset_type: str     # "stock" or "crypto"
    quantity: float     # How many shares / coins you own
    buy_price: float    # Price when you bought (in INR)
    current_price: float  # Current market price (in INR)
    current_value: float  # quantity × current_price
    profit_loss: float    # current_value − (quantity × buy_price)
    profit_loss_pct: float  # profit/loss as a percentage


class Portfolio(BaseModel):
    """The full portfolio summary returned by our API."""
    total_value: float          # Total portfolio value in INR
    total_invested: float       # Total amount you put in
    total_profit_loss: float    # Overall profit or loss
    total_profit_loss_pct: float  # Profit/loss as a percentage
    daily_change: float         # How much the value changed today (INR)
    daily_change_pct: float     # Today's change as a percentage
    assets: List[Asset]         # List of all your holdings


# ============================================================
# Mock Data
#
# "Mock" means fake/hardcoded data we use for testing.
# Later you can replace this with real data from a stock API.
# ============================================================

MOCK_ASSETS = [
    {
        "name": "Reliance Industries",
        "symbol": "RELIANCE",
        "asset_type": "stock",
        "quantity": 10,
        "buy_price": 2400.00,
        "current_price": 2875.50,
        "current_value": 28755.00,
        "profit_loss": 4755.00,
        "profit_loss_pct": 19.81,
    },
    {
        "name": "Infosys",
        "symbol": "INFY",
        "asset_type": "stock",
        "quantity": 15,
        "buy_price": 1450.00,
        "current_price": 1623.75,
        "current_value": 24356.25,
        "profit_loss": 2606.25,
        "profit_loss_pct": 11.98,
    },
    {
        "name": "HDFC Bank",
        "symbol": "HDFCBANK",
        "asset_type": "stock",
        "quantity": 8,
        "buy_price": 1600.00,
        "current_price": 1742.30,
        "current_value": 13938.40,
        "profit_loss": 1138.40,
        "profit_loss_pct": 8.89,
    },
    {
        "name": "Tata Consultancy Services",
        "symbol": "TCS",
        "asset_type": "stock",
        "quantity": 5,
        "buy_price": 3200.00,
        "current_price": 3589.00,
        "current_value": 17945.00,
        "profit_loss": 1945.00,
        "profit_loss_pct": 12.16,
    },
    {
        "name": "Bitcoin",
        "symbol": "BTC",
        "asset_type": "crypto",
        "quantity": 0.05,
        "buy_price": 4200000.00,   # INR equivalent when bought
        "current_price": 6850000.00,  # Current INR equivalent
        "current_value": 342500.00,
        "profit_loss": 132500.00,
        "profit_loss_pct": 63.10,
    },
]


# ============================================================
# API Endpoint: GET /portfolio
#
# An "endpoint" is a URL that your app calls to get data.
# "@app.get" is a decorator — it tells FastAPI:
#   "When someone visits GET /portfolio, run this function."
#
# "response_model=Portfolio" means FastAPI will validate and
# format the response according to our Portfolio blueprint.
# ============================================================

@app.get("/portfolio", response_model=Portfolio)
def get_portfolio():
    """
    Returns the full mock portfolio including:
    - Summary (total value, profit/loss, daily change)
    - List of all assets (stocks + Bitcoin)
    """

    # Calculate summary numbers from mock data
    total_value = sum(a["current_value"] for a in MOCK_ASSETS)
    total_invested = sum(a["quantity"] * a["buy_price"] for a in MOCK_ASSETS)
    total_profit_loss = total_value - total_invested
    total_profit_loss_pct = (total_profit_loss / total_invested) * 100

    # Hardcoded daily change for mock purposes
    daily_change = 3420.75
    daily_change_pct = 0.81

    # Build and return the Portfolio object
    # FastAPI automatically converts this to JSON
    return Portfolio(
        total_value=round(total_value, 2),
        total_invested=round(total_invested, 2),
        total_profit_loss=round(total_profit_loss, 2),
        total_profit_loss_pct=round(total_profit_loss_pct, 2),
        daily_change=daily_change,
        daily_change_pct=daily_change_pct,
        assets=[Asset(**a) for a in MOCK_ASSETS],  # Convert each dict to an Asset object
    )


# ============================================================
# Root endpoint — just a health check
# Visit http://localhost:8000/ to confirm the server is running
# ============================================================

@app.get("/")
def root():
    return {"message": "Market Portfolio API is running!", "docs": "/docs"}
