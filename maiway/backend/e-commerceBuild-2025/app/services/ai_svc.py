from typing import Optional
import logging
import httpx

logger = logging.getLogger(__name__)

# Ollama configuration
OLLAMA_BASE_URL = "http://localhost:11434"
OLLAMA_MODEL = "llama3.1:latest"  # or llama2, mistral, etc.

class OllamaClient:
    """Simple Ollama client for chat"""
    
    def __init__(self, base_url: str = OLLAMA_BASE_URL, model: str = OLLAMA_MODEL):
        self.base_url = base_url
        self.model = model
    
    async def chat(self, message: str, context: str = "") -> str:
        """Send a chat message to Ollama"""
        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                prompt = f"{context}\n\nUser: {message}\nAssistant:" if context else message
                
                response = await client.post(
                    f"{self.base_url}/api/generate",
                    json={
                        "model": self.model,
                        "prompt": prompt,
                        "stream": False
                    }
                )
                
                if response.status_code == 200:
                    result = response.json()
                    return result.get("response", "No response from AI")
                else:
                    logger.error(f"Ollama error: {response.status_code}")
                    return "AI service temporarily unavailable"
                    
        except httpx.ConnectError:
            logger.error("Cannot connect to Ollama - is it running? Run 'ollama serve'")
            return "AI assistant is offline. Please start Ollama with 'ollama serve'"
        except Exception as e:
            logger.error(f"Error calling Ollama: {e}")
            return "I'm having trouble processing your request right now."

# Global client
ollama_client = None

def init_ai():
    """Initialize Ollama client"""
    global ollama_client
    try:
        ollama_client = OllamaClient()
        logger.info("Ollama chat service initialized")
    except Exception as e:
        logger.error(f"Error initializing Ollama: {e}")
        ollama_client = None

async def assistant_reply(message: str, user_email: Optional[str] = None) -> str:
    """Generate AI assistant reply using Ollama"""
    try:
        if not ollama_client:
            init_ai()
        
        if not ollama_client:
            return "AI assistant is offline. Make sure Ollama is running ('ollama serve')"
        
        # Add context to make responses more helpful
        context = """You are a helpful e-commerce assistant. 
You help customers with their orders, products, and general inquiries.
Keep responses concise and friendly."""
        
        response = await ollama_client.chat(message, context)
        return response
        
    except Exception as e:
        logger.error(f"Error in assistant_reply: {e}")
        return "I'm having trouble processing your request right now. Please try again."

# Initialize on import
init_ai()