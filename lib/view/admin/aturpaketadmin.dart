import 'package:bbs_booking_system/controller/paketController.dart';
import 'package:bbs_booking_system/model/paketModel.dart';
import 'package:bbs_booking_system/view/admin/fileinputwidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AturPaketAdmin extends StatefulWidget {
  @override
  _AturPaketAdminState createState() => _AturPaketAdminState();
}

class _AturPaketAdminState extends State<AturPaketAdmin> {
  // List<Map<String, dynamic>> packages = [
  //   {
  //     'image': 'https://via.placeholder.com/150',
  //     'namaPaket': 'Paket BL #1',
  //     'durasiPaket': '3',
  //     'detailPaket': 'Pisang Keju/Bitterballen/PotatoCheese',
  //     'hargaPaket': '90.000'
  //   },
  //   {
  //     'image': 'https://via.placeholder.com/150',
  //     'namaPaket': 'Paket BL #2',
  //     'durasiPaket': '5',
  //     'detailPaket': 'Pisang Keju/Bitterballen/PotatoCheese',
  //     'hargaPaket': '200.000'
  //   },
  // ];

  void showPackageDialog(Paket package, String docID) {
    double screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text('${package.namaPaket} - ${package.durasiPaket} Jam'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  package.urlImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network('https://via.placeholder.com/150');
                  },
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(package.rincianPaket),
                SizedBox(height: screenWidth * 0.01),
                Text('Harga: ${package.hargaPaket}'),
              ],
            ),
            actions: [
              TextButton(
                // logic edit here
                onPressed: () {
                  Navigator.of(context).pop();
                  showEditPackageForm(package, docID);
                },
                child: Text('Edit'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    PaketController paketController = PaketController();
                    paketController.deletePaket(docID);
                  });
                  Navigator.of(context).pop();
                },
                child: Text('Hapus'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Tutup'),
              ),
            ],
          ),
        );
      },
    );
  }

  void showAddPackageForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PackageForm(
          package: Paket(
            namaPaket: '',
            rincianPaket: '',
            hargaPaket: 0,
            urlImage: '',
            durasiPaket: 0,
            createdAt: Timestamp.now(),
          ),
          id: '',
          onSubmit: (paket) {
            setState(() {
              PaketController paketController = PaketController();
              paketController.addPaket(paket);
            });
          },
        );
      },
    );
  }

  void showEditPackageForm(Paket package, String docID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PackageForm(
          id: docID,
          package: package,
          onSubmit: (updatedPackage) {
            setState(() {
              PaketController paketController = PaketController();
              paketController.updatePaket(docID, updatedPackage);
            });
          },
        );
      },
    );
  }

  Widget buildPaket(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    PaketController _paketController = PaketController();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _paketController.getPaketsWithDocID(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Tidak ada paket yang tersedia.'));
        }

        List<Map<String, dynamic>> paketsWithDocID = snapshot.data!;

        return ListView.builder(
          itemCount: paketsWithDocID.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> packageData = paketsWithDocID[index];
            Paket package = packageData['data'];
            String docID = packageData['docID'];

            return ListTile(
              onTap: () {
                showPackageDialog(package, docID);
              },
              contentPadding: EdgeInsets.all(screenWidth * 0.02),
              leading: Container(
                width: screenWidth * 0.1,
                height: screenWidth * 0.1,
                child: Image.network(
                  package.urlImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network('https://via.placeholder.com/150');
                  },
                ),
              ),
              title: Text('${package.namaPaket} - ${package.durasiPaket} Jam'),
              subtitle: Text(package.rincianPaket),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Rp ${package.hargaPaket}'),
                  Icon(Icons.arrow_forward_ios),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Atur Paket",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: buildPaket(context),
      // SingleChildScrollView(
      //   child: ListView.builder(
      //     shrinkWrap: true,
      //     physics: NeverScrollableScrollPhysics(),
      //     itemCount: packages.length,
      //     itemBuilder: (context, index) {
      //       final package = packages[index];
      //       return ListTile(
      //         onTap: () {
      //           showPackageDialog(package);
      //         },
      //         contentPadding: EdgeInsets.all(screenWidth * 0.02),
      //         leading: Container(
      //           width: screenWidth * 0.1,
      //           height: screenWidth * 0.1,
      //           child: Image.network(package['image']),
      //         ),
      //         title: Text(
      //             '${package['namaPaket']} - ${package['durasiPaket']} Jam'),
      //         subtitle: Text(package['detailPaket']),
      //         trailing: Row(
      //           mainAxisSize: MainAxisSize.min,
      //           children: [
      //             Text(package['hargaPaket']),
      //             Icon(Icons.arrow_forward_ios),
      //           ],
      //         ),
      //       );
      //     },
      //   ),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddPackageForm,
        child: Icon(Icons.add),
      ),
    );
  }
}

class PackageForm extends StatefulWidget {
  final Paket package;
  final String id;
  final Function(Paket) onSubmit;

  PackageForm(
      {required this.package, required this.id, required this.onSubmit});

  @override
  _PackageFormState createState() => _PackageFormState();
}

class _PackageFormState extends State<PackageForm> {
  late TextEditingController _namaPaketController;
  late TextEditingController _durasiPaketController;
  late TextEditingController _detailPaketController;
  late TextEditingController _hargaPaketController;
  TextEditingController _imageUrlController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    _namaPaketController =
        TextEditingController(text: widget.package.namaPaket);
    _durasiPaketController =
        TextEditingController(text: widget.package.durasiPaket.toString());
    _detailPaketController =
        TextEditingController(text: widget.package.rincianPaket);
    _hargaPaketController =
        TextEditingController(text: widget.package.hargaPaket.toString());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.id == '' ? 'Tambah Paket' : 'Edit Paket'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _namaPaketController,
              decoration: InputDecoration(labelText: 'Nama Paket'),
            ),
            TextField(
              controller: _durasiPaketController,
              decoration: InputDecoration(labelText: 'Durasi Paket'),
              keyboardType: TextInputType.number, // Set keyboard type to number
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly, // Allow only digits
              ],
            ),
            TextField(
              controller: _detailPaketController,
              decoration: InputDecoration(labelText: 'Rincian Paket'),
            ),
            TextField(
              controller: _hargaPaketController,
              decoration: InputDecoration(labelText: 'Harga Paket'),
              keyboardType: TextInputType.number, // Set keyboard type to number
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly, // Allow only digits
              ],
            ),
            FileInputWidget(
              fileType: 'Image',
              onSaveToDatabase: (img) {
                _imageUrlController.text = img!;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_namaPaketController.text == "" ||
                int.parse(_durasiPaketController.text) == 0 ||
                _detailPaketController.text == "" ||
                int.parse(_hargaPaketController.text) == 0 ||
                _imageUrlController.text == "") {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        SizedBox(width: 10),
                        Text(
                          'Lengkapi Form Booking!',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    content: Text(
                      'Mohon lengkapi form booking!',
                    ),
                    backgroundColor: Color.fromARGB(255, 255, 255, 255),
                    actions: <Widget>[
                      TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              Paket paket = Paket(
                namaPaket: _namaPaketController.text,
                durasiPaket: int.parse(_durasiPaketController.text),
                rincianPaket: _detailPaketController.text,
                hargaPaket: int.parse(_hargaPaketController.text),
                urlImage: _imageUrlController.text,
                createdAt: Timestamp.now(),
              );
              widget.onSubmit(paket);
              Navigator.of(context).pop();
            }
          },
          child: Text('Simpan'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Batal'),
        ),
      ],
    );
  }
}
