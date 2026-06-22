import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime targetDate;
  final bool compact;

  const CountdownTimer({
    super.key,
    required this.targetDate,
    this.compact = false,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late Duration _timeRemaining;

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.targetDate.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _timeRemaining = widget.targetDate.difference(DateTime.now());
        if (_timeRemaining.isNegative) {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeRemaining.isNegative) {
      return widget.compact
          ? const Text(
              'Desbloqueada',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            )
          : _buildCountdownCard(
              context,
              days: 0,
              hours: 0,
              minutes: 0,
              seconds: 0,
              unlocked: true,
            );
    }

    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;

    if (widget.compact) {
      return Text(
        _formatCompact(days, hours, minutes),
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      );
    }

    return _buildCountdownCard(
      context,
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      unlocked: false,
    );
  }

  Widget _buildCountdownCard(
    BuildContext context, {
    required int days,
    required int hours,
    required int minutes,
    required int seconds,
    required bool unlocked,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  unlocked ? Icons.lock_open : Icons.timer_outlined,
                  color: unlocked ? Colors.green : Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  unlocked ? 'Cápsula Desbloqueada' : 'Tiempo Restante',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!unlocked)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTimeUnit(context, days, 'Días'),
                  _buildSeparator(context),
                  _buildTimeUnit(context, hours, 'Horas'),
                  _buildSeparator(context),
                  _buildTimeUnit(context, minutes, 'Min'),
                  _buildSeparator(context),
                  _buildTimeUnit(context, seconds, 'Seg'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeUnit(BuildContext context, int value, String label) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              value.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }

  Widget _buildSeparator(BuildContext context) {
    return Text(
      ':',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade400,
      ),
    );
  }

  String _formatCompact(int days, int hours, int minutes) {
    if (days > 0) return '$days días';
    if (hours > 0) return '$hours hrs';
    return '$minutes min';
  }
}
