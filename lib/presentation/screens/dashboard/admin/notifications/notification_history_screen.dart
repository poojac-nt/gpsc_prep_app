import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/domain/entities/notification_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/notification/notification_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/notification/notification_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/notification/notification_state.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState
    extends State<NotificationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(FetchNotificationHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
          color: const Color(0xff1f2937),
        ),
        title: Text(
          'Notification History',
          style: AppTexts.titleTextStyle.copyWith(
            fontSize: 18.sp,
            color: const Color(0xff1f2937),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<NotificationBloc>().add(FetchNotificationHistory());
            },
            icon: Icon(
              Icons.refresh_rounded,
              size: 22.sp,
              color: AppColors.primary,
            ),
          ),
          16.wGap,
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state.status == NotificationStatus.loadingHistory) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.status == NotificationStatus.historyError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48.sp,
                    color: Colors.red[300],
                  ),
                  16.hGap,
                  Text(
                    'Failed to load notifications',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  12.hGap,
                  TextButton(
                    onPressed: () {
                      context
                          .read<NotificationBloc>()
                          .add(FetchNotificationHistory());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 56.sp,
                    color: Colors.grey[300],
                  ),
                  16.hGap,
                  Text(
                    'No notifications sent yet',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<NotificationBloc>().add(FetchNotificationHistory());
            },
            child: ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: state.notifications.length,
              separatorBuilder: (_, _) => 10.hGap,
              itemBuilder: (context, index) {
                final n = state.notifications[index];
                return _NotificationHistoryCard(
                  notification: n,
                  onResend: () => _onResend(n),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _onResend(NotificationModel notification) {
    context.push(
      AppRoutes.createNotification,
      extra: notification,
    );
  }
}

class _NotificationHistoryCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onResend;

  const _NotificationHistoryCard({
    required this.notification,
    required this.onResend,
  });

  Color get _typeColor {
    switch (notification.type) {
      case 'course':
        return const Color(0xff0284c7);
      case 'test':
        return const Color(0xff7c3aed);
      default:
        return const Color(0xff059669);
    }
  }

  IconData get _typeIcon {
    switch (notification.type) {
      case 'course':
        return Icons.book_outlined;
      case 'test':
        return Icons.quiz_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final day = local.day.toString().padLeft(2, '0');
    final month = months[local.month - 1];
    final year = local.year;
    final hour = local.hour > 12
        ? local.hour - 12
        : (local.hour == 0 ? 12 : local.hour);
    final min = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    return '$day $month $year, $hour:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final scheduledDate = _formatDate(notification.scheduledAt);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Type badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: _typeColor.withAlpha(18),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: _typeColor.withAlpha(50),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_typeIcon, size: 12.sp, color: _typeColor),
                    4.wGap,
                    Text(
                      notification.type.toUpperCase(),
                      style: TextStyle(
                        color: _typeColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              8.wGap,
              // Audience badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  notification.targetAudience.toUpperCase(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              // Sent status indicator
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 3.h,
                ),
                decoration: BoxDecoration(
                  color: (notification.isSent ?? false)
                      ? Colors.green.withAlpha(20)
                      : Colors.orange.withAlpha(20),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  (notification.isSent ?? false) ? 'Sent' : 'Pending',
                  style: TextStyle(
                    color: (notification.isSent ?? false)
                        ? Colors.green[700]
                        : Colors.orange[700],
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          12.hGap,
          Text(
            notification.title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff1f2937),
            ),
          ),
          6.hGap,
          Text(
            notification.body,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          12.hGap,
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 13.sp,
                color: Colors.grey[400],
              ),
              4.wGap,
              Expanded(
                child: Text(
                  scheduledDate,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              // Resend button
              GestureDetector(
                onTap: onResend,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.send_rounded,
                        size: 13.sp,
                        color: Colors.white,
                      ),
                      6.wGap,
                      Text(
                        'Resend',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
