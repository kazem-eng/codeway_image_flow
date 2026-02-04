import 'package:flutter/material.dart';

import 'package:codeway_image_processing/features/image_processing/presentation/detail/detail_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/detail/detail_view.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/home_view.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/processing_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/processing_view.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/result/result_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/result/result_view.dart';
import 'routes.dart';

/// Routes handler. Views receive props as parameters; VMs are created inside each view via [BaseView].
class RoutesHandler {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const HomeView(),
        );
      case Routes.processing:
        final props = settings.arguments is ProcessingProps
            ? settings.arguments as ProcessingProps
            : null;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ProcessingView(imageBytes: props?.imageBytes),
        );
      case Routes.result:
        final resultArgs = settings.arguments;
        if (resultArgs is! ResultProps) {
          return _createRedirectRoute(Routes.home);
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ResultView(processedImage: resultArgs.processedImage),
        );
      case Routes.detail:
        final detailArgs = settings.arguments;
        if (detailArgs is! DetailProps) {
          return _createRedirectRoute(Routes.home);
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => DetailView(imageId: detailArgs.imageId),
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static MaterialPageRoute<void> _createRedirectRoute(String route) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: Routes.home),
      builder: (ctx) => _RedirectToRoute(route: route),
    );
  }
}

class _RedirectToRoute extends StatefulWidget {
  const _RedirectToRoute({required this.route});

  final String route;

  @override
  State<_RedirectToRoute> createState() => _RedirectToRouteState();
}

class _RedirectToRouteState extends State<_RedirectToRoute> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(widget.route, (_) => false);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
