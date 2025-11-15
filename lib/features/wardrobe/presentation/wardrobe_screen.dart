import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'controllers/wardrobe_controller.dart';
import '../data/models/wardrobe_item.dart';

// Define a common color to avoid repetition and for easier maintenance
const Color kPrimaryWardrobeColor = Color(0xFFD00A62);

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  @override
  void initState() {
    super.initState();
    // The WardrobeController's _init method now handles the initial data fetching
    // when the provider is first read/initialized.
  }

  @override
  Widget build(BuildContext context) {
    // Watch the wardrobe state for changes and rebuild the UI accordingly
    final wardrobeState = ref.watch(wardrobeProvider);
    // Read the controller for calling methods (actions)
    final controller = ref.read(wardrobeProvider.notifier);

    Widget content;
    if (wardrobeState.isLoading && wardrobeState.items.isEmpty) {
      // Show a loading indicator only if items are empty and it's the initial load
      content = const Center(child: CircularProgressIndicator(color: kPrimaryWardrobeColor));
    } else if (wardrobeState.error != null && wardrobeState.items.isEmpty) {
      // Show error message if there's an error and no items are loaded
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              wardrobeState.error!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.refresh(), // Use the specific refresh method
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryWardrobeColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12), // Added padding
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white, fontSize: 16)), // Added font size
            ),
          ],
        ),
      );
    } else {
      // Main content display (filters and grid)
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            // Build category filters, passing the currently selected category and controller
            child: _buildCategoryFilters(controller.selectedCategory, controller, controller.categories),
          ),
          Expanded(
            child: controller.getFilteredItems().isEmpty && !wardrobeState.isLoading
                ? Center( // Show empty state message if no items match filters or wardrobe is empty
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.checkroom, size: 80, color: Colors.grey),
                  const SizedBox(height: 24),
                  const Text(
                    "No clothes yet!\nUpload your first item to start building your wardrobe.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => controller.pickImageWithFeedback(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryWardrobeColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12), // Added padding
                    ),
                    child: const Text('Upload Item', style: TextStyle(color: Colors.white, fontSize: 16)), // Added font size
                  ),
                ],
              ),
            )
                : Stack( // Use Stack to show a loading indicator over the grid when refreshing
              children: [
                _buildImageGrid(controller.getFilteredItems(), controller),
                if (wardrobeState.isLoading && wardrobeState.items.isNotEmpty)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(0.5),
                      child: const Center(child: CircularProgressIndicator(color: kPrimaryWardrobeColor)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white, // Ensure Scaffold background is white
      appBar: AppBar(
        // Ensure the AppBar color remains consistent
        backgroundColor: Colors.white, // Explicitly set to white
        surfaceTintColor: Colors.white, // NEW: Prevents tinting on scroll (Android 12+)
        shadowColor: Colors.grey.withOpacity(0.2), // NEW: Subtle shadow
        elevation: 1.0, // NEW: A small elevation for definition
        title: const Text(
          'My Wardrobe',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Plus Jakarta Sans', // Ensure this font is in pubspec.yaml
            fontWeight: FontWeight.w600, // Slightly bolder for app bar title
          ),
        ),
        centerTitle: true,
        actions: [
          // Show refresh button only if not in initial loading or error state without items
          if (!wardrobeState.isLoading && wardrobeState.error == null || wardrobeState.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh, color: kPrimaryWardrobeColor),
              onPressed: () => controller.refresh(),
              tooltip: 'Refresh Wardrobe',
            ),
        ],
      ),
      body: content,
      floatingActionButton: wardrobeState.isLoading && wardrobeState.items.isEmpty
          ? null // Hide FAB during initial full screen load
          : FloatingActionButton(
        onPressed: () => controller.pickImageWithFeedback(context),
        backgroundColor: kPrimaryWardrobeColor,
        tooltip: 'Upload New Item',
        elevation: 4.0, // Added elevation
        shape: const CircleBorder(),
        child: const Icon(Icons.add_photo_alternate, color: Colors.white), // Explicitly make it a circle
      ),
    );
  }

  // Widget to build the horizontal list of category filters
  Widget _buildCategoryFilters(String selectedCategory, WardrobeController controller, List<String> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // Added a slight bottom padding to separate from grid
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: categories.map((category) {
          final isSelected = category == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 10), // Increased spacing between filters
            child: GestureDetector(
              onTap: () => controller.setCategory(category), // Set the selected category on tap
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Adjusted padding for better button feel
                decoration: ShapeDecoration(
                  color: isSelected ? kPrimaryWardrobeColor.withOpacity(0.1) : const Color(0xFFF3F4F6), // Lighter tint for selected
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: isSelected ? 1.8 : 1, // Slightly thicker border for selected
                      color: isSelected ? kPrimaryWardrobeColor : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(28), // More rounded, pill-like
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? kPrimaryWardrobeColor : const Color(0xFF121A2C),
                    fontSize: 13, // Slightly larger font
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, // Bolder when selected
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Widget to build the grid of wardrobe items
  Widget _buildImageGrid(List<WardrobeItem> items, WardrobeController controller) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), // Adjusted padding, no top padding here as filters provide it
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,        // Number of columns
        crossAxisSpacing: 16,     // Horizontal spacing
        mainAxisSpacing: 16,      // Vertical spacing
        childAspectRatio: 0.8,    // Adjusted aspect ratio for slightly taller cards
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card( // Using Card for better elevation and structure
          elevation: 3.0, // Slightly increased elevation
          clipBehavior: Clip.antiAlias, // Ensures content respects rounded corners
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners for the card
          ),
          child: Stack(
            children: [
              // Image container
              Positioned.fill(
                // Use CachedNetworkImage for robust loading with placeholders and error handling
                child: item.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover, // Cover the entire area of the card
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: kPrimaryWardrobeColor.withOpacity(0.7),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.broken_image, size: 48, color: Colors.grey)),
                )
                    : const Center(child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey)),
              ),
              // Delete button
              Positioned(
                  right: 8, // Adjusted position
                  top: 8,   // Adjusted position
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5), // Slightly more opaque
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                      onPressed: () async {
                        final confirmDelete = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Delete Item', style: TextStyle(fontWeight: FontWeight.bold)),
                            content: const Text('Are you sure you want to delete this item from your wardrobe? This action cannot be undone.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                              ),
                              ElevatedButton( // Changed to ElevatedButton for "Delete" for emphasis
                                onPressed: () => Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red, // Red for delete action
                                ),
                                child: const Text('Delete', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                        if (confirmDelete == true) {
                          controller.deleteItem(item.id);
                        }
                      },
                      tooltip: 'Delete Item',
                      padding: const EdgeInsets.all(4), // Give it some padding
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32), // Ensure tappable area
                    ),
                  )
              ),
              // Category label
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Increased padding
                  decoration: ShapeDecoration(
                    color: Colors.black.withOpacity(0.6), // Semi-transparent background
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Slightly more rounded corners
                    ),
                  ),
                  child: Text(
                    item.category.isNotEmpty ? item.category : "Uncategorized", // Display category
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11, // Slightly larger font size
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600, // Bolder
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}