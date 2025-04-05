import 'package:flutter/material.dart';
import '../models/metric.dart';
import '../services/metric_service.dart';

class AddMetricScreen extends StatefulWidget {
  final String userId;
  final MetricType initialMetricType;
  final MetricService? metricService;

  const AddMetricScreen({
    Key? key,
    required this.userId,
    required this.initialMetricType,
    this.metricService,
  }) : super(key: key);

  @override
  State<AddMetricScreen> createState() => _AddMetricScreenState();
}

class _AddMetricScreenState extends State<AddMetricScreen> {
  final _formKey = GlobalKey<FormState>();
  late MetricService _metricService;
  late TextEditingController _valueController;
  late TextEditingController _notesController;
  late MetricType _selectedMetricType;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _metricService = widget.metricService ?? MockMetricService();
    _valueController = TextEditingController();
    _notesController = TextEditingController();
    _selectedMetricType = widget.initialMetricType;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveMetric() async {
    if (_formKey.currentState!.validate()) {
      double value;

      // For gym visits, always use 1.0 as the value
      if (_selectedMetricType == MetricType.gymVisit) {
        value = 1.0;
      } else {
        value = double.parse(_valueController.text);
      }

      final metric = Metric(
        id: '', // Will be assigned by service
        userId: widget.userId,
        date: _selectedDate,
        type: _selectedMetricType,
        value: value,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await _metricService.addMetric(metric);

      if (!mounted) return;

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isGymVisit = _selectedMetricType == MetricType.gymVisit;

    return Scaffold(
      appBar: AppBar(title: Text('Add ${_getMetricName(_selectedMetricType)}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<MetricType>(
              value: _selectedMetricType,
              decoration: const InputDecoration(
                labelText: 'Metric Type',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final type in MetricType.values)
                  DropdownMenuItem(
                    value: type,
                    child: Text(_getMetricName(type)),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedMetricType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Select Date'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!isGymVisit) ...[
              TextFormField(
                controller: _valueController,
                decoration: InputDecoration(
                  labelText: 'Value (${_getValueUnit(_selectedMetricType)})',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveMetric,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isGymVisit ? 'Log Gym Visit' : 'Save Metric'),
            ),
          ],
        ),
      ),
    );
  }

  String _getMetricName(MetricType type) {
    switch (type) {
      case MetricType.weight:
        return 'Weight';
      case MetricType.bodyFatPercentage:
        return 'Body Fat Percentage';
      case MetricType.chestCircumference:
        return 'Chest Circumference';
      case MetricType.waistCircumference:
        return 'Waist Circumference';
      case MetricType.armCircumference:
        return 'Arm Circumference';
      case MetricType.legCircumference:
        return 'Leg Circumference';
      case MetricType.gymVisit:
        return 'Gym Visit';
      case MetricType.caloriesBurned:
        return 'Calories Burned';
    }
  }

  String _getValueUnit(MetricType type) {
    switch (type) {
      case MetricType.weight:
        return 'lbs';
      case MetricType.bodyFatPercentage:
        return '%';
      case MetricType.chestCircumference:
      case MetricType.waistCircumference:
      case MetricType.armCircumference:
      case MetricType.legCircumference:
        return 'inches';
      case MetricType.gymVisit:
        return '';
      case MetricType.caloriesBurned:
        return 'kcal';
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
