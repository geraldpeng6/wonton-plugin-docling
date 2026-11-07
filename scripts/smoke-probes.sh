# shellcheck shell=bash
# scripts/smoke.sh 的一项一项探测，跟着插件走。没写的项会 FAIL 并给出写法，不会默认放行。
#
# 页面：web_assert 从标准输入读页面，命中的确是应用的真实页面时返回 0。
# 身份：docling-serve 没有用户体系，用户身份是网关代登录注入的 X-Api-Key；identity_check
#       打一个受它保护的接口（不存在的任务号）：注入成功返回 404（任务不存在），没注入是 401。
# 数据：DATA_NA=1。docling-serve 不存用户数据：转换结果单次有效，过几分钟自动删除，
#       没有可校验的持久用户数据；临时文件在数据目录的 scratch/ 下，由服务自己清理。
# 工具：MCP_TOOL 用上游标了 readOnlyHint 的缓存检查工具；mcp_assert 从标准输入读调用结果。

web_assert() { grep -q '<title>Docling Serve</title>'; }

identity_check() {
  # docling-serve 没有用户体系；用户身份是网关代登录注入的 X-Api-Key。
  # SMOKE_WEB_URL 带着清单的 webui.path（/ui），应用 API 挂在根路径：用 dweb（dev.sh 的地址不带 path）。
  # 打受 X-Api-Key 保护的接口（不存在的任务号）：注入成功是 404 "Task not found."，没注入是 401。
  local out
  out="$(dweb /v1/status/poll/wonton-smoke-probe 2>&1)" || true
  grep -q "Task not found" <<<"$out" || {
    echo "受 X-Api-Key 保护的接口没认出用户（401 说明网关没注入密钥）：$(head -c 150 <<<"$out")"
    return 1
  }
}

# shellcheck disable=SC2034  # 由探针套件 source 后读取
DATA_NA=1
# shellcheck disable=SC2034  # 由探针套件 source 后读取
SMOKE_NOTE="docling-serve 不存用户数据：转换结果单次有效，超时自动删除；scratch 临时目录不构成可校验的用户数据。"

# shellcheck disable=SC2034  # 由探针套件 source 后读取
MCP_TOOL="check_document_in_local_cache"
# shellcheck disable=SC2034  # 由探针套件 source 后读取
MCP_ARGS='{"document_key": "wonton-smoke-probe"}'
mcp_assert() { grep -Eq '"in_cache"[[:space:]:]*false'; }
