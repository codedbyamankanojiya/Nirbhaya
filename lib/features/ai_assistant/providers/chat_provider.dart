import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirbhaya/features/ai_assistant/data/gemini_service.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? actionLabel;
  final String? actionRoute;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.actionLabel,
    this.actionRoute,
  });
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;

  ChatState({
    this.messages = const [],
    this.isTyping = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref.watch(geminiServiceProvider));
});

class ChatNotifier extends StateNotifier<ChatState> {
  final GeminiService _geminiService;

  ChatNotifier(this._geminiService) : super(ChatState()) {
    _initWelcomeMessage();
  }

  void _initWelcomeMessage() {
    state = state.copyWith(
      messages: [
        ChatMessage(
          id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
          text:
              "Hi! I am Nirbhaya AI, your 24/7 personal safety assistant. I can provide real-time guidance on emergency protocols, legal rights in India (Zero FIR, Domestic Violence Act, POSH), self-defense, and crisis reporting.\n\nHow can I support your safety today?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  void clearChat() {
    state = ChatState();
    _initWelcomeMessage();
  }

  Future<void> sendMessage(String text) async {
    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    ChatMessage aiMsg;

    try {
      // 1. Try real live Google Gemini API
      final geminiResponse = await _geminiService.generateAiResponse(text);
      if (geminiResponse != null && geminiResponse.isNotEmpty) {
        aiMsg = ChatMessage(
          id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
          text: geminiResponse,
          isUser: false,
          timestamp: DateTime.now(),
          actionLabel: _extractActionLabel(text),
          actionRoute: _extractActionRoute(text),
        );
      } else {
        // 2. Comprehensive offline safety knowledge engine
        aiMsg = _generateOfflineSafetyResponse(text);
      }
    } catch (_) {
      aiMsg = _generateOfflineSafetyResponse(text);
    }

    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      isTyping: false,
    );
  }

  String? _extractActionLabel(String query) {
    final q = query.toLowerCase();
    if (q.contains('danger') || q.contains('help') || q.contains('unsafe') || q.contains('attack')) {
      return 'Call 112';
    }
    if (q.contains('report') || q.contains('police') || q.contains('complaint')) {
      return 'Report Incident';
    }
    if (q.contains('fake call') || q.contains('escape') || q.contains('uncomfortable')) {
      return 'Fake Call';
    }
    return null;
  }

  String? _extractActionRoute(String query) {
    final q = query.toLowerCase();
    if (q.contains('danger') || q.contains('help') || q.contains('unsafe') || q.contains('attack')) {
      return 'tel:112';
    }
    if (q.contains('report') || q.contains('police') || q.contains('complaint')) {
      return '/incidents';
    }
    if (q.contains('fake call') || q.contains('escape') || q.contains('uncomfortable')) {
      return '/fake-call';
    }
    return null;
  }

  ChatMessage _generateOfflineSafetyResponse(String query) {
    final q = query.toLowerCase();
    String text;
    String? actionLabel;
    String? actionRoute;

    if (q.contains('unsafe') ||
        q.contains('danger') ||
        q.contains('scared') ||
        q.contains('help') ||
        q.contains('attack') ||
        q.contains('emergency')) {
      text =
          "🚨 IMMEDIATE SAFETY ALERT:\n"
          "1. If you are in immediate danger, dial 112 or press the SOS button immediately.\n"
          "2. Head directly toward a well-lit public area, open business, or police beat.\n"
          "3. Use the 'Fake Call' feature from the bottom bar to disincentivize harassment.\n"
          "4. Keep your phone in hand and broadcast your live location.";
      actionLabel = 'Call 112';
      actionRoute = 'tel:112';
    } else if (q.contains('zero fir') || q.contains('fir')) {
      text =
          "📜 ZERO FIR PROTOCOL IN INDIA:\n"
          "Under Indian law, a 'Zero FIR' can be registered at ANY police station irrespective of jurisdictional boundaries.\n"
          "• Police cannot refuse registration under Section 166A of IPC / Bharatiya Nyaya Sanhita.\n"
          "• Once registered, the station transfers the case to the competent jurisdiction.\n"
          "• You have the right to receive a free signed copy of the FIR on the spot.";
      actionLabel = 'Report Incident';
      actionRoute = '/incidents';
    } else if (q.contains('domestic') || q.contains('abuse') || q.contains('violence') || q.contains('husband') || q.contains('in laws')) {
      text =
          "🛡️ DOMESTIC VIOLENCE PROTECTION:\n"
          "Under the Protection of Women from Domestic Violence Act (PWDVA) 2005 & Section 498A IPC:\n"
          "• You can seek immediate Protection Orders, Residence Orders, and monetary relief.\n"
          "• Call National Helpline 181 for 24/7 domestic crisis intervention and shelter linkage.\n"
          "• Contact the National Commission for Women (NCW) at 7827170170.";
      actionLabel = 'Call 181';
      actionRoute = 'tel:181';
    } else if (q.contains('stalk') || q.contains('following') || q.contains('chasing')) {
      text =
          "⚠️ ANTI-STALKING SAFETY STEPS:\n"
          "Stalking is a punishable offense under Section 354D of IPC / BNS.\n"
          "1. Do not head straight home if someone is following you. Enter a crowded public place (cafe, metro station, store).\n"
          "2. Alert store staff or security immediately.\n"
          "3. Turn on Live Journey Tracking in Nirbhaya to record your GPS trail.\n"
          "4. Call police at 100 / 112.";
      actionLabel = 'Open Map';
      actionRoute = '/map';
    } else if (q.contains('workplace') || q.contains('posh') || q.contains('office') || q.contains('boss')) {
      text =
          "⚖️ POSH ACT (Prevention of Sexual Harassment):\n"
          "The POSH Act 2013 mandates every workplace with 10+ employees to have an Internal Complaints Committee (ICC).\n"
          "• You can file a written complaint within 3 months of the incident.\n"
          "• The inquiry must conclude within 90 days.\n"
          "• You have the right to conciliation or interim relief (leave/transfer).";
      actionLabel = 'Safety Resources';
      actionRoute = '/resources';
    } else if (q.contains('cyber') || q.contains('blackmail') || q.contains('photo') || q.contains('nude') || q.contains('hacked')) {
      text =
          "🔒 CYBER HARASSMENT & BLACKMAIL:\n"
          "1. Do NOT delete screenshots, messages, or profile links — save them as evidence.\n"
          "2. Immediately report to the National Cyber Crime Helpline at 1930.\n"
          "3. File a formal complaint online at cybercrime.gov.in (under 'Report Women/Child Crime' with anonymous reporting option).\n"
          "4. Never yield to financial demands.";
      actionLabel = 'Call 1930';
      actionRoute = 'tel:1930';
    } else if (q.contains('self defense') || q.contains('pepper spray') || q.contains('weapon')) {
      text =
          "🥋 SELF-DEFENSE PRACTICES:\n"
          "• Section 96-106 IPC confers the legal Right of Private Defense against bodily harm.\n"
          "• Carrying pepper spray for self-defense is legal in India.\n"
          "• Target vulnerability points: eyes, nose bridge, throat, groin, and shins.\n"
          "• Scream loudly with assertive commands: 'BACK OFF!', 'FIRE!', or 'POLICE!' to attract public attention.";
      actionLabel = 'Safety Tips';
      actionRoute = '/resources';
    } else {
      text =
          "I can guide you on:\n"
          "• 🚨 Emergency numbers & SOS instructions\n"
          "• 📜 Zero FIR, BNS/IPC legal rights & free legal aid\n"
          "• 💻 Cyber harassment, blackmail, and reporting to 1930\n"
          "• 🛡️ Anti-stalking, de-escalation, and self-defense tips\n"
          "• 🏢 Workplace harassment (POSH Act) & domestic abuse (181)\n\n"
          "(Note: To enable live Gemini conversational AI, add your Gemini API key in Settings).";
    }

    return ChatMessage(
      id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      actionLabel: actionLabel,
      actionRoute: actionRoute,
    );
  }
}
