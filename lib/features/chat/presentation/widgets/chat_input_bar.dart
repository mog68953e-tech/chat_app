import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../cubit/chat_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';

/// Bottom input bar with text, emoji, attach (image), and voice recording
class ChatInputBar extends StatefulWidget {
  final Future<void> Function(String) onSendText;
  final Future<void> Function() onSendImage;
  final Future<void> Function(bool) onTypingChanged;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final ChatCubit chatCubit;

  const ChatInputBar({
    super.key,
    required this.onSendText,
    required this.onSendImage,
    required this.onTypingChanged,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.chatCubit,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _textController = TextEditingController();
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  String? _recordingPath;
  bool _hasSomethingToSend = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final hasText = _textController.text.trim().isNotEmpty;
      if (hasText != _hasSomethingToSend) {
        setState(() => _hasSomethingToSend = hasText);
        widget.onTypingChanged(hasText);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _recorder.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    setState(() => _hasSomethingToSend = false);
    await widget.onSendText(text);
    widget.onTypingChanged(false);
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) return;
      AppSnackbar.show(context, 'Microphone permission denied', isError: true);
      return;
    }
    final dir = await getTemporaryDirectory();
    _recordingPath =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 64000),
      path: _recordingPath!,
    );
    setState(() {
      _isRecording = true;
      _recordingDuration = 0;
    });
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordingDuration++);
    });
  }

  Future<void> _stopAndSendRecording() async {
    _recordingTimer?.cancel();
    await _recorder.stop();
    setState(() => _isRecording = false);
    if (_recordingPath != null && _recordingDuration > 0) {
      final file = File(_recordingPath!);
      if (await file.exists()) {
        await widget.chatCubit.sendVoiceMessage(
          conversationId: widget.conversationId,
          senderId: widget.senderId,
          receiverId: widget.receiverId,
          voiceFile: file,
          durationSeconds: _recordingDuration,
        );
      }
    }
    _recordingDuration = 0;
  }

  Future<void> _cancelRecording() async {
    _recordingTimer?.cancel();
    await _recorder.cancel();
    setState(() {
      _isRecording = false;
      _recordingDuration = 0;
    });
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SafeArea(
        top: false,
        child: _isRecording ? _buildRecordingBar() : _buildInputBar(),
      ),
    );
  }

  Widget _buildInputBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Attach button ─────────────────────────────
        IconButton(
          onPressed: widget.onSendImage,
          icon: const Icon(Icons.attach_file_rounded),
          color: AppColors.textSecondary,
        ),

        // ── Text field ────────────────────────────────
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 120),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: 'Message...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // ── Send / Voice button ───────────────────────
        _hasSomethingToSend
            ? FloatingActionButton.small(
                onPressed: _handleSend,
                backgroundColor: AppColors.primary,
                elevation: 0,
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ).animate().scale(duration: 150.ms)
            : GestureDetector(
                onLongPressStart: (_) => _startRecording(),
                onLongPressEnd: (_) => _stopAndSendRecording(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
      ],
    );
  }

  Widget _buildRecordingBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 500.ms),
          const SizedBox(width: 8),
          Text(
            _formatDuration(_recordingDuration),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _cancelRecording,
            child: const Text('Cancel',
                style: TextStyle(color: Colors.red)),
          ),
          GestureDetector(
            onTap: _stopAndSendRecording,
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
