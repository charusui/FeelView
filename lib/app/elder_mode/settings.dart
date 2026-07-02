import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feelview/services/tts_service.dart';
import 'package:feelview/widgets/accessible_button.dart';
import 'package:feelview/widgets/accessible_text.dart';
import 'package:feelview/models/models.dart';
import 'package:feelview/services/firestore_service.dart';
import 'package:feelview/app/router.dart';
import 'package:feelview/providers/app_providers.dart';

class ElderSettings extends ConsumerStatefulWidget {
  const ElderSettings({super.key});

  @override
  ConsumerState<ElderSettings> createState() => _ElderSettingsState();
}

class _ElderSettingsState extends ConsumerState<ElderSettings> {
  double _volume = 1.0;

  @override
  Widget build(BuildContext context) {
    final textScale = ref.watch(textScaleProvider);
    final isSimplified = ref.watch(simplifyFurtherProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        children: [
          const ElderHeading('Adjust App Size & Sound'),
          const SizedBox(height: 24),
          const ElderBody('Text Size'),
          Slider(
            value: textScale,
            min: 0.8,
            max: 2.0,
            divisions: 6,
            label: '${(textScale * 100).round()}%',
            onChanged: (val) {
              ref.read(textScaleProvider.notifier).state = val;
            },
          ),
          const SizedBox(height: 24),
          const ElderBody('Voice Volume'),
          Slider(
            value: _volume,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: '${(_volume * 100).round()}%',
            onChanged: (val) {
              setState(() => _volume = val);
              TtsService.setVolume(val);
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const ElderBody('Natural / Piper Voice'),
            subtitle: const ElderCaption('High-definition human neural voice'),
            value: TtsService.useNeuralCloudVoice,
            onChanged: (val) {
              setState(() {
                TtsService.useNeuralCloudVoice = val;
              });
              if (val) {
                TtsService.speak('Natural voice streaming enabled');
              } else {
                TtsService.speak('Standard voice enabled');
              }
            },
          ),
          const SizedBox(height: 32),
          AccessibleButton(
            onPressed: () async {
              final elder = ref.read(activeProfileProvider);
              final members = ref.read(familyMembersProvider).value ?? [];
              if (elder == null) return;
              
              final admin = members.where((m) => m.role == UserRole.admin && m.id != elder.id).firstOrNull ??
                            members.where((m) => m.id != elder.id).firstOrNull;
              if (admin == null) return;

              final thread = await FirestoreService.getOrCreateDirectThread(
                elder.familyId,
                elder.id,
                admin.id,
              );
              if (thread != null && context.mounted) {
                Navigator.pushNamed(
                  context,
                  AppRouter.elderChatConversation,
                  arguments: thread,
                );
              }
            },
            label: 'Contact Family Admin',
            icon: Icons.chat_bubble_rounded,
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const ElderBody('Simplify Further'),
            subtitle: const ElderCaption('Extra text magnification for easier reading'),
            value: isSimplified,
            onChanged: (val) {
              ref.read(simplifyFurtherProvider.notifier).state = val;
            },
          ),
        ],
      ),
    );
  }
}
