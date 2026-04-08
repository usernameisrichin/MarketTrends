# ============================================================
# services/tax_service.py — Indian Capital Gains Tax Calculator
# ============================================================
#
# Tax rules applied (FY 2024-25, post Union Budget July 2024):
#
#  Asset    Duration        Rate        Notes
#  ─────    ────────        ────        ─────
#  Equity   < 12 months    20%         STCG — Short Term Capital Gains
#  Equity   ≥ 12 months    12.5%       LTCG — first ₹1.25L exempt per year
#  Crypto   any            30%         + 1% TDS deducted at source on sell value
#
# No loss offset is allowed for crypto under Indian law.
# LTCG losses from equity CAN offset other LTCG equity gains.
# ============================================================

from models.tax import TaxCalculationRequest, TaxCalculationResponse

# ── Tax rate constants ────────────────────────────────────────
EQUITY_STCG_RATE      = 0.20       # 20%
EQUITY_LTCG_RATE      = 0.125      # 12.5%
EQUITY_LTCG_EXEMPTION = 125_000.0  # ₹1,25,000 annual exemption
CRYPTO_TAX_RATE       = 0.30       # 30%
CRYPTO_TDS_RATE       = 0.01       # 1% TDS on gross sell value
STCG_THRESHOLD_DAYS   = 365        # Must hold ≥ 365 days for LTCG


def calculate_tax(req: TaxCalculationRequest) -> TaxCalculationResponse:
    """
    Core tax calculation function.

    Steps:
      1. Calculate holding duration (days)
      2. Calculate gross gain = (sell_price - buy_price) × quantity
      3. Apply the correct tax rule based on asset_type and duration
      4. Return structured breakdown

    Args:
        req: Validated TaxCalculationRequest from the route handler.

    Returns:
        TaxCalculationResponse with full breakdown.
    """

    holding_days    = (req.sell_date - req.buy_date).days
    total_buy_cost  = req.buy_price  * req.quantity
    total_sell_val  = req.sell_price * req.quantity
    gross_gain      = total_sell_val - total_buy_cost  # Can be negative (loss)

    # ── Crypto Tax ───────────────────────────────────────────
    # Flat 30% on ANY gain. Losses cannot offset other income.
    # TDS is charged on the SELL value regardless of profit/loss.
    if req.asset_type == "crypto":
        # Tax is only on positive gains (30% flat, no exemption)
        taxable_gain = max(0.0, gross_gain)
        tax_amount   = taxable_gain * CRYPTO_TAX_RATE
        tds_amount   = total_sell_val * CRYPTO_TDS_RATE   # Always deducted

        return TaxCalculationResponse(
            gain               = round(gross_gain, 2),
            tax_amount         = round(tax_amount, 2),
            tax_type           = "CRYPTO",
            tax_rate           = CRYPTO_TAX_RATE * 100,   # Return as %, e.g. 30.0
            net_profit         = round(gross_gain - tax_amount, 2),
            holding_days       = holding_days,
            tds_amount         = round(tds_amount, 2),
            exemption_applied  = None,
        )

    # ── Equity Tax ───────────────────────────────────────────
    taxable_gain       = max(0.0, gross_gain)
    exemption_applied  = None

    if holding_days < STCG_THRESHOLD_DAYS:
        # STCG: Short Term — held less than 1 year
        tax_amount = taxable_gain * EQUITY_STCG_RATE
        tax_type   = "STCG"
        tax_rate   = EQUITY_STCG_RATE * 100   # 20.0

    else:
        # LTCG: Long Term — held 1 year or more
        # First ₹1,25,000 of long-term gains is exempt per financial year
        exemption_applied = min(taxable_gain, EQUITY_LTCG_EXEMPTION)
        taxable_after_exemption = max(0.0, taxable_gain - EQUITY_LTCG_EXEMPTION)
        tax_amount = taxable_after_exemption * EQUITY_LTCG_RATE
        tax_type   = "LTCG"
        tax_rate   = EQUITY_LTCG_RATE * 100   # 12.5

    return TaxCalculationResponse(
        gain               = round(gross_gain, 2),
        tax_amount         = round(tax_amount, 2),
        tax_type           = tax_type,
        tax_rate           = tax_rate,
        net_profit         = round(gross_gain - tax_amount, 2),
        holding_days       = holding_days,
        tds_amount         = None,
        exemption_applied  = round(exemption_applied, 2) if exemption_applied else None,
    )
