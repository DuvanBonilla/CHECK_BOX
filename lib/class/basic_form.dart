import 'package:flutter/material.dart';

class BasicForm {
  final TextEditingController _name = TextEditingController();
  late FocusNode _focusNode; // Actualiza la declaración del campo como 'late'

  List<String> _options = const [];
  String _selectedValue = '';
  bool hasFocus = true;

  BasicForm(options, selectedValue, FocusNode focusNode) {
    // Agrega 'late' al parámetro del constructor
    _options = options;
    _selectedValue = selectedValue.isNotEmpty ? selectedValue : options[0];
    _focusNode = focusNode; // Elimina 'late' aquí, ya que el campo es 'late'
  }
  void requestFocus() {
    _focusNode.requestFocus();
  }

  FocusNode get focusNode => _focusNode;
  TextEditingController get name => _name;

  String get getSelectedValue => _selectedValue;

  void setSelectedValue(String selectedValue) {
    _selectedValue = selectedValue;
  }

  List<String> get getOptions => _options;
}
