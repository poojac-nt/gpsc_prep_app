import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/mentor/mentor_bloc.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class MentorListScreen extends StatefulWidget {
  const MentorListScreen({super.key});

  @override
  State<MentorListScreen> createState() => _MentorListScreenState();
}

class _MentorListScreenState extends State<MentorListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MentorBloc>().add(FetchMentorList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: _buildAppBar(),
      body: BlocBuilder<MentorBloc, MentorState>(
        builder: (context, state) {
          if (state is MentorListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MentorListError) {
            return _buildErrorState(state.message);
          } else if (state is MentorListLoaded) {
            if (state.mentors.isEmpty) {
              return _buildEmptyState();
            }
            return _buildMentorList(state.mentors);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.scaffoldColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColors.gray900,
          size: 20.sp,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mentor Management',
            style: TextStyle(
              color: AppColors.gray900,
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      titleSpacing: 0,
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => context.push(AppRoutes.mentorRegistration),
      backgroundColor: AppColors.primary,
      shape: const CircleBorder(),
      child: Icon(Icons.add, color: Colors.white, size: 28.sp),
    );
  }

  Widget _buildMentorList(List<MentorModel> mentors) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildListHeader(mentors.length)),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildMentorCard(mentors[index]),
              childCount: mentors.length,
            ),
          ),
        ),
        SliverToBoxAdapter(child: 100.hGap),
      ],
    );
  }

  Widget _buildListHeader(int count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Expert Faculty',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$count Mentors Total',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorCard(MentorModel mentor) {
    final initials = _getInitials(mentor.user.name);
    final status = (mentor.user.isActive ?? false) ? 'Active' : 'Deactivated';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(mentor.user.profilePicture, initials),
          14.wGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mentor.user.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                4.hGap,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color:
                        (mentor.user.isActive ?? false)
                            ? AppColors.primary.withAlpha(20)
                            : Colors.red.withAlpha(20),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color:
                          (mentor.user.isActive ?? false)
                              ? AppColors.primary
                              : Colors.red,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final result = await context.push<bool>(
                AppRoutes.editMentor,
                extra: EditMentorScreenArgs(mentor: mentor),
              );
              if (result == true && mounted) {
                context.read<MentorBloc>().add(FetchMentorList());
              }
            },
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Icon(
                Icons.mode_edit,
                color: AppColors.gray400,
                size: 22.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? profilePicture, String initials) {
    const avatarColors = [
      Color(0xFFEFF6FF),
      Color(0xFFFFF7ED),
      Color(0xFFF0FDF4),
      Color(0xFFFDF4FF),
      Color(0xFFFFF1F2),
    ];
    const textColors = [
      Color(0xFF3B82F6),
      Color(0xFFF97316),
      Color(0xFF10B981),
      Color(0xFFA855F7),
      Color(0xFFF43F5E),
    ];
    final colorIndex = initials.codeUnitAt(0) % avatarColors.length;

    if (profilePicture != null && profilePicture.isNotEmpty) {
      return CircleAvatar(
        radius: 26.r,
        backgroundImage: NetworkImage(profilePicture),
        backgroundColor: avatarColors[colorIndex],
      );
    }

    return CircleAvatar(
      radius: 26.r,
      backgroundColor: avatarColors[colorIndex],
      child: Text(
        initials,
        style: TextStyle(
          color: textColors[colorIndex],
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 48.sp,
              color: AppColors.primary,
            ),
          ),
          20.hGap,
          Text(
            'No Mentors Yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          8.hGap,
          Text(
            'Tap + to register your first mentor.',
            style: TextStyle(fontSize: 13.sp, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 40.sp, color: AppColors.red500),
            12.hGap,
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.gray500, fontSize: 14.sp),
            ),
            16.hGap,
            ElevatedButton(
              onPressed:
                  () => context.read<MentorBloc>().add(FetchMentorList()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.length == 1 && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'M';
  }
}
