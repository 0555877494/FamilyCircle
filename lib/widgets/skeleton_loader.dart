import 'package:flutter/material.dart';
import '../theme/modern_ui.dart';

class SkeletonLoader extends StatefulWidget {
  final double height;
  final double width;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.height = 20,
    this.width = double.infinity,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: _animation.value),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

class SettingsSkeleton extends StatelessWidget {
  const SettingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(
        6,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonLoader(height: 24, width: 120),
              const SizedBox(height: 12),
              ...List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const SkeletonLoader(height: 40, width: 40, borderRadius: 12),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SkeletonLoader(height: 16, width: 150),
                            SizedBox(height: 4),
                            SkeletonLoader(height: 12, width: 100),
                          ],
                        ),
                      ),
                      const SkeletonLoader(height: 24, width: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ModernCard(
          child: Column(
            children: [
              const SizedBox(height: 24),
              const SkeletonLoader(height: 100, width: 100, borderRadius: 50),
              const SizedBox(height: 16),
              const SkeletonLoader(height: 24, width: 200),
              const SizedBox(height: 8),
              const SkeletonLoader(height: 16, width: 100),
              const SizedBox(height: 24),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ModernCard(
          child: Column(
            children: List.generate(
              2,
              (i) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const SkeletonLoader(height: 22, width: 22, borderRadius: 4),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              SkeletonLoader(height: 16, width: 100),
                              SizedBox(height: 4),
                              SkeletonLoader(height: 14, width: 200),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < 1) const Divider(height: 1, indent: 54),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: SkeletonLoader(height: 18, width: 160),
              ),
              const Divider(height: 1),
              ...List.generate(
                4,
                (i) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const SkeletonLoader(height: 22, width: 22, borderRadius: 4),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                SkeletonLoader(height: 12, width: 80),
                                SizedBox(height: 4),
                                SkeletonLoader(height: 14, width: 120),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < 3) const Divider(height: 1, indent: 54),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MemberListSkeleton extends StatelessWidget {
  const MemberListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ModernCard(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const SkeletonLoader(height: 40, width: 40, borderRadius: 20),
            title: const SkeletonLoader(height: 16, width: 150),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 6),
                SkeletonLoader(height: 12, width: 100),
                SizedBox(height: 4),
                SkeletonLoader(height: 12, width: 80),
              ],
            ),
            trailing: const SkeletonLoader(height: 24, width: 24),
          ),
        ),
      ),
    );
  }
}

class DataUsageSkeleton extends StatelessWidget {
  const DataUsageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...List.generate(
          4,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ModernCard(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const SkeletonLoader(height: 44, width: 44, borderRadius: 12),
                title: const SkeletonLoader(height: 16, width: 120),
                trailing: const SkeletonLoader(height: 20, width: 80),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: SkeletonLoader(height: 18, width: 140),
              ),
              const Divider(height: 1),
              ...List.generate(
                2,
                (i) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const SkeletonLoader(height: 22, width: 22, borderRadius: 4),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                SkeletonLoader(height: 15, width: 140),
                                SizedBox(height: 4),
                                SkeletonLoader(height: 12, width: 180),
                              ],
                            ),
                          ),
                          const SkeletonLoader(height: 24, width: 50),
                        ],
                      ),
                    ),
                    if (i < 1) const Divider(height: 1, indent: 54),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: SkeletonLoader(height: 18, width: 160),
              ),
              const Divider(height: 1),
              ...List.generate(
                2,
                (i) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const SkeletonLoader(height: 22, width: 22, borderRadius: 4),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                SkeletonLoader(height: 15, width: 130),
                                SizedBox(height: 4),
                                SkeletonLoader(height: 12, width: 100),
                              ],
                            ),
                          ),
                          const SkeletonLoader(height: 32, width: 60, borderRadius: 4),
                        ],
                      ),
                    ),
                    if (i < 1) const Divider(height: 1, indent: 54),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChatSkeleton extends StatelessWidget {
  const ChatSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        final isMe = index % 3 == 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe) ...[
                const SkeletonLoader(height: 32, width: 32, borderRadius: 16),
                const SizedBox(width: 8),
              ],
              Container(
                constraints: const BoxConstraints(maxWidth: 250),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (!isMe) const SkeletonLoader(height: 10, width: 60),
                    const SizedBox(height: 4),
                    SkeletonLoader(
                      height: 40,
                      width: isMe ? 180 : 220,
                      borderRadius: 16,
                    ),
                  ],
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 8),
                const SkeletonLoader(height: 32, width: 32, borderRadius: 16),
              ],
            ],
          ),
        );
      },
    );
  }
}

class ProjectListSkeleton extends StatelessWidget {
  const ProjectListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ModernCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SkeletonLoader(height: 16, width: 80),
                    const Spacer(),
                    const SkeletonLoader(height: 20, width: 60, borderRadius: 10),
                  ],
                ),
                const SizedBox(height: 12),
                const SkeletonLoader(height: 20, width: 200),
                const SizedBox(height: 8),
                const SkeletonLoader(height: 14, width: double.infinity),
                const SizedBox(height: 4),
                const SkeletonLoader(height: 14, width: 250),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    SkeletonLoader(height: 8, width: 60),
                    SizedBox(width: 8),
                    SkeletonLoader(height: 8, width: 60),
                    SizedBox(width: 8),
                    SkeletonLoader(height: 8, width: 60),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const SkeletonLoader(height: 32, width: 32, borderRadius: 16),
                    const SizedBox(width: 8),
                    const SkeletonLoader(height: 32, width: 32, borderRadius: 16),
                    const SizedBox(width: 8),
                    const SkeletonLoader(height: 32, width: 32, borderRadius: 16),
                    const Spacer(),
                    const SkeletonLoader(height: 36, width: 100, borderRadius: 4),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProjectDetailSkeleton extends StatelessWidget {
  const ProjectDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ModernCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SkeletonLoader(height: 20, width: 100),
                    const Spacer(),
                    const SkeletonLoader(height: 24, width: 80, borderRadius: 12),
                  ],
                ),
                const SizedBox(height: 12),
                const SkeletonLoader(height: 24, width: 250),
                const SizedBox(height: 8),
                const SkeletonLoader(height: 16, width: double.infinity),
                const SizedBox(height: 4),
                const SkeletonLoader(height: 16, width: 300),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: SkeletonLoader(height: 18, width: 100),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const SkeletonLoader(height: 36, width: 36, borderRadius: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SkeletonLoader(height: 16, width: 180),
                          SizedBox(height: 4),
                          SkeletonLoader(height: 12, width: 100),
                        ],
                      ),
                    ),
                    const SkeletonLoader(height: 20, width: 20),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const SkeletonLoader(height: 36, width: 36, borderRadius: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SkeletonLoader(height: 16, width: 150),
                          SizedBox(height: 4),
                          SkeletonLoader(height: 12, width: 120),
                        ],
                      ),
                    ),
                    const SkeletonLoader(height: 20, width: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
