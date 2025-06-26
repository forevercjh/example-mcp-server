### MCP 开发手册 
#### 1. 项目概述
本项目是一个 MCP (Model Context Protocol) 项目，核心是通过工具注册表管理各种工具实例。 BaseHandler 作为工具基类，所有具体工具需继承该类并实现必要方法。
#### 2. 开发环境准备
确保已安装 Python 环境，项目依赖维护在 requirements.txt 中，可通过以下命令安装依赖：
```
pip3 install -r requirements.txt
``` 
#### 3. 核心类说明
- ToolRegistry : 工具注册表，负责管理所有工具实例，提供注册、获取单个工具和获取所有工具描述的方法。
- BaseHandler : 工具基类，子类需实现 get_tool_description 和 run_tool 方法。子类初始化时会自动注册到 ToolRegistry 。 
#### 4. 开发新工具步骤
以下是开发新工具的示例，假设我们要创建一个名为 ExampleTool 的新工具。
##### 4.1 创建新工具类文件
在 src/handles 目录下创建新文件，例如 example_tool.py 。

```
from typing import Dict, Any, Sequence
from mcp.types import TextContent, Tool
from handles.base import BaseHandler

class ExampleTool(BaseHandler):
    name = "example_tool"
    description = "这是一个示例工具"

    def get_tool_description(self) -> Tool:
        return Tool(
            name=self.name,
            description=self.description,
            inputSchema={
                "type": "object",
                "properties": {
                    "text": {
                        "type": "string",
                        "description": "示例输入文本"
                    }
                },
                "required": ["text"]
            }
        )

    async def run_tool(self, arguments: Dict[str, 
    Any]) -> Sequence[TextContent]:
        text = arguments.get('text', '')
        return [TextContent(type="text", text=f"你输入的
        文本是: {text}")]
``` 
##### 4.2 注册新工具
由于 BaseHandler 的 __init_subclass__ 方法会自动注册工具，只需继承 BaseHandler 并设置 name 属性即可完成注册。
#### 5. 打包 Docker 镜像
项目根目录下已存在 Dockerfile ，可使用以下命令构建 Docker 镜像：

```
docker build -t mcp-server .
```
运行 Docker 容器：

```
docker run -p 8000:8000 mcp-server
``` 
#### 6. 依赖管理
项目依赖版本维护在 requirements.txt 中，添加新依赖时，请在文件中添加对应依赖及其版本，示例如下：

```
mcp==1.0.0
aiohttp==3.8.1
# 添加新依赖时按此格式添加
```
### 基础项目代码整理说明 src/handles/base.py 代码
```
from typing import Dict, Any, Sequence, Type, ClassVar

from mcp.types import TextContent, Tool


class ToolRegistry:
    """工具注册表，用于管理所有工具实例"""
    _tools: ClassVar[Dict[str, 'BaseHandler']] = {}

    @classmethod
    def register(cls, tool_class: Type['BaseHandler']) 
    -> Type['BaseHandler']:
        """注册工具类
        
        Args:
            tool_class: 要注册的工具类
            
        Returns:
            返回注册的工具类，方便作为装饰器使用
        """
        tool = tool_class()
        cls._tools[tool.name] = tool
        return tool_class

    @classmethod
    def get_tool(cls, name: str) -> 'BaseHandler':
        """获取工具实例
        
        Args:
            name: 工具名称
            
        Returns:
            工具实例
            
        Raises:
            ValueError: 当工具不存在时抛出
        """
        if name not in cls._tools:
            raise ValueError(f"未知的工具: {name}")
        return cls._tools[name]

    @classmethod
    def get_all_tools(cls) -> list[Tool]:
        """获取所有工具的描述
        
        Returns:
            所有工具的描述列表
        """
        return [tool.get_tool_description() for tool 
        in cls._tools.values()]


class BaseHandler:
    """工具基类"""
    name: str = ""
    description: str = ""

    def __init_subclass__(cls, **kwargs):
        """子类初始化时自动注册到工具注册表"""
        super().__init_subclass__(**kwargs)
        if cls.name:  # 只注册有名称的工具
            ToolRegistry.register(cls)

    def get_tool_description(self) -> Tool:
        raise NotImplementedError

    async def run_tool(self, arguments: Dict[str, 
    Any]) -> Sequence[TextContent]:
        raise NotImplementedError
```
该文件定义了项目的核心类，为开发新工具提供基础框架。按照上述开发手册，开发者可基于 BaseHandler 类快速开发新工具。