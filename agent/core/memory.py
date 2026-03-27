from typing import Dict, List

class SessionManager:
    def __init__(self, max_history=10):
        self.sessions: Dict[str, List[Dict[str, str]]] = {}
        self.max_history = max_history

    def get_history(self, user_id: str) -> List[Dict[str, str]]:
        history = self.sessions.get(str(user_id), [])
        return history

    def add_message(self, user_id: str, role: str, content: str):
        user_id = str(user_id)
        if user_id not in self.sessions:
            self.sessions[user_id] = []
        
        self.sessions[user_id].append({"role": role, "content": content})
        
        # Keep only the last N messages
        if len(self.sessions[user_id]) > self.max_history:
            self.sessions[user_id] = self.sessions[user_id][-self.max_history:]

# Singleton for conversation memory
session_manager = SessionManager(max_history=10)
