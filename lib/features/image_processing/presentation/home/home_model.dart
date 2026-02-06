import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processed_image.dart';

/// Home screen model.
class HomeModel {
  const HomeModel({this.items = const []});

  final List<HomeHistoryItem> items;

  HomeModel copyWith({List<HomeHistoryItem>? items}) {
    return HomeModel(items: items ?? this.items);
  }
}

/// View-ready history item for the home list.
class HomeHistoryItem {
  const HomeHistoryItem({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  final ProcessedImage image;
  final String title;
  final String subtitle;
}
