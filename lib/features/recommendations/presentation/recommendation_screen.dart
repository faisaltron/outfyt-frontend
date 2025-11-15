import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import for robust image loading
import 'controllers/recommendation_controller.dart';
import '../data/models/outfit.dart'; // Ensure this path is correct for your SIMPLIFIED Outfit model

// Define a common color for consistency
const Color kPrimaryRecommendationColor = Color(0xFFD00A62);

class RecommendationScreen extends ConsumerWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recommendationProvider);
    final controller = ref.read(recommendationProvider.notifier);
    final size = MediaQuery.of(context).size;

    // Define a consistent size for outfit item images
    final double outfitItemSize = size.width * 0.4; // e.g., 40% of screen width

    // Get the current recommended outfit (if available)
    final currentOutfit = state.recommendations.isNotEmpty
        ? state.recommendations.first
        : null;

    Widget bodyContent;
    if (state.isLoading && state.recommendations.isEmpty) { // Check if initial load and no previous items
      bodyContent = const Center(child: CircularProgressIndicator(color: kPrimaryRecommendationColor));
    } else if (state.error != null && state.recommendations.isEmpty) { // Check if initial load error and no previous items
      bodyContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.refreshRecommendations(), // Retry button
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryRecommendationColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      );
    } else if (currentOutfit == null || (currentOutfit.topImageUrl == null && currentOutfit.bottomImageUrl == null && currentOutfit.footwearImageUrl == null)) {
      // Updated condition for empty/no recommendations
      bodyContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.checkroom, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'No recommendations yet!\nUpload more items to your wardrobe to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement navigation to Wardrobe screen
                // Navigator.of(context).push(MaterialPageRoute(builder: (_) => WardrobeScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryRecommendationColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text('Add Items to Wardrobe', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      );
    } else {
      // Display the outfit using direct image URLs
      bodyContent = Stack(
        children: [
          // Main clothing items column - Centered to occupy available space
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Vertically center the items
              children: [
                // Top item - Always first
                _buildClothingItem(
                  imageUrl: currentOutfit.topImageUrl,
                  category: 'Top',
                  size: outfitItemSize, // Equal size
                ),
                const SizedBox(height: 16), // Spacing between items

                // Bottom item - Always second
                _buildClothingItem(
                  imageUrl: currentOutfit.bottomImageUrl,
                  category: 'Bottom',
                  size: outfitItemSize, // Equal size
                ),
                const SizedBox(height: 16), // Spacing between items

                // Footwear item - Always third
                _buildClothingItem(
                  imageUrl: currentOutfit.footwearImageUrl,
                  category: 'Footwear',
                  size: outfitItemSize, // Equal size
                ),
                const SizedBox(height: 24), // Spacing before the refresh button
                // Refresh button for new recommendation (moved back to body)
                ElevatedButton.icon(
                  onPressed: () => controller.refreshRecommendations(),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text('Next Outfit', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryRecommendationColor, // Pink color
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          // Action buttons on the right - Adjusted position to be relative to the column of clothes
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.5 - (outfitItemSize * 1.5 + 16) / 2,
            child: _buildActionButtons(
              controller: controller,
              currentOutfit: currentOutfit,
              isCurrentOutfitSaved: state.isCurrentOutfitSaved,
              isCurrentOutfitBookmarked: state.isCurrentOutfitBookmarked, // Pass the new bookmark state
              selectedButtonIndex: state.selectedButtonIndex,
            ),
          ),
          // Show overlay loading indicator if refreshing content
          if (state.isLoading && state.recommendations.isNotEmpty) // If loading after first display
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator(color: kPrimaryRecommendationColor)),
              ),
            ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white, // Prevents tinting on scroll (Android 12+)
        shadowColor: Colors.grey.withOpacity(0.2), // Subtle shadow
        elevation: 1.0, // A small elevation for definition
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 22, color: Colors.black87), // Increased size
          onPressed: () => Navigator.pop(context), // Pop from the current route
          tooltip: 'Back',
        ),
        title: const Text(
          'Recommendation',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        // AppBar actions are now empty as per your request
        actions: const [
          // No refresh button here now
          SizedBox(width: 8), // Just a little spacing if needed, or remove if no other actions
        ],
      ),
      body: SafeArea(child: bodyContent),
    );
  }

  // --- _buildClothingItem (no changes needed) ---
  Widget _buildClothingItem({
    required String? imageUrl,
    required String category,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16), // Nicer rounded corners
        color: const Color(0xFFF0F0F0), // Default background for empty state
        boxShadow: [ // Subtle shadow for depth
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, // Clip image to rounded corners
      child: imageUrl != null && imageUrl.isNotEmpty
          ? CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover, // Cover the entire area of the container
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: kPrimaryRecommendationColor.withOpacity(0.7),
          ),
        ),
        errorWidget: (context, url, error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: size * 0.3, color: Colors.grey.shade400),
              Text(
                category,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
              ),
            ],
          ),
        ),
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: size * 0.3, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'No $category',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // --- _buildActionButtons (MODIFIED) ---
  Widget _buildActionButtons({
    required RecommendationController controller,
    required Outfit? currentOutfit,
    required bool isCurrentOutfitSaved,
    required bool isCurrentOutfitBookmarked, // Receive the new bookmark state
    required int selectedButtonIndex,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // View Saved Outfits Button (Bookmark Icon) - persistent toggle
        _buildActionButton(
          icon: isCurrentOutfitBookmarked ? Icons.bookmark : Icons.bookmark_border, // Toggled icon
          isPrimary: isCurrentOutfitBookmarked, // Color based on its own persistent state
          onPressed: () {
            if (currentOutfit == null) return;
            controller.toggleBookmarkStatus(currentOutfit); // Call the new toggle method
            // Do NOT call setSelectedButton here, as this is a persistent toggle
          },
          tooltip: isCurrentOutfitBookmarked ? 'Unbookmark Outfit' : 'Bookmark Outfit',
        ),
        const SizedBox(height: 16),

        // Like/Save button (Heart Icon) - persistent toggle
        _buildActionButton(
          icon: isCurrentOutfitSaved ? Icons.favorite : Icons.favorite_border,
          isPrimary: isCurrentOutfitSaved, // Color based on its own persistent state
          onPressed: () {
            if (currentOutfit == null) return; // Prevent action if no outfit
            controller.toggleSaveStatus(currentOutfit);
            // Do NOT call setSelectedButton here, as this is a persistent toggle
          },
          tooltip: isCurrentOutfitSaved ? 'Unsave Outfit' : 'Save Outfit',
        ),
        const SizedBox(height: 16),

        // Share button - temporary highlight
        _buildActionButton(
          icon: Icons.share,
          isPrimary: selectedButtonIndex == 2, // Color based on temporary selected index
          onPressed: () {
            controller.setSelectedButton(2); // Set index for temporary highlight
            // TODO: Implement share logic
          },
          tooltip: 'Share Outfit',
        ),
        const SizedBox(height: 16),

        // More options button - temporary highlight
        _buildActionButton(
          icon: Icons.more_vert,
          isPrimary: selectedButtonIndex == 3, // Color based on temporary selected index
          onPressed: () {
            controller.setSelectedButton(3); // Set index for temporary highlight
            // TODO: Implement more options logic
          },
          tooltip: 'More Options',
        ),
      ],
    );
  }

  // --- _buildActionButton (no changes needed) ---
  Widget _buildActionButton({
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPrimary ? kPrimaryRecommendationColor : const Color(0xFFE7E7E7),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 24, color: isPrimary ? Colors.white : Colors.black87),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}