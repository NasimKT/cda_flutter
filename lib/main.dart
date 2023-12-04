import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:CDA/db.dart';

void main() {
  runApp(EmergencyApp());
}

class EmergencyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isToggleOn = false;
  PermissionStatus permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  void checkPermission() async {
    // Check and request location permission
    if (await Permission.location.status == PermissionStatus.denied) {
      await Permission.location.request();
    }

    // Check and request call phone permission
    if (await Permission.phone.status == PermissionStatus.denied) {
      await Permission.phone.request();
    }

    // Check and request send SMS permission
    if (await Permission.sms.status == PermissionStatus.denied) {
      await Permission.sms.request();
    }

    // Check and request coarse location permission
    if (await Permission.locationWhenInUse.status == PermissionStatus.denied) {
      await Permission.locationWhenInUse.request();
    }

    // Check and request read contacts permission
    if (await Permission.contacts.status == PermissionStatus.denied) {
      await Permission.contacts.request();
    }

    // Update permissionStatus
    PermissionStatus status = await Permission.location.status;

    setState(() {
      permissionStatus = status;
    });
  }

  void openNewWindow(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EmergencyContacts()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/app_icon.png'),
        title: Text('C D A'),
        backgroundColor: Color.fromARGB(255, 0, 195, 255),
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (permissionStatus == PermissionStatus.granted) ...[
              Text(
                isToggleOn ? 'TURN OFF SERVICE' : 'TURN ON SERVICE',
                style: TextStyle(
                  color: const Color.fromARGB(255, 243, 33, 33),
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Switch(
                value: isToggleOn,
                onChanged: (value) {
                  setState(() {
                    isToggleOn = value;
                  });
                  // Add your logic for toggle change if needed
                },
              ),
              if (isToggleOn) ...[
                ElevatedButton(
                  onPressed: () {
                    // Use a Builder here to get a context with a Navigator
                    openNewWindow(context);
                  },
                  child: Text('Add Emergency Contacts'),
                ),
              ],
            ] else ...[
              Text('Allow all the permissions to start the service.'),
              ElevatedButton(
                onPressed: () async {
                  await Permission.location.request();
                  checkPermission();
                },
                child: Text('Request Permission'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmergencyContacts extends StatelessWidget {
  const EmergencyContacts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.quick_contacts_dialer_outlined),
        title: const Text("Add Emergency Contacts"),
        backgroundColor: Color.fromARGB(255, 0, 195, 255),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: ElevatedButton(
                onPressed: () {
                  // Check and request contacts permission
                  _requestContactsPermission(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(30, 50), // Adjust the size as needed
                ),
                child: Icon(Icons.add),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(350, 30), // Adjust the size as needed
              ),
              child: const Text('Back!'),
            ),
          ),
        ],
      ),
    );
  }

  void _requestContactsPermission(BuildContext context) async {
    PermissionStatus status = await Permission.contacts.request();

    if (status == PermissionStatus.granted) {
      // Permission granted, open contact picker
      _openContactPicker(context);
    } else {
      // Permission denied, handle accordingly (e.g., show a message)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contacts permission denied.'),
        ),
      );
    }
  }

  void _openContactPicker(BuildContext context) async {
    Iterable<Contact> contacts = await ContactsService.getContacts();

    // Do something with the selected contacts (e.g., save them to a list)
    for (var contact in contacts) {
      // Handle each contact as needed
      print('Selected contact: ${contact.displayName}');
    }
  }
}
