import os
from typing import Optional, Dict, Any
from abc import ABC, abstractmethod
from groq import Groq
import ollama
from dotenv import load_dotenv

load_dotenv()

class AIClient(ABC):
    @abstractmethod
    def chat_completion(self, messages: list, model: str = None) -> str:
        pass

class OllamaClient(AIClient):
    def __init__(self, model: str = "llama3.1"):
        self.model = model

    def chat_completion(self, messages: list, model: str = None) -> str:
        try:
            response = ollama.chat(
                model=model or self.model,
                messages=messages
            )
            return response['message']['content'].strip()
        except Exception as e:
            raise RuntimeError(f"Ollama error: {e}")

class GroqClient(AIClient):
    def __init__(self, api_key: str, model: str = "llama-3.1-8b-instant"):
        self.client = Groq(api_key=api_key)
        self.model = model

    def chat_completion(self, messages: list, model: str = None) -> str:
        try:
            response = self.client.chat.completions.create(
                model=model or self.model,
                messages=messages,
                temperature=0.7,
                max_tokens=1000
            )
            return response.choices[0].message.content.strip()
        except Exception as e:
            raise RuntimeError(f"Groq error: {e}")

def get_ai_client() -> AIClient:
    env = os.getenv("ENV", "development")
    if env == "production":
        api_key = os.getenv("GROQ_API_KEY")
        if not api_key:
            raise ValueError("GROQ_API_KEY is required in production")
        return GroqClient(api_key=api_key)
    else:
        return OllamaClient(model="llama3.1")