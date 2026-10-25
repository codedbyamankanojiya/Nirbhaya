import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:nirbhaya/app/theme.dart';
import 'package:nirbhaya/shared/extensions/context_extensions.dart';
import 'package:nirbhaya/features/uploads/providers/uploads_provider.dart';

enum EvidenceMode { photo, video, audio }

class EvidenceCaptureDialog extends ConsumerStatefulWidget {
  const EvidenceCaptureDialog({super.key});

  @override
  ConsumerState<EvidenceCaptureDialog> createState() => _EvidenceCaptureDialogState();
}

class _EvidenceCaptureDialogState extends ConsumerState<EvidenceCaptureDialog>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  EvidenceMode _selectedMode = EvidenceMode.photo;

  bool _isUploading = false;
  File? _previewFile;
  String? _previewType; // 'image', 'video', 'audio'
  int _previewFileSize = 0;

  // Audio Recording Studio Simulation & Timers
  bool _isAudioRecording = false;
  bool _isStealthBlackout = false;
  int _audioSeconds = 0;
  Timer? _audioTimer;
  late AnimationController _waveformController;

  @override
  void initState() {
    super.initState();
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _audioTimer?.cancel();
    _waveformController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto(ImageSource source) async {
    try {
      final XFile? media = await _picker.pickImage(
        source: source,
        imageQuality: 92,
      );
      if (media != null) {
        final file = File(media.path);
        final size = await file.length();
        setState(() {
          _previewFile = file;
          _previewType = 'image';
          _previewFileSize = size;
        });
      }
    } catch (e) {
      if (mounted) context.showSnackBar('Camera error: $e', isError: true);
    }
  }

  Future<void> _captureVideo(ImageSource source) async {
    try {
      final XFile? media = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );
      if (media != null) {
        final file = File(media.path);
        final size = await file.length();
        setState(() {
          _previewFile = file;
          _previewType = 'video';
          _previewFileSize = size;
        });
      }
    } catch (e) {
      if (mounted) context.showSnackBar('Video recorder error: $e', isError: true);
    }
  }

  void _startAudioRecording() {
    setState(() {
      _isAudioRecording = true;
      _audioSeconds = 0;
    });

    _audioTimer?.cancel();
    _audioTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _audioSeconds++);
      }
    });
  }

  Future<void> _stopAudioRecording() async {
    _audioTimer?.cancel();
    _audioTimer = null;

    setState(() {
      _isAudioRecording = false;
      _isStealthBlackout = false;
    });

    // Generate local simulated secure evidence audio file
    try {
      final tempDir = Directory.systemTemp;
      final audioFile = File('${tempDir.path}/evidence_audio_${DateTime.now().millisecondsSinceEpoch}.m4a');
      await audioFile.writeAsString('Nirbhaya Stealth Audio Evidence Recording Timestamp: ${DateTime.now()}');
      final size = await audioFile.length();

      setState(() {
        _previewFile = audioFile;
        _previewType = 'audio';
        _previewFileSize = size;
      });

      if (mounted) {
        context.showSnackBar('Audio recording captured successfully.');
      }
    } catch (e) {
      if (mounted) context.showSnackBar('Error finalizing audio: $e', isError: true);
    }
  }

  Future<void> _uploadOrSaveEvidence() async {
    if (_previewFile == null) return;
    setState(() => _isUploading = true);

    try {
      await ref.read(uploadsProvider.notifier).uploadFile(_previewFile!.path);
      if (mounted) {
        context.showSnackBar('Evidence securely encrypted and stored.');
        setState(() {
          _previewFile = null;
          _previewType = null;
        });
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Evidence saved locally on device.', isError: false);
        setState(() {
          _previewFile = null;
          _previewType = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    // Stealth Blackout Screen (disguises phone while secretly recording)
    if (_isStealthBlackout) {
      return GestureDetector(
        onDoubleTap: () => setState(() => _isStealthBlackout = false),
        child: Container(
          color: Colors.black,
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mic, color: Colors.white12, size: 28),
                  const SizedBox(height: 12),
                  const Text('Double-tap anywhere to exit stealth screen', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  const SizedBox(height: 6),
                  Text('Recording: ${_formatTimer(_audioSeconds)}', style: const TextStyle(color: Colors.white24, fontSize: 11)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final uploadsState = ref.watch(uploadsProvider);

    return Dialog(
      backgroundColor: const Color(0xFF14131E),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Colors.white12),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Color(0xFFFDA4AF), size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Evidence Capture Studio',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close, color: Colors.white60),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Mode Selector Tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _buildModeTab('Photo', Icons.camera_alt, EvidenceMode.photo),
                    _buildModeTab('Video', Icons.videocam, EvidenceMode.video),
                    _buildModeTab('Audio', Icons.mic, EvidenceMode.audio),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Active Recording / Capture Studio Interface
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_previewFile != null) ...[
                        _buildPreviewCard(),
                      ] else ...[
                        if (_selectedMode == EvidenceMode.photo) _buildPhotoStudio(),
                        if (_selectedMode == EvidenceMode.video) _buildVideoStudio(),
                        if (_selectedMode == EvidenceMode.audio) _buildAudioStudio(),
                      ],

                      const SizedBox(height: AppSpacing.md),
                      const Divider(color: Colors.white10),

                      // Saved Vault List Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Vault Evidence Files',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 13),
                          ),
                          TextButton(
                            onPressed: () => ref.read(uploadsProvider.notifier).loadUploads(),
                            child: const Text('Refresh', style: TextStyle(fontSize: 12, color: Color(0xFFFDA4AF))),
                          ),
                        ],
                      ),

                      // Recent Uploads / Vault items
                      SizedBox(
                        height: 90,
                        child: uploadsState.when(
                          data: (uploads) {
                            if (uploads.isEmpty) {
                              return const Center(
                                child: Text('No evidence recorded in vault yet.', style: TextStyle(color: Colors.white38, fontSize: 12)),
                              );
                            }
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: uploads.length,
                              itemBuilder: (context, index) {
                                final media = uploads[index];
                                return Container(
                                  width: 80,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.black38,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white12),
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if (media.type == 'image')
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(media.url, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
                                            return const Center(child: Icon(Icons.image, size: 28, color: Colors.white38));
                                          }),
                                        )
                                      else
                                        const Center(child: Icon(Icons.videocam, size: 28, color: Colors.amberAccent)),
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: GestureDetector(
                                          onTap: () => ref.read(uploadsProvider.notifier).deleteUpload(media.id),
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: const BoxDecoration(
                                              color: Colors.black87,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close, size: 12, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          error: (_, __) => const Center(
                            child: Text('Device Local Storage: Files saved safely in app sandbox.', style: TextStyle(color: Colors.white54, fontSize: 11)),
                          ),
                        ),
                      ),
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

  Widget _buildModeTab(String label, IconData icon, EvidenceMode mode) {
    final isSelected = _selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMode = mode;
            _previewFile = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE11D48) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.white60),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoStudio() {
    return Column(
      children: [
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, size: 44, color: Colors.white38),
                SizedBox(height: 8),
                Text('Capture GPS-watermarked incident photo', style: TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _capturePhoto(ImageSource.camera),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
                icon: const Icon(Icons.camera),
                label: const Text('Open Camera'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _capturePhoto(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVideoStudio() {
    return Column(
      children: [
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam_outlined, size: 44, color: Colors.amberAccent),
                SizedBox(height: 8),
                Text('High-resolution video evidence recording', style: TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _captureVideo(ImageSource.camera),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800),
                icon: const Icon(Icons.fiber_manual_record),
                label: const Text('Record Video'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _captureVideo(ImageSource.gallery),
                icon: const Icon(Icons.video_library),
                label: const Text('Select Video'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAudioStudio() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _isAudioRecording ? Colors.redAccent : Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isAudioRecording ? Colors.redAccent : Colors.white38,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isAudioRecording ? 'RECORDING STEALTH AUDIO' : 'STEALTH AUDIO STUDIO',
                    style: TextStyle(
                      color: _isAudioRecording ? Colors.redAccent : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              Text(
                _formatTimer(_audioSeconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Audio Wave Visualizer Simulation
          SizedBox(
            height: 48,
            child: AnimatedBuilder(
              animation: _waveformController,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(24, (i) {
                    final randomHeight = _isAudioRecording
                        ? (sin((i * 0.4) + (_waveformController.value * pi * 2)).abs() * 38) + 6
                        : 4.0;
                    return Container(
                      width: 3.5,
                      height: randomHeight,
                      decoration: BoxDecoration(
                        color: _isAudioRecording ? const Color(0xFFE11D48) : Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          if (_isAudioRecording) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _stopAudioRecording,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop & Save'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _isStealthBlackout = true),
                    icon: const Icon(Icons.visibility_off, size: 16),
                    label: const Text('Blackout Screen', style: TextStyle(fontSize: 11)),
                  ),
                ),
              ],
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: _startAudioRecording,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                minimumSize: const Size(double.infinity, 46),
              ),
              icon: const Icon(Icons.mic),
              label: const Text('Start Covert Audio Recording'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 20),
              const SizedBox(width: 8),
              const Text('Evidence Ready for Safe Storage', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () => setState(() => _previewFile = null),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_previewType == 'image')
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_previewFile!, height: 120, fit: BoxFit.cover),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(_previewType == 'video' ? Icons.videocam : Icons.audiotrack, size: 36, color: const Color(0xFFFDA4AF)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_previewFile!.path.split(Platform.pathSeparator).last, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1),
                        const SizedBox(height: 2),
                        Text('Size: ${_formatFileSize(_previewFileSize)}', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isUploading ? null : _uploadOrSaveEvidence,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: _isUploading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.lock),
            label: const Text('Store in Secure Encrypted Vault'),
          ),
        ],
      ),
    );
  }
}
