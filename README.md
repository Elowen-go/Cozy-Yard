# AnZhi

基于 Godot 4.4 的 2D 游戏项目。

## 素材来源

- **Tiny Swords (Free Pack)** — 基础包：建筑、单位、地形瓦片、特效、UI 元素
- **Tiny Swords (Update 010)** — 更新包：新增阵营（哥布林、骑士）、地形、UI

两套素材均为 [PIXELEAN](https://pixelean.itch.io/) 出品的像素风 RTS/奇幻主题资源包。

## 技术栈

- Godot 4.4.1 (GL Compatibility 渲染)
- godot_mcp 插件（AI 编辑器集成）

## 当前进度

- 创建了一个基础 2D 场景 `scenes/main.tscn`
- 从 `Tilemap_color1.png` 生成了 `tileset_ground.tres` TileSet 资源
- 铺设了 31×31 的地面区域，中间有一条土路
- 添加了 Camera2D 摄像机（2 倍缩放）

## 项目结构

```
AnZhi/
├── assets/
│   ├── Tiny Swords/            # 更新包
│   └── Tiny Swords (Free Pack)/# 免费版基础包
├── addons/
│   └── godot_mcp/              # MCP 集成插件
├── scenes/                     # 游戏场景
│   └── main.tscn               # 主场景
├── scripts/                    # 游戏脚本
│   ├── generate_tileset.gd     # TileSet 生成工具
│   └── build_scene.gd          # 场景生成工具
├── prefabs/                    # 可复用子场景
└── project.godot
```
