# routes/sip.py — SIP Backtesting Endpoint

from fastapi import APIRouter, HTTPException, status
from models.sip import SIPRequest, SIPResponse
from services.sip_service import run_sip_backtest

router = APIRouter(prefix="/sip", tags=["SIP Backtester"])


@router.post(
    "/backtest",
    response_model=SIPResponse,
    status_code=status.HTTP_200_OK,
    summary="Run a SIP simulation on historical price data",
)
async def sip_backtest(request: SIPRequest):
    """
    **POST /sip/backtest**

    Simulates a monthly SIP investment on a stock or crypto asset
    using real historical price data.

    - Stocks: fetched from Yahoo Finance (e.g. `RELIANCE.NS`)
    - Crypto: fetched from CoinGecko (e.g. `BTC`, `ETH`)
    - Returns time-series data for charting + summary cards
    """
    try:
        return await run_sip_backtest(request)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
