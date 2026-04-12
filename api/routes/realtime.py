# ============================================================
# routes/realtime.py — WebSocket Real-Time Price Streaming
# ============================================================
#
# WebSocket is a persistent, two-way connection between the
# client and server. Unlike HTTP (request → response → close),
# WebSocket stays open and the server can PUSH data anytime.
#
# How to test this endpoint manually:
#   Install wscat: npm install -g wscat
#   Connect: wscat -c ws://localhost:8000/realtime/crypto
#   You'll see JSON price ticks every 5 seconds.
#
# In the Flutter app, the `web_socket_channel` package handles
# WebSocket connections.
# ============================================================

import json
import asyncio
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from services.market_data_service import get_crypto_price, get_stock_price

router = APIRouter(prefix="/realtime", tags=["Real-Time Data"])

# Track active WebSocket connections (for broadcasting in future)
_active_connections: list[WebSocket] = []


@router.websocket("/crypto")
async def crypto_stream(websocket: WebSocket):
    """
    WebSocket /realtime/crypto

    Streams live Bitcoin and Ethereum prices every 5 seconds.
    Each message is a JSON object:
    {
        "coin": "bitcoin",
        "price": 6850000,
        "change_24h": 2.3,
        "currency": "INR",
        "timestamp": "2026-04-12T14:30:00"
    }
    """
    await websocket.accept()
    _active_connections.append(websocket)

    try:
        while True:
            for coin in ["bitcoin", "ethereum"]:
                try:
                    data = await get_crypto_price(coin)
                    await websocket.send_text(json.dumps(data))
                except Exception as e:
                    await websocket.send_text(
                        json.dumps({"error": str(e), "coin": coin})
                    )

            # Wait 5 seconds before next batch
            await asyncio.sleep(5)

    except WebSocketDisconnect:
        _active_connections.remove(websocket)


@router.get(
    "/price/{symbol}",
    summary="Get latest stock price (REST fallback)",
)
async def stock_price(symbol: str):
    """
    **GET /realtime/price/{symbol}**

    REST endpoint for stock prices (fallback when WebSocket isn't needed).
    Respects market hours — returns cached price after 15:30 IST.

    Example: GET /realtime/price/RELIANCE
    """
    return await get_stock_price(symbol)
