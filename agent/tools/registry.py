import logging
from typing import Dict, Any, Callable, Coroutine

logger = logging.getLogger(__name__)

class ToolRegistry:
    def __init__(self):
        self.tools: Dict[str, Callable[[Any], Coroutine[Any, Any, Any]]] = {}

    def register(self, name: str):
        def decorator(func: Callable[[Any], Coroutine[Any, Any, Any]]):
            self.tools[name] = func
            return func
        return decorator

    async def execute(self, action: str, data: Any):
        if action in self.tools:
            try:
                logger.info(f"Executing tool: {action}")
                return await self.tools[action](data)
            except Exception as e:
                logger.error(f"Tool execution error ({action}): {e}")
                return f"❌ Error executing action '{action}': {str(e)}"
        logger.warning(f"Action '{action}' not found in registry.")
        return f"❌ Action '{action}' is not supported."

registry = ToolRegistry()
