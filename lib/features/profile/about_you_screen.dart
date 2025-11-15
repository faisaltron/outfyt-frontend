import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controller/about_you_controller.dart';

class AboutYouScreen extends ConsumerWidget { // <--- Changed to ConsumerWidget
  const AboutYouScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // <--- Build method for ConsumerWidget
    // Watch the controller's state to rebuild UI on changes
    final aboutYouState = ref.watch(aboutYouControllerProvider);
    // Read the controller itself to call methods
    final aboutYouController = ref.read(aboutYouControllerProvider.notifier);

    // No longer needing local state, remove these
    // String? selectedGender;
    // Set<String> selectedStyle = {};
    // bool showStyleSelection = false;
    // bool isSaving = false;

    // Use state values from the controller
    final selectedGender = aboutYouState.selectedGender;
    final selectedStyle = aboutYouState.selectedStyle;
    final showStyleSelection = aboutYouState.showStyleSelection;
    final isSaving = aboutYouState.isSaving;

    debugPrint('AboutYouScreen build called. isSaving: '
        '[32m$isSaving[0m, showStyleSelection: $showStyleSelection, selectedGender: $selectedGender, selectedStyle: $selectedStyle');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("About You", textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!showStyleSelection) ...[
                      _buildSectionTitle("Choose Gender"),
                      Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _genderButton(context, ref, "Male", selectedGender, aboutYouController), // Pass controller
                          _genderButton(context, ref, "Female", selectedGender, aboutYouController), // Pass controller
                        ],
                      ),
                      const SizedBox(height: 24),
                    ] else ...[
                      _buildSectionTitle("Which style do you associate with the most?"),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _styleButton(context, ref, "Sportswear", selectedStyle, aboutYouController), // Pass controller
                          _styleButton(context, ref, "Casual", selectedStyle, aboutYouController),     // Pass controller
                          _styleButton(context, ref, "Formal", selectedStyle, aboutYouController),     // Pass controller
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: _buildSaveButton(context, ref, isSaving, aboutYouController), // Pass controller
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for the save button
  Widget _buildSaveButton(BuildContext context, WidgetRef ref, bool isSaving, AboutYouController controller) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD00A62),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: isSaving ? null : () => controller.onSave(context), // Call controller method
        child: isSaving
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : const Text('Save', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  // Helper method for section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper method for gender buttons
  Widget _genderButton(BuildContext context, WidgetRef ref, String gender, String? selectedGender, AboutYouController controller) {
    return GestureDetector(
      onTap: () => controller.selectGender(gender), // Call controller method
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selectedGender == gender ? Colors.pink.shade100 : Colors.grey.shade200,
          border: Border.all(color: selectedGender == gender ? Colors.pink : Colors.transparent),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(gender, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
      ),
    );
  }

  // Helper method for style buttons
  Widget _styleButton(BuildContext context, WidgetRef ref, String style, Set<String> selectedStyle, AboutYouController controller) {
    bool isSelected = selectedStyle.contains(style);
    return GestureDetector(
      onTap: () => controller.selectStyle(style), // Call controller method
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink.shade100 : Colors.grey.shade200,
          border: Border.all(color: isSelected ? Colors.pink : Colors.transparent),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(style, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
      ),
    );
  }
}