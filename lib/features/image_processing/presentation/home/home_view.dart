import 'package:codeway_image_processing/base/mvvm_base/base.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/_widgets/_add_fab.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/_widgets/_home_body.dart';
import 'package:codeway_image_processing/features/image_processing/presentation/home/home_vm.dart';
import 'package:codeway_image_processing/setup/locator.dart';
import 'package:codeway_image_processing/ui_kit/components/imageflow_components_export.dart';
import 'package:codeway_image_processing/ui_kit/strings/app_strings.dart';
import 'package:codeway_image_processing/ui_kit/styles/theme_data.dart';
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

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
