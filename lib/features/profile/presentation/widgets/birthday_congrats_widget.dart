import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

class BirthdayCongratsWidget extends StatefulWidget {
  final String userName;
  final VoidCallback onClose;

  const BirthdayCongratsWidget({
    super.key,
    required this.userName,
    required this.onClose,
  });

  @override
  State<BirthdayCongratsWidget> createState() => _BirthdayCongratsWidgetState();
}

class _BirthdayCongratsWidgetState extends State<BirthdayCongratsWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<_ConfettiParticle> _confettiParticles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeIn,
    );

    // Generate confetti particles
    for (int i = 0; i < 50; i++) {
      _confettiParticles.add(_ConfettiParticle(
        x: _random.nextDouble(),
        y: -_random.nextDouble() * 0.3,
        color: _getRandomColor(),
        size: _random.nextDouble() * 8 + 4,
        speed: _random.nextDouble() * 0.5 + 0.3,
        rotation: _random.nextDouble() * 360,
        rotationSpeed: _random.nextDouble() * 10 - 5,
      ));
    }

    _scaleController.forward();
    _confettiController.repeat();
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
      AppColors.primary,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: Stack(
        children: [
          // Confetti animation
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ConfettiPainter(
                  particles: _confettiParticles,
                  progress: _confettiController.value,
                ),
              );
            },
          ),

          // Main content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.pink.shade50,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Stack(
                      children: [
                        // Background decorations
                        Positioned(
                          top: -30,
                          right: -30,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.yellow.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -20,
                          left: -20,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.pink.withValues(alpha: 0.2),
                            ),
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(28),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.75,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Cake emoji with glow
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              Colors.yellow.withValues(alpha: 0.4),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        '🎂',
                                        style: TextStyle(fontSize: 48),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Title with gradient
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [
                                        Colors.pink.shade400,
                                        Colors.purple.shade400,
                                        Colors.blue.shade400,
                                      ],
                                    ).createShader(bounds),
                                    child: const Text(
                                      'ТУУЛГАН КУНУН МЕНЕН!',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // User name highlight
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary.withValues(alpha: 0.15),
                                          Colors.pink.withValues(alpha: 0.15),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: AppColors.primary.withValues(alpha: 0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('✨', style: TextStyle(fontSize: 16)),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            'Кымбаттуу ${widget.userName}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text('✨', style: TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Message
                                  Text(
                                    'Өздүк майрамың менен "Жайдем" коомдук фонду чын дилден куттуктайт!\n\n'
                                    'Жашооңдо эң баалуу болгон ден-соолугун бекем болсун!\n\n'
                                    'Билимге болгон умтулууң, максатыңа болгон аракетиң эч качан токтобосун.\n\n'
                                    'Сен жалгыз эмессиң - "Жайдем" коомдук фонду ар дайым сени колдоп, шыктандырууга даяр.\n\n'
                                    'Аруу тилек, максаттарың ишке ашып, чексиз ийгиликтерге жетишиңди каалайбыз!\n\n'
                                    'Эл керегине жараган, өлкөбүздүн өнүгүшүнө салым кошкон, чоң кадыр-баркка ээ болгон, илимдүү-билимдүү, бактылуу инсан болушуна тилектешпиз!',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 16),

                                  // Party emojis
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('🎉', style: TextStyle(fontSize: 24)),
                                      SizedBox(width: 6),
                                      Text('🎈', style: TextStyle(fontSize: 24)),
                                      SizedBox(width: 6),
                                      Text('🎁', style: TextStyle(fontSize: 24)),
                                      SizedBox(width: 6),
                                      Text('🥳', style: TextStyle(fontSize: 24)),
                                      SizedBox(width: 6),
                                      Text('🎊', style: TextStyle(fontSize: 24)),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  // Thank you button
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.mediumImpact();
                                      widget.onClose();
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            Colors.pink.shade400,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.4),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '🙏',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            'Рахмат!',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
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
                        ),

                        // Close button at top right (on top of content)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              widget.onClose();
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  final Color color;
  final double size;
  final double speed;
  double rotation;
  final double rotationSpeed;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      // Update position
      final y = particle.y + progress * particle.speed * 1.5;
      final x = particle.x + sin(progress * 10 + particle.rotation) * 0.02;

      // Only draw if within bounds
      if (y <= 1.2) {
        canvas.save();
        canvas.translate(
          x * size.width,
          y * size.height,
        );
        canvas.rotate((particle.rotation + progress * particle.rotationSpeed * 50) * pi / 180);

        // Draw confetti shape (rectangle)
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size * 0.6,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

/// Helper function to check if today is user's birthday
bool isTodayBirthday(String? birthday) {
  if (birthday == null || birthday.isEmpty) return false;

  try {
    final parts = birthday.split('-');
    if (parts.length != 3) return false;

    final birthMonth = int.parse(parts[1]);
    final birthDay = int.parse(parts[2]);

    final now = DateTime.now();
    return now.month == birthMonth && now.day == birthDay;
  } catch (e) {
    return false;
  }
}
