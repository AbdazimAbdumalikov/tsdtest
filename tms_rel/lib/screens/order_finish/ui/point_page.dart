import 'package:europharm_flutter/generated/l10n.dart';
import 'package:europharm_flutter/network/models/order_dto.dart';
import 'package:europharm_flutter/network/models/phone_list.dart';
import 'package:europharm_flutter/network/models/point_dto.dart';
import 'package:europharm_flutter/network/repository/global_repository.dart';
import 'package:europharm_flutter/screens/map_screen/data/bloc/map_cubit.dart';
import 'package:europharm_flutter/screens/map_screen/data/repo_map.dart';
import 'package:europharm_flutter/screens/map_screen/map.dart';
import 'package:europharm_flutter/screens/map_screen/point_map.dart';
import 'package:europharm_flutter/screens/order_card/bloc/order_detail_bloc.dart';
import 'package:europharm_flutter/screens/order_card/ui/order_detail_page.dart';
import 'package:europharm_flutter/screens/order_card/ui/widgets/line_animation.dart';
import 'package:europharm_flutter/screens/order_finish/bloc/point_page_bloc.dart';
import 'package:europharm_flutter/screens/order_finish/ui/widgets/success_order_finished.dart';
import 'package:europharm_flutter/styles/color_palette.dart';
import 'package:europharm_flutter/styles/text_styles.dart';
import 'package:europharm_flutter/utils/app_router.dart';
import 'package:europharm_flutter/widgets/app_bottom_sheets/app_bottom_sheet.dart';
import 'package:europharm_flutter/widgets/app_bottom_sheets/app_dialog.dart';
import 'package:europharm_flutter/widgets/app_loader_overlay.dart';
import 'package:europharm_flutter/widgets/main_button/main_button.dart';
import 'package:europharm_flutter/widgets/main_text_field/app_text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PointPage extends StatefulWidget {
  final OrderDTO order;
  final bool isScan;
  final PointDTO point;
  final GlobalRepository repository;

  const PointPage({
    Key? key,
    required this.order,
    required this.point,
    required this.repository,
    this.isScan = true,
  }) : super(key: key);

  @override
  State<PointPage> createState() => _PointPageState();
}

class _PointPageState extends State<PointPage> with TickerProviderStateMixin {
  List<String> buttonText = [
    "Продолжить",
    "Принять оплату",
    "Принять и подписать",
  ];
  int _current = 0;

  late TabController _tabController;
  late PageController pageController;
  String? selectedValue;
  int? productId;
  late bool isScan;

  @override
  void initState() {
    super.initState();
    productId = 0;
    isScan = widget.isScan;
    _tabController = TabController(length: 2, vsync: this);
    pageController = PageController();
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          if (kDebugMode) {
            print(_tabController.index);
          }
          _current = _tabController.index;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AppLoaderOverlay(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "${widget.point.name}",
              style: const TextStyle(
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
                Navigator.of(context).pop();
              },
            ),
          ),
          backgroundColor: ColorPalette.white,
          body: SafeArea(
            child: BlocConsumer<PointPageBloc, PointPageState>(
              listener: (context, state) {
                if (state is PointPageStateLoading) {
                  context.loaderOverlay.show();
                } else {
                  context.loaderOverlay.hide();
                }

                if (state is PointPageStateFinished) {
                  AppRouter.pushReplacement(
                    context,
                    const SuccessOrderFinished(),
                  );

                  BlocProvider.of<OrderDetailBloc>(context)
                      .add(OrderDetailRefreshEvent(
                    orderId: widget.order.id,
                  ));
                }

                if (state is PointPageStateError) {
                  showAppDialog(
                    context,
                    title: state.error.message,
                    onTap: () => Navigator.pop(context),
                  );
                }
              },
              buildWhen: (p, c) => c is PointPageStateLoaded,
              builder: (context, state) {
                if (state is PointPageStateLoaded) {
                  return Stack(
                    children: [
                      // const SizedBox(height: 15),
                      _MapSection(
                        order: widget.order,
                      ),
                      SizedBox.expand(
                        child: DraggableScrollableSheet(
                          initialChildSize: 0.4,
                          minChildSize: 0.2,
                          maxChildSize: 0.95,
                          builder: (BuildContext context,
                              ScrollController scrollController) {
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 15.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(25)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: SingleChildScrollView(
                                key: UniqueKey(),
                                controller: scrollController,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height * 1,
                                  ),
                                  child: Column(
                                    children: [
                                      AnimatedGradientDivider(),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  widget.point?.ourPharmacy == 0
                                                      ? Text(
                                                          "Контрагент",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.purple,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                          ),
                                                        )
                                                      : widget.point
                                                                  ?.ourPharmacy !=
                                                              1
                                                          ? Text(
                                                              widget.point
                                                                      ?.ourPharmacy
                                                                      .toString() ??
                                                                  S
                                                                      .of(context)
                                                                      .no_data,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .purple,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                            )
                                                          : Container(),
                                                  Text(
                                                    widget.order.startDate !=
                                                            null
                                                        ? DateFormat(
                                                                "dd MMMM, hh:mm")
                                                            .format(widget.order
                                                                .startDate!)
                                                        : "",
                                                    style: ProjectTextStyles
                                                        .ui_12Medium
                                                        .copyWith(
                                                      color: ColorPalette
                                                          .commonGrey,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${widget.point.address}",
                                                    // order.customerName ?? S.of(context).no_data,
                                                    style: ProjectTextStyles
                                                        .ui_16Medium,
                                                  ),
                                                  widget.point?.ourPharmacy == 0
                                                      ? Text(
                                                          "Подтвердите заказ, отправив SMS-код",
                                                          style: TextStyle(
                                                            color: Colors.blue,
                                                            fontSize: 14,
                                                          ),
                                                        )
                                                      : widget.point
                                                                  ?.ourPharmacy !=
                                                              1
                                                          ? Text(
                                                              widget.point
                                                                      ?.ourPharmacy
                                                                      .toString() ??
                                                                  S
                                                                      .of(context)
                                                                      .no_data,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .purple,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                            )
                                                          : Container(),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: ColorPalette.background,
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          height: 46,
                                          child: TabBar(
                                            indicator: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: ColorPalette.main,
                                            ),
                                            indicatorSize:
                                                TabBarIndicatorSize.tab,
                                            labelPadding: EdgeInsets.zero,
                                            labelColor: ColorPalette.white,
                                            labelStyle:
                                                ProjectTextStyles.ui_16Medium,
                                            unselectedLabelColor:
                                                ColorPalette.commonGrey,
                                            controller: _tabController,
                                            onTap: (index) {
                                              setState(() {
                                                _current = index;
                                                pageController.animateToPage(
                                                  _current,
                                                  duration: const Duration(
                                                      milliseconds: 50),
                                                  curve: Curves.ease,
                                                );
                                              });
                                            },
                                            tabs: const [
                                              Tab(
                                                child: Text("Контейнеры"),
                                              ),
                                              Tab(
                                                child: Text("QR"),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 28,
                                      ),
                                      // _buildOrderData(context),
                                      Expanded(
                                        child: PageView(
                                          controller: pageController,
                                          onPageChanged: (int page) {
                                            _current = page;
                                            _tabController.animateTo(page);
                                            setState(() {});
                                          },
                                          children: [
                                            if (state.orderPoint.containers !=
                                                    null &&
                                                state.orderPoint.containers!
                                                    .isNotEmpty)
                                              ListView.separated(
                                                shrinkWrap: true,
                                                itemCount: state.orderPoint
                                                    .containers!.length,
                                                separatorBuilder:
                                                    (context, index) =>
                                                        const SizedBox(
                                                  height: 8,
                                                ), //state.orderPoint.products?.length,
                                                itemBuilder: (context, index) {
                                                  // return Container(
                                                  //   color: Colors.black,
                                                  //   height: 100,
                                                  // );

                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      bottom: 17,
                                                      left: 10,
                                                      right: 10,
                                                    ),
                                                    child: GestureDetector(
                                                      onTap: !isScan
                                                          ? null
                                                          : () {
                                                              setState(() {
                                                                if (productId ==
                                                                    state
                                                                        .orderPoint
                                                                        .containers?[
                                                                            index]
                                                                        .containerId) {
                                                                  productId = 0;
                                                                } else {
                                                                  productId = state
                                                                      .orderPoint
                                                                      .containers?[
                                                                          index]
                                                                      .containerId;
                                                                }
                                                              });
                                                            },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(7),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                          color: state
                                                                      .orderPoint
                                                                      .containers?[
                                                                          index]
                                                                      .containerId ==
                                                                  productId
                                                              ? ColorPalette
                                                                  .main
                                                                  .withOpacity(
                                                                      0.1)
                                                              : null,
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                    9,
                                                                  ),
                                                                  width: 40,
                                                                  height: 40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: ColorPalette
                                                                        .orange
                                                                        .withOpacity(
                                                                            0.1),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                      100,
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    "assets/images/svg/box.svg",
                                                                    color: ColorPalette
                                                                        .orange,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  state
                                                                          .orderPoint
                                                                          .containers?[
                                                                              index]
                                                                          .code ??
                                                                      "No data",
                                                                  style: ProjectTextStyles
                                                                      .ui_14Medium
                                                                      .copyWith(
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            if (state
                                                                .orderPoint
                                                                .containers![
                                                                    index]
                                                                .isScanned)
                                                              SvgPicture.asset(
                                                                "assets/images/svg/ic_check.svg",
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )
                                            else
                                              const Center(
                                                child: Text('Товаров нет'),
                                              ),

                                            ///
                                            ///
                                            ///

                                            // Padding(
                                            //   padding: const EdgeInsets.symmetric(
                                            //     horizontal: 10.0,
                                            //   ),
                                            //   child: Row(
                                            //     crossAxisAlignment: CrossAxisAlignment.start,
                                            //     children: [
                                            //       Padding(
                                            //         padding: const EdgeInsets.only(top: 8.0),
                                            //         child: Container(
                                            //           padding: const EdgeInsets.all(7),
                                            //           decoration: BoxDecoration(
                                            //             color: ColorPalette.main.withOpacity(0.1),
                                            //             borderRadius: BorderRadius.circular(100),
                                            //           ),
                                            //           child: SvgPicture.asset(
                                            //             "assets/images/svg/payments.svg",
                                            //           ),
                                            //         ),
                                            //       ),
                                            //       const SizedBox(
                                            //         width: 12,
                                            //       ),
                                            //       Column(
                                            //         crossAxisAlignment: CrossAxisAlignment.start,
                                            //         children: [
                                            //           RichText(
                                            //             text: TextSpan(
                                            //               children: [
                                            //                 const TextSpan(
                                            //                   text: "Тип оплаты: ",
                                            //                   style:
                                            //                       ProjectTextStyles.ui_16Medium,
                                            //                 ),
                                            //                 TextSpan(
                                            //                   text: "Наличными",
                                            //                   style: ProjectTextStyles.ui_16Medium
                                            //                       .copyWith(
                                            //                     color: ColorPalette.main,
                                            //                   ),
                                            //                 ),
                                            //               ],
                                            //             ),
                                            //           ),
                                            //           RichText(
                                            //             text: TextSpan(
                                            //               children: [
                                            //                 const TextSpan(
                                            //                   text: "Сумма оплаты: ",
                                            //                   style:
                                            //                       ProjectTextStyles.ui_16Medium,
                                            //                 ),
                                            //                 TextSpan(
                                            //                   text: "95 310. 00 ₸",
                                            //                   style: ProjectTextStyles.ui_16Medium
                                            //                       .copyWith(
                                            //                     color: ColorPalette.main,
                                            //                   ),
                                            //                 ),
                                            //               ],
                                            //             ),
                                            //           ),
                                            //         ],
                                            //       )
                                            //     ],
                                            //   ),
                                            // )
                                            Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  // top: 10,
                                                  left: 10,
                                                  right: 10,
                                                  bottom: 80,
                                                ),
                                                // child: QrImage(
                                                //   data: widget.point.name!,
                                                //   version: QrVersions.auto,
                                                //   // size: 200.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ),

          ///
          ///
          ///
          ///
          ///
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: BlocBuilder<PointPageBloc, PointPageState>(
            builder: (context, state) {
              if (state is PointPageStateLoaded &&
                  (state.orderPoint.status != "Завершен")) {
                print("${widget.order.orderType}");
                bool isAcceptAndSignButton = widget.point.ourPharmacy == 0;
                return SizedBox(
                  height: 70,
                  child: Padding(
                      padding: const EdgeInsets.only(
                        left: 10.0,
                        right: 10,
                        bottom: 10,
                      ),
                      child: _current ==
                              0 //  !isScan || (state.areAllFinished && _current == 0)
                          ? GestureDetector(
                              onTap: () {
                                if (!isScan) {
                                  for (var element
                                      in state.orderPoint.products!) {
                                    context.read<PointPageBloc>().add(
                                          PointPageEventProductFinish(
                                            productId: element.id,
                                            code: element.code!,
                                          ),
                                        );
                                  }
                                  setState(() {
                                    isScan = true;
                                  });
                                }
                                setState(() {
                                  _current = 1;
                                  pageController.animateToPage(
                                    _current,
                                    duration: const Duration(milliseconds: 50),
                                    curve: Curves.ease,
                                  );
                                  _tabController.animateTo(_current);
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: ColorPalette.secondaryMain,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Text(
                                        buttonText[0],
                                        style: ProjectTextStyles.ui_16Medium
                                            .copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 15,
                                      child: SvgPicture.asset(
                                        "assets/images/svg/arrow_right.svg",
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          : _current == 0
                              ? GestureDetector(
                                  onTap: productId != 0
                                      ? () {
                                          showCreatePasswordBottomDialog(
                                            context,
                                            productId!,
                                          );
                                        }
                                      : null,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    decoration: BoxDecoration(
                                      color: productId != 0
                                          ? ColorPalette.main
                                          : ColorPalette.lightGrey,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Text(
                                            "Отсканировать",
                                            style: ProjectTextStyles.ui_16Medium
                                                .copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 18,
                                          child: SvgPicture.asset(
                                            "assets/images/svg/scan.svg",
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : isAcceptAndSignButton
                                  ? GestureDetector(
                                      onTap: () async {
                                        _handleSendSMS();
                                        // try {
                                        //   final phoneList = await widget
                                        //       .repository
                                        //       .getPhoneList(
                                        //           pointId: widget.point.id);
                                        //   // После успешного получения данных, отображаем их в модальном нижнем окне
                                        //   showModalBottomSheet<void>(
                                        //     context: context,
                                        //     builder: (BuildContext context) {
                                        //       return ListView.builder(
                                        //         itemCount: phoneList
                                        //             .data?.phones!.length,
                                        //         itemBuilder: (context, index) {
                                        //           final phone = phoneList
                                        //               .data?.phones![index];
                                        //           return ListTile(
                                        //             title: Text(phone!),
                                        //             // Добавьте другие данные телефона, если это необходимо
                                        //           );
                                        //         },
                                        //       );
                                        //     },
                                        //   );
                                        // } catch (e) {
                                        //   // Обработка ошибок
                                        //   print(
                                        //       'Ошибка при получении списка телефонов: $e');
                                        //   // Возможно, покажем диалог с ошибкой или выполним другие действия
                                        // }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        decoration: BoxDecoration(
                                          color: ColorPalette.main,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: Text(
                                                "Отправить СМС",
                                                style: ProjectTextStyles
                                                    .ui_16Medium
                                                    .copyWith(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        BlocProvider.of<PointPageBloc>(context)
                                            .add(
                                          PointPageEventFinishingPoint(
                                            pointId: widget.point.id,
                                            containers:
                                                widget.point.containers ?? [],
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: ColorPalette.secondaryMain,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: Text(
                                                "Принять и подписать",
                                                style: ProjectTextStyles
                                                    .ui_16Medium
                                                    .copyWith(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleSendSMS() async {
    try {
      final phoneList =
          await widget.repository.getPhoneList(pointId: widget.point.id);
      if (phoneList.data?.phones != null &&
          phoneList.data!.phones!.isNotEmpty) {
        final selectedPhone = await showModalBottomSheet<String>(
          context: context,
          builder: (BuildContext context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Выберите номер телефона',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: phoneList.data!.phones!.length,
                    itemBuilder: (context, index) {
                      final phone = phoneList.data!.phones![index];
                      return ListTile(
                        title: Text(phone),
                        onTap: () {
                          Navigator.pop(context, phone);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );

        if (selectedPhone != null) {
          try {
            final employeeId = phoneList.data!.employeeId ?? 0;
            final codeResponse =
                await widget.repository.createCode(employeeId: employeeId);
            final code = codeResponse
                .code; // Извлекаем код из объекта CreateCodeResponse
            print('Generated code: $code');
            // Показываем диалог с выбранным номером и полем для ввода кода
            _showVerificationDialog(context, selectedPhone, code);
          } catch (e) {
            print('Error creating code: $e');
          }
        } else {
          print('No phone selected');
        }
      } else {
        print('No phones available');
      }
    } catch (e) {
      print('Error sending SMS: $e');
    }
  }

  void _showVerificationDialog(
      BuildContext context, String phoneNumber, int code) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String verificationCode = '';
        bool verificationFailed = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Подтверждение кода'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Подтвердите код. Номер телефона: $phoneNumber'),
                  SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Введите код',
                      errorText: verificationFailed ? 'Неверный код' : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        verificationCode = value;
                        verificationFailed = false;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    try {
                      final confirmResponse = await widget.repository
                          .confirmCode(code: verificationCode);
                      print('Confirmation status: ${confirmResponse.message}');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Код успешно подтвержден'),
                        backgroundColor: Colors.green,
                      ));
                      if (verificationCode == code.toString()) {
                        // Вызываем orderPointFinish только в случае успешной верификации
                        await widget.repository
                            .orderPointFinish(pointId: widget.point.id);
                        AppRouter.pushReplacement(
                          context,
                          const SuccessOrderFinished(),
                        );
                        // ignore: use_build_context_synchronously
                        AppRouter.pushReplacement(
                          context,
                          OrderDetailPage(
                            order: widget.order,
                          ),
                        );
                        // Navigator.popUntil(
                        //   context,
                        //   ModalRoute.withName(Navigator.defaultRouteName),
                        // );
                        // Вызываем обновление экрана
                        setState(() {});
                      }
                    } catch (e) {
                      print('Error confirming code: $e');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Ошибка при подтверждении кода'),
                        backgroundColor: Colors.red,
                      ));
                    }

                    if (verificationCode != code.toString()) {
                      print('Verification failed');
                      setState(() {
                        verificationFailed = true;
                      });
                    }
                  },
                  child: Text('Подтвердить'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class GetPhone extends StatelessWidget {
  final int pointId;
  const GetPhone({super.key, required this.pointId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PointPageBloc, PointPageState>(
      builder: (context, state) {
        if (state is PointPageStatePhoneListLoaded) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Список номеров:',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: state.phoneList.data?.phones?.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(
                        state.phoneList.data!.phones![index],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }
}

void _showPhoneListBottomSheet(BuildContext context, PhoneList phoneList) {
  Container(
    padding: EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Список номеров:',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.0),
        Expanded(
          child: ListView.builder(
            itemCount: phoneList.data?.phones?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(
                  phoneList.data?.phones?[index] ?? '',
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

void showCreatePasswordBottomDialog(BuildContext context, int productId) {
  showAppBottomSheet(
    context,
    initialChildSize: 0.45,
    useRootNavigator: true,
    child: _BuildScanMethodChoose(
      onScan: (code) => context.read<PointPageBloc>().add(
            PointPageEventProductFinish(
              productId: productId,
              code: code.toString(),
            ),
          ),
    ),
  );
}

class _MapSection extends StatelessWidget {
  final OrderDTO order;
  const _MapSection({
    required this.order,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        // height: MediaQuery.of(context).size.height * 1,
        decoration: BoxDecoration(
          color: ColorPalette.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            BlocProvider(
              create: (_) => MapCubit(
                mapRepository: MapRepository(),
                repository: context.read<GlobalRepository>(),
              ),
              child: SessionPage(
                orderId: order.id,
                order: order,
                // pointId: order.id,
                repository: context.read<GlobalRepository>(),
                orderPoints: [], // TODO
              ),
            ),
            // YandexMap(
            //   mapObjects: widget.mapObjects,
            //   fastTapEnabled: true,
            //   mode2DEnabled: true,
            // ),
            Positioned(
              right: 5,
              top: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: ColorPalette.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 4.5,
                  horizontal: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      height: 6,
                      width: 6,
                      decoration: BoxDecoration(
                        color: ColorPalette.red,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text(
                      "LIVE",
                      style: ProjectTextStyles.ui_12Medium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildScanMethodChoose extends StatelessWidget {
  final Function onScan;

  const _BuildScanMethodChoose({Key? key, required this.onScan})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        children: [
          Center(
            child: Text(
              "Выберите способ сканирования",
              style: ProjectTextStyles.ui_16Medium.copyWith(
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              String barcode = await FlutterBarcodeScanner.scanBarcode(
                '#ff6666',
                'Cancel',
                true,
                ScanMode.BARCODE,
              );
              if (barcode.isNotEmpty) {
                Navigator.pop(context, barcode);
                onScan.call(barcode);
                // blocContext.read<BlocOrderFinish>().add(EventOrderProductFinish(
                //     productId: productId, code: barcode));
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: ColorPalette.main,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  "Сфотографировать",
                  style: ProjectTextStyles.ui_16Medium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              showBarcodeEnterDialog(context, onScan);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: ColorPalette.main,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  "Ручной сканнер",
                  style: ProjectTextStyles.ui_16Medium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showBarcodeEnterDialog(BuildContext context, Function onScan) {
  showAppBottomSheet(
    context,
    initialChildSize: 0.45,
    useRootNavigator: true,
    child: BuildBarcodeEnterField(onScan: onScan),
  );
}

class BuildBarcodeEnterField extends StatefulWidget {
  final Function onScan;

  const BuildBarcodeEnterField({Key? key, required this.onScan})
      : super(key: key);

  @override
  _BuildBarcodeEnterField createState() => _BuildBarcodeEnterField();
}

class _BuildBarcodeEnterField extends State<BuildBarcodeEnterField> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 10,
      ),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Введите код",
            style: ProjectTextStyles.ui_20Medium,
          ),
          const SizedBox(
            height: 20,
          ),
          AppTextField(
            controller: controller,
            hintStyle: ProjectTextStyles.ui_16Medium.copyWith(
              color: ColorPalette.commonGrey,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          MainButton(
            title: "Подтвердить",
            onTap: () {
              Navigator.pop(context, controller.text);
              widget.onScan(controller.text);
            },
          )
        ],
      ),
    );
  }
}

class BottomSheetExample extends StatelessWidget {
  const BottomSheetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: const Text('showModalBottomSheet'),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('Modal BottomSheet'),
                      ElevatedButton(
                        child: const Text('Close BottomSheet'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
