import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../connection_manager/connection_manager_controller.dart';
import '../style/app_colors.dart';
import '../style/app_style.dart';
import 'base_controller.dart';

abstract class BaseView<Controller extends BaseController>
    extends GetView<Controller> {
  BaseView({super.key});

  final _connectionController = Get.find<ConnectionManagerController>();

  PreferredSizeWidget? appBar(BuildContext context);

  //required
  Widget body(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Obx(() {
        return Scaffold(
            //sets ios status bar color
            backgroundColor: AppColors.white,
            // key: controller.globalKey,
            appBar: appBar(context),
            floatingActionButton: floatingActionButton(),
            bottomNavigationBar: bottomNavigationBar(),
            drawer: drawer(context),
            body: pageScaffold(context));
      }),
    );
  }

  // widgets
  Widget pageScaffold(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Column(
        children: [
          _connectionController.isInternetConnected.value
              ? const SizedBox()
              : connectionStatusView() ?? const SizedBox(),
          Expanded(child: pageContent(context)),
        ],
      ),
    );
  }

  Widget pageContent(BuildContext context) {
    return body(context);
  }

  //optional
  Widget? bottomNavigationBar() {
    return null;
  }

  Widget? drawer(BuildContext context) {
    return null;
  }

  Widget? floatingActionButton() {
    return null;
  }

  Widget? connectionStatusView() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
          width: double.infinity,
          height: 30,
          color: AppColors.black,
          child: Center(
            child: Text(
              _connectionController.connectedStatusMessage.value,
              style: textRegularStyle(isWhiteColor: true),
            ),
          )),
    );
  }
}
