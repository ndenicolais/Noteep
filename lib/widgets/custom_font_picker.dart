import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomFontPicker extends StatefulWidget {
  final String pickerFont;
  final ValueChanged<String> onFontChanged;
  final List<String> availableFonts;

  const CustomFontPicker({
    super.key,
    required this.pickerFont,
    required this.onFontChanged,
    required this.availableFonts,
  });

  @override
  CustomFontPickerState createState() => CustomFontPickerState();
}

class CustomFontPickerState extends State<CustomFontPicker> {
  late String _selectedFont;

  @override
  void initState() {
    super.initState();
    _selectedFont = widget.pickerFont;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.availableFonts.length,
      itemBuilder: (context, index) {
        final font = widget.availableFonts[index];
        final isSelected = _selectedFont == font;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedFont = font;
            });
            widget.onFontChanged(font);
          },
          child: Container(
            width: 100.w,
            height: 40.h,
            margin: EdgeInsets.symmetric(horizontal: 5.r),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey,
                width: isSelected ? 2.0 : 1.0,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Text(
                font,
                style: GoogleFonts.getFont(
                  font,
                  color: Colors.black,
                  fontSize: 18.sp,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
