import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../../../app/constants/app_assets.dart';
import '../../../../app/constants/app_colors.dart';
import '../bloc/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final VideoPlayerController _videoController;
  Timer? _bootTimer;
  bool _isVideoReady = false;
  bool _bootRequested = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(AppAssets.splashVideo)
      ..setLooping(false)
      ..setVolume(1);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _videoController.initialize();
      if (!mounted) return;
      setState(() => _isVideoReady = true);
      await _videoController.play();
      _startBootTimer();
    } catch (error) {
      debugPrint('Splash video failed to initialize: $error');
      _startBootTimer();
    }
  }

  void _startBootTimer() {
    _bootTimer ??= Timer(const Duration(seconds: 10), _boot);
  }

  void _boot() {
    if (_bootRequested) return;
    _bootRequested = true;
    if (!mounted) return;
    context.read<AuthBloc>().add(const AuthCheckRequested());
  }

  @override
  void dispose() {
    _bootTimer?.cancel();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: AppColors.white),
          if (_isVideoReady)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            ),
        ],
      ),
    );
  }
}
