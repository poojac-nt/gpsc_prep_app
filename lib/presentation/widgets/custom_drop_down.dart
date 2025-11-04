import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/domain/entities/test_without_material_model.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

class CustomTestDropdown extends StatefulWidget {
  final List<TestWithoutMaterial> items;
  final int? selectedValue;
  final String hint;
  final ValueChanged<int?> onChanged;

  const CustomTestDropdown({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.hint,
    required this.onChanged,
  });

  @override
  State<CustomTestDropdown> createState() => _CustomTestDropdownState();
}

class _CustomTestDropdownState extends State<CustomTestDropdown>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (isExpanded) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    setState(() => isExpanded = true);
    _controller.forward();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropdown() {
    setState(() => isExpanded = false);
    _controller.reverse().then((_) => _removeOverlay());
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder:
          (context) => GestureDetector(
            onTap: _closeDropdown,
            behavior: HitTestBehavior.translucent,
            child: Stack(
              children: [
                Positioned(
                  width: size.width,
                  child: CompositedTransformFollower(
                    link: _layerLink,
                    showWhenUnlinked: false,
                    offset: Offset(0, size.height + 4.h),
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12.r),
                      child: FadeTransition(
                        opacity: _animation,
                        child: SizeTransition(
                          sizeFactor: _animation,
                          axisAlignment: -1,
                          child: Container(
                            constraints: BoxConstraints(maxHeight: 200.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              shrinkWrap: true,
                              itemCount: widget.items.length,
                              itemBuilder: (context, index) {
                                final item = widget.items[index];
                                final isSelected =
                                    widget.selectedValue == item.id;
                                return InkWell(
                                  onTap: () {
                                    widget.onChanged(item.id);
                                    _closeDropdown();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 12.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? Colors.black.withValues(
                                                alpha: 0.05,
                                              )
                                              : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              color:
                                                  isSelected
                                                      ? Colors.black
                                                      : Colors.grey[800],
                                              fontWeight:
                                                  isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check,
                                            size: 20.sp,
                                            color: Colors.black,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedItem =
        widget.selectedValue != null
            ? widget.items.firstWhere((item) => item.id == widget.selectedValue)
            : null;

    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleDropdown,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isExpanded ? Colors.black : AppColors.accentColor,
              width: isExpanded ? 2.w : 1.w,
            ),
            boxShadow: [
              if (isExpanded)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedItem?.name ?? widget.hint,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color:
                        selectedItem != null
                            ? Colors.grey[800]
                            : Colors.grey[500],
                    fontWeight:
                        selectedItem != null
                            ? FontWeight.w500
                            : FontWeight.normal,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 22.sp,
                  color: isExpanded ? Colors.black : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
