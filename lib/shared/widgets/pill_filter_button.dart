import 'package:flutter/material.dart';

class PillFilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const PillFilterButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white.withAlpha(20) : Colors.transparent)
              : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
          border: Border.all(
            color: isSelected
                ? (isDark ? Colors.white.withAlpha(40) : const Color(0xFFE0E0E0))
                : Colors.transparent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(100),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? (isDark ? Colors.white : Colors.black)
                : (isDark ? Colors.grey.shade400 : const Color(0xFF888888)),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
