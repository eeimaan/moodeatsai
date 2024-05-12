import 'package:flutter/material.dart';

class AllergiesModel extends ChangeNotifier {
  Set<String> _selectedAllergies = {};

  Set<String> get selectedAllergies => _selectedAllergies;

  void addAllergy(String allergy) {
    _selectedAllergies.add(allergy);
    notifyListeners();
  }

  void removeAllergy(String allergy) {
    _selectedAllergies.remove(allergy);
    notifyListeners();
  }
}
