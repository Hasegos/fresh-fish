import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/decorations.dart';
import '../../models/decoration_model.dart' as deco_model;
import '../../models/user_data_model.dart';
import '../../providers/user_data_provider.dart';
import 'shop_colors.dart';

// ========== 장식 관리 탭 ==========
class ManageDecorationTab extends StatefulWidget {
  const ManageDecorationTab({super.key});

  @override
  State<ManageDecorationTab> createState() => _ManageDecorationTabState();
}

class _ManageDecorationTabState extends State<ManageDecorationTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, provider, child) {
        final userData = provider.userData;
        if (userData == null) return const SizedBox();

        final owned = userData.ownedDecorations;
        final ownedDecorations = availableDecorations
            .where((d) => owned.contains(d.id))
            .toList();

        if (ownedDecorations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🪨',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 16),
                const Text('아직 소유한 장식이 없습니다'),
                const SizedBox(height: 8),
                const Text('장식 상점에서 아이템을 구매해보세요!',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
              ],
            ),
          );
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  const Text(
                    '수족관 꾸미기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 수족관 에디터
                  _AquariumEditor(
                    decorations: userData.decorations,
                    ownedDecorations: ownedDecorations,
                    onDecorationsChanged: (newDecorations) {
                      provider.updateUserData(
                        (data) => data.copyWith(decorations: newDecorations),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // 보유 장식 목록
                  const Text(
                    '보유한 장식',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: ownedDecorations.length,
                    itemBuilder: (context, index) {
                      final decoration = ownedDecorations[index];
                      final isPlaced = userData.decorations
                          .any((d) => d.decorationId == decoration.id);

                      return DecorationCard(
                        decoration: decoration,
                        isPlaced: isPlaced,
                        onAddToAquarium: () {
                          if (!isPlaced) {
                            final newPlaced = PlacedDecoration(
                              decorationId: decoration.id,
                              x: 90,
                              y: 60,
                            );
                            provider.updateUserData(
                              (data) => data.copyWith(
                                decorations: [
                                  ...data.decorations,
                                  newPlaced,
                                ],
                              ),
                            );
                          }
                        },
                        onRemoveFromAquarium: isPlaced
                            ? () {
                                provider.updateUserData(
                                  (data) => data.copyWith(
                                    decorations: [
                                      ...data.decorations
                                          .where((d) => d.decorationId != decoration.id)
                                    ],
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${decoration.name} 제거됨'),
                                    backgroundColor: Colors.orange,
                                    duration: const Duration(milliseconds: 1500),
                                  ),
                                );
                              }
                            : null,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
class _AquariumEditor extends StatefulWidget {
  final List<PlacedDecoration> decorations;
  final List<deco_model.Decoration> ownedDecorations;
  final Function(List<PlacedDecoration>) onDecorationsChanged;

  const _AquariumEditor({
    required this.decorations,
    required this.ownedDecorations,
    required this.onDecorationsChanged,
  });

  @override
  State<_AquariumEditor> createState() => _AquariumEditorState();
}

class _AquariumEditorState extends State<_AquariumEditor> {
  PlacedDecoration? _selectedDecoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ShopColors.editorGradientStart,
            ShopColors.editorGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ShopColors.editorBorder.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Container(
          width: 280,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withValues(alpha: 0.3),
          ),
          child: Stack(
            children: [
              // 드래그 가능한 장식들
              ...widget.decorations.asMap().entries.map<Widget>((entry) {
                final index = entry.key;
                final decoration = entry.value;
                final decoData = widget.ownedDecorations.firstWhere(
                  (d) => d.id == decoration.decorationId,
                  orElse: () => widget.ownedDecorations.first,
                );

                return Positioned(
                  left: decoration.x,
                  top: decoration.y,
                  child: _DraggableDecorationItem(
                    decoration: decoData,
                    isSelected: _selectedDecoration == decoration,
                    onDragUpdate: (newX, newY) {
                  final updatedDecorations = [...widget.decorations];
                  updatedDecorations[index] =
                      decoration.copyWith(x: newX, y: newY);
                  widget.onDecorationsChanged(updatedDecorations);
                },
                onTap: () {
                  setState(() {
                    _selectedDecoration =
                        _selectedDecoration == decoration ? null : decoration;
                  });
                },
                onDelete: () {
                  final updatedDecorations = [...widget.decorations];
                  updatedDecorations.removeAt(index);
                  widget.onDecorationsChanged(updatedDecorations);
                  setState(() {
                    _selectedDecoration = null;
                  });
                },
              ),
            );
          }),

              // 삭제 버튼 (선택된 장식이 있을 때)
              if (_selectedDecoration != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      final updatedDecorations = [
                        ...widget.decorations
                            .where((d) => d != _selectedDecoration)
                      ];
                      widget.onDecorationsChanged(updatedDecorations);
                      setState(() {
                        _selectedDecoration = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// 드래그 가능한 장식 아이템
class _DraggableDecorationItem extends StatefulWidget {
  final deco_model.Decoration decoration;
  final bool isSelected;
  final Function(double, double) onDragUpdate;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DraggableDecorationItem({
    required this.decoration,
    required this.isSelected,
    required this.onDragUpdate,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_DraggableDecorationItem> createState() =>
      _DraggableDecorationItemState();
}

class _DraggableDecorationItemState extends State<_DraggableDecorationItem> {
  late Offset _offset;

  @override
  void initState() {
    super.initState();
    _offset = Offset.zero;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onPanUpdate: (details) {
        setState(() {
          _offset += details.delta;
          // 280x200 수족관 경계 내에서만 움직이도록 제한
          _offset = Offset(
            _offset.dx.clamp(0, 250), // 280 - 30 (아이템 크기)
            _offset.dy.clamp(0, 170), // 200 - 30 (아이템 크기)
          );
        });
        widget.onDragUpdate(
          _offset.dx,
          _offset.dy,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: widget.isSelected
              ? Border.all(
                  color: Colors.blue.shade300,
                  width: 2,
                )
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          widget.decoration.icon,
          style: const TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}

// 보유한 장식 카드
class DecorationCard extends StatelessWidget {
  final deco_model.Decoration decoration;
  final bool isPlaced;
  final VoidCallback onAddToAquarium;
  final VoidCallback? onRemoveFromAquarium;

  const DecorationCard({
    super.key,
    required this.decoration,
    required this.isPlaced,
    required this.onAddToAquarium,
    this.onRemoveFromAquarium,
  });

  Color _getRarityColor() {
    switch (decoration.rarity) {
      case deco_model.Rarity.common:
        return ShopColors.rarityCommon;
      case deco_model.Rarity.rare:
        return ShopColors.rarityRare;
      case deco_model.Rarity.epic:
        return ShopColors.rarityEpic;
      case deco_model.Rarity.legendary:
        return ShopColors.rarityLegendary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: isPlaced && onRemoveFromAquarium != null
          ? onRemoveFromAquarium
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: ShopColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getRarityColor(),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _getRarityColor().withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      decoration.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ShopColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ShopColors.successButton,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '보유중',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                decoration.description,
                style: const TextStyle(
                  fontSize: 11,
                  color: ShopColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Center(
                child: Text(
                  decoration.icon,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isPlaced ? null : onAddToAquarium,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPlaced
                        ? ShopColors.disabledButton
                        : ShopColors.successButton,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isPlaced ? '배치됨' : '추가',
                    style: TextStyle(
                      color: isPlaced
                          ? ShopColors.textDisabled
                          : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
