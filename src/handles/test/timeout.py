import asyncio
from typing import Dict, Any, Sequence
from mcp import Tool
from mcp.types import TextContent

from handles.base import BaseHandler


class Timeout(BaseHandler):
    name = "timeout"
    description = (
        "根据指定时间睡眠时间（单位是秒）测试mcp工具超时时使用"
    )

    def get_tool_description(self) -> Tool:
        return Tool(
            name=self.name,
            description=self.description,
            inputSchema={
                "type": "object",
                "properties": {
                    "seconds": {
                        "type": "integer",
                        "description": "睡眠时间，单位是秒"
                    }
                },
                "required": ["seconds"]
            }
        )

    async def run_tool(self, arguments: Dict[str, Any]) -> Sequence[TextContent]:
        if "seconds" not in arguments:
            raise ValueError("缺少参数 'seconds'")

        seconds = arguments["seconds"]
        await asyncio.sleep(seconds)
        return [TextContent(type="text", text=f"已等待{seconds}秒")]

