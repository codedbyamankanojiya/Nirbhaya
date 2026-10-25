import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nirbhaya/app/theme.dart';
import 'package:nirbhaya/shared/extensions/context_extensions.dart';
import 'package:nirbhaya/shared/widgets/app_header.dart';
import 'package:nirbhaya/features/ai_assistant/providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickActions = [
    'I feel unsafe',
    'Need legal help',
    'Report incident',
    'Emergency contacts',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? text]) {
    final messageText = text ?? _controller.text.trim();
    if (messageText.isEmpty) return;

    _controller.clear();
    ref.read(chatProvider.notifier).sendMessage(messageText);
    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleAction(String route) async {
    if (route.startsWith('tel:')) {
      final url = Uri.parse(route);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } else if (route == 'sos') {
      // Trigger SOS feature or navigate
      context.showSnackBar('SOS Triggered (Simulated)');
    } else {
      context.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider);

    // Auto-scroll when new messages arrive
    ref.listen(chatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'AI Safety Assistant',
              extraActions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.read(chatProvider.notifier).clearChat(),
                  tooltip: 'Clear Chat',
                ),
              ],
            ),
            
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: state.messages.length + (state.isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.messages.length) {
                    return _buildTypingIndicator(context);
                  }
                  return _buildMessageBubble(context, state.messages[index]);
                },
              ),
            ),

            _buildQuickActions(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: context.colorScheme.primary.withValues(alpha: 0.2),
              radius: 16,
              child: Icon(Icons.auto_awesome, size: 16, color: context.colorScheme.primary),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isUser ? context.colorScheme.primary : const Color(0xFF18181B),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppRadius.base),
                      topRight: const Radius.circular(AppRadius.base),
                      bottomLeft: Radius.circular(isUser ? AppRadius.base : 0),
                      bottomRight: Radius.circular(isUser ? 0 : AppRadius.base),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.black87 : Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
                
                if (message.actionLabel != null && message.actionRoute != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  ActionChip(
                    label: Text(message.actionLabel!),
                    backgroundColor: context.colorScheme.primary.withValues(alpha: 0.1),
                    side: BorderSide(color: context.colorScheme.primary),
                    onPressed: () => _handleAction(message.actionRoute!),
                  ),
                ],
              ],
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: AppSpacing.sm),
            CircleAvatar(
              backgroundColor: Colors.white12,
              radius: 16,
              child: const Icon(Icons.person, size: 16, color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: context.colorScheme.primary.withValues(alpha: 0.2),
            radius: 16,
            child: Icon(Icons.auto_awesome, size: 16, color: context.colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: const BoxDecoration(
              color: Color(0xFF18181B),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.base),
                topRight: Radius.circular(AppRadius.base),
                bottomRight: Radius.circular(AppRadius.base),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Typing...', style: TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: _quickActions.map((action) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm, bottom: AppSpacing.sm),
            child: ActionChip(
              label: Text(action, style: const TextStyle(fontSize: 13)),
              backgroundColor: const Color(0xFF18181B),
              side: BorderSide(color: Colors.white24),
              onPressed: () => _sendMessage(action),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: const BoxDecoration(
        color: Color(0xFF18181B),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.black26,
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              ),
              onSubmitted: (_) => _sendMessage(),
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: context.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.black87),
              onPressed: () => _sendMessage(),
            ),
          ),
        ],
      ),
    );
  }
}
