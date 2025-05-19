import '../models/product.dart';
import '../utils/supabase_client.dart';

class ProductService {
  // Récupérer tous les produits
  Future<List<Product>> getAllProducts() async {
    final response = await supabase
        .from('products')
        .select()
        .order('name');
    
    return (response as List).map((item) => Product.fromJson(item)).toList();
  }

  // Récupérer les produits par catégorie
  Future<List<Product>> getProductsByCategory(String category) async {
    final response = await supabase
        .from('products')
        .select()
        .eq('category', category)
        .order('name');
    
    return (response as List).map((item) => Product.fromJson(item)).toList();
  }

  // Récupérer un produit par ID
  Future<Product> getProductById(String id) async {
    final response = await supabase
        .from('products')
        .select()
        .eq('id', id)
        .single();
    
    return Product.fromJson(response);
  }

  // Rechercher des produits
  Future<List<Product>> searchProducts(String query) async {
    final response = await supabase
        .from('products')
        .select()
        .ilike('name', '%$query%')
        .order('name');
    
    return (response as List).map((item) => Product.fromJson(item)).toList();
  }
}