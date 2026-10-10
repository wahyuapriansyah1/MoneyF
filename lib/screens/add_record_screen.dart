import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../models.dart';
import '../state/finance_state.dart';
import '../widgets/responsive_layout.dart';

class AddRecordScreen extends StatefulWidget {
  final RecordType initialType;
  final DebtType? initialDebtType;
  final FinancialRecord? recordToEdit;

  const AddRecordScreen({
    super.key,
    this.initialType = RecordType.expense,
    this.initialDebtType,
    this.recordToEdit,
  });

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  late RecordType _selectedType;
  DebtType _debtType = DebtType.payable;
  
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _personController;
  late TextEditingController _noteController;
  
  late CategoryOption _selectedCategory;
  late DateTime _selectedDate;

  bool get _isEditing => widget.recordToEdit != null;

  @override
  void initState() {
    super.initState();
    final edit = widget.recordToEdit;
    if (edit != null) {
      _selectedType = edit.type;
      _debtType = edit.debtType ?? DebtType.payable;
      _titleController = TextEditingController(text: edit.title);
      _amountController = TextEditingController(
        text: _formatInitialAmount(edit.amount),
      );
      _personController = TextEditingController(text: edit.personName ?? '');
      _noteController = TextEditingController(text: edit.note ?? '');
      _selectedDate = edit.date;

      final matched = defaultCategories.where((c) => c.name == edit.category && c.type == edit.type);
      if (matched.isNotEmpty) {
        _selectedCategory = matched.first;
      } else {
        _updateCategoryForType();
      }
    } else {
      _selectedType = widget.initialType;
      _debtType = widget.initialDebtType ?? DebtType.payable;
      _titleController = TextEditingController();
      _amountController = TextEditingController();
      _personController = TextEditingController();
      _noteController = TextEditingController();
      _selectedDate = DateTime.now();
      _updateCategoryForType();
    }
  }

  void _updateCategoryForType() {
    final available = defaultCategories.where((c) => c.type == _selectedType).toList();
    if (available.isNotEmpty) {
      _selectedCategory = available.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _personController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _deleteData() {
    if (!_isEditing) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: Text('Apakah Anda yakin ingin menghapus catatan "${widget.recordToEdit!.title}"?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final state = FinanceProvider.of(context);
              state.deleteRecord(widget.recordToEdit!.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Catatan "${widget.recordToEdit!.title}" berhasil dihapus')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  String _formatInitialAmount(double amount) {
    final cleanDigits = amount.toInt().toString();
    final buffer = StringBuffer();
    final len = cleanDigits.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(cleanDigits[i]);
    }
    return buffer.toString();
  }

  void _submitData() {
    var title = _titleController.text.trim();
    final rawText = _amountController.text.trim();
    final person = _personController.text.trim();

    // Jika transaksi Utang/Piutang dan judul kosong tapi nama orang terisi, buatkan judul otomatis
    if (title.isEmpty && _selectedType == RecordType.debt && person.isNotEmpty) {
      title = _debtType == DebtType.payable ? 'Utang ke $person' : 'Piutang $person';
    }
    
    // Clean amount text from dots and non-digit characters
    final digitsOnly = rawText.replaceAll(RegExp(r'\D'), '');
    final amount = double.tryParse(digitsOnly);

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul transaksi tidak boleh kosong')),
      );
      return;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal angka yang valid')),
      );
      return;
    }

    final state = FinanceProvider.of(context);

    if (_isEditing) {
      final updated = widget.recordToEdit!.copyWith(
        title: title,
        amount: amount,
        type: _selectedType,
        debtType: _selectedType == RecordType.debt ? _debtType : null,
        category: _selectedCategory.name,
        categoryIcon: _selectedCategory.icon,
        date: _selectedDate,
        personName: _selectedType == RecordType.debt ? _personController.text.trim() : null,
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      );

      state.updateRecord(updated);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan berhasil diperbarui!')),
      );
    } else {
      final newRecord = FinancialRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amount: amount,
        type: _selectedType,
        debtType: _selectedType == RecordType.debt ? _debtType : null,
        category: _selectedCategory.name,
        categoryIcon: _selectedCategory.icon,
        date: _selectedDate,
        personName: _selectedType == RecordType.debt ? _personController.text.trim() : null,
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
        isPaid: false,
      );

      state.addRecord(newRecord);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedType == RecordType.income
                ? 'Pemasukan berhasil ditambahkan!'
                : _selectedType == RecordType.expense
                    ? 'Pengeluaran berhasil ditambahkan!'
                    : 'Utang berhasil ditambahkan!',
          ),
        ),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final availableCategories = defaultCategories.where((c) => c.type == _selectedType).toList();

    final pageTitle = _isEditing
        ? 'Edit Catatan'
        : (_selectedType == RecordType.income
            ? 'Tambah Pemasukan'
            : _selectedType == RecordType.expense
                ? 'Tambah Pengeluaran'
                : 'Catat Utang / Piutang');

    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: SafeArea(
        child: ResponsiveLayout(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              children: [
                _TopBar(
                  title: pageTitle,
                  onDelete: _isEditing ? _deleteData : null,
                ),
                const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type Selector (Pemasukan, Pengeluaran, Utang)
                      _TypeSegmentedControl(
                            selectedType: _selectedType,
                            onTypeChanged: (type) {
                              setState(() {
                                _selectedType = type;
                                _updateCategoryForType();
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          // If Debt selected: Sub-type (Utang Saya vs Piutang Orang)
                          if (_selectedType == RecordType.debt) ...[
                            _DebtTypeSelector(
                              selectedDebtType: _debtType,
                              onChanged: (dt) {
                                setState(() {
                                  _debtType = dt;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            const _FieldLabel('Nama Pihak / Orang'),
                            _CustomInputField(
                              controller: _personController,
                              hintText: _debtType == DebtType.payable
                                  ? 'Contoh: Budi (Pemberi Pinjaman)'
                                  : 'Contoh: Andi (Peminjam)',
                              prefixIcon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Title Input
                          const _FieldLabel('Judul / Deskripsi'),
                          _CustomInputField(
                            controller: _titleController,
                            hintText: _selectedType == RecordType.income
                                ? 'Contoh: Gaji Bulanan, Transfer Masuk'
                                : _selectedType == RecordType.expense
                                    ? 'Contoh: Makan Siang, Beli Baju'
                                    : 'Contoh: Pinjaman Modal Usaha',
                            prefixIcon: Icons.edit_note_rounded,
                          ),
                          const SizedBox(height: 16),

                          // Amount Input
                          const _FieldLabel('Nominal (Jumlah Uang dlm Rupiah)'),
                          _CustomInputField(
                            controller: _amountController,
                            hintText: 'Contoh: 5.000.000',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              ThousandsSeparatorInputFormatter(),
                            ],
                            prefixIcon: Icons.payments_outlined,
                          ),
                          const SizedBox(height: 16),

                      // Category Picker
                      const _FieldLabel('Kategori'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availableCategories.map((cat) {
                          final isSelected = cat.name == _selectedCategory.name;
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  cat.icon,
                                  size: 16,
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                ),
                                const SizedBox(width: 6),
                                Text(cat.name),
                              ],
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : Colors.black12,
                              ),
                            ),
                            onSelected: (_) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            },
                          );
                        }).toList(),
                      ),
                          const SizedBox(height: 16),

                          // Date Picker Row
                          const _FieldLabel('Tanggal Transaksi'),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() {
                                  _selectedDate = picked;
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textSecondary),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Note Input
                          const _FieldLabel('Catatan (Opsional)'),
                          _CustomInputField(
                            controller: _noteController,
                            hintText: 'Tambahkan keterangan detail...',
                            prefixIcon: Icons.chat_bubble_outline_rounded,
                          ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              BlackButton(
                label: _isEditing ? 'Simpan Perubahan' : 'Simpan Catatan',
                onPressed: _submitData,
              ),
              if (_isEditing) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _deleteData,
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.negative, size: 20),
                    label: const Text(
                      'Hapus Catatan Ini',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.negative,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.negative),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
}

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onDelete;
  const _TopBar({required this.title, this.onDelete});

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
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (onDelete != null)
          InkWell(
            onTap: onDelete,
            customBorder: const CircleBorder(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.negative,
              ),
            ),
          )
        else
          const SizedBox(width: 42),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _TypeSegmentedControl extends StatelessWidget {
  final RecordType selectedType;
  final ValueChanged<RecordType> onTypeChanged;

  const _TypeSegmentedControl({
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildItem('Pemasukan', RecordType.income, Icons.arrow_downward_rounded, AppColors.positive),
          _buildItem('Pengeluaran', RecordType.expense, Icons.arrow_upward_rounded, AppColors.negative),
          _buildItem('Utang', RecordType.debt, Icons.handshake_rounded, AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildItem(String label, RecordType type, IconData icon, Color activeAccent) {
    final isSelected = selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTypeChanged(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
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

class _DebtTypeSelector extends StatelessWidget {
  final DebtType selectedDebtType;
  final ValueChanged<DebtType> onChanged;

  const _DebtTypeSelector({
    required this.selectedDebtType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: const Center(
              child: Text('Saya Berutang'),
            ),
            selected: selectedDebtType == DebtType.payable,
            selectedColor: AppColors.primary,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: selectedDebtType == DebtType.payable ? Colors.white : AppColors.textPrimary,
              fontWeight: selectedDebtType == DebtType.payable ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
            onSelected: (_) => onChanged(DebtType.payable),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: selectedDebtType == DebtType.payable ? AppColors.primary : Colors.black12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ChoiceChip(
            label: const Center(
              child: Text('Orang Berutang'),
            ),
            selected: selectedDebtType == DebtType.receivable,
            selectedColor: AppColors.primary,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: selectedDebtType == DebtType.receivable ? Colors.white : AppColors.textPrimary,
              fontWeight: selectedDebtType == DebtType.receivable ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
            onSelected: (_) => onChanged(DebtType.receivable),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: selectedDebtType == DebtType.receivable ? AppColors.primary : Colors.black12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _CustomInputField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Icon(prefixIcon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final cleanDigits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (cleanDigits.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    final buffer = StringBuffer();
    final len = cleanDigits.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(cleanDigits[i]);
    }

    final formattedText = buffer.toString();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
