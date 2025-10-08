from .chat.chat_api import router as chat_router
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .middleware.rate_limiter import RateLimitMiddleware  # ← ADDED: Rate limiter import
from sqlalchemy.orm import Session
from .config import settings
from .db import init_db, SessionLocal
from . import models
from .routes import users, products, checkout, stripe_webhooks, orders, analytics

app = FastAPI(title="AI Commerce Backend")

# ✅ ADD RATE LIMITING MIDDLEWARE FIRST
app.add_middleware(RateLimitMiddleware)

# CORS middleware (after rate limiting)
app.add_middleware(
    CORSMiddleware,
    allow_origins=[settings.FRONTEND_URL, "http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(chat_router, prefix="/api", tags=["chat"])
app.include_router(users.router, prefix="/api/auth", tags=["auth"])
app.include_router(products.router, prefix="/api", tags=["products"])
app.include_router(checkout.router, prefix="/api", tags=["checkout"])
app.include_router(stripe_webhooks.router, prefix="/api", tags=["stripe"])
app.include_router(orders.router, prefix="/api", tags=["orders"])
# app.include_router(ai.router, prefix="/api", tags=["ai"])  # removed
app.include_router(analytics.router, prefix="/api", tags=["analytics"])

@app.on_event("startup")
def on_startup():
    init_db()
    seed_products()

def seed_products():
    db: Session = SessionLocal()
    try:
        if db.query(models.Product).count() == 0:
            demo_products = [
                dict(sku="lp_pro", name="LP‑Builder Pro", slug="lp-builder-pro",
                     description="AI landing page generator with 20+ templates.",
                     price_cents=14900, currency="usd", stripe_price_id=None,
                     active=True, is_subscription=False, interval=None,
                     features_json=["AI copy", "Templates", "Export HTML"]),
                dict(sku="lp_sub", name="LP‑Builder Pro Updates (Monthly)", slug="lp-builder-pro-updates",
                     description="Monthly templates and updates.", price_cents=1900, currency="usd",
                     stripe_price_id=None, active=True, is_subscription=True, interval="month",
                     features_json=["New templates monthly", "Priority support"])
            ]
            for p in demo_products:
                db.add(models.Product(**p))
            db.commit()
    finally:
        db.close()

@app.get("/health")
def health():
    return {"ok": True}