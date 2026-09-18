import 'package:flutter/material.dart';

import '../models/loyalty_card.dart';
import '../services/loyalty_card_service.dart';

const _marcasComunes = ['Repsol', 'Cepsa', 'BP', 'Galp', 'Shell', 'Carrefour', 'Alcampo'];

/// Gestión de las tarjetas de descuento del usuario: qué marcas tiene y
/// cuánto le ahorran por litro, para verlo reflejado en los precios de la
/// app allá donde repostar en esa marca.
class LoyaltyCardsScreen extends StatefulWidget {
  const LoyaltyCardsScreen({super.key});

  @override
  State<LoyaltyCardsScreen> createState() => _LoyaltyCardsScreenState();
}

class _LoyaltyCardsScreenState extends State<LoyaltyCardsScreen> {
  final _service = LoyaltyCardService();
  List<LoyaltyCard> _cards = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cards = await _service.getCards();
    if (!mounted) return;
    setState(() {
      _cards = cards;
      _loading = false;
    });
  }

  Future<void> _addCard() async {
    final brandController = TextEditingController();
    final discountController = TextEditingController();
    String? selectedQuickBrand;
    String? error;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final colorScheme = Theme.of(dialogContext).colorScheme;
          return AlertDialog(
            title: const Text('Nueva tarjeta de descuento'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _marcasComunes.map((m) {
                      return ChoiceChip(
                        label: Text(m),
                        selected: selectedQuickBrand == m,
                        onSelected: (v) {
                          setDialogState(() {
                            selectedQuickBrand = v ? m : null;
                            if (v) brandController.text = m;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: brandController,
                    decoration: const InputDecoration(labelText: 'Marca'),
                    onChanged: (_) => setDialogState(() => selectedQuickBrand = null),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: discountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Descuento por litro',
                      suffixText: '€/L',
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Text(error!,
                        style: TextStyle(color: colorScheme.error, fontSize: 12.5)),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  final brand = brandController.text.trim();
                  final discount = double.tryParse(
                      discountController.text.trim().replaceAll(',', '.'));
                  if (brand.isEmpty || discount == null || discount <= 0) {
                    setDialogState(
                        () => error = 'Rellena la marca y un descuento válido.');
                    return;
                  }
                  Navigator.pop(dialogContext, true);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );

    if (saved != true) return;
    final brand = brandController.text.trim();
    final discount =
        double.tryParse(discountController.text.trim().replaceAll(',', '.'));
    if (brand.isNotEmpty && discount != null && discount > 0) {
      await _service.saveCard(LoyaltyCard(brand: brand, discountPerLiter: discount));
      _load();
    }
  }

  Future<void> _removeCard(LoyaltyCard card) async {
    await _service.removeCard(card.brand);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Mis tarjetas de descuento')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCard,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tarjeta'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                Text(
                  'Apunta tus tarjetas de fidelización para ver cuánto pagas '
                  'de verdad en cada gasolinera, descuento incluido.',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                if (_cards.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Column(
                      children: [
                        Icon(Icons.local_activity_outlined,
                            size: 40, color: colorScheme.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text(
                          'Aún no has añadido ninguna tarjeta.',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                else
                  ..._cards.map((card) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.local_activity_rounded,
                                  color: colorScheme.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  card.brand,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                              Text(
                                '-${card.discountPerLiter.toStringAsFixed(3)} €/L',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.primary,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline_rounded,
                                    color: colorScheme.onSurfaceVariant),
                                onPressed: () => _removeCard(card),
                              ),
                            ],
                          ),
                        ),
                      )),
              ],
            ),
    );
  }
}
