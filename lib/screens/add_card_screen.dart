import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/responsive_layout.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  late final TextEditingController _holderCtrl;
  late final TextEditingController _numberCtrl;
  late final TextEditingController _expiryCtrl;
  late final TextEditingController _cvvCtrl;

  String _selectedCardType = 'Mastercard / Visa';

  @override
  void initState() {
    super.initState();
    _holderCtrl = TextEditingController(text: 'Dari Dandy');
    _numberCtrl = TextEditingController(text: '5412 7512 3412 9975');
    _expiryCtrl = TextEditingController(text: '12/28');
    _cvvCtrl = TextEditingController(text: '288');

    _holderCtrl.addListener(_onFieldChanged);
    _numberCtrl.addListener(_onFieldChanged);
    _expiryCtrl.addListener(_onFieldChanged);
    _cvvCtrl.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _holderCtrl.dispose();
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: screenBackground(),
        child: SafeArea(
          child: ResponsiveLayout(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                children: [
                  const _TopBar(title: 'Tambah Kartu & Rekening'),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // Interactive Credit Card Preview Card
                        _CardPreview(
                          holderName: _holderCtrl.text.isEmpty ? 'NAMA PEMILIK' : _holderCtrl.text,
                          cardNumber: _numberCtrl.text.isEmpty ? '•••• •••• •••• ••••' : _numberCtrl.text,
                          expiry: _expiryCtrl.text.isEmpty ? 'MM/YY' : _expiryCtrl.text,
                          cardType: _selectedCardType,
                        ),
                        const SizedBox(height: 24),

                        const _FieldLabel('Tipe / Jenis Kartu'),
                        _CardTypeSelector(
                          selectedType: _selectedCardType,
                          onChanged: (newType) {
                            setState(() {
                              _selectedCardType = newType;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        const _FieldLabel('Nama Pemilik Kartu'),
                        _InputField(
                          controller: _holderCtrl,
                          hintText: 'Contoh: Dari Dandy',
                          prefixIcon: Icons.person_outline_rounded,
                          trailingCheck: _holderCtrl.text.trim().isNotEmpty,
                        ),
                        const SizedBox(height: 16),

                        const _FieldLabel('Nomor Kartu / Rekening'),
                        _InputField(
                          controller: _numberCtrl,
                          hintText: 'Contoh: 5412 7512 3412 9975',
                          prefixIcon: Icons.credit_card_rounded,
                          trailingCheck: _numberCtrl.text.trim().isNotEmpty,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _FieldLabel('Masa Berlaku'),
                                  _InputField(
                                    controller: _expiryCtrl,
                                    hintText: 'MM/YY (12/28)',
                                    prefixIcon: Icons.calendar_today_rounded,
                                    trailingCheck: _expiryCtrl.text.trim().isNotEmpty,
                                    keyboardType: TextInputType.datetime,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _FieldLabel('CVV / PIN'),
                                  _InputField(
                                    controller: _cvvCtrl,
                                    hintText: '3 digit CVV',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  BlackButton(
                    label: 'Simpan Kartu',
                    onPressed: () {
                      if (_holderCtrl.text.trim().isEmpty || _numberCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nama dan nomor kartu harus diisi')),
                        );
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kartu berhasil disimpan')),
                      );
                      Navigator.of(context).pop();
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

class _CardPreview extends StatelessWidget {
  final String holderName;
  final String cardNumber;
  final String expiry;
  final String cardType;

  const _CardPreview({
    required this.holderName,
    required this.cardNumber,
    required this.expiry,
    required this.cardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E24), Color(0xFF2C2D35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEB001B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(-6, 0),
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF79E1B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                cardType,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            cardNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PEMILIK KARTU',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    holderName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'BERLAKU HINGGA',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expiry,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;

  const _CardTypeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  static const types = [
    'Mastercard / Visa',
    'BCA / Mandiri / BRI',
    'GPN / Debit Lokal',
    'E-Wallet / QRIS',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedType,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          items: types.map((t) {
            return DropdownMenuItem<String>(
              value: t,
              child: Row(
                children: [
                  const Icon(Icons.credit_card_rounded, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Text(t),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundIcon(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 42),
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final IconData? prefixIcon;
  final bool trailingCheck;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    this.hintText,
    this.prefixIcon,
    this.trailingCheck = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            Icon(prefixIcon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          if (trailingCheck)
            const Icon(
              Icons.check_circle_rounded,
              size: 20,
              color: AppColors.positive,
            ),
        ],
      ),
    );
  }
}
