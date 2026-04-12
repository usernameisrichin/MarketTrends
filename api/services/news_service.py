# ============================================================
# services/news_service.py — Financial News + Sentiment Feed
# ============================================================
#
# Pipeline:
#   1. Fetch RSS feeds from financial news sources
#   2. Parse headlines using feedparser
#   3. Run each headline through VADER sentiment analyzer
#   4. Classify as: bullish / bearish / neutral
#   5. Return sorted list
#
# VADER (Valence Aware Dictionary and sEntiment Reasoner):
#   - Rule-based, no ML training needed
#   - compound score range: -1.0 (most negative) to +1.0 (most positive)
#   - >= +0.05  → bullish
#   - <= -0.05  → bearish
#   - otherwise → neutral
#
# feedparser is a synchronous library. We run it in a thread
# pool with asyncio.to_thread() to avoid blocking the event loop.
# ============================================================

import asyncio
import feedparser
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer
from datetime import datetime
from models.news import NewsItem, NewsResponse

# ── Sentiment analyzer (single shared instance) ──────────────
_analyzer = SentimentIntensityAnalyzer()

# ── RSS feed sources ──────────────────────────────────────────
_FEEDS = [
    {
        "url":        "https://economictimes.indiatimes.com/markets/rssfeeds/1977021501.cms",
        "source":     "Economic Times",
        "asset_type": "stock",
    },
    {
        "url":        "https://feeds.feedburner.com/ndtvprofit-latest",
        "source":     "NDTV Profit",
        "asset_type": "stock",
    },
    {
        "url":        "https://www.coindesk.com/arc/outboundfeeds/rss/",
        "source":     "CoinDesk",
        "asset_type": "crypto",
    },
]

# ── Fallback mock news (shown when RSS feeds are unreachable) ──
_MOCK_NEWS = [
    NewsItem(headline="RBI holds repo rate steady; markets cheer liquidity stance",
             source="Economic Times", url="#", published="2026-04-12",
             sentiment="bullish", sentiment_score=0.62, asset_type="stock"),
    NewsItem(headline="Nifty50 hits new high on strong FII inflows",
             source="Economic Times", url="#", published="2026-04-12",
             sentiment="bullish", sentiment_score=0.71, asset_type="stock"),
    NewsItem(headline="Infosys Q4 earnings miss estimates; stock falls 3%",
             source="NDTV Profit",   url="#", published="2026-04-11",
             sentiment="bearish",    sentiment_score=-0.45, asset_type="stock"),
    NewsItem(headline="Bitcoin crosses $90,000 as ETF inflows surge",
             source="CoinDesk",      url="#", published="2026-04-12",
             sentiment="bullish",    sentiment_score=0.78, asset_type="crypto"),
    NewsItem(headline="Ethereum upgrade scheduled for next month — devs remain cautious",
             source="CoinDesk",      url="#", published="2026-04-11",
             sentiment="neutral",    sentiment_score=0.02, asset_type="crypto"),
    NewsItem(headline="Crypto market sees $2 billion liquidation in 24 hours",
             source="CoinDesk",      url="#", published="2026-04-10",
             sentiment="bearish",    sentiment_score=-0.68, asset_type="crypto"),
    NewsItem(headline="Reliance Industries plans major green energy investment",
             source="Economic Times", url="#", published="2026-04-10",
             sentiment="bullish",    sentiment_score=0.54, asset_type="stock"),
    NewsItem(headline="SEBI tightens F&O regulations; traders brace for impact",
             source="NDTV Profit",   url="#", published="2026-04-09",
             sentiment="bearish",    sentiment_score=-0.31, asset_type="stock"),
]


def _classify(score: float) -> str:
    if score >= 0.05:
        return "bullish"
    if score <= -0.05:
        return "bearish"
    return "neutral"


def _fetch_feed_sync(feed_config: dict, per_feed_limit: int) -> list[NewsItem]:
    """
    Fetch and parse one RSS feed synchronously.
    Called via asyncio.to_thread() to avoid blocking.
    """
    try:
        feed = feedparser.parse(feed_config["url"])
        items = []
        for entry in feed.entries[:per_feed_limit]:
            headline = entry.get("title", "").strip()
            if not headline:
                continue
            scores  = _analyzer.polarity_scores(headline)
            score   = scores["compound"]
            items.append(NewsItem(
                headline       = headline,
                source         = feed_config["source"],
                url            = entry.get("link", ""),
                published      = entry.get("published", datetime.now().isoformat()),
                sentiment      = _classify(score),
                sentiment_score= round(score, 3),
                asset_type     = feed_config["asset_type"],
            ))
        return items
    except Exception:
        return []  # Silently skip unreachable feeds


async def get_news_feed(limit: int = 20) -> NewsResponse:
    """
    Fetch news from all configured RSS feeds concurrently.
    Falls back to mock data if all feeds fail.
    """
    per_feed = max(3, limit // len(_FEEDS))

    # Run all feed fetches concurrently in thread pool
    tasks = [
        asyncio.to_thread(_fetch_feed_sync, feed, per_feed)
        for feed in _FEEDS
    ]
    results = await asyncio.gather(*tasks, return_exceptions=True)

    all_items: list[NewsItem] = []
    for result in results:
        if isinstance(result, list):
            all_items.extend(result)

    # Use mock data if no real news was fetched
    if not all_items:
        all_items = _MOCK_NEWS

    # Sort: bullish first, then neutral, then bearish (within each: by score desc)
    order = {"bullish": 0, "neutral": 1, "bearish": 2}
    all_items.sort(key=lambda x: (order[x.sentiment], -x.sentiment_score))

    trimmed = all_items[:limit]
    return NewsResponse(items=trimmed, total=len(trimmed))
