from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from ..services.ai_svc import assistant_reply  # adjust path if needed

router = APIRouter()

class ChatRequest(BaseModel):
    user_input: str
    user_email: str | None = None

@router.post("/chat")
async def chat_rest(req: ChatRequest):
    try:
        reply = await assistant_reply(req.user_input, user_email=req.user_email)
        return {"reply": reply}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))