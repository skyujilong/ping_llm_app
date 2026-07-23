import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/provider_model.dart';
import '../services/provider_store.dart';
import '../theme/app_theme.dart';
import '../widgets/provider_tile.dart';
import '../widgets/provider_form_sheet.dart';

/// Provider configuration screen with white background.
class ProvidersScreen extends StatelessWidget {
  const ProvidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ProviderStore>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('服务商配置'),
            backgroundColor: Colors.white,
            foregroundColor: AppColors.fg,
            surfaceTintColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.add, size: 22),
                onPressed: () => _addProvider(context),
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: ProviderTile(
                  provider: store.providers[i],
                  onEdit: () => _editProvider(context, store.providers[i]),
                  onDelete: () =>
                      _deleteProvider(context, store, store.providers[i]),
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
                        size: 40,
                        color: AppColors.muted.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '还没有配置服务商\n点击右上方 + 添加',
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: OutlinedButton.icon(
                onPressed: () => _addProvider(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('添加服务商'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: AppColors.border,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  foregroundColor: AppColors.muted,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Future<void> _addProvider(BuildContext context) async {
    final result = await ProviderFormSheet.show(context);
    if (result != null && context.mounted) {
      final store = context.read<ProviderStore>();
      final p = result.copyWith(id: store.generateId());
      await store.addProvider(p);
    }
  }

  Future<void> _editProvider(BuildContext context, ProviderModel p) async {
    final result = await ProviderFormSheet.show(context, provider: p);
    if (result != null && context.mounted) {
      final store = context.read<ProviderStore>();
      await store.updateProvider(result.copyWith(id: p.id));
    }
  }

  Future<void> _deleteProvider(
    BuildContext context,
    ProviderStore store,
    ProviderModel p,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确定删除此服务商？'),
        content: Text('${p.effectiveName} 的配置将被永久删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await store.removeProvider(p.id);
    }
  }
}
