from typing import Optional
import logging
from ..config import settings

logger = logging.getLogger(__name__)

# Try to import LangChain components
try:
    from langchain_openai import ChatOpenAI
    from langchain.chains import ConversationalRetrievalChain
    from ..ai.retriever import get_retriever
    HAS_LANGCHAIN = True
except ImportError:
    HAS_LANGCHAIN = False
    logger.warning("LangChain not available - AI chat features disabled")

retriever = None
llm = None

def init_ai():
    """Initialize AI components with proper error handling"""
    global retriever, llm
    try:
        if HAS_LANGCHAIN and settings.OPENAI_API_KEY:
            llm = ChatOpenAI(temperature=0, api_key=settings.OPENAI_API_KEY)
            retriever = get_retriever()
            logger.info("AI chat service initialized successfully")
        else:
            llm = None
            retriever = None
            if not HAS_LANGCHAIN:
                logger.warning("LangChain not available")
            if not settings.OPENAI_API_KEY:
                logger.warning("OpenAI API key not configured")
    except Exception as e:
        logger.error(f"Error initializing AI: {e}")
        llm = None
        retriever = None

async def assistant_reply(message: str, user_email: Optional[str] = None) -> str:
    """Generate AI assistant reply with error handling"""
    try:
        if not HAS_LANGCHAIN or not settings.OPENAI_API_KEY or not llm or not retriever:
            return "AI assistant is offline (missing OpenAI key or LangChain). Describe your issue and support will reply."
        
        chain = ConversationalRetrievalChain.from_llm(llm, retriever)
        res = chain({"question": message, "chat_history": []})
        return res["answer"]
    except Exception as e:
        logger.error(f"Error in assistant_reply: {e}")
        return "I'm having trouble processing your request right now. Please try again or contact support."

# Initialize AI on import
init_ai()
