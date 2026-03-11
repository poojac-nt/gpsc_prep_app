import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/presentation/blocs/download%20pdf/download_pdf_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/study_material_widgets.dart';

import '../../../../core/di/di.dart';
import '../../../blocs/study_material/study_material_bloc.dart';

class StudyMaterialListScreen extends StatefulWidget {
  final String selectedLanguage;
  final String? highlightedMaterialId;

  const StudyMaterialListScreen({
    super.key,
    required this.selectedLanguage,
    this.highlightedMaterialId,
  });

  @override
  State<StudyMaterialListScreen> createState() =>
      _StudyMaterialListScreenState();
}

class _StudyMaterialListScreenState extends State<StudyMaterialListScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {}; // index -> key

  String? _highlightedId;
  Timer? _removeHighlightTimer;
  bool _hasScrolledToTarget = false;

  @override
  void initState() {
    super.initState();

    _highlightedId = widget.highlightedMaterialId;
    final bloc = context.read<StudyMaterialBloc>();

    if (bloc.state is! StudyMaterialLoaded) {
      bloc.add(FetchStudyMaterial());
    }
  }

  @override
  void didUpdateWidget(covariant StudyMaterialListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.highlightedMaterialId != widget.highlightedMaterialId) {
      _highlightedId = widget.highlightedMaterialId;
      _hasScrolledToTarget = false;
    }

    if (oldWidget.selectedLanguage != widget.selectedLanguage) {
      _hasScrolledToTarget = false;
    }
  }

  void _scrollToTarget(int targetIndex) {
    if (_hasScrolledToTarget) {
      return;
    }

    // Wait for ListView to build all items up to target
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      // Wait one more frame for items to be laid out
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        final key = _itemKeys[targetIndex];
        if (key?.currentContext == null) {
          _scrollByEstimate(targetIndex);
          return;
        }

        try {
          _hasScrolledToTarget = true;

          final RenderObject? renderObject =
              key!.currentContext!.findRenderObject();
          if (renderObject is RenderBox) {
            final position = renderObject.localToGlobal(Offset.zero);
            debugPrint("📍 Item position: $position");
          }

          await Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
            alignment: 0.15,
            alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
          );

          debugPrint("🎉 Successfully scrolled to index $targetIndex");

          _removeHighlightTimer?.cancel();
          _removeHighlightTimer = Timer(const Duration(seconds: 5), () {
            if (mounted) {
              debugPrint("⏰ Removing highlight after 2 seconds");
              setState(() => _highlightedId = null);
            }
          });
        } catch (e) {
          debugPrint("❌ Scroll error: $e");
          _scrollByEstimate(targetIndex);
        }
      });
    });
  }

  void _scrollByEstimate(int targetIndex) {
    if (_hasScrolledToTarget) return;

    debugPrint("📏 Using estimated scroll for index $targetIndex");
    _hasScrolledToTarget = true;

    const double estimatedItemHeight =
        150.0; // Adjust based on your MaterialCard
    final double targetPosition = targetIndex * estimatedItemHeight;

    _scrollController
        .animateTo(
          targetPosition,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        )
        .then((_) {
          _removeHighlightTimer?.cancel();
          _removeHighlightTimer = Timer(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() => _highlightedId = null);
            }
          });
        });
  }

  @override
  void dispose() {
    debugPrint("🧹 Disposing StudyMaterialListScreen");
    _scrollController.dispose();
    _removeHighlightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      "🔄 Building StudyMaterialListScreen - highlighted: $_highlightedId",
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Study Materials",
          style: TextStyle(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<StudyMaterialBloc>().add(FetchStudyMaterial());
          await context.read<StudyMaterialBloc>().stream.firstWhere(
            (state) =>
                state is StudyMaterialLoaded || state is StudyMaterialError,
          );
        },
        child: BlocListener<DownLoadPdfBloc, DownLoadPdfState>(
          listener: (context, state) {
            if (state is PdfDownloadFailure) {
              getIt<SnackBarHelper>().showError(
                'Unable to download study material',
              );
            }
          },
          child: BlocBuilder<StudyMaterialBloc, StudyMaterialState>(
            builder: (context, state) {
              if (state is StudyMaterialLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is StudyMaterialLoaded) {
                final materials =
                    state.materials
                        .where((e) => e.language == widget.selectedLanguage)
                        .toList();

                if (materials.isEmpty) {
                  return Center(
                    child: Text(
                      'No Materials Found for ${widget.selectedLanguage == "gj" ? "Gujarati" : "English"} language.',
                    ),
                  );
                }

                // Find index of highlighted item
                int? targetIndex;
                if (_highlightedId != null) {
                  targetIndex = materials.indexWhere(
                    (m) => m.id.toString() == _highlightedId,
                  );
                  if (targetIndex != -1) {
                    // Create keys for items
                    for (int i = 0; i < materials.length; i++) {
                      _itemKeys.putIfAbsent(i, () => GlobalKey());
                    }

                    // Schedule scroll
                    if (!_hasScrolledToTarget) {
                      _scrollToTarget(targetIndex);
                    }
                  } else {
                    debugPrint(
                      "⚠️ Highlighted ID $_highlightedId not found in materials",
                    );
                    targetIndex = null;
                  }
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(20.sp),
                  itemCount: materials.length,
                  itemBuilder: (context, index) {
                    final item = materials[index];
                    final isHighlighted = item.id.toString() == _highlightedId;

                    if (isHighlighted) {
                      debugPrint(
                        "🌟 Rendering highlighted item at index $index: ${item.id}",
                      );
                    }

                    return MaterialCard(
                      item: item,
                      index: index,
                      isHighlighted: isHighlighted,
                      key: _itemKeys[index],
                    );
                  },
                );
              }

              if (state is StudyMaterialError) {
                return const Center(child: Text('Something went wrong'));
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
