import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../colors/app_colors.dart';

class CustomInputAuth extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isPass;
  final RxBool? obscureValue;
  final VoidCallback? toggleVisibility;
  final Function(String)? onChanged;
  final RxnString? errorText;
  final RxBool? isValid;
  final Widget? bottomWidget;

  final String? Function(String?)? validator;

  const CustomInputAuth({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isPass = false,
    this.obscureValue,
    this.toggleVisibility,
    this.onChanged,
    this.errorText,
    this.isValid,
    this.bottomWidget,
    this.validator,
  });

  @override
  State<CustomInputAuth> createState() => _CustomInputAuthState();
}

class _CustomInputAuthState extends State<CustomInputAuth> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isPass;
  }

  void _toggleObscure() {
    if (widget.toggleVisibility != null) {
      widget.toggleVisibility!();
    } else {
      setState(() {
        _isObscured = !_isObscured;
      });
    }
  }

  Widget? _buildSuffixIconContent(bool isObscure) {
    // Only read `.value` if isValid exists
    final showCheck = widget.isValid != null && widget.isValid!.value == true;

    if (widget.isPass) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (showCheck)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.check_circle, color: Colors.green, size: 20),
            ),
          IconButton(
            icon: Icon(
              isObscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: _toggleObscure,
          ),
        ],
      );
    } else {
      if (showCheck) {
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      }
      return null;
    }
  }

  Widget _buildTextField(bool isObscure) {
    return TextFormField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.orange),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        suffixIcon: widget.isValid != null
            ? Obx(() {
                // Determine obscure within the context so icon adjusts if external bool changes
                final currentObscure = widget.obscureValue?.value ?? isObscure;
                return _buildSuffixIconContent(currentObscure) ??
                    const SizedBox.shrink();
              })
            : _buildSuffixIconContent(isObscure),
        errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.obscureValue != null)
          Obx(() => _buildTextField(widget.obscureValue!.value))
        else
          _buildTextField(_isObscured),
        if (widget.bottomWidget != null) widget.bottomWidget!,
      ],
    );
  }
}
