# NotesHelper

AI 驱动的智能笔记助手 — 拍照即可自动生成结构化笔记和思维导图。

## 功能特性

- 📷 拍照/上传图片，AI 自动识别内容
- 📝 生成结构化笔记（标题、要点、关键概念）
- 🧠 自动生成可交互思维导图（缩放、拖拽、编辑）
- 🤖 多 AI 模型支持（Claude、GPT-4o、Gemini）
- 📱 多平台支持：Web、Android、iOS、Windows、Mac
- 📤 导出为 PDF、Markdown、图片

## 技术栈

- **前端**: Flutter (Dart)
- **后端**: Python FastAPI
- **数据库**: PostgreSQL
- **AI**: Claude Vision / GPT-4o Vision / Gemini Vision

## 快速开始

### 后端

```bash
cd backend
cp .env.example .env  # 编辑 .env 填入 API Key
docker-compose up -d  # 启动 PostgreSQL
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### 前端

```bash
cd frontend
flutter pub get
flutter run
```

## 项目结构

```
noteshelper/
├── frontend/    # Flutter 多平台应用
├── backend/     # FastAPI 后端服务
└── docker-compose.yml
```
