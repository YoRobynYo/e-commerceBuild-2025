import pytest
import os
from unittest.mock import patch, MagicMock
from app.services.ai_services import AIService, AIUtils
from app.services.ai_svc import assistant_reply, init_ai


class TestAIServices:
    """Test AI services functionality"""
    
    def test_ai_utils_status(self):
        """Test AI status checking"""
        status = AIUtils.get_ai_status()
        assert isinstance(status, dict)
        assert "openai_installed" in status
        assert "client_initialized" in status
        assert "api_key_configured" in status
        assert "fully_available" in status
    
    def test_prompt_validation(self):
        """Test prompt validation"""
        # Valid prompts
        assert AIUtils.validate_prompt("Hello world") == True
        assert AIUtils.validate_prompt("What is the weather?") == True
        
        # Invalid prompts
        assert AIUtils.validate_prompt("") == False
        assert AIUtils.validate_prompt("   ") == False
        assert AIUtils.validate_prompt(None) == False
    
    def test_mock_response(self):
        """Test mock response generation"""
        # Test email response
        email_response = AIService._mock_response("Write an email about cart abandonment")
        assert "subject" in email_response or "email" in email_response.lower()
        
        # Test churn response
        churn_response = AIService._mock_response("What is the churn risk?")
        assert churn_response == "0.6"
        
        # Test price response
        price_response = AIService._mock_response("What should be the price?")
        assert price_response == "150.0"
    
    @patch.dict(os.environ, {"OPENAI_API_KEY": ""})
    def test_generate_content_no_api_key(self):
        """Test content generation without API key"""
        result = AIService.generate_content("Test prompt")
        assert isinstance(result, str)
        assert len(result) > 0
    
    def test_quick_analysis_no_api_key(self):
        """Test quick analysis without API key"""
        result = AIService.quick_analysis("Test analysis")
        assert result == "0.5"
    
    @pytest.mark.asyncio
    async def test_assistant_reply_no_api_key(self):
        """Test assistant reply without API key"""
        result = await assistant_reply("Hello")
        assert isinstance(result, str)
        assert "offline" in result.lower() or "support" in result.lower()
    
    def test_legacy_functions(self):
        """Test legacy function compatibility"""
        from app.services.ai_services import openai_call, generate_personalized_email
        
        # Test openai_call
        result = openai_call("product_abc pricing", "json")
        assert isinstance(result, dict)
        assert "product_abc" in result
        
        # Test generate_personalized_email
        email = generate_personalized_email("John", ["Product A", "Product B"])
        assert isinstance(email, str)
        assert len(email) > 0


class TestAIIntegration:
    """Test AI integration scenarios"""
    
    def test_ai_service_initialization(self):
        """Test that AI services initialize without errors"""
        # This should not raise any exceptions
        status = AIUtils.get_ai_status()
        assert isinstance(status, dict)
    
    def test_retriever_initialization(self):
        """Test retriever initialization"""
        from app.ai.retriever import get_retriever
        
        retriever = get_retriever()
        # Should return None if no API key, or a retriever object if configured
        assert retriever is None or hasattr(retriever, 'get_relevant_documents')
    
    def test_ai_chat_initialization(self):
        """Test AI chat initialization"""
        # This should not raise any exceptions
        init_ai()
        # The function should complete without errors