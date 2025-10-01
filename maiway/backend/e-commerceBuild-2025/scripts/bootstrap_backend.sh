#!/usr/bin/env bash
set -euo pipefail

if [ ! -d .git ]; then
  echo "Run this in your repo root (a git repo)."
  exit 1
fi

echo "Creating backend structure..."
mkdir -p backend/app/{routes,services,ai/docs} backend/tests .github/workflows scripts
touch backend/app/__init__.py backend/app/routes/{__init__.py} backend/app/services/{__init__.py} backend/app/ai/{__init__.py}

cat > .gitignore <<'EOF'
.venv/
.env
__pycache__/
*.pyc
dev.db
test.db
.DS_Store
.idea/
.vscode/
EOF

cat > backend/requirements.txt <<'EOF'
fastapi>=0.111.0
uvicorn[standard]>=0.30.1
sqlalchemy>=2.0.29
pydantic>=2.8.2
pydantic-settings>=2.3.4
python-jose[cryptography]>=3.3.0
passlib[bcrypt]>=1.7.4
stripe>=10.13.0
httpx>=0.27.0
sendgrid>=6.11.0
langchain>=0.2.12
langchain-openai>=0.1.22
langchain-community>=0.2.11
langchain-text-splitters>=0.0.2
faiss-cpu>=1.8.0
tiktoken>=0.7.0
python-multipart>=0.0.9
pytest>=8.3.2
EOF

cat > backend/.env.example <<'EOF'
DATABASE_URL=sqlite:///./dev.db
JWT_SECRET=replace_me_with_long_random
FRONTEND_URL=http://localhost:5173

STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
STRIPE_PRICE_IDS={"lp_pro":"price_xxx","lp_sub":"price_yyy"}

OPENAI_API_KEY=
SENDGRID_API_KEY=
FROM_EMAIL=no-reply@yourco.com
EOF

cat > backend/app/config.py <<'EOF'
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    DATABASE_URL: str = "sqlite:///./dev.db"
    JWT_SECRET: str = "change_me"
    FRONTEND_URL: str = "http://localhost:5173"

    STRIPE_SECRET_KEY: str = ""
    STRIPE_WEBHOOK_SECRET: str = ""
    STRIPE_PRICE_IDS: str | None = None

    OPENAI_API_KEY: str | None = None
    SENDGRID_API_KEY: str | None = None
    FROM_EMAIL: str = "no-reply@example.com"

    model_config = SettingsConfigDict(env_file=".env", case_sensitive=False)

settings = Settings()
EOF

cat > backend/app/db.py <<'EOF'
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from .config import settings

DATABASE_URL = settings.DATABASE_URL
connect_args = {"check_same_thread": False} if DATABASE_URL.startswith("sqlite") else {}
engine = create_engine(DATABASE_URL, echo=False, future=True, connect_args=connect_args)
SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False, future=True)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def init_db():
    Base.metadata.create_all(bind=engine)
EOF

cat > backend/app/models.py <<'EOF'
from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ForeignKey, JSON, func, UniqueConstraint
from sqlalchemy.orm import relationship
from .db import Base

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    role = Column(String(20), default="customer")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    orders = relationship("Order", back_populates="user")

class Product(Base):
    __tablename__ = "products"
    id = Column(Integer, primary_key=True)
    sku = Column(String(64), unique=True, index=True, nullable=False)
    name = Column(String(255), nullable=False)
    slug = Column(String(255), unique=True, index=True, nullable=False)
    description = Column(Text, default="")
    price_cents = Column(Integer, nullable=False)
    currency = Column(String(10), default="usd")
    stripe_price_id = Column(String(128), nullable=True)
    active = Column(Boolean, default=True)
    is_subscription = Column(Boolean, default=False)
    interval = Column(String(20), nullable=True)
    features_json = Column(JSON, default=[])
    media_urls_json = Column(JSON, default=[])

class Order(Base):
    __tablename__ = "orders"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)
    stripe_session_id = Column(String(128), unique=True, index=True)
    stripe_payment_intent = Column(String(128), index=True)
    total_cents = Column(Integer, default=0)
    tax_cents = Column(Integer, default=0)
    currency = Column(String(10), default="usd")
    status = Column(String(20), default="paid")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    user = relationship("User", back_populates="orders")
    items = relationship("OrderItem", back_populates="order")
    licenses = relationship("License", back_populates="order")

class OrderItem(Base):
    __tablename__ = "order_items"
    id = Column(Integer, primary_key=True)
    order_id = Column(Integer, ForeignKey("orders.id"), index=True, nullable=False)
    product_id = Column(Integer, ForeignKey("products.id"), index=True, nullable=False)
    unit_price_cents = Column(Integer, nullable=False)
    qty = Column(Integer, default=1)
    order = relationship("Order", back_populates="items")
    product = relationship("Product")

class License(Base):
    __tablename__ = "licenses"
    id = Column(Integer, primary_key=True)
    order_id = Column(Integer, ForeignKey("orders.id"), index=True, nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)
    product_id = Column(Integer, ForeignKey("products.id"), index=True, nullable=False)
    key = Column(String(64), unique=True, index=True, nullable=False)
    status = Column(String(20), default="active")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    order = relationship("Order", back_populates="licenses")
    user = relationship("User")
    product = relationship("Product")

class Thread(Base):
    __tablename__ = "threads"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    __table_args__ = (UniqueConstraint("user_id", name="uix_user_thread"),)

class Message(Base):
    __tablename__ = "messages"
    id = Column(Integer, primary_key=True)
    thread_id = Column(Integer, ForeignKey("threads.id"), index=True, nullable=False)
    sender_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    body = Column(Text, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class AnalyticsEvent(Base):
    __tablename__ = "analytics_events"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    session_id = Column(String(64), nullable=True)
    event_name = Column(String(64), nullable=False)
    meta_json = Column(JSON, default={})
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class Subscription(Base):
    __tablename__ = "subscriptions"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)
    product_id = Column(Integer, ForeignKey("products.id"), index=True, nullable=False)
    stripe_subscription_id = Column(String(128), unique=True)
    status = Column(String(32), default="active")
    current_period_end = Column(DateTime(timezone=True), nullable=True)
EOF

cat > backend/app/schemas.py <<'EOF'
from pydantic import BaseModel, EmailStr
from typing import List, Optional

class UserCreate(BaseModel):
    email: EmailStr
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserOut(BaseModel):
    id: int
    email: EmailStr
    role: str
    class Config:
        from_attributes = True

class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"

class ProductOut(BaseModel):
    id: int
    sku: str
    name: str
    slug: str
    description: str
    price_cents: int
    currency: str
    is_subscription: bool
    features_json: list | None = None
    media_urls_json: list | None = None
    class Config:
        from_attributes = True

class LineItem(BaseModel):
    price_id: str
    qty: int = 1

class CheckoutSessionCreate(BaseModel):
    items: List[LineItem]

class OrderItemOut(BaseModel):
    product_id: int
    qty: int
    unit_price_cents: int
    class Config:
        from_attributes = True

class OrderOut(BaseModel):
    id: int
    status: str
    currency: str
    total_cents: int
    tax_cents: int
    items: List[OrderItemOut]
    class Config:
        from_attributes = True

class ChatMessageIn(BaseModel):
    thread_id: Optional[int] = None
    body: str

class AIMessage(BaseModel):
    message: str
    user_email: Optional[str] = None
EOF

cat > backend/app/auth.py <<'EOF'
from datetime import datetime, timedelta, timezone
from typing import Optional
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt, JWTError
from passlib.context import CryptContext
from sqlalchemy.orm import Session
from .config import settings
from .db import get_db
from . import models

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
security = HTTPBearer()

ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 7

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(password: str, hash_: str) -> bool:
    return pwd_context.verify(password, hash_)

def create_access_token(sub: str, expires_delta: Optional[timedelta] = None) -> str:
    expire = datetime.now(timezone.utc) + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode = {"sub": sub, "exp": expire}
    return jwt.encode(to_encode, settings.JWT_SECRET, algorithm=ALGORITHM)

def get_current_user(creds: HTTPAuthorizationCredentials = Depends(security), db: Session = Depends(get_db)) -> models.User:
    token = creds.credentials
    try:
        payload = jwt.decode(token, settings.JWT_SECRET, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise HTTPException(status_code=401, detail="Invalid token")
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
    user = db.query(models.User).filter(models.User.email == email).first()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    return user
EOF

cat > backend/app/services/license_svc.py <<'EOF'
import secrets
from sqlalchemy.orm import Session
from .. import models

def generate_key() -> str:
    return "-".join(secrets.token_hex(4) for _ in range(3)).upper()

def issue_licenses(db: Session, order: models.Order):
    for item in order.items:
        product = item.product
        if product.is_subscription:
            continue
        for _ in range(item.qty):
            lic = models.License(
                order_id=order.id,
                user_id=order.user_id,
                product_id=product.id,
                key=generate_key(),
                status="active"
            )
            db.add(lic)
    db.commit()
EOF

cat > backend/app/services/email_svc.py <<'EOF'
from ..config import settings

def send_order_confirmation(email: str, order_id: int, total_cents: int, currency: str):
    print(f"[Email → {email}] Order #{order_id} total {total_cents/100:.2f} {currency.upper()}")
EOF

cat > backend/app/services/stripe_svc.py <<'EOF'
import stripe
from sqlalchemy.orm import Session
from fastapi import HTTPException
from ..config import settings
from .. import models
from .license_svc import issue_licenses
from .email_svc import send_order_confirmation

stripe.api_key = settings.STRIPE_SECRET_KEY

def create_checkout_session(items: list[dict], success_url: str, cancel_url: str, customer_email: str | None = None) -> str:
    try:
        session = stripe.checkout.Session.create(
            mode="payment",
            line_items=items,
            success_url=success_url,
            cancel_url=cancel_url,
            automatic_tax={"enabled": True},
            allow_promotion_codes=True,
            customer_email=customer_email
        )
        return session.url
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

def fulfill_checkout_session(db: Session, session_obj: dict):
    sess_id = session_obj.get("id")
    exists = db.query(models.Order).filter(models.Order.stripe_session_id == sess_id).first()
    if exists:
        return exists

    email = (session_obj.get("customer_details") or {}).get("email") or session_obj.get("customer_email")

    user = db.query(models.User).filter(models.User.email == email).first()
    if not user:
        user = models.User(email=email, password_hash="!stripe_customer", role="customer")
        db.add(user)
        db.flush()

    line_items = stripe.checkout.Session.list_line_items(sess_id)
    currency = (session_obj.get("currency") or "usd").lower()
    total_cents = int(session_obj.get("amount_total") or 0)
    tax_cents = int((session_obj.get("total_details") or {}).get("amount_tax") or 0)
    payment_intent = session_obj.get("payment_intent")

    order = models.Order(
        user_id=user.id,
        stripe_session_id=sess_id,
        stripe_payment_intent=payment_intent,
        total_cents=total_cents,
        tax_cents=tax_cents,
        currency=currency,
        status="paid"
    )
    db.add(order)
    db.flush()

    price_ids = []
    for li in line_items.auto_paging_iter():
        price_id = li.price.id if hasattr(li, "price") and li.price else li.get("price", {}).get("id")
        qty = li.quantity or 1
        price_ids.append((price_id, qty))

    for price_id, qty in price_ids:
        product = db.query(models.Product).filter(models.Product.stripe_price_id == price_id).first()
        if not product:
            continue
        db.add(models.OrderItem(
            order_id=order.id,
            product_id=product.id,
            unit_price_cents=product.price_cents,
            qty=qty
        ))

    db.commit()
    db.refresh(order)

    issue_licenses(db, order)
    send_order_confirmation(user.email, order.id, total_cents, currency)
    return order
EOF

cat > backend/app/services/ai_svc.py <<'EOF'
from typing import Optional
from langchain_openai import ChatOpenAI
from langchain.chains import ConversationalRetrievalChain
from ..config import settings
from ..ai.retriever import get_retriever

retriever = None
llm = None

def init_ai():
    global retriever, llm
    if settings.OPENAI_API_KEY:
        llm = ChatOpenAI(temperature=0)
        retriever = get_retriever()
    else:
        llm = None
        retriever = None

async def assistant_reply(message: str, user_email: Optional[str] = None) -> str:
    if not settings.OPENAI_API_KEY:
        return "AI assistant is offline (missing OpenAI key). Describe your issue and support will reply."
    chain = ConversationalRetrievalChain.from_llm(llm, retriever)
    res = chain({"question": message, "chat_history": []})
    return res["answer"]

init_ai()
EOF

cat > backend/app/services/chat_service.py <<'EOF'
from typing import Dict, Set
from fastapi import WebSocket

class ChatManager:
    def __init__(self):
        self.active: Dict[int, Set[WebSocket]] = {}

    async def connect(self, thread_id: int, ws: WebSocket):
        await ws.accept()
        self.active.setdefault(thread_id, set()).add(ws)

    def disconnect(self, thread_id: int, ws: WebSocket):
        if thread_id in self.active and ws in self.active[thread_id]:
            self.active[thread_id].remove(ws)
            if not self.active[thread_id]:
                self.active.pop(thread_id, None)

    async def broadcast(self, thread_id: int, message: dict):
        for ws in list(self.active.get(thread_id, [])):
            await ws.send_json(message)

manager = ChatManager()
EOF

cat > backend/app/ai/retriever.py <<'EOF'
from pathlib import Path
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import FAISS
from langchain_text_splitters import RecursiveCharacterTextSplitter

def get_retriever():
    docs_dir = Path(__file__).parent / "docs"
    texts = []
    for p in docs_dir.glob("*.md"):
        try:
            texts.append(p.read_text(encoding="utf-8"))
        except Exception:
            pass
    if not texts:
        texts = [
            "Refunds: 14-day money-back for one-time purchases. Subscriptions can be canceled anytime.",
            "Setup: After purchase you receive a license key and download link via email.",
            "Taxes: Stripe Tax automatically calculates at checkout."
        ]
    splitter = RecursiveCharacterTextSplitter(chunk_size=800, chunk_overlap=100)
    splits = []
    for t in texts:
        splits.extend(splitter.split_text(t))
    embeddings = OpenAIEmbeddings()
    vect = FAISS.from_texts(splits, embedding=embeddings)
    return vect.as_retriever(search_kwargs={"k": 4})
EOF

cat > backend/app/ai/docs/faq.md <<'EOF'
Q: How do I receive my software?
A: After successful payment at Stripe Checkout, we email your download link and license key.

Q: What is your refund policy?
A: 14-day no-questions-asked refunds for one-time purchases.
EOF

cat > backend/app/ai/docs/policy.md <<'EOF'
We collect only essential information (email and order details). Payments are processed securely by Stripe. Automatic tax calculation is enabled via Stripe Tax.
EOF

cat > backend/app/routes/users.py <<'EOF'
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..db import get_db
from .. import models
from ..schemas import UserCreate, UserLogin, UserOut, TokenOut
from ..auth import hash_password, verify_password, create_access_token, get_current_user

router = APIRouter()

@router.post("/register", response_model=UserOut)
def register(body: UserCreate, db: Session = Depends(get_db)):
    exists = db.query(models.User).filter(models.User.email == body.email).first()
    if exists:
        raise HTTPException(status_code=400, detail="Email already registered")
    user = models.User(email=body.email, password_hash=hash_password(body.password), role="customer")
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

@router.post("/login", response_model=TokenOut)
def login(body: UserLogin, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.email == body.email).first()
    if not user or not verify_password(body.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    token = create_access_token(user.email)
    return TokenOut(access_token=token)

@router.get("/me", response_model=UserOut)
def me(current = Depends(get_current_user)):
    return current
EOF

cat > backend/app/routes/products.py <<'EOF'
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..db import get_db
from .. import models
from ..schemas import ProductOut
from typing import List

router = APIRouter()

@router.get("/products", response_model=List[ProductOut])
def list_products(db: Session = Depends(get_db)):
    q = db.query(models.Product).filter(models.Product.active == True)
    return q.all()

@router.get("/products/{slug}", response_model=ProductOut)
def get_product(slug: str, db: Session = Depends(get_db)):
    p = db.query(models.Product).filter(models.Product.slug == slug, models.Product.active == True).first()
    if not p:
        raise HTTPException(status_code=404, detail="Product not found")
    return p
EOF

cat > backend/app/routes/checkout.py <<'EOF'
from fastapi import APIRouter, Depends
from ..schemas import CheckoutSessionCreate
from ..config import settings
from ..services.stripe_svc import create_checkout_session
from ..auth import get_current_user

router = APIRouter()

@router.post("/checkout/session")
def checkout_session(payload: CheckoutSessionCreate, user = Depends(get_current_user)):
    url = create_checkout_session(
        items=[{"price": i.price_id, "quantity": i.qty} for i in payload.items],
        success_url=f"{settings.FRONTEND_URL}/account?success=true&sid={{CHECKOUT_SESSION_ID}}",
        cancel_url=f"{settings.FRONTEND_URL}/checkout?canceled=true",
        customer_email=user.email if user else None
    )
    return {"url": url}
EOF

cat > backend/app/routes/stripe_webhooks.py <<'EOF'
from fastapi import APIRouter, Request, HTTPException, Depends
import stripe
from ..config import settings
from ..db import get_db
from sqlalchemy.orm import Session
from ..services.stripe_svc import fulfill_checkout_session

router = APIRouter()

@router.post("/stripe/webhook")
async def stripe_webhook(request: Request, db: Session = Depends(get_db)):
    payload = await request.body()
    sig = request.headers.get("stripe-signature")
    try:
        event = stripe.Webhook.construct_event(payload, sig, settings.STRIPE_WEBHOOK_SECRET)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

    if event["type"] == "checkout.session.completed":
        session = event["data"]["object"]
        fulfill_checkout_session(db, session)
    return {"received": True}
EOF

cat > backend/app/routes/orders.py <<'EOF'
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..db import get_db
from ..auth import get_current_user
from .. import models
from ..schemas import OrderOut
from typing import List

router = APIRouter()

@router.get("/orders/me", response_model=List[OrderOut])
def my_orders(user=Depends(get_current_user), db: Session = Depends(get_db)):
    orders = (db.query(models.Order).filter(models.Order.user_id == user.id)
              .order_by(models.Order.created_at.desc()).all())
    return orders
EOF

cat > backend/app/routes/ai.py <<'EOF'
from fastapi import APIRouter
from ..schemas import AIMessage
from ..services.ai_svc import assistant_reply

router = APIRouter()

@router.post("/ai/assist")
async def ai_assist(msg: AIMessage):
    reply = await assistant_reply(msg.message, user_email=msg.user_email)
    return {"reply": reply}
EOF

cat > backend/app/routes/analytics.py <<'EOF'
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import text
from ..db import get_db

router = APIRouter()

@router.get("/analytics/summary")
def summary(db: Session = Depends(get_db)):
    row = db.execute(text("""
        SELECT
          COUNT(*) FILTER (WHERE status='paid') as orders,
          COALESCE(SUM(total_cents) FILTER (WHERE status='paid'),0) as revenue_cents,
          COALESCE(SUM(tax_cents) FILTER (WHERE status='paid'),0) as tax_cents
        FROM orders
    """)).mappings().first()
    return row or {}
EOF

cat > backend/app/main.py <<'EOF'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from .config import settings
from .db import init_db, SessionLocal
from . import models
from .routes import users, products, checkout, stripe_webhooks, orders, ai, analytics

app = FastAPI(title="AI Commerce Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[settings.FRONTEND_URL, "http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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

app.include_router(users.router, prefix="/api/auth", tags=["auth"])
app.include_router(products.router, prefix="/api", tags=["products"])
app.include_router(checkout.router, prefix="/api", tags=["checkout"])
app.include_router(stripe_webhooks.router, prefix="/api", tags=["stripe"])
app.include_router(orders.router, prefix="/api", tags=["orders"])
app.include_router(ai.router, prefix="/api", tags=["ai"])
app.include_router(analytics.router, prefix="/api", tags=["analytics"])
EOF

cat > backend/tests/test_health.py <<'EOF'
from fastapi.testclient import TestClient
from app.main import app

def test_health():
    client = TestClient(app)
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json().get("ok") is True
EOF

cat > .github/workflows/ci.yml <<'EOF'
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - name: Install deps
        run: |
          python -m pip install --upgrade pip
          pip install -r backend/requirements.txt
      - name: Run tests
        working-directory: backend
        run: pytest -q
EOF

cat > README.md <<'EOF'
# E-commerceBuild-2025 (Backend)

FastAPI + Stripe + LangChain backend.

## Quick start
1) cd backend && cp .env.example .env
2) Edit .env (JWT_SECRET, STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET, OPENAI_API_KEY optional)
3) Create venv and install:
   python3 -m venv .venv && source .venv/bin/activate
   pip install -r requirements.txt
4) Run API:
   uvicorn app.main:app --reload --port 8000
5) In another terminal run Stripe webhook:
   stripe login
   stripe listen --forward-to localhost:8000/api/stripe/webhook

Docs: http://localhost:8000/docs
EOF

echo "Installing Python deps in a new virtualenv..."
python3 -m venv .venv
source .venv/bin/activate
pip install -U pip
pip install -r backend/requirements.txt

echo "Committing files..."
git add .
git commit -m "feat(backend): FastAPI + Stripe + LangChain scaffold" || true
git branch -M main || true
git push -u origin main

echo "Done. Next:"
echo "1) cd backend && cp .env.example .env && edit secrets"
echo "2) source ../.venv/bin/activate && uvicorn app.main:app --reload --port 8000"
echo "3) stripe listen --forward-to localhost:8000/api/stripe/webhook"
