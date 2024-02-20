import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:europharm_flutter/network/models/user_dto.dart';
import 'package:europharm_flutter/screens/order_card/ui/pdf_view.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:europharm_flutter/network/models/order_documents_sign.dart';
import 'package:europharm_flutter/network/models/order_dto.dart';
import 'package:europharm_flutter/network/repository/global_repository.dart';
import 'package:europharm_flutter/screens/order_card/bloc/file_signing_bloc.dart';
import 'package:europharm_flutter/styles/color_palette.dart';
import 'package:europharm_flutter/styles/text_styles.dart';
import 'package:europharm_flutter/widgets/app_bottom_sheets/app_bottom_sheet.dart';
import 'package:europharm_flutter/widgets/app_loader_overlay.dart';
import 'package:europharm_flutter/widgets/main_button/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FileSigningPage extends StatelessWidget {
  final OrderDTO order;
  const FileSigningPage({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FileSigningBloc(
          repository: context.read<GlobalRepository>(), orderId: order.id),
      child: BlocConsumer<FileSigningBloc, FileSigningState>(
        listener: (context, state) {
          if (state is OrderDocumentsIsLoadedState) {
            context.loaderOverlay.show();
          } else {
            context.loaderOverlay.hide();
          }
        },
        builder: (context, state) {
          return AppLoaderOverlay(
            child: Scaffold(
              backgroundColor: ColorPalette.white,
              appBar: AppBar(
                centerTitle: true,
                title: const Text(
                  "Документы",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                elevation: 0,
                leading: IconButton(
                  icon: SvgPicture.asset(
                    "assets/images/svg/arrow_back.svg",
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ),
              body: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: state is OrderDocumentsIsLoadedSignState
                    ? ListView.builder(
                        itemCount: state.document.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                title: Text(
                                  "Название: ${state.document[index]?.documentsToSign![0].nameRu ?? ''}",
                                  style: ProjectTextStyles.ui_16Medium,
                                ),
                                subtitle: Text(
                                  "№: ${order.id}",
                                  style: ProjectTextStyles.ui_14Regular,
                                ),
                                trailing: Text(
                                  "${state.document[index]?.documentsToSign![0].meta![0].value == 0 ? 'Не подписан' : 'Подписан'}",
                                  style: ProjectTextStyles.ui_14Regular,
                                ),
                                onTap: () {
                                  showAppBottomSheet(
                                    context,
                                    initialChildSize: 0.45,
                                    useRootNavigator: true,
                                    child: BlocProvider.value(
                                      value: context.read<FileSigningBloc>(),
                                      child: BuildChooseDocumentAction(
                                        order: order,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const Divider()
                            ],
                          );
                        })
                    : const SizedBox.shrink(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BuildChooseDocumentAction extends StatelessWidget {
  const BuildChooseDocumentAction({Key? key, required this.order})
      : super(key: key);
  // final OrderDocumentSign document;
  final OrderDTO order;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<FileSigningBloc>();
    return BlocBuilder<FileSigningBloc, FileSigningState>(
      bloc: bloc,
      builder: (BuildContext context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 10,
          ),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Center(
                child: Text(
                  "Выберите действие",
                  style: ProjectTextStyles.ui_20Medium,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              MainButton(
                width: MediaQuery.of(context).size.width * 0.4,
                title: "Посмотреть",
                iconColor: ColorPalette.white,
                onTap: () async {
                  String base64Data = state is OrderDocumentsIsLoadedSignState
                      ? state.document[0]?.documentsToSign![0].document!.file!
                              .data ??
                          ''
                      : '';
                  List<int> bytes = base64.decode(base64Data);

                  // Открываем новую страницу с PDFViewPage
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PDFViewPage(
                        pdfBytes: bytes,
                        order: order,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 10,
              ),
              MainButton(
                width: MediaQuery.of(context).size.width * 0.4,
                title: "Подписать",
                iconColor: ColorPalette.white,
                onTap: () async {
                  // bloc.add(FetchOrderIdAndUserIdEvent());
                  final String userId = await _getUserId(context);
                  final String url = _buildSigningUrl(order.id, userId);
                  _launchUrl(url);
                  print('orderId: ${order.id} и UserID: ${userId}');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> _getUserId(BuildContext context) async {
    final UserDTO profile = await context.read<GlobalRepository>().getProfile();
    return profile.id.toString();
  }

  String _buildSigningUrl(int orderId, String userId) {
    final String baseUrl =
        'https://mgovsign.page.link/?link=https://api.sattiway.kz/api/v2/egov/ttn/mgovSign?order_id%3D$orderId%26user_id%3D$userId%26type_sign%3Dtms';
    final String iosUrl = '$baseUrl&isi=1476128386&ibi=kz.egov.mobile';
    final String androidUrl = '$baseUrl&apn=kz.mobile.mgov';
    return Platform.isIOS ? iosUrl : androidUrl;
  }

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }
}
