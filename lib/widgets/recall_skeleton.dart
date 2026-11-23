import 'package:flutter/material.dart';

class RecallSkeletonList extends StatelessWidget {
  const RecallSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surfaceContainerHighest;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _SkeletonBox(width: 112, height: 26, color: surface),
                    const Spacer(),
                    _SkeletonBox(width: 72, height: 16, color: surface),
                  ],
                ),
                const SizedBox(height: 14),
                _SkeletonBox(width: double.infinity, height: 20, color: surface),
                const SizedBox(height: 8),
                _SkeletonBox(width: 160, height: 16, color: surface),
                const SizedBox(height: 14),
                _SkeletonBox(width: double.infinity, height: 34, color: surface),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
