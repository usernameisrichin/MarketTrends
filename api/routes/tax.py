# routes/tax.py — Tax Estimation Endpoint

from fastapi import APIRouter, HTTPException, status
from models.tax import TaxCalculationRequest, TaxCalculationResponse
from services.tax_service import calculate_tax

router = APIRouter(prefix="/tax", tags=["Tax Estimator"])


@router.post(
    "/calculate",
    response_model=TaxCalculationResponse,
    status_code=status.HTTP_200_OK,
    summary="Calculate Indian capital gains tax",
)
def tax_calculate(request: TaxCalculationRequest):
    """
    **POST /tax/calculate**

    Calculates capital gains tax for Indian investors:
    - Equity STCG  (< 12 months)  → 20%
    - Equity LTCG  (≥ 12 months)  → 12.5% with ₹1.25L exemption
    - Crypto       (any duration)  → 30% flat + 1% TDS

    Send a JSON body matching `TaxCalculationRequest`.
    """
    try:
        return calculate_tax(request)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))
