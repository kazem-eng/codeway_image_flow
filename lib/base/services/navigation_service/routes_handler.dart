import 'package:flutter/material.dart';

import 'package:codeway_image_processing/features/image_processing/presentation/detail/detail_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/detail/detail_view.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/home_view.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/mixed_review/mixed_review_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/mixed_review/mixed_review_view.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/document_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/document/document_view.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/processing_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/processing/processing_view.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_props.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/summary/summary_view.dart';
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
        final props = settings.arguments;
        if (props is! ProcessingProps) {
          return _createRedirectRoute(Routes.home);
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ProcessingView(props: props),
        );
      case Routes.multiPage:
        final props = settings.arguments;
        if (props is! DocumentProps) {
          return _createRedirectRoute(Routes.home);
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => DocumentView(props: props),
        );
      case Routes.summary:
        final props = settings.arguments;
        if (props is! SummaryProps) {
          return _createRedirectRoute(Routes.home);
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => SummaryView(props: props),
        );
      case Routes.mixedReview:
        final props = settings.arguments;
        if (props is! MixedReviewProps) {
          return _createRedirectRoute(Routes.home);
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => MixedReviewView(props: props),
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

/// Redirects to [route] after first frame; used when route arguments are invalid.
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
