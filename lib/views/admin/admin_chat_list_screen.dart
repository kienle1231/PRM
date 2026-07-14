import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/admin_chat_viewmodel.dart';

class AdminChatListScreen extends StatelessWidget {
  const AdminChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hỗ trợ khách hàng'),
      ),
      body: Consumer<AdminChatViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.rooms.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có cuộc trò chuyện nào.',
                style: TextStyle(color: AppColors.textHint),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vm.rooms.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final room = vm.rooms[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primarySurface,
                  child: Text(
                    room.userId.length > 1 ? room.userId.substring(0, 2).toUpperCase() : 'U',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  room.userId == 'support' ? 'Chung (Support)' : 'Khách hàng: ${room.userId}',
                  style: TextStyle(
                    fontWeight: room.unreadByAdmin ? FontWeight.w700 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  room.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: room.unreadByAdmin ? AppColors.textPrimary : AppColors.textHint,
                    fontWeight: room.unreadByAdmin ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(room.lastMessageAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: room.unreadByAdmin ? AppColors.primary : AppColors.textHint,
                      ),
                    ),
                    if (room.unreadByAdmin)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  vm.markAsRead(room.id);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.adminChatDetail,
                    arguments: room.id,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
