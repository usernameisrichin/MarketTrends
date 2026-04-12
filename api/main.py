# ============================================================
# main.py — FastAPI Application Entry Point (v3)
# ============================================================
#
# This file is the "front door" of the backend.
# Its ONLY responsibilities:
#   1. Create the FastAPI app instance
#   2. Add middleware (CORS)
#   3. Register all routers
#
# Actual logic lives in: services/
# Data shapes live in:   models/
# URL handlers live in:  routes/
#
# Run with:
#   cd api
#   uvicorn main:app --reload
# ============================================================

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# ── Import all route modules ──────────────────────────────────
from routes.portfolio import router as portfolio_router
from routes.family    import router as family_router
from routes.tax       import router as tax_router
from routes.sip       import router as sip_router
from routes.news      import router as news_router
from routes.realtime  import router as realtime_router


# ── App instance ──────────────────────────────────────────────
app = FastAPI(
    title       = "Market Portfolio API",
    description = "Indian investment aggregator — stocks, crypto, tax, SIP, news",
    version     = "3.0.0",
    docs_url    = "/docs",       # Swagger UI at http://localhost:8000/docs
    redoc_url   = "/redoc",      # ReDoc UI  at http://localhost:8000/redoc
)


# ── CORS ──────────────────────────────────────────────────────
# Required so the Flutter web build (different port) can call this API.
# In production, replace ["*"] with your actual domain(s).
app.add_middleware(
    CORSMiddleware,
    allow_origins  = ["*"],
    allow_methods  = ["*"],
    allow_headers  = ["*"],
)


# ── Register routers ──────────────────────────────────────────
# Each router handles a slice of the API surface area.
# Prefixes are defined inside each router file.

app.include_router(portfolio_router)   # GET  /portfolio
app.include_router(family_router)      # GET  /portfolio/family-summary
                                       # GET  /portfolio/member/{id}
app.include_router(tax_router)         # POST /tax/calculate
app.include_router(sip_router)         # POST /sip/backtest
app.include_router(news_router)        # GET  /news
app.include_router(realtime_router)    # WS   /realtime/crypto
                                       # GET  /realtime/price/{symbol}


# ── Root health check ─────────────────────────────────────────
@app.get("/", tags=["Health"])
def root():
    """
    Health check. Visit /docs for interactive API documentation.
    """
    return {
        "status":    "running",
        "version":   "3.0.0",
        "endpoints": {
            "portfolio":      "GET  /portfolio",
            "family":         "GET  /portfolio/family-summary",
            "tax":            "POST /tax/calculate",
            "sip":            "POST /sip/backtest",
            "news":           "GET  /news",
            "realtime_ws":    "WS   /realtime/crypto",
            "realtime_stock": "GET  /realtime/price/{symbol}",
            "docs":           "GET  /docs",
        },
    }
