import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// 贡献声明对话框
class DisclaimerDialog extends StatefulWidget {
  const DisclaimerDialog({super.key});

  @override
  State<DisclaimerDialog> createState() => _DisclaimerDialogState();

  /// 检查是否需要显示声明对话框
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('disclaimer_accepted') ?? false);
  }

  /// 标记声明已被接受
  static Future<void> markAsAccepted({bool dontShowAgain = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('disclaimer_accepted', dontShowAgain);
  }

  /// 显示声明对话框
  static Future<void> showIfNeeded(BuildContext context) async {
    if (await shouldShow()) {
      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false, // 不允许点击外部关闭
          builder: (context) => const DisclaimerDialog(),
        );
      }
    }
  }
}

class _DisclaimerDialogState extends State<DisclaimerDialog> {
  bool _dontShowAgain = false;

  /// 打开GitHub链接
  Future<void> _openGitHubLink() async {
    final uri = Uri.parse('https://github.com/Samueli924/chaoxing');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法打开链接，请手动访问')),
        );
      }
    }
  }

  /// 构建富文本内容
  Widget _buildContent() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 15,
          height: 1.6,
          color: Colors.black87,
        ),
        children: [
          const TextSpan(
            text: '该项目实现逻辑借鉴于：',
          ),
          TextSpan(
            text: 'https://github.com/Samueli924/chaoxing',
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = _openGitHubLink,
          ),
          const TextSpan(
            text: ' 项目，感谢该项目各个贡献者的付出。\n\n',
          ),
          const TextSpan(
            text: '本项目完全免费，绝无存在收费情况。',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const TextSpan(
            text: '本项目提供了一个全平台的操作GUI界面，方便使用者直接使用，由于是重写实现，因此与原项目在代码层面完全不同。',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            '贡献声明',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 主要内容
            _buildContent(),
            const SizedBox(height: 20),
            
            // 分隔线
            const Divider(),
            
            // "不再显示"复选框
            CheckboxListTile(
              value: _dontShowAgain,
              onChanged: (value) {
                setState(() {
                  _dontShowAgain = value ?? false;
                });
              },
              title: const Text(
                '不再显示此声明',
                style: TextStyle(fontSize: 14),
              ),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
      actions: [
        // 查看原项目按钮
        TextButton.icon(
          onPressed: _openGitHubLink,
          icon: const Icon(Icons.open_in_new, size: 18),
          label: const Text('查看原项目'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[700],
          ),
        ),
        const Spacer(),
        
        // 确认按钮
        ElevatedButton(
          onPressed: () async {
            await DisclaimerDialog.markAsAccepted(dontShowAgain: _dontShowAgain);
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text(
            '我已知晓',
            style: TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }
}
