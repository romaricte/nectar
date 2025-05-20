import 'package:flutter/material.dart';
import '../../models/cart_item.dart';
import '../../services/cart_service.dart';
import '../../utils/supabase_client.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpController = TextEditingController();
  final _cardCVVController = TextEditingController();

  final CartService _cartService = CartService();
  late Future<List<CartItem>> _cartFuture;
  bool _isLoading = false;
  bool _isProcessingOrder = false;

  @override
  void initState() {
    super.initState();
    _cartFuture = _cartService.getUserCart();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cardNumberController.dispose();
    _cardExpController.dispose();
    _cardCVVController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        _nameController.text = response['name'] ?? '';
        _emailController.text = user.email ?? '';
        _phoneController.text = response['phone'] ?? '';
        _addressController.text = response['address'] ?? '';
      });
    } catch (e) {
      // Gérer l'erreur
    }
  }

  Future<void> _processOrder() async {
    if (!_formKey.currentState!.validate()) return;
    
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() {
      _isProcessingOrder = true;
    });

    try {
      // Récupérer les articles du panier
      final cartItems = await _cartService.getUserCart();
      
      if (cartItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Votre panier est vide')),
        );
        return;
      }

      // Calculer le montant total
      final total = cartItems.fold<double>(
        0,
        (sum, item) => sum + item.total,
      );

      // Créer une nouvelle commande
      final orderResponse = await supabase.from('orders').insert({
        'user_id': user.id,
        'status': 'pending',
        'total_amount': total,
        'shipping_address': _addressController.text,
        'shipping_name': _nameController.text,
        'shipping_phone': _phoneController.text,
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      final orderId = orderResponse[0]['id'];

      // Ajouter les articles commandés
      for (var item in cartItems) {
        await supabase.from('order_items').insert({
          'order_id': orderId,
          'product_id': item.product.id,
          'quantity': item.quantity,
          'price': item.product.price,
        });

        // Mettre à jour le stock du produit
        await supabase
            .from('products')
            .update({'stock': item.product.stock - item.quantity})
            .eq('id', item.product.id);
      }

      // Vider le panier de l'utilisateur
      await _cartService.clearCart();

      // Rediriger vers la page de confirmation
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => OrderSuccessScreen(orderId: orderId),
          ),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isProcessingOrder = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Résumé de la commande
                    const Text(
                      'Récapitulatif de la commande',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<List<CartItem>>(
                      future: _cartFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Text('Erreur: ${snapshot.error}');
                        }

                        final cartItems = snapshot.data ?? [];
                        final total = cartItems.fold<double>(
                          0,
                          (sum, item) => sum + item.total,
                        );

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: cartItems.length,
                                  itemBuilder: (context, index) {
                                    final item = cartItems[index];
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(item.product.name),
                                      subtitle: Text('${item.quantity} × ${item.product.price.toStringAsFixed(2)} €'),
                                      trailing: Text('${item.total.toStringAsFixed(2)} €'),
                                    );
                                  },
                                ),
                                const Divider(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '${total.toStringAsFixed(2)} €',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    // Informations de livraison
                    const Text(
                      'Informations de livraison',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom complet',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro de téléphone';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse de livraison',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre adresse';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),
                    // Informations de paiement
                    const Text(
                      'Informations de paiement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cardNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Numéro de carte',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le numéro de votre carte';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cardExpController,
                            decoration: const InputDecoration(
                              labelText: 'Date d\'expiration (MM/YY)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Requis';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _cardCVVController,
                            decoration: const InputDecoration(
                              labelText: 'CVV',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Requis';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isProcessingOrder ? null : _processOrder,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: _isProcessingOrder
                          ? const CircularProgressIndicator()
                          : const Text('Confirmer la commande'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}