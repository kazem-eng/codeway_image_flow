import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';

/// Home screen model.
class HomeModel {
  const HomeModel({this.history = const []});

  final List<ProcessedImage> history;

  HomeModel copyWith({List<ProcessedImage>? history}) {
    return HomeModel(history: history ?? this.history);
  }
}
