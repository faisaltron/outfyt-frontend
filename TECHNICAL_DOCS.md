# Fashion App - Technical Documentation

## Core Components

### 1. API Service (`lib/core/network/api_client.dart`)
The API service is the backbone of all network communications. It handles:
- Token management
- Request/response handling
- Error processing
- Retry logic

```dart
class ApiService {
  // Token management
  String? _authToken;
  DateTime? _tokenExpiry;
  
  // Request methods
  Future<dynamic> get(String endpoint) async {
    await ensureValidToken();
    // Make GET request
  }
  
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    await ensureValidToken();
    // Make POST request
  }
}
```

### 2. Authentication Service (`lib/core/services/auth_service.dart`)
Handles user authentication and session management:
- Firebase authentication
- Django token management
- User session persistence

```dart
class AuthService {
  final ApiService _apiService;
  
  Future<void> login(String email, String password) async {
    // 1. Firebase auth
    // 2. Get Django token
    // 3. Store session
  }
}
```

### 3. Wardrobe Service (`lib/features/wardrobe/data/services/wardrobe_service.dart`)
Manages clothing items and their metadata:
- Image upload
- Category management
- Style detection
- Color analysis

```dart
class WardrobeService {
  Future<WardrobeItem> uploadItem(File image) async {
    // 1. Upload image
    // 2. Process image
    // 3. Save metadata
  }
}
```

### 4. Recommendation Service (`lib/features/recommendations/data/services/recommendation_service.dart`)
Generates outfit recommendations:
- Style matching
- Color coordination
- Occasion-based recommendations

```dart
class RecommendationService {
  Future<List<Outfit>> getRecommendations() async {
    // 1. Get user preferences
    // 2. Generate outfits
    // 3. Return recommendations
  }
}
```

## State Management

### 1. Auth State (`lib/features/auth/presentation/controllers/auth_controller.dart`)
```dart
enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthController extends StateNotifier<AuthStatus> {
  // State management for authentication
}
```

### 2. Wardrobe State (`lib/features/wardrobe/presentation/controllers/wardrobe_controller.dart`)
```dart
class WardrobeState {
  final List<WardrobeItem> items;
  final bool isLoading;
  final String? error;
}
```

### 3. Recommendation State (`lib/features/recommendations/presentation/controllers/recommendation_controller.dart`)
```dart
class RecommendationState {
  final List<Outfit> recommendations;
  final List<Outfit> savedOutfits;
  final bool isLoading;
  final String? error;
}
```

## Data Models

### 1. WardrobeItem (`lib/features/wardrobe/data/models/wardrobe_item.dart`)
```dart
class WardrobeItem {
  final String id;
  final String name;
  final String category;
  final List<String> styles;
  final List<String> colors;
  final String imageUrl;
  final DateTime createdAt;
}
```

### 2. Outfit (`lib/features/recommendations/data/models/outfit.dart`)
```dart
class Outfit {
  final String id;
  final String name;
  final List<String> itemIds;
  final List<String> styles;
  final List<String> colors;
  final String occasion;
  final String season;
}
```

## API Endpoints

### Authentication
```dart
class ApiConfig {
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  static const String logout = '/auth/logout/';
  static const String refreshToken = '/auth/token/refresh/';
}
```

### Wardrobe
```dart
class ApiConfig {
  static const String wardrobeItems = '/wardrobe/items/';
  static const String uploadImage = '/wardrobe/upload/';
  static const String deleteItem = '/wardrobe/items/';
  static const String updateCategory = '/wardrobe/items/';
}
```

### Recommendations
```dart
class ApiConfig {
  static const String getRecommendations = '/outfits/recommend/';
  static const String saveOutfit = '/outfits/save/';
  static const String getSavedOutfits = '/outfits/saved/';
  static const String deleteOutfit = '/outfits/';
}
```

## Error Handling

### 1. API Exceptions
```dart
class ApiException implements Exception {
  final int statusCode;
  final String message;
  
  ApiException(this.statusCode, this.message);
}
```

### 2. Error Processing
```dart
Exception _handleError(dynamic error) {
  if (error is ApiException) return error;
  if (error is SocketException) {
    return ApiException(0, 'Network error: ${error.message}');
  }
  return ApiException(500, error.toString());
}
```

## File Upload

### 1. Image Upload
```dart
Future<String> uploadImage(File image) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('${ApiConfig.baseUrl}${ApiConfig.uploadImage}'),
  );
  
  request.files.add(
    await http.MultipartFile.fromPath('image', image.path),
  );
  
  final response = await request.send();
  // Process response
}
```

### 2. Background Removal
```dart
Future<File> removeBackground(File image) async {
  // 1. Upload to processing service
  // 2. Get processed image
  // 3. Save locally
}
```

## Caching

### 1. Local Storage
```dart
class LocalStorageService {
  static Future<void> saveUser(String userId) async {
    // Save user data
  }
  
  static Future<void> saveWardrobeItems(List<WardrobeItem> items) async {
    // Cache wardrobe items
  }
}
```

### 2. Image Caching
```dart
class ImageCache {
  static Future<File> getImage(String url) async {
    // Check cache
    // Download if not cached
    // Save to cache
  }
}
```

## Testing

### 1. Unit Tests
```dart
void main() {
  group('WardrobeService', () {
    test('uploadItem should return WardrobeItem', () async {
      // Test implementation
    });
  });
}
```

### 2. Integration Tests
```dart
void main() {
  integrationTest('end-to-end outfit recommendation', (tester) async {
    // Test implementation
  });
}
```

## Performance Optimization

### 1. Image Processing
```dart
Future<File> optimizeImage(File image) async {
  // 1. Resize image
  // 2. Compress image
  // 3. Save optimized image
}
```

### 2. API Caching
```dart
class ApiCache {
  static final Map<String, dynamic> _cache = {};
  
  static Future<dynamic> get(String key, Future<dynamic> Function() fetcher) async {
    // Check cache
    // Fetch if not cached
    // Update cache
  }
}
```

## Security

### 1. Token Management
```dart
class TokenManager {
  static Future<void> refreshToken() async {
    // 1. Check token expiry
    // 2. Request new token
    // 3. Update token
  }
}
```

### 2. Data Encryption
```dart
class Encryption {
  static String encrypt(String data) {
    // Encrypt sensitive data
  }
  
  static String decrypt(String encryptedData) {
    // Decrypt data
  }
}
```

## Logging

### 1. Error Logging
```dart
class Logger {
  static void logError(String message, dynamic error) {
    // Log to analytics
    // Log to crash reporting
  }
}
```

### 2. Performance Logging
```dart
class PerformanceLogger {
  static void logApiCall(String endpoint, Duration duration) {
    // Log API performance
  }
}
```

## Deployment

### 1. Environment Configuration
```dart
class Environment {
  static const String apiUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );
}
```

### 2. Release Configuration
```dart
class ReleaseConfig {
  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: false,
  );
}
```

## Maintenance

### 1. Code Organization
- Follow feature-first architecture
- Keep services modular
- Maintain clear separation of concerns

### 2. Documentation
- Keep API documentation updated
- Document complex algorithms
- Maintain changelog

### 3. Testing
- Maintain test coverage
- Update tests with new features
- Regular performance testing

## Troubleshooting

### 1. Common Issues
- Token expiration
- Network connectivity
- Image upload failures
- Cache invalidation

### 2. Debug Tools
- Network inspector
- State inspector
- Performance profiler
- Error tracking

## Best Practices

### 1. Code Style
- Follow Flutter style guide
- Use meaningful variable names
- Keep functions small and focused

### 2. Error Handling
- Use specific exception types
- Provide meaningful error messages
- Implement proper error recovery

### 3. Performance
- Optimize image sizes
- Implement proper caching
- Use lazy loading
- Monitor memory usage 