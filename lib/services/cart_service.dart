import '../models/cart_item.dart';
import '../models/product.dart';
import '../utils/supabase_client.dart';

class CartService {
  // Récupérer le panier de l'utilisateur actuel
  Future<List<CartItem>> getUserCart() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    // Récupérer les articles du panier avec les détails des produits
    final response = await supabase
        .from('cart')
        .select('id, product_id, quantity, products(*)')
        .eq('user_id', user.id);

    return (response as List).map((item) {
      final product = Product.fromJson(item['products']);
      return CartItem(
        id: item['id'],
        product: product,
        quantity: item['quantity'],
      );
    }).toList();
  }

  // Ajouter un produit au panier
  Future<void> addToCart(String productId, {int quantity = 1}) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    // Vérifier si le produit est déjà dans le panier
    final existing = await supabase
        .from('cart')
        .select()
        .eq('user_id', user.id)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      // Mettre à jour la quantité
      await supabase
          .from('cart')
          .update({'quantity': existing['quantity'] + quantity})
          .eq('id', existing['id']);
    } else {
      // Ajouter un nouvel article au panier
      await supabase.from('cart').insert({
        'user_id': user.id,
        'product_id': productId,
        'quantity': quantity,
      });
    }
  }

  // Mettre à jour la quantité d'un article
  Future<void> updateCartItemQuantity(String itemId, int quantity) async {
    await supabase
        .from('cart')
        .update({'quantity': quantity})
        .eq('id', itemId);
  }

  // Supprimer un article du panier
  Future<void> removeFromCart(String itemId) async {
    await supabase
        .from('cart')
        .delete()
        .eq('id', itemId);
  }

  // Vider le panier
  Future<void> clearCart() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    await supabase
        .from('cart')
        .delete()
        .eq('user_id', user.id);
  }
}