import '../../../../core/network/api_client.dart';

class WardrobeRepository {
  final ApiClient _apiClient;

  WardrobeRepository(this._apiClient);

  Future<List<Map<String, dynamic>>> getWardrobeItems() async {
    return await _apiClient.get('/wardrobe/items/');
  }

  Future<Map<String, dynamic>> uploadItem(String imagePath) async {
    return await _apiClient.uploadFile(
      '/wardrobe/upload/',
      imagePath,
      'image',
    );
  }

  Future<void> deleteItem(int itemId) async {
    await _apiClient.delete('/wardrobe/items/$itemId/');
  }

  Future<List<Map<String, dynamic>>> getOutfits() async {
    return await _apiClient.get('/wardrobe/outfits/');
  }

  Future<Map<String, dynamic>> createOutfit(List<int> itemIds, String style) async {
    return await _apiClient.post('/wardrobe/outfits/', {
      'items': itemIds,
      'style': style,
    });
  }

  Future<void> deleteOutfit(int outfitId) async {
    await _apiClient.delete('/wardrobe/outfits/$outfitId/');
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    return await _apiClient.get('/wardrobe/categories/');
  }

  Future<List<Map<String, dynamic>>> getColors() async {
    return await _apiClient.get('/wardrobe/colors/');
  }

  Future<List<Map<String, dynamic>>> getStyles() async {
    return await _apiClient.get('/wardrobe/styles/');
  }
} 