/// Supported LLM provider types.
enum ProviderType {
  openai('OpenAI', 'https://api.openai.com', 'gpt-4o-mini', 'O', 0xFF10a37f),
  anthropic(
    'Anthropic (Claude)',
    'https://api.anthropic.com',
    'claude-3-haiku-20240307',
    'C',
    0xFFd97757,
  ),
  google(
    'Google (Gemini)',
    'https://generativelanguage.googleapis.com',
    'gemini-2.0-flash',
    'G',
    0xFF4285f4,
  ),
  deepseek(
    'DeepSeek',
    'https://api.deepseek.com',
    'deepseek-chat',
    'D',
    0xFF4f46e5,
  ),
  local('本地部署', 'http://localhost:11434', 'llama3', 'L', 0xFF6b7280),
  volcengine(
    '火山方舟 (豆包)',
    'https://ark.cn-beijing.volces.com/api/v3',
    'doubao-seed-1-6-250615',
    'V',
    0xFF0b57d0,
  ),
  zhipu(
    '智谱AI (ChatGLM)',
    'https://open.bigmodel.cn/api/paas/v4',
    'glm-4-flash',
    'Z',
    0xFF3b82f6,
  ),
  moonshot(
    '月之暗面 (Kimi)',
    'https://api.moonshot.cn',
    'moonshot-v1-auto',
    'M',
    0xFF1e293b,
  ),
  minimax(
    'MiniMax',
    'https://api.minimax.io',
    'MiniMax-M3',
    'X',
    0xFFef4444,
  ),
  baichuan(
    '百川智能',
    'https://api.baichuan-ai.com',
    'Baichuan4',
    'B',
    0xFF22c55e,
  ),
  stepfun(
    '阶跃星辰',
    'https://api.stepfun.com',
    'step-2-16k',
    'S',
    0xFFf97316,
  ),
  qwen(
    '通义千问 (阿里)',
    'https://dashscope.aliyuncs.com/compatible-mode',
    'qwen-turbo',
    'Q',
    0xFF8b5cf6,
  ),
  openaiCompat(
    '兼容 OpenAI API',
    'https://api.example.com',
    'custom',
    'AP',
    0xFF8b5cf6,
  ),
  anthropicCompat(
    '兼容 Claude API',
    'https://api.example.com',
    'custom',
    'AC',
    0xFFa855f7,
  );

  const ProviderType(
    this.label,
    this.defaultHost,
    this.defaultModel,
    this.icon,
    this.color,
  );
  final String label;
  final String defaultHost;
  final String defaultModel;
  final String icon;
  final int color;

  static ProviderType fromString(String s) =>
      ProviderType.values.firstWhere((e) => e.name == s, orElse: () => openai);
}

/// Per-provider usage statistics.
class UsageStats {
  UsageStats({this.today = 0, this.month = 0, this.quota = 200000});

  factory UsageStats.fromJson(Map<String, dynamic> json) => UsageStats(
    today: (json['today'] as num?)?.toInt() ?? 0,
    month: (json['month'] as num?)?.toInt() ?? 0,
    quota: json['quota'] == null ? 200000 : (json['quota'] as num).toInt(),
  );

  int today;
  int month;
  int quota;

  Map<String, dynamic> toJson() => {
    'today': today,
    'month': month,
    'quota': quota,
  };
}

/// A configured LLM provider endpoint.
class ProviderModel {
  ProviderModel({
    required this.id,
    required this.type,
    this.displayName = '',
    this.apiKey = '',
    this.host = '',
    this.model = '',
    this.online = false,
    this.latencyMs,
    this.lastPingAt,
    UsageStats? usage,
  }) : usage = usage ?? UsageStats();

  factory ProviderModel.fromJson(Map<String, dynamic> json) => ProviderModel(
    id: json['id'] as String,
    type: ProviderType.fromString(json['type'] as String? ?? ''),
    displayName: (json['displayName'] as String?) ?? '',
    apiKey: (json['apiKey'] as String?) ?? '',
    host: (json['host'] as String?) ?? '',
    model: (json['model'] as String?) ?? '',
    online: (json['online'] as bool?) ?? false,
    latencyMs: (json['latencyMs'] as num?)?.toInt(),
    lastPingAt: json['lastPingAt'] != null
        ? DateTime.parse(json['lastPingAt'] as String)
        : null,
    usage: json['usage'] != null
        ? UsageStats.fromJson(json['usage'] as Map<String, dynamic>)
        : null,
  );

  final String id;
  ProviderType type;
  String displayName;
  String apiKey;
  String host;
  String model;
  bool online;
  int? latencyMs;
  DateTime? lastPingAt;
  UsageStats? usage;

  String get effectiveName => displayName.isNotEmpty ? displayName : type.label;
  String get effectiveHost => host.isNotEmpty ? host : type.defaultHost;
  String get effectiveModel => model.isNotEmpty ? model : type.defaultModel;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'displayName': displayName,
    'apiKey': apiKey,
    'host': host,
    'model': model,
    'online': online,
    'latencyMs': latencyMs,
    'lastPingAt': lastPingAt?.toIso8601String(),
    'usage': usage?.toJson(),
  };

  ProviderModel copyWith({
    String? id,
    ProviderType? type,
    String? displayName,
    String? apiKey,
    String? host,
    String? model,
    bool? online,
    int? latencyMs,
    bool clearLatency = false,
    DateTime? lastPingAt,
    UsageStats? usage,
  }) => ProviderModel(
    id: id ?? this.id,
    type: type ?? this.type,
    displayName: displayName ?? this.displayName,
    apiKey: apiKey ?? this.apiKey,
    host: host ?? this.host,
    model: model ?? this.model,
    online: online ?? this.online,
    latencyMs: clearLatency ? null : (latencyMs ?? this.latencyMs),
    lastPingAt: lastPingAt ?? this.lastPingAt,
    usage: usage ?? this.usage,
  );
}
