import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../viewmodels/user_admin_viewmodel.dart';

/// Admin screen for viewing and managing user accounts.
class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        final vm = context.read<UserAdminViewModel>();
        switch (_tabCtrl.index) {
          case 0:
            vm.setStatusFilter('all');
            break;
          case 1:
            vm.setStatusFilter('active');
            break;
          case 2:
            vm.setStatusFilter('disabled');
            break;
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserAdminViewModel>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleDisable(UserModel user) async {
    final vm = context.read<UserAdminViewModel>();

    // Prevent disabling admin accounts
    if (user.role == 'admin' && !user.isDisabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể vô hiệu hóa tài khoản admin'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final action = user.isDisabled ? 'kích hoạt' : 'vô hiệu hóa';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${user.isDisabled ? 'Kích hoạt' : 'Vô hiệu hóa'} tài khoản'),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.5),
            children: [
              const TextSpan(text: 'Bạn có chắc muốn '),
              TextSpan(
                text: action,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: user.isDisabled ? AppColors.success : AppColors.error,
                ),
              ),
              const TextSpan(text: ' tài khoản '),
              TextSpan(
                text: user.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: '?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  user.isDisabled ? AppColors.success : AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(user.isDisabled ? 'Kích hoạt' : 'Vô hiệu hóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final ok = await vm.toggleDisabled(user);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok
                ? (user.isDisabled
                    ? 'Đã kích hoạt tài khoản ${user.name}'
                    : 'Đã vô hiệu hóa tài khoản ${user.name}')
                : 'Thao tác thất bại, vui lòng thử lại'),
            backgroundColor: ok
                ? (user.isDisabled ? AppColors.success : AppColors.error)
                : AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Consumer<UserAdminViewModel>(
        builder: (context, vm, _) {
          return CustomScrollView(
            slivers: [
              // ── Header ──────────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () => vm.loadUsers(),
                    tooltip: 'Làm mới',
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -30,
                          right: -30,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.04),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.people_alt_rounded,
                                        color: AppColors.secondary, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Quản lý người dùng',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // Quick stats
                              Row(
                                children: [
                                  _QuickStatChip(
                                    label: '${vm.totalUsers} tổng',
                                    color: Colors.white54,
                                  ),
                                  const SizedBox(width: 8),
                                  _QuickStatChip(
                                    label: '${vm.activeUsers} hoạt động',
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 8),
                                  _QuickStatChip(
                                    label: '${vm.disabledUsers} bị khóa',
                                    color: AppColors.error,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(46),
                  child: Container(
                    color: const Color(0xFF0F3460),
                    child: TabBar(
                      controller: _tabCtrl,
                      indicatorColor: AppColors.secondary,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white54,
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13),
                      tabs: const [
                        Tab(text: 'Tất cả'),
                        Tab(text: 'Hoạt động'),
                        Tab(text: 'Bị khóa'),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Search & Filter Bar ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    children: [
                      // Search field
                      TextField(
                        controller: _searchCtrl,
                        onChanged: vm.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Tìm theo tên, email, số điện thoại...',
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.textHint),
                          suffixIcon: vm.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    vm.setSearchQuery('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.primarySurface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Role filter chips
                      Row(
                        children: [
                          const Text(
                            'Vai trò:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _FilterChip(
                            label: 'Tất cả',
                            selected: vm.roleFilter == 'all',
                            onTap: () => vm.setRoleFilter('all'),
                          ),
                          const SizedBox(width: 6),
                          _FilterChip(
                            label: 'Admin',
                            selected: vm.roleFilter == 'admin',
                            onTap: () => vm.setRoleFilter('admin'),
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 6),
                          _FilterChip(
                            label: 'User',
                            selected: vm.roleFilter == 'user',
                            onTap: () => vm.setRoleFilter('user'),
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 1)),

              // ── User List ───────────────────────────────────────────────────
              if (vm.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (vm.filteredUsers.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded,
                            size: 64, color: AppColors.textHint),
                        const SizedBox(height: 12),
                        Text(
                          vm.searchQuery.isNotEmpty
                              ? 'Không tìm thấy người dùng nào'
                              : 'Chưa có người dùng nào',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final user = vm.filteredUsers[i];
                        return _UserTile(
                          user: user,
                          onToggleDisable: () => _toggleDisable(user),
                        );
                      },
                      childCount: vm.filteredUsers.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── User Tile ──────────────────────────────────────────────────────────────────
class _UserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onToggleDisable;

  const _UserTile({required this.user, required this.onToggleDisable});

  @override
  Widget build(BuildContext context) {
    final initials = user.name.isNotEmpty
        ? user.name
            .trim()
            .split(' ')
            .where((s) => s.isNotEmpty)
            .map((s) => s[0].toUpperCase())
            .take(2)
            .join()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: user.isDisabled
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: user.role == 'admin'
                        ? const LinearGradient(
                            colors: [Color(0xFFFC466B), Color(0xFF3F5EFB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                  ),
                  alignment: Alignment.center,
                  child: user.avatar != null
                      ? ClipOval(
                          child: Image.network(
                            user.avatar!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                ),
                if (user.isDisabled)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.block_rounded,
                          color: Colors.white, size: 8),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: user.isDisabled
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                            decoration: user.isDisabled
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: user.role == 'admin'
                              ? AppColors.secondary.withValues(alpha: 0.12)
                              : AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          user.role == 'admin' ? 'Admin' : 'User',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: user.role == 'admin'
                                ? AppColors.secondary
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.phone.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      user.phone,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textHint),
                    ),
                  ],
                  const SizedBox(height: 4),
                  // Status chip
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: user.isDisabled
                          ? AppColors.error.withValues(alpha: 0.1)
                          : AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: user.isDisabled
                                ? AppColors.error
                                : AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.isDisabled ? 'Bị vô hiệu hóa' : 'Hoạt động',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: user.isDisabled
                                ? AppColors.error
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Toggle switch
            Column(
              children: [
                Switch.adaptive(
                  value: !user.isDisabled,
                  onChanged: user.role == 'admin' && !user.isDisabled
                      ? null
                      : (_) => onToggleDisable(),
                  activeThumbColor: AppColors.success,
                  inactiveThumbColor: AppColors.error,
                  inactiveTrackColor: AppColors.error.withValues(alpha: 0.3),
                ),
                Text(
                  user.isDisabled ? 'Khóa' : 'Bật',
                  style: TextStyle(
                    fontSize: 10,
                    color: user.isDisabled ? AppColors.error : AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────────────
class _QuickStatChip extends StatelessWidget {
  final String label;
  final Color color;

  const _QuickStatChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color == Colors.white54 ? Colors.white : color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? color : AppColors.primarySurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
