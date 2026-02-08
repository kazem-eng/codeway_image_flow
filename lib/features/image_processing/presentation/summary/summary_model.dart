import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_props.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';

class SummaryModel {
  const SummaryModel({
    this.faces = const [],
    this.documents = const [],
    this.selectedFaceIndex = 0,
    this.faceGroupId,
    this.faceGroupEntity,
  });

  final List<SummaryFacePreview> faces;
  final List<SummaryDocumentPreview> documents;
  final int selectedFaceIndex;
  final String? faceGroupId;
  final ProcessedImage? faceGroupEntity;

  SummaryModel copyWith({
    List<SummaryFacePreview>? faces,
    List<SummaryDocumentPreview>? documents,
    int? selectedFaceIndex,
    String? faceGroupId,
    ProcessedImage? faceGroupEntity,
  }) {
    return SummaryModel(
      faces: faces ?? this.faces,
      documents: documents ?? this.documents,
      selectedFaceIndex: selectedFaceIndex ?? this.selectedFaceIndex,
      faceGroupId: faceGroupId ?? this.faceGroupId,
      faceGroupEntity: faceGroupEntity ?? this.faceGroupEntity,
    );
  }
}
