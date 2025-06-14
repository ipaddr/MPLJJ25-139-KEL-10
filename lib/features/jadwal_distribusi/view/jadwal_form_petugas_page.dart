// lib/features/jadwal_distribusi/view/jadwal_form_petugas_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:giziku/models/jadwal_detail_item.dart';
import 'package:giziku/models/chat_user.dart'; // Untuk mendapatkan daftar pengguna umum

class JadwalFormPetugasPage extends StatefulWidget {
  final JadwalDetailItem? initialJadwal; // Untuk mode edit (opsional)

  const JadwalFormPetugasPage({super.key, this.initialJadwal});

  @override
  State<JadwalFormPetugasPage> createState() => _JadwalFormPetugasPageState();
}

class _JadwalFormPetugasPageState extends State<JadwalFormPetugasPage> {
  final _formKey = GlobalKey<FormState>();
  final _lokasiController = TextEditingController();
  final _subjectBantuanController = TextEditingController(); // Subject Bantuan
  final _deskripsiBantuanController =
      TextEditingController(); // Deskripsi Bantuan
  DateTime? _selectedDate;
  String? _errorMessage;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  String? _currentUserName; // ✅ Ini akan digunakan sekarang

  List<ChatUser> _allGeneralUsers = [];
  List<String> _selectedRecipientUids = []; // UID pengguna yang dipilih

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser == null) {
      _errorMessage = 'Anda harus login untuk menambah jadwal.';
    } else {
      _loadCurrentUserAndGeneralUsers();
      if (widget.initialJadwal != null) {
        _lokasiController.text = widget.initialJadwal!.lokasi;
        _subjectBantuanController.text = widget.initialJadwal!.jenisBantuan;
        _deskripsiBantuanController.text =
            widget.initialJadwal!.deskripsiBantuan;
        _selectedDate = widget.initialJadwal!.tanggal;
        _selectedRecipientUids = List.from(
          widget.initialJadwal!.recipientUserIds,
        );
      }
    }
  }

  @override
  void dispose() {
    _lokasiController.dispose();
    _subjectBantuanController.dispose();
    _deskripsiBantuanController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserAndGeneralUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Ambil nama petugas yang sedang login
      final userDoc =
          await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        setState(() {
          // setState di sini karena _currentUserName akan update UI jika loading di awal
          _currentUserName = userDoc.data()?['name'] as String?;
        });
      }

      // Ambil daftar pengguna umum
      final usersSnapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: 'Pengguna Umum')
              .get();
      _allGeneralUsers =
          usersSnapshot.docs.map((doc) => ChatUser.fromFirestore(doc)).toList();
    } catch (e) {
      _errorMessage = 'Gagal memuat data: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitJadwal() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _currentUser == null ||
        _currentUserName == null) {
      setState(() {
        _errorMessage =
            'Harap lengkapi semua field dan pilih tanggal. Pastikan Anda login dengan nama pengguna.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final JadwalDetailItem newJadwal = JadwalDetailItem(
        id: widget.initialJadwal?.id ?? '', // ID akan diisi Firestore jika baru
        tanggal: _selectedDate!,
        lokasi: _lokasiController.text.trim(),
        jenisBantuan: _subjectBantuanController.text.trim(), // Subject Bantuan
        deskripsiBantuan:
            _deskripsiBantuanController.text.trim(), // Deskripsi Bantuan
        status: 'Dijadwalkan', // Default status saat menambah
        recipientUserIds: _selectedRecipientUids, // UID penerima yang dipilih
        addedByUserId: _currentUser!.uid,
        addedByUserName: _currentUserName, // ✅ Gunakan _currentUserName di sini
        createdAt: widget.initialJadwal?.createdAt ?? DateTime.now(),
      );

      if (widget.initialJadwal == null) {
        await _firestore
            .collection('jadwal_distribusi')
            .add(newJadwal.toFirestore());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jadwal berhasil ditambahkan!')),
        );
      } else {
        await _firestore
            .collection('jadwal_distribusi')
            .doc(newJadwal.id)
            .update(newJadwal.toFirestore());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jadwal berhasil diperbarui!')),
        );
      }

      if (context.mounted) {
        context.pop(); // Kembali ke halaman sebelumnya
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal menyimpan jadwal: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menampilkan loading untuk loadCurrentUserAndGeneralUsers, bukan hanya daftar kosong
    if (_isLoading &&
        _allGeneralUsers.isEmpty &&
        _currentUser != null &&
        _errorMessage == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tambah Jadwal')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialJadwal == null ? 'Tambah Jadwal' : 'Edit Jadwal',
        ),
        backgroundColor: const Color(0xFF218BCF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _lokasiController,
                labelText: 'Lokasi Distribusi',
                validator:
                    (value) =>
                        value!.isEmpty ? 'Lokasi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _subjectBantuanController, // Subject Bantuan
                labelText: 'Subject Bantuan',
                hintText: 'Misal: Karbohidrat, Protein',
                validator:
                    (value) =>
                        value!.isEmpty
                            ? 'Subject bantuan tidak boleh kosong'
                            : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _deskripsiBantuanController, // Deskripsi Bantuan
                labelText: 'Deskripsi Bantuan',
                hintText: 'Misal: Beras, roti, jagung, dll. (sesuai subject)',
                validator:
                    (value) =>
                        value!.isEmpty
                            ? 'Deskripsi bantuan tidak boleh kosong'
                            : null,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  // Mencegah keyboard muncul saat tap GestureDetector
                  child: _buildTextField(
                    controller: TextEditingController(
                      text:
                          _selectedDate == null
                              ? ''
                              : DateFormat(
                                'dd MMMM yyyy',
                              ).format(_selectedDate!),
                    ), // Format tanggal
                    labelText: 'Tanggal Distribusi',
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Tanggal tidak boleh kosong'
                                : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Pilih Penerima Bantuan (Opsional):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_isLoading) // Tampilkan loading untuk daftar pengguna
                const Center(child: CircularProgressIndicator())
              else if (_allGeneralUsers.isEmpty)
                const Text(
                  'Tidak ada pengguna umum ditemukan.',
                  style: TextStyle(color: Colors.grey),
                )
              else
                ..._allGeneralUsers.map((user) {
                  final bool isSelected = _selectedRecipientUids.contains(
                    user.uid,
                  );
                  return CheckboxListTile(
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    value: isSelected,
                    onChanged: (bool? newValue) {
                      setState(() {
                        if (newValue == true) {
                          _selectedRecipientUids.add(user.uid);
                        } else {
                          _selectedRecipientUids.remove(user.uid);
                        }
                      });
                    },
                  );
                }).toList(),
              const SizedBox(height: 24),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              ElevatedButton(
                onPressed: _submitJadwal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF218BCF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Simpan Jadwal'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xFFEAF6FD),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
