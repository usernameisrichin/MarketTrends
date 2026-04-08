# ============================================================
# models/news.py — News Feed + Sentiment Models
# ============================================================
#
# Sentiment analysis using VADER:
#   compound score >= +0.05  → bullish
#   compound score <= -0.05  → bearish
#   otherwise               → neutral
#
# VADER is rule-based and works well for short headlines
# without needing ML training data.
# ============================================================

from pydantic import BaseModel
from typing import List


class NewsItem(BaseModel):
    """A single news headline with sentiment."""
    headline: str
    source: str              # "Economic Times", "CoinDesk", etc.
    url: str
    published: str           # Publication timestamp as string
    sentiment: str           # "bullish", "bearish", or "neutral"
    sentiment_score: float   # VADER compound score: -1.0 to +1.0
    asset_type: str          # "stock", "crypto", or "general"


class NewsResponse(BaseModel):
    """Paginated news feed."""
    items: List[NewsItem]
    total: int
