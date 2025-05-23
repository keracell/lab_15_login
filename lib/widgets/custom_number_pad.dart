import 'dart:io';
import 'package:flutter/material.dart';

class CustomNumberPad extends StatefulWidget {
  final int maxLength;
  final void Function(String pin) onFullyEntered;
  final void Function(String currentPin)? onChanged;

  const CustomNumberPad({
    super.key,
    required this.onFullyEntered,
    this.onChanged,
    this.maxLength = 4,
  });

  @override
  State<CustomNumberPad> createState() => _CustomNumberPadState();
}

class _CustomNumberPadState extends State<CustomNumberPad> {
  String _pin = '';

  void _onNumberPressed(String digit) {
    if (_pin.length >= widget.maxLength) return;

    setState(() {
      _pin += digit;
    });

    widget.onChanged?.call(_pin);

    if (_pin.length == widget.maxLength) {
      widget.onFullyEntered(_pin);
      setState(() {
        _pin = '';
      });
    }
  }

  void _onDeletePressed() {
    if (_pin.isEmpty) return;

    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
    });

    widget.onChanged?.call(_pin);
  }

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '←'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPinIndicators(),
        const SizedBox(height: 20),
        ...keys.map(
          (row) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                row.map((key) {
                  if (key.isEmpty) return _buildEmptyKey();
                  if (key == '←') {
                    return _buildAnimatedKey(
                      icon: Icons.backspace,
                      onTap: _onDeletePressed,
                    );
                  } else {
                    return _buildAnimatedKey(
                      label: key,
                      onTap: () => _onNumberPressed(key),
                    );
                  }
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPinIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.maxLength, (index) {
        bool filled = index < _pin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? Colors.black : Colors.grey[300],
          ),
        );
      }),
    );
  }

  Widget _buildAnimatedKey({
    String? label,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: _AnimatedScaleButton(
        onTap: onTap,
        child: Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Platform.isIOS ? Colors.white : Colors.grey[200],
            border: Border.all(
              color: Platform.isIOS ? Colors.grey.shade400 : Colors.transparent,
              width: Platform.isIOS ? 1.5 : 0,
            ),
            boxShadow:
                Platform.isIOS
                    ? [
                      const BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ]
                    : [],
          ),
          child: Center(
            child:
                icon != null
                    ? Icon(icon, size: 28, color: Colors.grey[700])
                    : Text(
                      label ?? '',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyKey() => const SizedBox(width: 75, height: 75);
}

class _AnimatedScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedScaleButton({required this.child, required this.onTap});

  @override
  State<_AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<_AnimatedScaleButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.9);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}
