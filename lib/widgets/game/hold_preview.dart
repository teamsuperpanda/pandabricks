import 'package:flutter/material.dart';
import 'package:pandabricks/models/game_types.dart' as game_data;
import 'package:pandabricks/widgets/game/preview.dart';

/// Renders the piece stashed in hold, reusing the [PiecePreview] painter.
class HoldPreview extends StatelessWidget {
  const HoldPreview({required this.hold, super.key});

  final game_data.FallingBlock? hold;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: hold != null ? 'Held piece: ${hold!.name}' : 'No held piece',
      child: PiecePreview(next: hold),
    );
  }
}
