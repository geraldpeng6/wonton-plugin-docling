# 云吞插件：Docling Serve

[Docling Serve](https://github.com/docling-project/docling-serve) 的云吞插件：把 PDF、扫描件、图片、
Word、PPT、HTML 等文档解析成 Markdown、JSON 或纯文本，扫描件和图片里的文字用 OCR 认出来。
开发流程见[插件开发指南](https://github.com/geraldpeng6/wonton-docs/blob/main/develop.md)。

## 用法

装好后从云吞打开，网页直接是转换界面：上传文件或粘贴链接，选输出格式（Markdown、JSON、纯文本），
转换完预览和下载。网页和 MCP 工具共用同一个解析服务。

给 Agent 用的工具经 MCP 总线暴露（`ai-docling-serve__convert_document_into_docling_document` 等），
Agent 解析文档时把 URL 交给它。

## 模型与显卡

- 默认解析模型（版面分析、表格结构、OCR：EasyOCR 和 RapidOCR，合计约 0.9 GB）随上游官方
  cu128 镜像内置，装好即用，运行时不下载模型；需要联网的只有转换链接来源的文档。
- 显卡：需要 NVIDIA 显卡（CUDA 12.8，适配 RTX 50 系），解析时显存约 2.1 GB，
  4 GB 及以上的显卡都跑得动（推荐 8 GB）；本机实测峰值 2114 MiB（RTX 5090）。
- 内存：serve 常驻约 2.2 GB，MCP 服务约 0.4 GB。

中文扫描件在网页的选项里把 OCR 引擎换成 RapidOCR。图片描述、VLM 管线这些要额外模型的
功能没有预置模型，启用时会报错，属上游镜像的默认行为。

## 图标

`icon.png` 来自 Docling 官方标志，来源和许可见 [NOTICE](NOTICE)。
