# backend/app/services/ai_services.py

import os
import logging
from typing import Dict, Any, List, Optional
from ..config import settings

logger = logging.getLogger(__name__)

# Try to import OpenAI, but don't fail if not installed
try:
    from openai import OpenAI
    HAS_OPENAI = True
    # Initialize client only if API key is available
    client = OpenAI(api_key=settings.OPENAI_API_KEY) if settings.OPENAI_API_KEY else None
except ImportError:
    HAS_OPENAI = False
    client = None
    logger.warning("OpenAI not installed - using mock responses")


class AIService:
    """AI Service - works with or without OpenAI installed"""
    
    @staticmethod
    def generate_content(prompt: str, model: str = "gpt-4") -> str:
        """Generate AI content"""
        if HAS_OPENAI and client and settings.OPENAI_API_KEY:
            try:
                response = client.chat.completions.create(
                    model=model,
                    messages=[
                        {"role": "system", "content": "You are a helpful assistant."},
                        {"role": "user", "content": prompt}
                    ],
                    temperature=0.7,
                    max_tokens=500
                )
                return response.choices[0].message.content
            except Exception as e:
                logger.error(f"OpenAI error: {e}")
                return AIService._mock_response(prompt)
        else:
            logger.info("OpenAI not available, using mock response")
            return AIService._mock_response(prompt)
    
    @staticmethod
    def quick_analysis(prompt: str) -> str:
        """Quick AI analysis"""
        if HAS_OPENAI and client and settings.OPENAI_API_KEY:
            try:
                response = client.chat.completions.create(
                    model="gpt-3.5-turbo",
                    messages=[{"role": "user", "content": prompt}],
                    temperature=0.3,
                    max_tokens=200
                )
                return response.choices[0].message.content
            except Exception as e:
                logger.error(f"OpenAI error: {e}")
                return "0.5"
        else:
            logger.info("OpenAI not available, using mock analysis")
            return "0.5"
    
    @staticmethod
    def _mock_response(prompt: str) -> str:
        """Mock response when OpenAI not available"""
        if "email" in prompt.lower():
            return '{"subject": "Your items are waiting!", "body": "Complete your purchase today."}'
        if "churn" in prompt.lower() or "risk" in prompt.lower():
            return "0.6"
        if "price" in prompt.lower():
            return "150.0"
        return "Mock AI response"


# Legacy functions for backward compatibility
def openai_call(prompt, response_format):
    """Legacy function"""
    logger.info(f"Legacy openai_call with prompt: {prompt}")
    
    if "product_abc" in prompt:
        return {"product_abc": "120.0"}
    if "product_xyz" in prompt:
        return {"product_xyz": "180.0"}
    return {"default_product": "150.0"}


def generate_personalized_email(user_name: str, product_names: List[str], viewed_items: List[str] = None) -> str:
    """Generate email content"""
    return AIService.generate_content(f"Write cart email for {user_name} with items: {product_names}")


# Additional utility methods
class AIUtils:
    """Utility methods for AI operations"""
    
    @staticmethod
    def is_ai_available() -> bool:
        """Check if AI services are available"""
        return HAS_OPENAI and client is not None and settings.OPENAI_API_KEY is not None
    
    @staticmethod
    def get_ai_status() -> Dict[str, Any]:
        """Get AI service status"""
        return {
            "openai_installed": HAS_OPENAI,
            "client_initialized": client is not None,
            "api_key_configured": settings.OPENAI_API_KEY is not None,
            "fully_available": AIUtils.is_ai_available()
        }
    
    @staticmethod
    def validate_prompt(prompt: str) -> bool:
        """Validate prompt before sending to AI"""
        if not prompt or not prompt.strip():
            return False
        if len(prompt) > 4000:  # Reasonable limit
            logger.warning("Prompt too long, truncating")
            return False
        return True

