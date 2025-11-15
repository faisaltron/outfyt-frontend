import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/providers.dart';
import '../../data/services/wardrobe_service.dart';
import '../../data/models/wardrobe_item.dart';
import 'package:flutter/material.dart';
import 'package:new_fashion_app/core/network/api_client.dart';

// State class for wardrobe (no changes needed)
class WardrobeState {
  final List<WardrobeItem> items;
  final String selectedCategory;
  final bool isLoading;
  final String? error;

  final List<String> canonicalCategories = const ['All', 'Top', 'Bottom', 'Footwear'];

  WardrobeState({
    required this.items,
    this.selectedCategory = 'All',
    this.isLoading = false,
    this.error,
  });

  WardrobeState copyWith({
    List<WardrobeItem>? items,
    String? selectedCategory,
    bool? isLoading,
    String? error,
  }) {
    return WardrobeState(
      items: items ?? this.items,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Provider for wardrobe state (no changes needed)
final wardrobeProvider = StateNotifierProvider.autoDispose<WardrobeController, WardrobeState>((ref) {
  final wardrobeService = ref.watch(wardrobeServiceProvider);
  final apiClient = ref.watch(apiClientProvider);
  final imagePicker = ImagePicker();

  return WardrobeController(
    wardrobeService: wardrobeService,
    apiClient: apiClient,
    imagePicker: imagePicker,
  );
});

class WardrobeController extends StateNotifier<WardrobeState> {
  final WardrobeService _wardrobeService;
  final ApiClient _apiClient;
  final ImagePicker _imagePicker;

  List<String> _displayedCategories = [];
  List<String> get categories => _displayedCategories;

  String? _userGender;
  String? get userGender => _userGender;
  bool _hasInitialized = false;

  WardrobeController({
    required WardrobeService wardrobeService,
    required ApiClient apiClient,
    ImagePicker? imagePicker,
  }) : _wardrobeService = wardrobeService,
        _apiClient = apiClient,
        _imagePicker = imagePicker ?? ImagePicker(),
        super(WardrobeState(items: [])) {
    debugPrint('[WardrobeController] Constructor called');
    _init();
  }

  String get selectedCategory => state.selectedCategory;

  Future<void> _init() async {
    if (_hasInitialized) {
      debugPrint('[WardrobeController] _init skipped (already initialized)');
      return;
    }
    _hasInitialized = true;
    debugPrint('[WardrobeController] _init called');
    _setHardcodedCategories();
    await _fetchUserGender();
    await _loadItems();
  }

  void _setHardcodedCategories() {
    _displayedCategories = state.canonicalCategories;
    debugPrint('[WardrobeController] Categories hardcoded for display: $_displayedCategories');
  }

  Future<void> _fetchUserGender() async {
    try {
      final profile = await _apiClient.get('/auth/profile/');
      String? gender = profile['gender'];
      if (gender == 'M') {
        gender = 'Male';
      } else if (gender == 'F') {
        gender = 'Female';
      }
      _userGender = gender;
    } catch (e) {
      _userGender = null;
      debugPrint('Error fetching user gender: $e');
    }
  }

  Future<void> _loadItems() async {
    debugPrint('[WardrobeController] _loadItems called');
    try {
      state = state.copyWith(isLoading: true, error: null);
      final items = await _wardrobeService.getItems();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load wardrobe items: ${e.toString()}',
      );
      debugPrint('Error loading wardrobe items: $e');
    }
  }

  // MODIFIED: Now accepts ImageSource as an argument
  Future<void> pickImage(ImageSource source) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final XFile? image = await _imagePicker.pickImage(
        source: source, // Use the provided source (gallery or camera)
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        final file = File(image.path);
        final gender = _userGender;
        if (gender == null) {
          state = state.copyWith(isLoading: false, error: 'Please complete your profile (gender required)');
          return;
        }
        final newItem = await _wardrobeService.uploadItem(
          file,
          gender,
        );
        state = state.copyWith(
          items: [...state.items, newItem],
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to upload image: ${e.toString()}',
      );
      debugPrint('Error picking or uploading image: $e');
    }
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  List<WardrobeItem> getFilteredItems() {
    final selected = state.selectedCategory;
    if (selected == 'All') {
      return state.items;
    }
    return state.items.where((item) => item.category.toLowerCase() == selected.toLowerCase()).toList();
  }

  Future<void> deleteItem(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _wardrobeService.deleteItem(id);
      state = state.copyWith(
        items: state.items.where((item) => item.id != id).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete item: ${e.toString()}',
      );
      debugPrint('Error deleting item: $e');
    }
  }

  void refresh() => _loadItems();

  // MODIFIED: Now handles showing the source selection and then calling pickImage
  Future<void> pickImageWithFeedback(BuildContext context) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent, // To allow custom shape/color of the container
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Choose Image Source',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFD00A62)),
                title: const Text('Camera', style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.camera);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFFD00A62)),
                title: const Text('Gallery', style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // Close bottom sheet without selecting
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) { // Only proceed if a source was selected
      final prevCount = state.items.length;
      await pickImage(source); // Call pickImage with the selected source
      if (state.error == null && state.items.length > prevCount) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload successful! Your item will appear soon.')),
          );
        }
      } else if (state.error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${state.error}')),
        );
      }
    }
  }
}