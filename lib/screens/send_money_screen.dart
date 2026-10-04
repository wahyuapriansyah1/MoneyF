import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../widgets/responsive_layout.dart';
import 'add_card_screen.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  String amount = '500000';

  String _formatRupiah(String raw) {
    if (raw.isEmpty) return '0';
    final numVal = int.tryParse(raw);
    if (numVal == null) return raw;
    final str = numVal.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  void _onKeyTap(String value) {
    setState(() {
      if (value == 'back') {
        if (amount.isNotEmpty) {
          amount = amount.substring(0, amount.length - 1);
        }
      } else if (value == 'ok') {
        // confirm amount
      } else {
        if (amount == '0') {
          amount = value;
        } else if (amount.length < 12) {
          amount += value;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final contact = mockContacts.last;
    return Scaffold(
      body: Container(
        decoration: screenBackground(),
        child: SafeArea(
          child: ResponsiveLayout(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                children: [
                  const _TopBar(),
                  const SizedBox(height: 24),
                  const _CardSelector(),
                  const SizedBox(height: 16),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Rp ${_formatRupiah(amount)}',
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _ContactCard(contact: contact),
                  const Spacer(),
                  _NumPad(onKeyTap: _onKeyTap),
                  const SizedBox(height: 20),
                  BlackButton(
                    label: 'Kirim Sekarang',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Berhasil mengirim Rp ${_formatRupiah(amount)} ke ${contact.name}')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.of(context).maybePop(),
          customBorder: const CircleBorder(),
          child: Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const Expanded(
          child: Text(
            'Kirim Uang',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.more_horiz_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _CardSelector extends StatelessWidget {
  const _CardSelector();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const AddCardScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: AppColors.black,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0472B),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '**** 9975',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final Contact contact;
  const _ContactCard({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: contact.avatarBg,
            child: Text(
              contact.initials,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  contact.phone ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.cancel, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _NumPad extends StatelessWidget {
  final void Function(String) onKeyTap;
  const _NumPad({required this.onKeyTap});

  static const keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['back', '0', 'ok'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: keys
          .map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: row
                    .map(
                      (k) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: _NumKey(value: k, onTap: onKeyTap),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _NumKey extends StatelessWidget {
  final String value;
  final void Function(String) onTap;
  const _NumKey({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (value == 'back') {
      child = const Icon(Icons.backspace_outlined, size: 18);
    } else if (value == 'ok') {
      child = const Icon(Icons.check, size: 20);
    } else {
      child = Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      );
    }

    return InkWell(
      onTap: () => onTap(value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}
