import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/utils/common_widgets/app_button.dart';


class MapScreen extends StatefulWidget {
  String? currentLocation;
  MapScreen({Key? key, this.currentLocation}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Position? position;
  BitmapDescriptor? pinLocationIcon;

  final Map<String, Marker> _markers = {};
  final Set<Circle> _circles = {};

  bool isLoading = false;

  String Address = 'Fetching...';
  String TitleAddress = 'Fetching...';

  String pincode = "";
  double lat = 0;
  double lng = 0;

  @override
  void initState() {
    super.initState();
    _initMap();
    _setCustomMapPin();
  }

  /// ---------------- INIT MAP ----------------
  Future<void> _initMap() async {
    position = await _getGeoLocationPosition();
    await _getAddressFromLatLong(position!);
    _updateLocationMarker(position!.latitude, position!.longitude);

    setState(() {
      isLoading = true;
    });
  }

  /// ---------------- GET CURRENT LOCATION ----------------
  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('Location services disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permission permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// ---------------- GET ADDRESS FROM LAT LNG ----------------
  Future<void> _getAddressFromLatLong(Position pos) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );

    Placemark place = placemarks.first;

    setState(() {
      lat = pos.latitude;
      lng = pos.longitude;
      pincode = place.postalCode ?? "";

      Address =
          "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";

      TitleAddress = place.subLocality ?? "";
    });
  }

  /// ---------------- CUSTOM MARKER ----------------
  void _setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'assets/images/start_map.png',
    );
  }

  /// ---------------- UPDATE MARKER ----------------
  void _updateLocationMarker(double lat, double lng) {
    _markers.clear();
    _circles.clear();

    _markers["current"] = Marker(
      markerId: const MarkerId("current"),
      position: LatLng(lat, lng),
      icon: pinLocationIcon ?? BitmapDescriptor.defaultMarker,
      draggable: true,
      onDragEnd: (newPos) {
        _handleTap(newPos.latitude, newPos.longitude);
      },
    );

    _circles.add(
      Circle(
        circleId: const CircleId("circle"),
        center: LatLng(lat, lng),
        radius: 1000,
        fillColor: Colors.blue.withOpacity(0.2),
        strokeColor: Colors.blueAccent,
        strokeWidth: 2,
      ),
    );
  }

  /// ---------------- MAP TAP ----------------
  Future<void> _handleTap(double latitude, double longitude) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      latitude,
      longitude,
    );

    Placemark place = placemarks.first;

    setState(() {
      lat = latitude;
      lng = longitude;
      pincode = place.postalCode ?? "";

      Address =
          "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";

      TitleAddress = place.subLocality ?? "";
    });

    _updateLocationMarker(latitude, longitude);
    _zoomLocation(latitude, longitude);
  }

  /// ---------------- CAMERA ZOOM ----------------
  void _zoomLocation(double lat, double lng) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 18),
      ),
    );
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              mapController = controller;
            },
            zoomGesturesEnabled: true,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: CameraPosition(
              target: LatLng(position!.latitude, position!.longitude),
              zoom: 18,
            ),
            markers: _markers.values.toSet(),
            circles: _circles,
            mapType: MapType.normal,
            onTap: (tapped) => _handleTap(tapped.latitude, tapped.longitude),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 20.0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.backBtnBgColor,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppTheme.black_Color,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Material(
                color: AppTheme.whiteColor,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 5.0, left: 10.0),
                        child: Text(
                          "SELECT COURT ADDRESS",
                          style: MyStyles.boldText(
                            size: 14,
                            color: AppTheme.black_Color,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (TitleAddress.isNotEmpty)
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/address.svg',
                                    height: 18,
                                    width: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    TitleAddress,
                                    style: MyStyles.regularText(
                                      size: 14,
                                      color: AppTheme.graySubTitleColor,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          Address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: MyStyles.regularText(
                            size: 14,
                            color: AppTheme.black_Color,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        child: AppButton(
                          title: "save",
                          isLoading: false,
                          color: AppTheme.btnColor,
                          onTap: () {
                            Map<String, dynamic> locationData = {
                              "address": Address,
                              "pincode": pincode,
                              "lat": lat,
                              "lng": lng,
                            };
                            Navigator.pop(context, locationData);
                          },
                        ),
                      ),
                    ],
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
