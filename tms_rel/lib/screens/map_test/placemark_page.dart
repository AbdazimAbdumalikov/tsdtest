import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'control_button.dart';
import 'map_page.dart';

const _tag = 'placemark_page';

class PlacemarkPage extends MapPage {
  const PlacemarkPage() : super('Placemark example');

  @override
  Widget build(BuildContext context) {
    return _PlacemarkExample();
  }
}

class _PlacemarkExample extends StatefulWidget {
  @override
  _PlacemarkExampleState createState() => _PlacemarkExampleState();
}

class _PlacemarkExampleState extends State<_PlacemarkExample> {
  final List<MapObject> mapObjects = [];

  final MapObjectId placemarkId = const MapObjectId('normal_icon_placemark');
  final MapObjectId placemarkWithDynamicIconId =
      const MapObjectId('dynamic_icon_placemark');
  final MapObjectId placemarkWithCompositeIconId =
      const MapObjectId('composite_icon_placemark');

  Future<Uint8List> _rawPlacemarkImage() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(50, 50);
    final fillPaint = Paint()
      ..color = Colors.blue[100]!
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const radius = 20.0;

    final circleOffset = Offset(size.height / 2, size.width / 2);

    canvas.drawCircle(circleOffset, radius, fillPaint);
    canvas.drawCircle(circleOffset, radius, strokePaint);

    final image = await recorder
        .endRecording()
        .toImage(size.width.toInt(), size.height.toInt());
    final pngBytes = await image.toByteData(format: ImageByteFormat.png);

    return pngBytes!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: YandexMap(mapObjects: mapObjects)),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const Text('Placemark with Assets Icon:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ControlButton(
                      onPressed: () async {
                        if (mapObjects.any((el) => el.mapId == placemarkId)) {
                          return;
                        }

                        final placemark = PlacemarkMapObject(
                          mapId: placemarkId,
                          point: const Point(
                            latitude: 59.945933,
                            longitude: 30.320045,
                          ),
                          onTap: (PlacemarkMapObject self, Point point) =>
                              log('Tapped me at $point', name: _tag),
                          opacity: 0.7,
                          direction: 90,
                          isDraggable: true,
                          onDragStart: (_) => log('Drag start', name: _tag),
                          onDrag: (_, Point point) =>
                              log('Drag at point $point', name: _tag),
                          onDragEnd: (_) => log('Drag end', name: _tag),
                          icon: PlacemarkIcon.single(
                            PlacemarkIconStyle(
                              image: BitmapDescriptor.fromAssetImage(
                                'lib/assets/place.png',
                              ),
                              rotationType: RotationType.rotate,
                            ),
                          ),
                        );

                        setState(() {
                          mapObjects.add(placemark);
                        });
                      },
                      title: 'Add',
                    ),
                    ControlButton(
                      onPressed: () async {
                        if (!mapObjects.any((el) => el.mapId == placemarkId)) {
                          return;
                        }

                        final placemark = mapObjects
                                .firstWhere((el) => el.mapId == placemarkId)
                            as PlacemarkMapObject;

                        setState(() {
                          mapObjects[mapObjects.indexOf(placemark)] =
                              placemark.copyWith(
                            point: Point(
                              latitude: placemark.point.latitude - 1,
                              longitude: placemark.point.longitude - 1,
                            ),
                          );
                        });
                      },
                      title: 'Update',
                    ),
                    ControlButton(
                      onPressed: () async {
                        setState(() {
                          mapObjects
                              .removeWhere((el) => el.mapId == placemarkId);
                        });
                      },
                      title: 'Remove',
                    ),
                  ],
                ),
                const Text('Placemark with Binary Icon:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ControlButton(
                      onPressed: () async {
                        if (mapObjects.any(
                          (el) => el.mapId == placemarkWithDynamicIconId,
                        )) {
                          return;
                        }

                        final placemarkWithDynamicIcon = PlacemarkMapObject(
                          mapId: placemarkWithDynamicIconId,
                          point: const Point(
                            latitude: 30.320045,
                            longitude: 59.945933,
                          ),
                          onTap: (PlacemarkMapObject self, Point point) =>
                              log('Tapped me at $point', name: _tag),
                          isDraggable: true,
                          onDragStart: (_) => log('Drag start', name: _tag),
                          onDrag: (_, Point point) =>
                              log('Drag at point $point', name: _tag),
                          onDragEnd: (_) => log('Drag end', name: _tag),
                          opacity: 0.95,
                          icon: PlacemarkIcon.single(
                            PlacemarkIconStyle(
                              image: BitmapDescriptor.fromBytes(
                                await _rawPlacemarkImage(),
                              ),
                            ),
                          ),
                        );

                        setState(() {
                          mapObjects.add(placemarkWithDynamicIcon);
                        });
                      },
                      title: 'Add',
                    ),
                    ControlButton(
                      onPressed: () async {
                        if (!mapObjects.any(
                          (el) => el.mapId == placemarkWithDynamicIconId,
                        )) {
                          return;
                        }

                        final placemarkWithDynamicIcon = mapObjects.firstWhere(
                          (el) => el.mapId == placemarkWithDynamicIconId,
                        ) as PlacemarkMapObject;

                        setState(() {
                          mapObjects[mapObjects
                                  .indexOf(placemarkWithDynamicIcon)] =
                              placemarkWithDynamicIcon.copyWith(
                            point: Point(
                              latitude:
                                  placemarkWithDynamicIcon.point.latitude + 1,
                              longitude:
                                  placemarkWithDynamicIcon.point.longitude + 1,
                            ),
                          );
                        });
                      },
                      title: 'Update',
                    ),
                    ControlButton(
                      onPressed: () async {
                        setState(() {
                          mapObjects.removeWhere(
                            (el) => el.mapId == placemarkWithDynamicIconId,
                          );
                        });
                      },
                      title: 'Remove',
                    ),
                  ],
                ),
                const Text('Placemark with Composite Icon:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ControlButton(
                      onPressed: () async {
                        if (mapObjects.any(
                          (el) => el.mapId == placemarkWithCompositeIconId,
                        )) {
                          return;
                        }

                        final placemarkWithCompositeIcon = PlacemarkMapObject(
                          mapId: placemarkWithCompositeIconId,
                          point: const Point(
                            latitude: 34.820045,
                            longitude: 45.945933,
                          ),
                          onTap: (PlacemarkMapObject self, Point point) => log(
                            'Tapped me at $point',
                          ),
                          isDraggable: true,
                          onDragStart: (_) => log('Drag start', name: _tag),
                          onDrag: (_, Point point) =>
                              log('Drag at point $point', name: _tag),
                          onDragEnd: (_) => log('Drag end', name: _tag),
                          icon: PlacemarkIcon.composite(
                            [
                              PlacemarkCompositeIconItem(
                                name: 'user',
                                style: PlacemarkIconStyle(
                                  image: BitmapDescriptor.fromAssetImage(
                                    'lib/assets/user.png',
                                  ),
                                ),
                              ),
                              PlacemarkCompositeIconItem(
                                name: 'arrow',
                                style: PlacemarkIconStyle(
                                  image: BitmapDescriptor.fromAssetImage(
                                    'lib/assets/arrow.png',
                                  ),
                                  anchor: const Offset(0.5, 1.5),
                                ),
                              )
                            ],
                          ),
                          opacity: 0.7,
                        );

                        setState(() {
                          mapObjects.add(placemarkWithCompositeIcon);
                        });
                      },
                      title: 'Add',
                    ),
                    ControlButton(
                      onPressed: () async {
                        if (!mapObjects.any(
                          (el) => el.mapId == placemarkWithCompositeIconId,
                        )) {
                          return;
                        }

                        final placemarkWithCompositeIcon =
                            mapObjects.firstWhere(
                          (el) => el.mapId == placemarkWithCompositeIconId,
                        ) as PlacemarkMapObject;

                        setState(
                          () {
                            mapObjects[mapObjects
                                    .indexOf(placemarkWithCompositeIcon)] =
                                placemarkWithCompositeIcon.copyWith(
                              point: Point(
                                latitude:
                                    placemarkWithCompositeIcon.point.latitude +
                                        1,
                                longitude:
                                    placemarkWithCompositeIcon.point.longitude +
                                        1,
                              ),
                            );
                          },
                        );
                      },
                      title: 'Update',
                    ),
                    ControlButton(
                      onPressed: () async {
                        setState(
                          () {
                            mapObjects.removeWhere(
                              (el) => el.mapId == placemarkWithCompositeIconId,
                            );
                          },
                        );
                      },
                      title: 'Remove',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
