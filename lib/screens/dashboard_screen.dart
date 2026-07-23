import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/provider_store.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/provider_tile.dart';
import 'providers_screen.dart';

/// Home screen — stats + provider list + big ping button.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ProviderStore>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('LLM Ping'),
            backgroundColor: AppColors.bg,
            actions: [
              IconButton(
                icon: const Icon(Icons.tune, size: 22),
                onPressed: () => _onSettings(context),
              ),
            ],
          ),
          SliverToBoxAdapter(child: _buildPingHero(context, store)),
          SliverToBoxAdapter(child: _buildStatsGrid(store)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              child: Text(
                '服务商状态',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                  letterSpacing: 0.02,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  i == 0 ? 0 : 0,
                  20,
                  i == store.providers.length - 1 ? 12 : 0,
                ),
                child: ProviderTile(
                  provider: store.providers[i],
                  onPing: () => _quickPing(context, store.providers[i].id),
                ),
              ),
              childCount: store.providers.length,
            ),
          ),
          if (store.providers.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.wifi_tethering,
                        size: 36,
                        color: AppColors.muted.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '还没有配置服务商\n点击右上角图标添加',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.muted,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildPingHero(BuildContext context, ProviderStore store) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        children: [
          GestureDetector(
            onTap: store.pinning ? null : () => _pingAll(context, store),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: store.pinning
                    ? AppColors.accent.withValues(alpha: 0.7)
                    : AppColors.accent,
                shape: BoxShape.circle,
                boxShadow: store.pinning
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 16,
                        ),
                      ],
              ),
              child: Center(
                child: store.pinning
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 28,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            store.pinning ? 'Ping 中…' : '一键 Ping 全部',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.muted,
              letterSpacing: 0.02,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ProviderStore store) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: '已配置',
                  value: '${store.providers.length}',
                  sub: '服务商',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: '在线',
                  value: '${store.onlineCount} / ${store.providers.length}',
                  valueColor: AppColors.success,
                  sub: '/ 全部在线',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: '平均响应',
                  value: store.avgLatency == 0 ? '—' : '${store.avgLatency}ms',
                  sub: 'ms',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: '上次 PING',
                  value: store.lastPingAllTime == null
                      ? '—'
                      : _relativeTime(store.lastPingAllTime!),
                  sub: store.lastPingAllTime == null ? '点击按钮开始' : '上次批量 Ping',
                  valueStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.fg,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes} 分钟前';
    return DateFormat('HH:mm').format(dt);
  }

  void _onSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProvidersScreen()));
  }

  Future<void> _quickPing(BuildContext context, String id) async {
    final store = context.read<ProviderStore>();
    final result = await store.pingSingle(id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? '${result.latencyMs}ms'
              : (result.errorMessage ?? '超时'),
        ),
        backgroundColor: result.success ? AppColors.success : AppColors.danger,
      ),
    );
  }

  Future<void> _pingAll(BuildContext context, ProviderStore store) async {
    final count = store.providers.length;
    await store.pingAll(
      onProgress: (done, _) {
        debugPrint('Ping progress: $done / $count');
      },
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ping 完成 · ${store.onlineCount}/$count 在线'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
