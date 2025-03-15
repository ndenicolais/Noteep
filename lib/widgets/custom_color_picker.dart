import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:noteep/theme/app_colors.dart';

class CustomBlockPicker extends StatefulWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final List<Color> availableColors;

  const CustomBlockPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
    required this.availableColors,
  });

  @override
  CustomBlockPickerState createState() => CustomBlockPickerState();
}

class CustomBlockPickerState extends State<CustomBlockPicker> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.pickerColor;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.availableColors.length,
      itemBuilder: (context, index) {
        final color = widget.availableColors[index];
        final isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
            widget.onColorChanged(color);
          },
          child: Container(
            width: 40.w,
            height: 40.h,
            margin: EdgeInsets.symmetric(horizontal: 5.r),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: isSelected ? AppColors.featureDark : AppColors.baseDark,
                width: isSelected ? 2.0 : 1.0,
              ),
              shape: BoxShape.circle,
            ),
            child: isSelected
                ? Center(
                    child: Icon(
                      MingCuteIcons.mgc_check_line,
                      color: AppColors.featureDark,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
