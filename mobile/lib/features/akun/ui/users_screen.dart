import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/users_provider.dart';
import '../../../core/theme/notification_helper.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengguna'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: state.isLoading && state.users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    final user = state.users[index];
                    final role = user['role'] as String? ?? 'unknown';
                    return _UserCard(
                      user: user,
                      roleColor: _roleColor(role),
                      onEdit: () => _showUserForm(context, ref, user: user),
                      onDelete: () => _confirmDelete(context, ref, user['id'], user['username']),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserForm(context, ref),
        backgroundColor: const Color(0xFF00AA5B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return Colors.purple;
      case 'admin':
        return Colors.blue;
      case 'cashier':
        return const Color(0xFF00AA5B);
      case 'dev':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  void _showUserForm(BuildContext context, WidgetRef ref, {Map<String, dynamic>? user}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UserFormSheet(user: user),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, int id, String username) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengguna?'),
        content: Text('Apakah Anda yakin ingin menghapus pengguna "$username"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!context.mounted) return;
      final success = await ref.read(usersProvider.notifier).deleteUser(id);
      if (context.mounted) {
        if (success) {
          showTopSnackBar(context, 'Pengguna berhasil dihapus');
        } else {
          showTopSnackBar(context, 'Gagal menghapus pengguna', backgroundColor: Colors.red[700]);
        }
      }
    }
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final Color roleColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.roleColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final role = user['role'] as String? ?? 'unknown';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor.withValues(alpha: 0.15),
          child: Text(
            (user['username'] as String? ?? 'U')[0].toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.bold, color: roleColor),
          ),
        ),
        title: Text(user['username'] as String? ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(role.toUpperCase(), style: TextStyle(fontSize: 12, color: roleColor, fontWeight: FontWeight.bold)),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onSelected: (val) {
            if (val == 'edit') onEdit();
            if (val == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Edit Pengguna'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Hapus Pengguna', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserFormSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic>? user;

  const _UserFormSheet({this.user});

  @override
  ConsumerState<_UserFormSheet> createState() => _UserFormSheetState();
}

class _UserFormSheetState extends ConsumerState<_UserFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameCtrl;
  late TextEditingController _passwordCtrl;
  String _selectedRole = 'cashier';
  bool _isLoading = false;

  final List<String> _roles = ['cashier', 'admin', 'owner', 'dev'];

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: widget.user?['username'] ?? '');
    _passwordCtrl = TextEditingController();
    _selectedRole = widget.user?['role'] ?? 'cashier';
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final role = _selectedRole;

    bool success;
    if (widget.user != null) {
      success = await ref.read(usersProvider.notifier).updateUser(
        widget.user!['id'],
        username,
        password.isEmpty ? null : password,
        role,
      );
    } else {
      success = await ref.read(usersProvider.notifier).createUser(username, password, role);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        showTopSnackBar(context, widget.user != null ? 'Pengguna diperbarui' : 'Pengguna dibuat');
        Navigator.pop(context);
      } else {
        showTopSnackBar(context, 'Gagal menyimpan pengguna', backgroundColor: Colors.red[700]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    
    return Container(
      padding: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom,
        left: 20, right: 20, top: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48, height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.user != null ? 'Edit Pengguna' : 'Tambah Pengguna',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameCtrl,
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: true,
              validator: (v) => widget.user == null && v!.isEmpty ? 'Wajib diisi' : null,
              decoration: InputDecoration(
                labelText: widget.user != null ? 'Password (kosongkan jika tidak diubah)' : 'Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase()))).toList(),
              onChanged: (v) => setState(() => _selectedRole = v!),
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AA5B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(widget.user != null ? 'Simpan Perubahan' : 'Buat Pengguna', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
