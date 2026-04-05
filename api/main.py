# ============================================================
# main.py — FastAPI Application Entry Point
# ============================================================
#
# This file is now intentionally SHORT.
# Its only job is to:
#   1. Create the FastAPI app
#   2. Add middleware (CORS)
#   3. Register routes from the routes/ folder
#
# All business logic lives in services/
# All data shapes live in models/
# All URL handlers live in routes/
#
# This is the "separation of concerns" principle —
# each file has one clear responsibility.
#
# Run with:
#   uvicorn main:app --reload
# ============================================================

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Import the portfolio router we defined in routes/portfolio.py
from routes.portfolio import router as portfolio_router


# ── Create the app ───────────────────────────────────────────
app = FastAPI(
    title="Market Portfolio API",
    description="Tracks Indian stock and Bitcoin holdings",
    version="2.0.0",
)


# ── CORS Middleware ──────────────────────────────────────────
# Allows the Flutter web app (running on a different port)
# to make requests to this API without being blocked by the browser.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # Allow all origins (fine for development)
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Register Routes ──────────────────────────────────────────
# Include the portfolio router. All its routes are now live.
# The prefix "/portfolio" is defined inside the router itself.
app.include_router(portfolio_router)


# ── Health Check ─────────────────────────────────────────────
@app.get("/")
def root():
    """
    Health check endpoint.
    Visit http://localhost:8000/ to confirm the server is running.
    Visit http://localhost:8000/docs for interactive API documentation.
    """
    return {
        "status": "running",
        "message": "Market Portfolio API v2",
        "docs": "/docs",
        "portfolio": "/portfolio",
    }
