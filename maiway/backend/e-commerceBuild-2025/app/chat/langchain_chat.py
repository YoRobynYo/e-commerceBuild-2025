import tkinter as tk
import threading
from plyer import notification
from langchain import LLMChain, PromptTemplate
from langchain.llms import HuggingFaceHub

class LangChainChat:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("LangChain Chat")

        # Notification
        notification.notify(
            title="LangChain Chat",
            message="Welcome to the LangChain chat!",
            app_name="LangChain Chat",
            app_icon=None,
            timeout=10,
        )

        # UI: chat log
        self.chat_log = tk.Text(self.root, width=50, height=10)
        self.chat_log.pack()

        # UI: user input
        self.input_box = tk.Text(self.root, width=40, height=5)
        self.input_box.pack()

        # UI: send button
        self.send_button = tk.Button(self.root, text="Send", command=self.send_input)
        self.send_button.pack()

        # LangChain setup (CPU-friendly, online inference)
        llm = HuggingFaceHub(repo_id="distilgpt2", model_kwargs={"temperature": 0.6})
        template = PromptTemplate(
            input_variables=["user_input"],
            template="User asked: {user_input}\nAssistant:",
        )
        self.llm_chain = LLMChain(prompt=template, llm=llm)

    def _generate_response(self, user_input):
        try:
            # Use run() for simplicity; passes the input to the template
            response = self.llm_chain.run(user_input)
        except Exception as e:
            import traceback
            traceback.print_exc()
            response = f"AI error: {type(e).__name__}: {e}"
        # Update UI on main thread
        self.root.after(0, lambda: self.chat_log.insert(tk.END, f"AI: {response}\n"))

    def send_input(self):
        user_input = self.input_box.get("1.0", tk.END).strip()
        if not user_input:
            return
        self.chat_log.insert(tk.END, f"You: {user_input}\n")
        self.input_box.delete("1.0", tk.END)

        # Run AI in a background thread to keep UI responsive
        threading.Thread(target=self._generate_response, args=(user_input,), daemon=True).start()

    def run(self):
        self.root.mainloop()

if __name__ == "__main__":
    chat = LangChainChat()
    chat.run()