from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.routers import auth, users, gyms, plans, subscriptions, checkins, payments, admin

app = FastAPI(
    title="1Pass ME API",
    description="Fitness aggregator platform for the Middle East",
    version="1.0.0",
    docs_url="/api/docs",
    redoc_url="/api/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api/v1/auth", tags=["Auth"])
app.include_router(users.router, prefix="/api/v1/users", tags=["Users"])
app.include_router(gyms.router, prefix="/api/v1/gyms", tags=["Gyms"])
app.include_router(plans.router, prefix="/api/v1/plans", tags=["Plans"])
app.include_router(subscriptions.router, prefix="/api/v1/subscriptions", tags=["Subscriptions"])
app.include_router(checkins.router, prefix="/api/v1/checkins", tags=["Checkins"])
app.include_router(payments.router, prefix="/api/v1/payments", tags=["Payments"])
app.include_router(admin.router, prefix="/api/v1/admin", tags=["Admin"])


@app.get("/api/health")
async def health():
    return {"status": "ok", "service": "1pass-me"}
