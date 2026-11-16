import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme.dart';

/// Memutar video dari asset di dalam aplikasi (offline).
class VideoBox extends StatefulWidget {
  final String path;
  final bool loop;
  final bool muted;
  final double aspectRatio;
  final VoidCallback? onCompleted;

  const VideoBox({
    super.key,
    required this.path,
    this.loop = false,
    this.muted = false,
    this.aspectRatio = 16 / 9,
    this.onCompleted,
  });

  @override
  State<VideoBox> createState() => _VideoBoxState();
}

class _VideoBoxState extends State<VideoBox> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.path);
    _controller.addListener(_onTick);
    _controller.initialize().then((_) {
      if (!mounted) return;
      _controller.setLooping(widget.loop);
      if (widget.muted) _controller.setVolume(0);
      _controller.play();
      setState(() => _ready = true);
    }).catchError((_) {
      if (mounted) widget.onCompleted?.call();
    });
  }

  void _onTick() {
    final v = _controller.value;
    if (!widget.loop &&
        !_completed &&
        v.isInitialized &&
        v.duration > Duration.zero &&
        v.position >= v.duration) {
      _completed = true;
      widget.onCompleted?.call();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: ColoredBox(
        color: MarsColors.card,
        child: _ready
            ? VideoPlayer(_controller)
            : const Center(
                child: Icon(Icons.play_circle_fill,
                    color: MarsColors.accent, size: 56),
              ),
      ),
    );
  }
}
