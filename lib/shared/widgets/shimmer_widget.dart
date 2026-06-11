import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class CapsuleCardShimmer extends StatelessWidget {
  const CapsuleCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ShimmerLoading(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const ShimmerLoading(width: 60, height: 24, borderRadius: 12),
                ],
              ),
              const SizedBox(height: 12),
              const ShimmerLoading(height: 14),
              const SizedBox(height: 8),
              ShimmerLoading(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 14,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const ShimmerLoading(width: 14, height: 14, borderRadius: 7),
                  const SizedBox(width: 4),
                  const ShimmerLoading(width: 80, height: 12),
                  const Spacer(),
                  const ShimmerLoading(width: 14, height: 14, borderRadius: 7),
                  const SizedBox(width: 4),
                  const ShimmerLoading(width: 20, height: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
