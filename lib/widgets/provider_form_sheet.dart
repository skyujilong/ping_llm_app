import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/provider_model.dart';
import '../services/provider_store.dart';
import '../theme/app_theme.dart';

/// Bottom sheet for adding or editing a provider.
class ProviderFormSheet extends StatefulWidget {
  const ProviderFormSheet({super.key, this.provider});

  final ProviderModel? provider;

  static Future<ProviderModel?> show(
    BuildContext context, {
    ProviderModel? provider,
  }) => showModalBottomSheet<ProviderModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => ProviderFormSheet(provider: provider),
  );

  @override
  State<ProviderFormSheet> createState() => _ProviderFormSheetState();
}

class _ProviderFormSheetState extends State<ProviderFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late ProviderType _type;
  late TextEditingController _nameCtrl;
  late TextEditingController _keyCtrl;
  late TextEditingController _hostCtrl;
  late TextEditingController _modelCtrl;

  bool _fetchingModels = false;
  List<String> _fetchedModels = [];
  String? _fetchError;

  @override
  void initState() {
    super.initState();
    final p = widget.provider;
    _type = p?.type ?? ProviderType.openai;
    _nameCtrl = TextEditingController(text: p?.displayName ?? '');
    _keyCtrl = TextEditingController(text: p?.apiKey ?? '');
    _hostCtrl = TextEditingController(text: p?.host ?? '');
    _modelCtrl = TextEditingController(text: p?.model ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _keyCtrl.dispose();
    _hostCtrl.dispose();
    _modelCtrl.dispose();
    super.dispose();
  }

  ProviderModel _buildTempProvider() => ProviderModel(
    id: widget.provider?.id ?? '',
    type: _type,
    displayName: _nameCtrl.text.trim(),
    apiKey: _keyCtrl.text.trim(),
    host: _hostCtrl.text.trim().isEmpty ? _type.defaultHost : _hostCtrl.text.trim(),
    model: _modelCtrl.text.trim().isEmpty ? _type.defaultModel : _modelCtrl.text.trim(),
  );

  Future<void> _fetchModels() async {
    setState(() {
      _fetchingModels = true;
      _fetchError = null;
      _fetchedModels = [];
    });
    final store = context.read<ProviderStore>();
    try {
      final models = await store.fetchModels(_buildTempProvider());
      if (!mounted) return;
      setState(() {
        _fetchedModels = models;
        _fetchingModels = false;
        if (models.isEmpty) {
          _fetchError = '该接口返回了空列表';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _fetchingModels = false;
        _fetchError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.provider != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEditing ? '编辑服务商' : '添加服务商',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.02,
                ),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                '服务商',
                ProviderType.values,
                _type,
                (v) => setState(() {
                  if (v == null) return;
                  _type = v;
                  _fetchedModels = [];
                  _fetchError = null;
                  if (_hostCtrl.text.isEmpty ||
                      _hostCtrl.text == widget.provider?.host) {
                    _hostCtrl.text = v.defaultHost;
                  }
                  if (_modelCtrl.text.isEmpty ||
                      _modelCtrl.text == widget.provider?.model) {
                    _modelCtrl.text = v.defaultModel;
                  }
                }),
              ),
              const SizedBox(height: 12),
              _buildField('显示名称', _nameCtrl, hint: '例如：我的 OpenAI'),
              const SizedBox(height: 12),
              _buildField(
                'API Key',
                _keyCtrl,
                hint: 'sk-...',
                obscure: true,
                mono: true,
              ),
              const SizedBox(height: 12),
              _buildField(
                'API Host',
                _hostCtrl,
                hint: _type.defaultHost,
                mono: true,
              ),
              const SizedBox(height: 4),
              Text(
                '默认: ${_type.defaultHost}',
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _buildField(
                      '默认模型',
                      _modelCtrl,
                      hint: _type.defaultModel,
                      mono: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _fetchingModels ? null : _fetchModels,
                      icon: _fetchingModels
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.refresh, size: 18),
                      label: Text(
                        _fetchingModels ? '获取中' : '获取模型',
                        style: const TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_fetchedModels.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 160),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _fetchedModels.length,
                    separatorBuilder: (_, i) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final model = _fetchedModels[i];
                      final selected = _modelCtrl.text == model;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _modelCtrl.text = model;
                            _modelCtrl.selection = TextSelection.collapsed(offset: model.length);
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  model,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: '.SF Mono',
                                    color: selected ? AppColors.accent : AppColors.fg,
                                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (selected)
                                const Icon(Icons.check, size: 16, color: AppColors.accent),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (_fetchError != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _fetchError!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.danger,
                      fontFamily: '.SF Mono',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: const Text(
                        '取消',
                        style: TextStyle(color: AppColors.fg, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('保存'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<ProviderType> items,
    ProviderType value,
    void Function(ProviderType?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.02,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<ProviderType>(
          initialValue: value,
          items: items
              .map(
                (t) => DropdownMenuItem(
                  value: t,
                  child: Text(t.label, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    String? hint,
    bool obscure = false,
    bool mono = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.02,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          obscureText: obscure,
          style: TextStyle(
            fontSize: 14,
            fontFamily: mono ? '.SF Mono' : '.SF Pro Text',
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final p = ProviderModel(
      id: widget.provider?.id ?? '',
      type: _type,
      displayName: _nameCtrl.text.trim(),
      apiKey: _keyCtrl.text.trim(),
      host: _hostCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      usage: widget.provider?.usage,
    );
    Navigator.of(context).pop(p);
  }
}
