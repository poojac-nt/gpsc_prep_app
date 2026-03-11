import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/domain/entities/all_tests_model.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/admin/all_test/all_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/services/test_link_generator.dart';

class AllTestScreen extends StatefulWidget {
  const AllTestScreen({super.key});

  @override
  State<AllTestScreen> createState() => _AllTestScreenState();
}

class _AllTestScreenState extends State<AllTestScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'All Tests',
          style: AppTexts.titleTextStyle.copyWith(fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: BlocBuilder<AllTestBloc, AllTestState>(
              builder: (context, state) {
                if (state is AllTestLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AllTestLoaded) {
                  return _buildTestList(state.allTests);
                } else if (state is AllTestError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['All', 'Prelims', 'MCQ', 'Mains', 'Descriptive'];
    return Container(
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => 8.wGap,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return FilterChip(
            showCheckmark: false,
            label: Text(
              filter,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            selectedColor: AppColors.primary,
            backgroundColor: Colors.white,
            checkmarkColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.r),
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                width: 1,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTestList(AllTestsModel allTests) {
    List<_TestItemData> tests = [];

    if (_selectedFilter == 'All') {
      tests = [
        ...allTests.prelims.map(
          (e) => _TestItemData(test: e, type: TestType.prelims),
        ),
        ...allTests.mcq.map((e) => _TestItemData(test: e, type: TestType.mcq)),
        ...allTests.descriptive.map(
          (e) => _TestItemData(test: e, type: TestType.desc),
        ),
        ...allTests.mains.map(
          (e) => _TestItemData(test: e, type: TestType.mains),
        ),
      ];
    } else if (_selectedFilter == 'Prelims') {
      tests =
          allTests.prelims
              .map((e) => _TestItemData(test: e, type: TestType.prelims))
              .toList();
    } else if (_selectedFilter == 'MCQ') {
      tests =
          allTests.mcq
              .map((e) => _TestItemData(test: e, type: TestType.mcq))
              .toList();
    } else if (_selectedFilter == 'Descriptive') {
      tests =
          allTests.descriptive
              .map((e) => _TestItemData(test: e, type: TestType.desc))
              .toList();
    } else if (_selectedFilter == 'Mains') {
      tests =
          allTests.mains
              .map((e) => _TestItemData(test: e, type: TestType.mains))
              .toList();
    }

    if (tests.isEmpty) {
      return const Center(child: Text('No tests found'));
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: tests.length,
      separatorBuilder: (context, index) => 12.hGap,
      itemBuilder: (context, index) {
        final data = tests[index];
        return _buildTestCard(data);
      },
    );
  }

  Widget _buildTestCard(_TestItemData data) {
    final String name = data.test.name;
    final int attempts = data.test.totalAttempt ?? 0;

    final bool showShare =
        data.type != TestType.prelims && data.type != TestType.mains;
    final bool showTag = _selectedFilter == 'All';

    return TestModule(
      header: showTag ? _buildTypeTag(data) : null,
      title: name,
      fontSize: 16.sp,
      testType: data.type,
      showShareButton: showShare,
      testModel: data.test is TestModel ? data.test as TestModel : null,
      descTestModel:
          data.test is DescTestModel ? data.test as DescTestModel : null,
      cards: [
        showShare ? 4.hGap : 8.hGap,
        _buildInfoTag(
          Icons.group_outlined,
          '$attempts Attempts',
          Colors.blueGrey,
        ),
      ],
    );
  }

  Widget _buildInfoTag(IconData icon, String label, Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.sp, color: iconColor),
        6.wGap,
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeTag(_TestItemData data) {
    Color color;
    String label = data.type.name.toUpperCase();
    switch (data.type) {
      case TestType.mcq:
        color = Colors.blue;
        break;
      case TestType.desc:
        color = Colors.orange;
        break;
      case TestType.prelims:
        color = Colors.green;
        break;
      case TestType.mains:
        color = Colors.teal;
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _TestItemData {
  final dynamic test;
  final TestType type;

  _TestItemData({required this.test, required this.type});
}
