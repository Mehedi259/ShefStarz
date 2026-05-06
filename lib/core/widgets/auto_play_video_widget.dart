import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AutoPlayVideoWidget extends StatefulWidget {
  final String videoUrl;
  final double height;
  final VoidCallback? onTap;

  const AutoPlayVideoWidget({
    super.key,
    required this.videoUrl,
    this.height = 250,
    this.onTap,
  });

  @override
  State<AutoPlayVideoWidget> createState() => _AutoPlayVideoWidgetState();
}

class _AutoPlayVideoWidgetState extends State<AutoPlayVideoWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        // Auto play if visible
        if (_isVisible) {
          _controller!.play();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!mounted || _controller == null || !_isInitialized) return;

    final isVisible = info.visibleFraction > 0.5; // 50% visible

    setState(() {
      _isVisible = isVisible;
    });

    if (isVisible) {
      // Play when visible
      if (!_controller!.value.isPlaying) {
        _controller!.play();
      }
    } else {
      // Pause when not visible
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('video_${widget.videoUrl}'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: widget.height,
          width: double.infinity,
          color: Colors.black87,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Video Player - Cover the entire container like images
              if (_isInitialized && !_hasError)
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                ),

              // Loading Indicator
              if (!_isInitialized && !_hasError)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.orange,
                  ),
                ),

              // Error State
              if (_hasError)
                const Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),

              // Play/Pause Overlay (only show when paused)
              if (_isInitialized && !_hasError)
                ValueListenableBuilder(
                  valueListenable: _controller!,
                  builder: (context, VideoPlayerValue value, child) {
                    if (!value.isPlaying && value.position == Duration.zero) {
                      // Show play icon only at start
                      return const Icon(
                        Icons.play_circle_fill,
                        color: Colors.white70,
                        size: 60,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

              // Mute indicator (small icon at top right)
              if (_isInitialized && !_hasError)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.volume_off,
                      color: Colors.white,
                      size: 16,
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
