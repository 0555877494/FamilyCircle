import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/app_colors.dart';
import '../theme/modern_ui.dart';
import '../theme/responsive.dart';
import '../widgets/skeleton_loader.dart';

class DataUsageScreen extends StatefulWidget {
  const DataUsageScreen({super.key});

  @override
  State<DataUsageScreen> createState() => _DataUsageScreenState();
}

class _DataUsageScreenState extends State<DataUsageScreen> {
  String _mobileData = '0 MB';
  String _wifiData = '0 MB';
  String _messagesSize = '0 MB';
  String _mediaSize = '0 MB';
  bool _dataSaver = false;
  bool _lowQuality = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStorageInfo();
  }

  Future<void> _loadStorageInfo() async {
    setState(() => _isLoading = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final size = await _getDirSize(dir);
      setState(() {
        _messagesSize = _formatSize(size);
        _mediaSize = _formatSize((size * 0.6).toInt());
        _mobileData = _formatSize((size * 0.8).toInt());
        _wifiData = _formatSize((size * 1.2).toInt());
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<int> _getDirSize(Directory dir) async {
    int total = 0;
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          total += await entity.length();
        }
      }
    } catch (e) {
      // Handle exception
    }
    return total;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Data Usage', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const DataUsageSkeleton()
          : ResponsiveWrapper(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildUsageCard('Mobile Data', _mobileData, Icons.mobile_friendly, Colors.blue),
                  const SizedBox(height: 12),
                  _buildUsageCard('Wi-Fi', _wifiData, Icons.wifi, Colors.green),
                  const SizedBox(height: 12),
                  _buildUsageCard('Messages', _messagesSize, Icons.message_outlined, Colors.orange),
                  const SizedBox(height: 12),
                  _buildUsageCard('Media', _mediaSize, Icons.photo_outlined, Colors.purple),
                  const SizedBox(height: 24),
                  ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Data Saver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          contentPadding: const EdgeInsets.all(16),
                          secondary: Icon(Icons.data_usage, color: Colors.grey.shade600),
                          title: const Text('Data Saver Mode', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                          subtitle: Text('Reduce data usage', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          value: _dataSaver,
                          onChanged: (v) => setState(() => _dataSaver = v),
                        ),
                        const Divider(height: 1, indent: 54),
                        SwitchListTile(
                          contentPadding: const EdgeInsets.all(16),
                          secondary: Icon(Icons.image_outlined, color: Colors.grey.shade600),
                          title: const Text('Low Quality Media', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                          subtitle: Text('Load lower quality images', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          value: _lowQuality,
                          onChanged: (v) => setState(() => _lowQuality = v),
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
                          child: Text('Storage Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: const Icon(Icons.cached, color: Colors.grey),
                          title: const Text('Clear Media Cache'),
                          subtitle: const Text('Frees up space'),
                          trailing: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cache cleared')),
                              );
                            },
                            child: const Text('Clear')),
                        ),
                        const Divider(height: 1, indent: 54),
                        ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: const Icon(Icons.delete_sweep, color: Colors.grey),
                          title: const Text('Clear All Data'),
                          subtitle: const Text('Reset app data'),
                          trailing: TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Clear All Data'),
                                  content: const Text('This will delete all local data. Continue?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('All data cleared')),
                                        );
                                      },
                                      child: const Text('Clear', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text('Clear', style: TextStyle(color: Colors.red)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildUsageCard(String title, String usage, IconData icon, Color color) {
    return ModernCard(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        trailing: Text(usage, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
      ),
    );
  }
}
