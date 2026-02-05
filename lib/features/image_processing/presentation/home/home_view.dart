import 'package:codeway_image_processing/base/mvvm_base/base.dart';
import 'package:codeway_image_processing/base/services/navigation_service/route_observer.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/_widgets/_add_fab.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/_widgets/_home_body.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/home_vm.dart';
import 'package:codeway_image_processing/setup/locator.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_components_export.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    if (!Get.isRegistered<HomeVM>()) return;
    Get.find<HomeVM>().loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<HomeVM>(
      vmFactory: () => VMFactories.createHomeVM(),
      initViewModel: (vm) async {
        await vm.loadHistory();
      },
      builder: (context, vm) => Scaffold(
        appBar: ImageFlowAppBar(
          title: AppStrings.homeScreenTitle,
          titleStyle: ImageFlowTextStyles.appTitle,
          titleSpacing: 56,
        ),
        body: const HomeBody(),
        floatingActionButton: const AddFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
