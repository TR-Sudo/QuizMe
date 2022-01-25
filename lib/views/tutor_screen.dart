import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:quizme/utils/auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizme/widgets/app_drawer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../model/db_user.dart';

class TutorScreen extends StatefulWidget {
  const TutorScreen({Key? key}) : super(key: key);

  @override
  _TutorScreenState createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  final tutorData = FirebaseFirestore.instance.collection('tutors');
  var userDB = FirebaseFirestore.instance.collection('users');

  List<Marker> tutors = [];

  final defaultCenter =
      LatLng(43.9455, -78.8968); //For testing map: Ontario Tech
  late LatLng center;
  bool mapIsLoaded = false;
  //final center = LatLng(37.4219873, -122.0839954); //For testing map: Amphitheatre Pkwy

  MapController _mapController = MapController();
  Geolocator geolocator = Geolocator();
  String _currentLocation = '';
  String _address = '';
  String _phoneNum = '';
  String _price = '';
  double lat = 0.0, long = 0.0;

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final subjectController = TextEditingController();
  final priceController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.wait([
      getTutors(),
      _getCurrentPosition().then((currentPosition) {
        setState(() {
          center = (currentPosition != null)
              ? LatLng(currentPosition.latitude, currentPosition.longitude)
              : defaultCenter;
        });
      })
    ]).then((value) {
      setState(() {
        mapIsLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tutors"),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Markers'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: const [
                              Text(
                                  'Are you sure you want to delete your tutor markers?'),
                              SizedBox(height: 10),
                              Text('This action can\'t be undone.',
                                  style: TextStyle(fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                        actions: [
                          OutlinedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Deleting Marker(s)...')),
                              );

                              await deleteTutors();
                              getTutors();
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ButtonStyle(backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.red.withOpacity(0.5);
                                }
                                return Colors.red;
                              },
                            )),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.delete))
        ],
        backgroundColor: const Color(0xFFf85f6a),
      ),
      drawer: const AppDrawer(),
      body: !mapIsLoaded
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                  zoom: 15.0, center: center, minZoom: 5, maxZoom: 20),
              layers: [
                TileLayerOptions(
                    urlTemplate: dotenv.env['MAP_URL'],
                    additionalOptions: {
                      'accessToken': "${dotenv.env['MAP_TOKEN']}",
                      'id': 'mapbox.mapbox-streets-v8'
                    }),
                MarkerLayerOptions(markers: tutors),
              ],
            ),
      floatingActionButton: !mapIsLoaded
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xFFf85f6a),
              onPressed: () async {
                //Retrieving location & address
                var position = await _getCurrentPosition();
                if (position == null) return;

                setState(() {
                  _currentLocation =
                      "Position(${position.latitude}, ${position.longitude})";
                  lat = position.latitude;
                  long = position.longitude;
                });
                getAddress(lat, long);

                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Submit a Tutor Marker!'),
                        content: Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: nameController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter a name';
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                            icon: Icon(Icons.person),
                                            labelText: 'Name *',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: subjectController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter a subject';
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                            icon: Icon(Icons.subject),
                                            labelText: 'Subject *',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: priceController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter pricing';
                                            }
                                            return null;
                                          },
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            icon: Icon(Icons.money),
                                            labelText: 'Price *',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: phoneController,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter a phone number';
                                            } else if (value.length != 10) {
                                              return 'Number must be 10 digits long';
                                            }
                                            return null;
                                          },
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            icon: Icon(Icons.phone),
                                            labelText: 'Phone Number *',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: emailController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter an email';
                                            } else if (!value.contains("@") ||
                                                value.contains(" ")) {
                                              return "Invalid email";
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                            icon: Icon(Icons.mail),
                                            labelText: 'Email *',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: descriptionController,
                                          validator: (value) {
                                            if (value!.length > 100) {
                                              return 'Max Character Limit: 100';
                                            }
                                          },
                                          decoration: const InputDecoration(
                                            icon: Icon(Icons.info_outline),
                                            labelText: 'Description',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        actions: [
                          OutlinedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Submitting Marker...')),
                                );

                                _price = '\$' +
                                    priceController.text
                                        .replaceAll(' ', '')
                                        .replaceAll('-', '') +
                                    '/hr';

                                _phoneNum = '(' +
                                    phoneController.text.substring(0, 3) +
                                    ')' +
                                    ' ' +
                                    phoneController.text.substring(3, 6) +
                                    ' - ' +
                                    phoneController.text.substring(6, 10);

                                DBUser? user = await getAuthedUser();

                                Map<String, dynamic> insertRow = {
                                  "Name": nameController.text,
                                  "Subject": subjectController.text,
                                  "Price": _price,
                                  "Contact": _phoneNum,
                                  "Email": emailController.text,
                                  "Address": _address,
                                  "Description": descriptionController.text,
                                  "Location": GeoPoint(lat, long),
                                  "User": user!.username
                                };
                                await tutorData.add(insertRow);

                                getTutors();
                              }
                            },
                            child: const Text(
                              'Submit',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ButtonStyle(backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return const Color(0xFFf85f6a).withOpacity(0.5);
                                }
                                return const Color(0xFFf85f6a);
                              },
                            )),
                          )
                        ],
                      );
                    });
              },
              child: const Icon(Icons.add_location_alt)),
    );
  }

  Future<void> getTutors() async {
    DBUser? user = await getAuthedUser();
    await FirebaseFirestore.instance.collection('tutors').get().then((result) {
      if (result.docs.isNotEmpty) {
        List<Marker> updatedTutors = [];
        result.docs.forEach((e) {
          Marker marker = Marker(
              builder: (BuildContext context) {
                return IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return bottomSheet(
                              e.data()['Name'],
                              e.data()['Email'],
                              e.data()['Address'],
                              e.data()['Subject'],
                              e.data()['Contact'],
                              e.data()['Description'],
                              e.data()['Price']);
                        });
                  },
                  icon: const Icon(Icons.location_on),
                  iconSize: 30.0,
                  color: e.data()['User'] == user!.username
                      ? Colors.redAccent
                      : Colors.blueAccent,
                );
              },
              point: LatLng(e.data()['Location'].latitude,
                  e.data()['Location'].longitude));

          updatedTutors.add(marker);
        });

        setState(() {
          tutors = updatedTutors;
        });
      }
    });

    return;
  }

  Future<void> deleteTutors() async {
    DBUser? user = await getAuthedUser();
    await FirebaseFirestore.instance
        .collection('tutors')
        .where('User', isEqualTo: user!.username)
        .get()
        .then((result) {
      if (result.docs.isNotEmpty) {
        result.docs.forEach((element) {
          tutorData.doc(element.id).delete();
        });
      }
    });

    return;
  }

  Future<Position?> _getCurrentPosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    const String locationErrorMessage =
        "Could not get current location since location services are disabled.";
    const locationErrorSnackBar = SnackBar(
        duration: Duration(seconds: 5),
        content: Text(
          locationErrorMessage,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red);

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(locationErrorSnackBar);
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(locationErrorSnackBar);
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      // for some reason, in emulator, when location services are disabled, Geolocator.checkPermission()
      // returns LocationPermission.always and then Geolocator.getCurrentPosition() throws an exception
      // since location services are disabled.. so this just handles that case
      ScaffoldMessenger.of(context).showSnackBar(locationErrorSnackBar);
      return null;
    }
  }

  getAddress(double latitude, double longitude) async {
    List<Placemark> places =
        await placemarkFromCoordinates(latitude, longitude);

    _address =
        "${places.first.street}, ${places.first.locality}, ${places.first.country}, ${places.first.postalCode}";
  }
}

Widget bottomSheet(String name, String email, String address, String subject,
    String contact, String description, String price) {
  return Column(
    children: [
      Container(
        height: 80,
        color: Colors.blueAccent,
        child: ListTile(
          title: Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 20.0),
          ),
          subtitle: Text(
            subject,
            style: const TextStyle(color: Colors.white70, fontSize: 14.0),
          ),
          trailing: Text(
            price,
            style: const TextStyle(color: Colors.white, fontSize: 20.0),
          ),
        ),
      ),
      const SizedBox(
        height: 10.0,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 250,
            child: ListTile(
              title: FittedBox(child: Text(contact)),
              leading: const Icon(
                Icons.call,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
      const Divider(
        thickness: 1.5,
      ),
      Row(
        children: [
          SizedBox(
            width: 250,
            child: ListTile(
              title: FittedBox(child: Text(email)),
              leading: const Icon(
                Icons.mail,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
      const Divider(
        thickness: 1.5,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ListTile(
              title: FittedBox(child: Text(address)),
              leading: const Icon(
                Icons.location_on,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
      const Divider(
        thickness: 1.5,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ListTile(
              title: Text(
                description,
                style: const TextStyle(fontSize: 14),
              ),
              leading: const Icon(
                Icons.info_outline,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
      )
    ],
  );
}
