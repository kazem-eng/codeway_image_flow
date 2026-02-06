/// Type of processing applied (face or document).
enum ProcessingType {
  face(0),
  document(1),
  faceBatch(2);

  const ProcessingType(this.value);
  final int value;

  bool get isDocument => this == ProcessingType.document;
  bool get isFace =>
      this == ProcessingType.face || this == ProcessingType.faceBatch;
  bool get isFaceBatch => this == ProcessingType.faceBatch;

  static ProcessingType fromInt(int value) {
    return ProcessingType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ProcessingType.face,
    );
  }
}
