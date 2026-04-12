# routes/news.py — News Feed Endpoint

from fastapi import APIRouter, Query
from models.news import NewsResponse
from services.news_service import get_news_feed

router = APIRouter(prefix="/news", tags=["News & Sentiment"])


@router.get(
    "",
    response_model=NewsResponse,
    summary="Get financial news with sentiment analysis",
)
async def news_feed(
    limit: int = Query(default=20, ge=1, le=50, description="Max number of news items to return"),
):
    """
    **GET /news**

    Fetches financial news from Economic Times and CoinDesk RSS feeds.
    Each headline is analyzed by VADER sentiment engine:
    - `bullish`  → positive sentiment (score ≥ +0.05)
    - `bearish`  → negative sentiment (score ≤ -0.05)
    - `neutral`  → no strong signal
    """
    return await get_news_feed(limit=limit)
