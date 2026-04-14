import 'package:flutter/material.dart';
import 'package:trip_planner_app/features/trips/data/models/trip_model.dart';
import 'package:trip_planner_app/features/trips/data/trip_store.dart';

class TripEditorSheet extends StatefulWidget {
  const TripEditorSheet({super.key, this.initialTrip});

  final TripSummary? initialTrip;

  bool get isEditing => initialTrip != null;

  @override
  State<TripEditorSheet> createState() => _TripEditorSheetState();
}

class _TripEditorSheetState extends State<TripEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTrip?.title ?? '');
    _startDate = widget.initialTrip?.startDate ?? DateTime(2026, 5, 1);
    _endDate = widget.initialTrip?.endDate ?? DateTime(2026, 5, 3);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? '編輯旅程' : '新增旅程';
    final description = widget.isEditing
        ? '更新旅程名稱與日期後，會同步到 Supabase。'
        : '先建立旅程基本資料，後續再補停靠點與提醒。';

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        decoration: const BoxDecoration(
          color: Color(0xFFF6FAFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(description),
              const SizedBox(height: 18),
              TextFormField(
                controller: _titleController,
                enabled: !_isSubmitting,
                decoration: const InputDecoration(
                  labelText: '旅程名稱',
                  hintText: '例如 台南兩天一夜',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '請輸入旅程名稱';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _DateField(
                label: '開始日期',
                value: _formatDate(_startDate),
                enabled: !_isSubmitting,
                onTap: () => _pickDate(isStartDate: true),
              ),
              const SizedBox(height: 12),
              _DateField(
                label: '結束日期',
                value: _formatDate(_endDate),
                enabled: !_isSubmitting,
                onTap: () => _pickDate(isStartDate: false),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.isEditing ? '儲存變更' : '建立旅程'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isStartDate}) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2030, 12, 31),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      if (isStartDate) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      } else {
        _endDate = picked.isBefore(_startDate) ? _startDate : picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final store = TripStore.instance;
      final trip = widget.isEditing
          ? await store.updateTrip(
              tripId: widget.initialTrip!.id,
              title: _titleController.text.trim(),
              startDate: _startDate,
              endDate: _endDate,
            )
          : await store.createTrip(
              title: _titleController.text.trim(),
              startDate: _startDate,
              endDate: _endDate,
            );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(trip);
    } on TripStoreException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}/$month/$day';
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.enabled,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: enabled ? const Color(0xFF12324D) : Colors.black38,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}
