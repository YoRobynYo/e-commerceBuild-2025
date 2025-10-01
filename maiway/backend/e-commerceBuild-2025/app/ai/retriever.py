from pathlib import Path
import logging
from ..config import settings

logger = logging.getLogger(__name__)

# Try to import LangChain components
try:
    from langchain_openai import OpenAIEmbeddings
    from langchain_community.vectorstores import FAISS
    from langchain_text_splitters import RecursiveCharacterTextSplitter
    HAS_LANGCHAIN = True
except ImportError:
    HAS_LANGCHAIN = False
    logger.warning("LangChain components not available")

def get_retriever():
    """Get document retriever with proper error handling"""
    try:
        if not HAS_LANGCHAIN:
            logger.warning("LangChain not available, returning None")
            return None
            
        if not settings.OPENAI_API_KEY:
            logger.warning("OpenAI API key not configured, returning None")
            return None
        
        docs_dir = Path(__file__).parent / "docs"
        texts = []
        
        # Read documentation files
        for p in docs_dir.glob("*.md"):
            try:
                texts.append(p.read_text(encoding="utf-8"))
            except Exception as e:
                logger.warning(f"Could not read {p}: {e}")
        
        # Fallback content if no docs found
        if not texts:
            texts = [
                "Refunds: 14-day money-back for one-time purchases. Subscriptions can be canceled anytime.",
                "Setup: After purchase you receive a license key and download link via email.",
                "Taxes: Stripe Tax automatically calculates at checkout."
            ]
        
        # Split texts
        splitter = RecursiveCharacterTextSplitter(chunk_size=800, chunk_overlap=100)
        splits = []
        for t in texts:
            splits.extend(splitter.split_text(t))
        
        # Create embeddings and vector store
        embeddings = OpenAIEmbeddings(api_key=settings.OPENAI_API_KEY)
        vect = FAISS.from_texts(splits, embedding=embeddings)
        
        logger.info(f"Created retriever with {len(splits)} text chunks")
        return vect.as_retriever(search_kwargs={"k": 4})
        
    except Exception as e:
        logger.error(f"Error creating retriever: {e}")
        return None
