import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/share_helper.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/all_tests_model.dart';
import 'package:gpsc_prep_app/domain/entities/course_model.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/admin/all_test/all_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/download%20pdf/download_pdf_bloc.dart';
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
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          context.read<AllTestBloc>().add(FetchAllTests());
        },
        child: Column(
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
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Center(child: Text(state.message)),
                        ),
                      ],
                    );
                  }
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
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
      tests = allTests.prelims
          .map((e) => _TestItemData(test: e, type: TestType.prelims))
          .toList();
    } else if (_selectedFilter == 'MCQ') {
      tests = allTests.mcq
          .map((e) => _TestItemData(test: e, type: TestType.mcq))
          .toList();
    } else if (_selectedFilter == 'Descriptive') {
      tests = allTests.descriptive
          .map((e) => _TestItemData(test: e, type: TestType.desc))
          .toList();
    } else if (_selectedFilter == 'Mains') {
      tests = allTests.mains
          .map((e) => _TestItemData(test: e, type: TestType.mains))
          .toList();
    }
    if (tests.isEmpty) {
      final message = 'No tests found';
      return Center(child: Text(message));
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
    if (data.test is CourseModel) {
      final course = data.test as CourseModel;
      final int totalTests =
          (course.tests?.prelims?.length ?? 0) +
          (course.tests?.descriptive?.length ?? 0);

      return TestModule(
        title: course.name,
        fontSize: 16.sp,
        showShareButton: true,
        onShareTap: () async {
          await ShareHelper.shareCourse(course);
        },
        cards: [
          4.hGap,
          _buildInfoTag(
            Icons.assignment_outlined,
            '$totalTests Tests',
            Colors.blueGrey,
          ),
        ],
      );
    }

    final dynamic test = data.test;
    final String name = test.name ?? "";
    final int attempts = (test is TestModel)
        ? (test.totalAttempt ?? 0)
        : (test is DescTestModel ? (test.totalAttempt ?? 0) : 0);

    final bool showShare =
        data.type != TestType.prelims && data.type != TestType.mains;

    final bool showDownload = data.type == TestType.desc;

    final bool showTag = _selectedFilter == 'All';

    return TestModule(
      header: showTag ? _buildTypeTag(data) : null,
      title: name,
      fontSize: 16.sp,
      testType: data.type!,
      showShareButton: showShare,
      testModel: test is TestModel ? test : null,
      descTestModel: test is DescTestModel ? test : null,
      trailing: showDownload
          ? IconButton(
              icon: Icon(
                Icons.download_for_offline_rounded,
                color: AppColors.primary,
                size: 24.sp,
              ),
              onPressed: () => _showDownloadOptions(
                test,
                isDescriptive: data.type == TestType.desc,
              ),
            )
          : null,
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
    String label = data.type!.name.toUpperCase();
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
      case null:
        // TODO: Handle this case.
        throw UnimplementedError();
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

  void _showDownloadOptions(dynamic test, {required bool isDescriptive}) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  "Download Options",
                  style: AppTexts.titleTextStyle.copyWith(fontSize: 18.sp),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text("Question Paper"),
                onTap: () {
                  Navigator.pop(context);
                  _handleDownload(test, isDescriptive, showAnswers: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment_turned_in_outlined),
                title: const Text("Model Answer"),
                onTap: () {
                  Navigator.pop(context);
                  _handleDownload(test, isDescriptive, showAnswers: true);
                },
              ),
              20.hGap,
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleDownload(
    dynamic test,
    bool isDescriptive, {
    required bool showAnswers,
  }) async {
    final downloadBloc = context.read<DownLoadPdfBloc>();
    final testRepo = getIt<TestRepository>();

    try {
      if (isDescriptive) {
        final result = await testRepo.fetchDescTestQuestions(test.id);
        result.fold(
          (failure) {
            getIt<LogHelper>().e(failure.message);
            getIt<SnackBarHelper>().showError(failure.message);
          },
          (questions) {
            downloadBloc.add(
              DownloadFullDescTestPdf(
                questions: questions,
                testName: test.name,
                langCodes: test.allowedLanguages ?? ['en'],
                showAnswers: showAnswers,
              ),
            );
          },
        );
      } else {
        if (!showAnswers && test.omrLink != null && test.omrLink.isNotEmpty) {
          downloadBloc.add(
            DownloadPrelimsOmr(
              url: test.omrLink,
              filename: "${test.name.replaceAll(' ', '_')}_QuestionPaper.pdf",
            ),
          );
        } else {
          final result = await testRepo.fetchMcqTestQuestions(test.id);
          result.fold(
            (failure) {
              getIt<LogHelper>().e(failure.message);
              getIt<SnackBarHelper>().showError(failure.message);
            },
            (questions) {
              downloadBloc.add(
                ExportQuestionsToPdfEvent(
                  questions,
                  test.name,
                  testType: TestType.prelims,
                  showAnswers: showAnswers,
                  language: 'en',
                  languages: test.allowedLanguages ?? ['en'],
                ),
              );
            },
          );
        }
      }
    } catch (e) {
      getIt<LogHelper>().e("An error occurred: $e");
      getIt<SnackBarHelper>().showError("An error occurred: $e");
    }
  }
}

class _TestItemData {
  final dynamic test;
  final TestType? type;

  _TestItemData({required this.test, this.type});
}
