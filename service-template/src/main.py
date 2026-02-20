import logging
import time

from fastapi import FastAPI, HTTPException
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from starlette.responses import Response

# Structured JSON logging — picked up by Loki/Promtail automatically
logging.basicConfig(
    format='{"time":"%(asctime)s","level":"%(levelname)s","logger":"%(name)s","message":"%(message)s"}',
    level=logging.INFO,
)
logger = logging.getLogger("account-service")

app = FastAPI(title="FinCore Account Service", version="1.0.0")

# --- Prometheus Metrics ---
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status"],
)
REQUEST_DURATION = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration in seconds",
    ["method", "endpoint"],
)


@app.middleware("http")
async def metrics_middleware(request, call_next):
    start = time.time()
    response = await call_next(request)
    duration = time.time() - start

    # Don't track internal endpoints in business metrics
    if request.url.path not in ("/metrics", "/health", "/docs", "/openapi.json"):
        REQUEST_COUNT.labels(
            method=request.method,
            endpoint=request.url.path,
            status=response.status_code,
        ).inc()
        REQUEST_DURATION.labels(
            method=request.method,
            endpoint=request.url.path,
        ).observe(duration)

    return response


# --- In-memory data (demo purposes) ---
accounts = {
    "ACC001": {"id": "ACC001", "name": "Alice Johnson", "balance": 15000.00, "currency": "EUR"},
    "ACC002": {"id": "ACC002", "name": "Bob Smith", "balance": 8500.50, "currency": "EUR"},
    "ACC003": {"id": "ACC003", "name": "Carol Williams", "balance": 32000.75, "currency": "EUR"},
}


# --- Health & Metrics (platform endpoints) ---

@app.get("/health")
async def health():
    return {"status": "healthy"}


@app.get("/metrics")
async def metrics():
    return Response(content=generate_latest(), media_type=CONTENT_TYPE_LATEST)


# --- Business Endpoints ---

@app.get("/api/v1/accounts")
async def list_accounts():
    logger.info("Listing all accounts")
    return {"accounts": list(accounts.values()), "count": len(accounts)}


@app.get("/api/v1/accounts/{account_id}")
async def get_account(account_id: str):
    if account_id not in accounts:
        logger.warning("Account not found: %s", account_id)
        raise HTTPException(status_code=404, detail="Account not found")
    logger.info("Retrieved account: %s", account_id)
    return accounts[account_id]
@app.get("/api/v1/accounts/{account_id}/balance")                                                                                                                                                                 
async def get_balance(account_id: str):                                                                                                                                                                           
    if account_id not in accounts:
        raise HTTPException(status_code=404, detail="Account not found")                                                                                                                                          
    logger.info("Balance check: %s", account_id)
    return {"account_id": account_id, "balance": accounts[account_id]["balance"]}