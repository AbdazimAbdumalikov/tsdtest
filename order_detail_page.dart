import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:europharm_flutter/generated/l10n.dart';
import 'package:europharm_flutter/network/models/dto_models/response/signed.dart';
import 'package:europharm_flutter/network/models/order_dto.dart';
import 'package:europharm_flutter/network/models/point_dto.dart';
import 'package:europharm_flutter/network/models/user_dto.dart';
import 'package:europharm_flutter/network/repository/global_repository.dart';
import 'package:europharm_flutter/screens/map_screen/data/bloc/map_cubit.dart';
import 'package:europharm_flutter/screens/map_screen/data/repo_map.dart';
import 'package:europharm_flutter/screens/map_screen/map.dart';
import 'package:europharm_flutter/screens/order_card/bloc/empty_drivers_cubit.dart';
import 'package:europharm_flutter/screens/order_card/bloc/order_detail_bloc.dart';
import 'package:europharm_flutter/screens/order_card/provider/order_detail_provider.dart';
import 'package:europharm_flutter/screens/order_card/ui/accident.dart';
import 'package:europharm_flutter/screens/order_card/ui/cause_bottom_sheet.dart';
import 'package:europharm_flutter/screens/order_card/ui/file_signing_page.dart';
import 'package:europharm_flutter/screens/order_card/ui/order_documents_page.dart';
import 'package:europharm_flutter/screens/order_card/ui/pdf_view.dart';
import 'package:europharm_flutter/screens/order_card/ui/pdf_wms_view.dart';
import 'package:europharm_flutter/screens/order_card/ui/widgets/line_animation.dart';
import 'package:europharm_flutter/screens/order_card/ui/widgets/timer.dart';
import 'package:europharm_flutter/screens/order_card/ui/widgets/transfer_order_bottom_sheet.dart';
import 'package:europharm_flutter/screens/order_finish/bloc/point_page_bloc.dart';
import 'package:europharm_flutter/screens/order_finish/ui/point_page.dart';
import 'package:europharm_flutter/screens/order_finish/ui/warehouse_page.dart';
import 'package:europharm_flutter/screens/orders_screen/bloc/orders_bloc.dart';
import 'package:europharm_flutter/styles/color_palette.dart';
import 'package:europharm_flutter/styles/text_styles.dart';
import 'package:europharm_flutter/utils/app_router.dart';
import 'package:europharm_flutter/widgets/app_bottom_sheets/app_bottom_sheet.dart';
import 'package:europharm_flutter/widgets/app_bottom_sheets/app_dialog.dart';
import 'package:europharm_flutter/widgets/app_loader_overlay.dart';
import 'package:europharm_flutter/widgets/main_button/main_button.dart';
import 'package:europharm_flutter/widgets/snackbar/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher_string.dart';

const _tag = 'order_detail_page.dart';

class OrderDetailPage extends StatefulWidget {
  final OrderDTO order;

  const OrderDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    Provider.of<OrderDetailProvider>(context, listen: false).init();
    BlocProvider.of<OrderDetailBloc>(context).add(OrderDetailEventReset());
    BlocProvider.of<OrderDetailBloc>(context).getCurrentOrder(widget.order);
    BlocProvider.of<EmptyDriversCubit>(context).getEmptyDrivers();
    BlocProvider.of<OrderDetailBloc>(context).add(
      OrderDetailRefreshEvent(
        orderId: widget.order.id,
      ),
    );
    BlocProvider.of<OrderDetailBloc>(context).add(
      OrderDetailSignEvent(
        orderId: widget.order.id,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLoaderOverlay(
      child: Scaffold(
        backgroundColor: ColorPalette.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "#0000000${widget.order.id}, ${widget.order.orderType}",
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
          elevation: 0,
          leading: Row(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  "assets/images/svg/arrow_back.svg",
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.playlist_add_check_circle,
                color: ColorPalette.black,
              ),
              tooltip: 'Documents',
              onPressed: () {
                AppRouter.push(context, FileSigningPage(order: widget.order));
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            AnimatedOpacity(
              opacity: widget.order.isCurrent ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: Visibility(
                visible: widget.order.isCurrent,
                child: BlocConsumer<OrderDetailBloc, OrderDetailState>(
                  listener: (context, state) {},
                  buildWhen: (p, c) {
                    if (c is OrderDetailStateLoaded) {
                      return true;
                    } else {
                      return false;
                    }
                  },
                  builder: (context, state) {
                    if (state is OrderDetailStateLoaded) {
                      return Container(
                        child: BlocProvider<MapCubit>(
                          create: (_) => MapCubit(
                            mapRepository: MapRepository(),
                            repository: context.read<GlobalRepository>(),
                          ),
                          child: SessionPage(
                            orderId: widget.order.id,
                            // pointId: widget.order.id,
                            order: state.order,
                            repository: context.read<GlobalRepository>(),
                            orderPoints: const [],
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              height: widget.order.isCurrent
                  ? MediaQuery.of(context).size.height * 0.95
                  : 0,
              curve: Curves.easeInOut,
              child: SizedBox.expand(
                child: DraggableScrollableSheet(
                  initialChildSize: 0.4,
                  minChildSize: 0.3,
                  maxChildSize: 0.95,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: BlocConsumer<OrderDetailBloc, OrderDetailState>(
                        listener: (context, state) {
                          if (state is OrderDetailStateLoading) {
                            context.loaderOverlay.show();
                          } else {
                            context.loaderOverlay.hide();
                          }
                          if (state is OrderDetailStateError) {
                            showAppDialog(context, body: state.error.message);
                          }
                          if (state is OrderDetailStateStartSuccess) {
                            showAppDialog(context,
                                body: "заказ успешно принят");
                            BlocProvider.of<OrderDetailBloc>(context).add(
                              OrderDetailRefreshEvent(orderId: widget.order.id),
                            );
                            BlocProvider.of<OrdersBloc>(context).add(
                              EventInitialOrdersScreen(),
                            );
                          }
                          if (state is OrderDetailStateResumeSuccess) {
                            showAppDialog(context,
                                body: "заказ успешно запущен");
                            Navigator.of(context).pop();
                            BlocProvider.of<OrderDetailBloc>(context).add(
                              OrderDetailRefreshEvent(orderId: widget.order.id),
                            );
                            // setState(() {
                            //   widget.order.status = "accepted";
                            // });
                          }
                          if (state is OrderDetailStateShowTimer) {
                            Duration time;
                            if (state.isForth) {
                              time =
                                  DateTime.now().difference(state.startTimer);
                            } else {
                              time = state.startTimer.isBefore(DateTime.now())
                                  ? Duration.zero
                                  : state.startTimer.difference(DateTime.now());
                            }
                            showAppBottomSheet(
                              context,
                              useRootNavigator: true,
                              isDismissible: false,
                              enableDrag: false,
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  const Text(
                                    "Перерыв",
                                    style: ProjectTextStyles.ui_20Medium,
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 100,
                                    child: TimerPage(
                                      isForth: state.isForth,
                                      duration: time,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18.0,
                                      horizontal: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        MainButton(
                                          width: 80,
                                          icon:
                                              "assets/images/svg/arrow_left.svg",
                                          iconColor: ColorPalette.white,
                                          onTap: () {
                                            Navigator.popUntil(
                                              context,
                                              (route) => route.isFirst,
                                            );
                                          },
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        MainButton(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              90 -
                                              20,
                                          onTap: () {
                                            context
                                                .read<OrderDetailBloc>()
                                                .add(OrderDetailEventResume());
                                            Navigator.pop(context);
                                          },
                                          title: "Выйти на линию",
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          if (state is OrderDetailStateStopSuccess) {
                            showAppDialog(context,
                                body: "заказ успешно остановлен");
                            Navigator.of(context).pop();
                            // setState(() {
                            //   widget.order.status = "stopped";
                            // });
                            BlocProvider.of<OrderDetailBloc>(context).add(
                              OrderDetailRefreshEvent(orderId: widget.order.id),
                            );
                          }

                          if (state is OrderDetailStateChangedDriverOrderCard) {
                            BlocProvider.of<OrdersBloc>(context).add(
                              EventInitialOrdersScreen(),
                            );
                            Navigator.pop(context);
                          }
                        },
                        buildWhen: (p, c) {
                          if (c is OrderDetailStateLoaded) {
                            return true;
                          } else {
                            return false;
                          }
                        },
                        builder: (context, state) {
                          if (state is OrderDetailStateLoaded) {
                            return SingleChildScrollView(
                              controller: scrollController,
                              key: UniqueKey(),
                              child: Column(
                                children: [
                                  Container(
                                    child: Column(
                                      children: [
                                        AnimatedGradientDivider(),
                                        // Divider(
                                        //   color: Colors.black87,
                                        //   height: 40,
                                        //   thickness: 2,
                                        //   indent: 100,
                                        //   endIndent: 100,
                                        // ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: <Widget>[
                                                  Text(
                                                    state.order.startDate !=
                                                            null
                                                        ? DateFormat(
                                                                "dd MMMM, HH:mm")
                                                            .format(state.order
                                                                .startDate!)
                                                        : "",
                                                    style: ProjectTextStyles
                                                        .ui_12Medium
                                                        .copyWith(
                                                      color: ColorPalette
                                                          .commonGrey,
                                                    ),
                                                  ),
                                                  Text(state.order.from ??
                                                      S.of(context).no_data),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: <Widget>[
                                                  Text(
                                                    state.order.endDate != null
                                                        ? DateFormat(
                                                                "dd MMMM, HH:mm")
                                                            .format(state
                                                                .order.endDate!)
                                                        : "",
                                                    style: ProjectTextStyles
                                                        .ui_12Medium
                                                        .copyWith(
                                                      color: ColorPalette
                                                          .commonGrey,
                                                    ),
                                                  ),
                                                  Text(state.order.to ??
                                                      S.of(context).no_data),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        const Divider(
                                          color: ColorPalette.lightGrey,
                                          thickness: 1,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const Text("Транспорт:"),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${state.order.transport?.model?.name}",
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  "${state.order.transport?.number}",
                                                  style: const TextStyle(
                                                    color:
                                                        ColorPalette.commonGrey,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        const Divider(
                                          color: ColorPalette.lightGrey,
                                          thickness: 1,
                                        ),
                                        SingleChildScrollView(
                                          child: _BuildOrderItem(
                                            order: state.order,
                                            callback: ({
                                              required bool isOpened,
                                              required PointDTO? orderPoint,
                                            }) {
                                              log(
                                                'isOpened in _BuildOrderItem : $isOpened',
                                                name: _tag,
                                              );
                                              Provider.of<OrderDetailProvider>(
                                                      context,
                                                      listen: false)
                                                  .isScan = isOpened;
                                              Provider.of<OrderDetailProvider>(
                                                      context,
                                                      listen: false)
                                                  .point = orderPoint;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          }
                          return const SizedBox(); // const Center(child: CircularProgressIndicator());
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: BlocBuilder<OrderDetailBloc, OrderDetailState>(
          builder: (context, state) {
            return FutureBuilder<UserDTO>(
              future: context.read<GlobalRepository>().getProfile(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Показываем индикатор загрузки пока происходит запрос профиля пользователя
                }
                if (snapshot.hasError) {
                  return Text('Ошибка загрузки профиля: ${snapshot.error}');
                }

                final user = snapshot.data;
                final isWmsUser = user?.role == 'wms';
                final userId = user?.id;

                if (state is OrderDetailStateLoaded) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      bottom: 10,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 60,
                      ),
                      child: _FABWidget(
                          isScan:
                              Provider.of<OrderDetailProvider>(context).isScan,
                          point:
                              Provider.of<OrderDetailProvider>(context).point,
                          index: Provider.of<OrderDetailProvider>(context)
                              .selected,
                          points: state.order.points ?? [],
                          order: state.order,
                          isWmsUser: isWmsUser,
                          userId: userId,
                          repository:
                              Provider.of<OrderDetailBloc>(context).repository),
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              },
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

bool isRightPoint({
  required List<PointDTO> points,
  required PointDTO point,
}) {
  int pointpos = 0;
  for (int i = 0; i < points.length; i++) {
    if (point.id == points[i].id) {
      pointpos = i;
      break;
    }
  }
  if (pointpos == 0) {
    return true;
  } else {
    if (points[pointpos - 1].status == "finished" ||
        points[pointpos - 1].status == "Завершен") {
      return true;
    } else {
      return false;
    }
  }
}

int getLastPointId(OrderDTO currentOrder) {
  int id = 0;
  for (int i = 0; i < currentOrder.points!.length; i++) {
    if (currentOrder.points![i]?.status != "Завершен") {
      id = currentOrder.points![i]?.id ?? 0;
      break;
    }
  }
  return id;
}

bool isAllFinished(OrderDTO currentOrder) {
  bool flag = true;
  for (int i = 0; i < currentOrder.points!.length; i++) {
    if (currentOrder.points![i] != null &&
        currentOrder.points![i]?.status != "Завершен") {
      log("${currentOrder.points![i]?.status!}");
      flag = false;
      break;
    }
  }
  return flag;
}

// AlertDialog(
//         title: const Text('AlertDialog Title'),
//         content: const SingleChildScrollView(
//           child: ListBody(
//             children: <Widget>[
//               Text('This is a demo alert dialog.'),
//               Text('Would you like to approve of this message?'),
//             ],
//           ),
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('Approve'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
class _FABWidgetsign extends StatelessWidget {
  final OrderDTO order;
  final int? userId;
  _FABWidgetsign({super.key, required this.order, this.userId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: ColorPalette.secondaryMain,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            late final String url;
            if (Theme.of(context).platform == TargetPlatform.iOS) {
              url =
                  'https://mgovsign.page.link/?link=https://api.sattiway.kz/api/v2/egov/ttn/mgovSign?order_id%3D${order.id}%26user_id%3D$userId%26type_sign%3Dwms&isi=1476128386&ibi=kz.egov.mobile';
            } else if (Theme.of(context).platform == TargetPlatform.android) {
              url =
                  'https://mgovsign.page.link/?link=https://api.sattiway.kz/api/v2/egov/ttn/mgovSign?order_id%3D${order.id}%26user_id%3D$userId%26type_sign%3Dwms&apn=kz.mobile.mgov';
            }
            // Проверяем, можем ли открыть ссылку
            if (await canLaunchUrlString(url)) {
              await launchUrlString(url);
            } else {
              throw 'Could not launch $url';
            }
            Timer(Duration(seconds: 5), () {
              context
                  .read<OrderDetailBloc>()
                  .add(OrderDetailRefreshEvent(orderId: order.id));
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'Подписать',
                style: ProjectTextStyles.ui_16Medium.copyWith(
                  color: ColorPalette.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FABWidget extends StatelessWidget {
  final OrderDTO order;
  final bool isScan;
  final List<PointDTO?> points;
  final int index;
  final PointDTO? point;
  final bool isWmsUser;
  final int? userId;
  final GlobalRepository repository;
  const _FABWidget({
    required this.order,
    required this.isScan,
    required this.point,
    Key? key,
    required this.points,
    required this.index,
    required this.isWmsUser,
    required this.userId,
    required this.repository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isWmsUser) {
      print('User is WMS user. Hiding other buttons.');
      return SizedBox(
        width: double.infinity,
        child: Material(
          color: ColorPalette.secondaryMain,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () async {
              bool signed = await repository.ttnStatus(orderId: order.id);
              if (signed == false) {
                // ignore: use_build_context_synchronously
                return showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return BlocBuilder<OrderDetailBloc, OrderDetailState>(
                      builder: (context, state) {
                        return AlertDialog(
                          title: Text('ТТН ещё не подписана!'),
                          content: Text(
                              'Нажмите на кнопку ${"Нажмите на кнопку 'Подписать'"}'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () async {
                                late final String url;
                                if (Theme.of(context).platform ==
                                    TargetPlatform.iOS) {
                                  url =
                                      'https://mgovsign.page.link/?link=https://api.sattiway.kz/api/v2/egov/ttn/mgovSign?order_id%3D${order.id}%26user_id%3D$userId%26type_sign%3Dwms&isi=1476128386&ibi=kz.egov.mobile';
                                } else if (Theme.of(context).platform ==
                                    TargetPlatform.android) {
                                  url =
                                      'https://mgovsign.page.link/?link=https://api.sattiway.kz/api/v2/egov/ttn/mgovSign?order_id%3D${order.id}%26user_id%3D$userId%26type_sign%3Dwms&apn=kz.mobile.mgov';
                                }
                                // Проверяем, можем ли открыть ссылку
                                if (await canLaunchUrlString(url)) {
                                  await launchUrlString(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                                Timer(Duration(seconds: 5), () {
                                  context.read<OrderDetailBloc>().add(
                                      OrderDetailRefreshEvent(
                                          orderId: order.id));
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text('Подписать'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              } else if (signed == true) {
                // ignore: use_build_context_synchronously
                return showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return BlocBuilder<OrderDetailBloc, OrderDetailState>(
                      builder: (context, state) {
                        return AlertDialog(
                          title: Text('ТТН уже подписана!'),
                          content: Text(
                              'Вы можете посмотреть, нажав на кнопку ${'Посмотреть'}.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () async {
                                String base64Data =
                                    state is OrdeWmsDocumentsIsLoadedSignState
                                        ? state.document![0]!.file ?? ''
                                        : '';
                                List<int> bytes = base64.decode(base64Data);

                                // Открываем новую страницу с PDFViewPage
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PDFWmsViewPage(
                                      pdfBytes: bytes,
                                      order: order,
                                    ),
                                  ),
                                );
                              },
                              child: Text('Посмотреть ТТН'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Проверить статус',
                  style: ProjectTextStyles.ui_16Medium.copyWith(
                    color: ColorPalette.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      print('User is not WMS user. Showing other buttons.');
      if (isScan &&
          (order.status == "accepted" ||
              order.status == "in_process" ||
              order.status == 'В пути')) {
        return GestureDetector(
          onTap: () {
            List<PointDTO> nonNullPoints = order.points
                    ?.where((point) => point != null)
                    .cast<PointDTO>()
                    .toList() ??
                [];
            if (isRightPoint(points: nonNullPoints, point: point!)) {
              Widget pageToNavigate;
              if (point?.pointType == 1) {
                pageToNavigate = WarehousePage(
                  order: order,
                  isScan: isScan,
                  point: point!,
                  repository: context.read<GlobalRepository>(),
                );
              } else {
                pageToNavigate = PointPage(
                  order: order,
                  point: point!,
                  isScan: order.points!.first?.id == point!.id,
                );
              }

              AppRouter.push(
                context,
                BlocProvider<PointPageBloc>(
                  create: (context) => PointPageBloc(
                    repository: context.read<GlobalRepository>(),
                    order: order,
                  )..add(
                      PointPageEventLoadProducts(
                        pointId: point!.id,
                      ),
                    ),
                  child: pageToNavigate,
                ),
              );
            } else {
              showCustomSnackbar(context, 'Сначала закончите предыдущие точки');
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: ColorPalette.secondaryMain,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    (order.points![index]?.status == "finished" ||
                            order.points![index]?.status == "Завершен")
                        ? "Приехал"
                        : "Посмотреть детали",
                    style: ProjectTextStyles.ui_16Medium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 3,
                  right: 15,
                  child: SvgPicture.asset(
                    "assets/images/svg/arrow_right.svg",
                  ),
                )
              ],
            ),
          ),
        );
      }
      // Второй блок кода
      else if (order.status == "accepted" ||
          order.status == "in_process" ||
          order.status == 'В пути') {
        return Row(
          children: [
            Expanded(
              child: Material(
                color: ColorPalette.secondaryMain,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    if (isAllFinished(order)) {
                      BlocProvider.of<OrderDetailBloc>(context)
                          .add(OrderDetailEventFinishOrder(orderId: order.id));
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Завершить маршрут',
                        style: ProjectTextStyles.ui_16Medium.copyWith(
                          color: ColorPalette.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  await showAppBottomSheet(
                    context,
                    initialChildSize: 0.45,
                    useRootNavigator: true,
                    child: const BuildCauses(),
                  ).then(
                    (value) async {
                      // Ваш блок кода для обработки value
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: ColorPalette.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ColorPalette.secondaryMain,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          "Стоп",
                          style: ProjectTextStyles.ui_16Medium.copyWith(
                            color: ColorPalette.secondaryMain,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 3,
                        right: 15,
                        child: SvgPicture.asset(
                          "assets/images/svg/chevrone_down.svg",
                          width: 24,
                          height: 24,
                          color: ColorPalette.secondaryMain,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }
      // Третий блок кода
      else if (order.status == "stopped") {
        return GestureDetector(
          onTap: () {
            context.read<OrderDetailBloc>().add(OrderDetailEventResume());
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: ColorPalette.secondaryMain,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    "Выйти на линию",
                    style: ProjectTextStyles.ui_16Medium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 3,
                  right: 15,
                  child: SvgPicture.asset(
                    "assets/images/svg/arrow_right.svg",
                  ),
                )
              ],
            ),
          ),
        );
      }
      // Четвертый блок кода
      else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  context.read<OrderDetailBloc>().add(OrderDetailEventStart());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: ColorPalette.secondaryMain,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "Принять",
                      style: ProjectTextStyles.ui_16Medium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  BlocProvider.of<OrderDetailBloc>(context)
                      .add(OrderDetailEventOrderDecline(orderId: order.id));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ColorPalette.secondaryMain,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Отклонить",
                      style: ProjectTextStyles.ui_16Medium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }
    }
    return SizedBox.shrink();
  }
}

class _BuildOrderItem extends StatefulWidget {
  final OrderDTO order;
  final Function({
    required bool isOpened,
    required PointDTO? orderPoint,
  }) callback;

  const _BuildOrderItem({
    Key? key,
    required this.order,
    required this.callback,
  }) : super(key: key);

  @override
  State<_BuildOrderItem> createState() => _BuildOrderItemState();
}

class _BuildOrderItemState extends State<_BuildOrderItem> {
  final TextEditingController searchController = TextEditingController();
  // int selected = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.order.points != null && widget.order.points!.isNotEmpty) {
      // Создайте копию списка, чтобы избежать ошибки изменения неизменяемого списка
      List<PointDTO> pointsCopy = List.from(widget.order.points!);
      pointsCopy.sort((a, b) {
        if (a.pointType == null || b.pointType == null) {
          // Обработка случая, когда pointType равен null
          return 0; // Или другое значение по умолчанию, в зависимости от вашей логики
        }

        // Сначала сортируем по pointType
        int typeComparison = a.pointType!.compareTo(b.pointType!);
        if (typeComparison != 0) {
          return typeComparison;
        }

        // Затем сортируем по eta
        DateTime? aEta = a.eta != null ? DateTime.parse(a.eta!) : null;
        DateTime? bEta = b.eta != null ? DateTime.parse(b.eta!) : null;

        if (aEta == null || bEta == null) {
          return 0; // Обработка случая, когда eta равна null
        }

        return aEta.compareTo(bEta);
      });
      return Padding(
          padding: EdgeInsets.only(bottom: 45),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 5, left: 5, right: 5),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: "Поиск по имени",
                    labelStyle: TextStyle(
                      fontSize: 12, // Уменьшаем размер шрифта для метки
                      color: Colors.blue, // Можно настроить цвет
                    ),
                    contentPadding:
                        EdgeInsets.all(12), // Уменьшаем внешние отступы
                    border: OutlineInputBorder(
                      // Задаем стиль границы
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (query) {
                    // Когда пользователь вводит текст в поисковой строке, обновите отфильтрованный список
                    setState(() {});
                  },
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pointsCopy.length,
                itemBuilder: (context, index) {
                  final point = pointsCopy[index];
                  final pointName =
                      point.name?.toLowerCase() ?? S.of(context).no_data;
                  final pointPharmacy = point.pharmacy_number?.toLowerCase() ??
                      S.of(context).no_data;
                  final query = searchController.text.toLowerCase();

                  if (pointName.contains(query) ||
                      pointPharmacy.contains(query)) {
                    return InkWell(
                      onLongPress: () {
                        _showPopupMenu(context, point);
                      },
                      child: _BuildExpandablePointItem(
                        point: point, // Используем элемент из копии списка
                        isExpanded: index ==
                            Provider.of<OrderDetailProvider>(context).selected,
                        onExpansionChanged: (bool isOpened) {
                          log('isOpened: $isOpened', name: _tag);
                          log('index: $index', name: _tag);
                          log('selected from provider: ${Provider.of<OrderDetailProvider>(context, listen: false).selected}',
                              name: _tag);
                          log('status: ${point?.status}');
                          if (isOpened) {
                            Provider.of<OrderDetailProvider>(context,
                                    listen: false)
                                .selected = index;
                          } else {
                            Provider.of<OrderDetailProvider>(context,
                                    listen: false)
                                .selected = -1;
                          }
                          setState(() {});
                          widget.callback.call(
                            isOpened: isOpened,
                            orderPoint:
                                point, // Используем элемент из копии списка
                          );
                        },
                      ),
                    );
                  } else {
                    return const SizedBox
                        .shrink(); // Скрыть элементы, которые не соответствуют поиску
                  }
                },
              )
            ],
          ));
    } else {
      // Обработка случая, когда список пуст
      return Text('Список пуст');
    }
  }
}

void _showPopupMenu(BuildContext context, point) {
  TextEditingController _messageController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Text(
              'Отклонение маршрута',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Причины отклонения',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Введите причины отклонения',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                // Обработчик отправки сообщения
                if (_messageController.text.isNotEmpty) {
                  _rejectRoute(context, _messageController.text);
                } else {
                  Fluttertoast.showToast(
                    msg: 'Введите причины отклонения',
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                  );
                }
              },
              child: Text('Отклонить маршрут'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Отклонение маршрута может повлиять на время доставки и требует обязательного подтверждения.',
              style: TextStyle(
                fontSize: 10,
                color: Colors.black45,
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

void _rejectRoute(BuildContext context, String reasons) {
  // Обработка отклонения маршрута
  Fluttertoast.showToast(
    msg: 'Маршрут отклонен по причинам: $reasons',
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.red,
  );
  Navigator.of(context).pop();
  // Ваш код для отклонения маршрута
}

class _BuildPointItem extends StatelessWidget {
  final String icon;
  final String? city;
  final DateTime? date;

  const _BuildPointItem({
    Key? key,
    required this.icon,
    required this.city,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 33,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorPalette.main,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SvgPicture.asset(
            "assets/images/svg/$icon.svg",
            color: ColorPalette.white,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat("dd MMMM yyyy, в")
                    .add_jm()
                    .format(date ?? DateTime.now()),
                style: ProjectTextStyles.ui_12Medium
                    .copyWith(color: ColorPalette.commonGrey),
              ),
              Text(
                city ?? S.of(context).no_data,
                style: ProjectTextStyles.ui_16Medium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BuildExpandablePointItem extends StatelessWidget {
  final PointDTO? point;
  final bool isExpanded;
  final Function(bool) onExpansionChanged;

  const _BuildExpandablePointItem({
    Key? key,
    required this.point,
    required this.isExpanded,
    required this.onExpansionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("isDeviation: ${point?.isDeviation}");
    bool isDeviationZero = (point?.isDeviation ?? -1) == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: ExpansionTile(
        onExpansionChanged: onExpansionChanged,
        initiallyExpanded: isExpanded,
        tilePadding: EdgeInsets.zero,
        expandedAlignment: Alignment.topLeft,
        childrenPadding: const EdgeInsets.only(left: 40),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color:
                    point?.status == "finished" || point?.status == 'Завершен'
                        ? ColorPalette.main
                        : ColorPalette.lightGrey,
                borderRadius: BorderRadius.circular(15),
              ),
              child: SvgPicture.asset(
                "assets/images/svg/orders_geo_done.svg",
                color:
                    point?.status == "finished" || point?.status == 'Завершен'
                        ? ColorPalette.white
                        : null,
                width: 18,
                height: 18,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat("dd MMMM yyyy, в")
                          .add_jm()
                          .format(point?.date ?? DateTime.now()),
                      style: ProjectTextStyles.ui_12Medium
                          .copyWith(color: ColorPalette.commonGrey),
                    ),
                    Row(
                      children: [
                        Text(
                          point?.crossdockName != null
                              ? '${point?.crossdockName} (Кроссдок)'
                              : (point?.name ?? S.of(context).no_data),
                          style: ProjectTextStyles.ui_16Medium,
                        ),
                      ],
                    ),
                    Text(
                      (point?.pharmacy_number ?? S.of(context).no_data),
                      style: ProjectTextStyles.ui_14Medium,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    if (!isExpanded)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/images/svg/pin-location.svg",
                            color: point?.status == "finished" ||
                                    point?.status == "Завершен"
                                ? ColorPalette.main
                                : null,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Expanded(
                            child: Text(
                              point?.address == null
                                  ? S.of(context).no_data
                                  : '${point?.address}',
                              style: ProjectTextStyles.ui_12Medium.copyWith(
                                color: ColorPalette.commonGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/images/svg/pin-location.svg",
                    color: point?.status == "finished" ||
                            point?.status == "Завершен"
                        ? ColorPalette.main
                        : null,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Expanded(
                    child: Text(
                      point?.address == null
                          ? S.of(context).no_data
                          : point?.address ?? "",
                      style: ProjectTextStyles.ui_12Medium.copyWith(
                        color: ColorPalette.commonGrey,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Количество контейнеров - ${point?.containers?.length}",
                textAlign: TextAlign.left,
                style: ProjectTextStyles.ui_12Medium
                    .copyWith(color: ColorPalette.black),
              ),
              if (point != null && point!.products != null)
                for (int k = 0; k < point!.products!.length; k++)
                  Text(
                    point!.products?[k].name ?? S.of(context).no_data,
                    style: ProjectTextStyles.ui_12Medium
                        .copyWith(color: ColorPalette.commonGrey),
                  ),
              const SizedBox(height: 4),
            ],
          ),
          if (isDeviationZero)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Icon(
                    Icons
                        .warning, // Иконка предупреждения (можете заменить на свою иконку)
                    color: Colors.yellow, // Цвет иконки
                    size: 24.0, // Размер иконки
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'Некоторый текст предупреждения', // Замените на свой текст
                    style: TextStyle(color: Colors.yellow),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
