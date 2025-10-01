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
